// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"bytes"
	"doppler-video-telemetry/code/pkg/sqs"
	"encoding/json"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/Jeffail/gabs/v2"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	sqsl "github.com/aws/aws-sdk-go/service/sqs"
	statsd "github.com/etsy/statsd/examples/go"
	kpl "github.com/turnerlabs/kplclientgo"
)

var statsdClient *statsd.StatsdClient
var metricsPrefix string
var kplClientDMT *kpl.KPLClient
var kplClientSLPD *kpl.KPLClient
var kinesisDownTSDMT time.Time
var kinesisDownTSSLPD time.Time
var recordType string

func startProcess() {
	// aws session
	sess, err := session.NewSession()
	if err != nil {
		logError("creating aws session", err)
	}

	// to allow testing locally as well as turning off in dev and qa
	testWithoutKPL := getTestWithoutKPL()
	debugLog("Not writing to KPL: " + strconv.FormatBool(getTestWithoutKPL()))

	// sqs endpoint
	sqsSvc := sqs.New(getSQSEndpoint())
	debugLog("Getting SQS messages from: " + getSQSEndpoint())

	sqsMaxMessages := getMaxSQSMessages()
	debugLog("SQS max messages: " + strconv.Itoa(getMaxSQSMessages()))

	timeout := getLongPollTimeout()
	debugLog("SQS long poll timeout: " + strconv.Itoa(getLongPollTimeout()))

	// statsd client(via cloudwatch metrics sidecar)
	statsdClient = statsd.New("localhost", 8125)

	// statsd metrics prefix
	metricsPrefix = getMetricPrefix()

	// KPL dead letter queue
	dlq := sqs.New(getDLQ())
	debugLog("Writing to dead letter queue: " + getDLQ())

	// S3 client
	svc := s3.New(sess)

	if !testWithoutKPL {
		// KPL client for Data Mart
		kplClientDMT = kpl.NewKPLClient(getHostDMT(), getSocketServerPortDMT())
		debugLog("Writing to KPL Data Mart: " + getHostDMT())

		kplClientDMT.ErrHost = getErrHostDMT()
		kplClientDMT.ErrPort = getErrPortDMT()
		kplClientDMT.ErrHandler = func(data string) {
			kinesisDownTSDMT = time.Now()
			err := dlq.SendMessage(data)
			if err != nil {
				logError("Error while sending to KPL Error SQS from Data Mart KPL", err)
			}
		}

		// KPL client for Slow Prod
		kplClientSLPD = kpl.NewKPLClient(getHostSLPD(), getSocketServerPortSLPD())
		debugLog("Writing to KPL Slow Prod: " + getHostSLPD())

		kplClientSLPD.ErrHost = getErrHostSLPD()
		kplClientSLPD.ErrPort = getErrPortSLPD()
		kplClientSLPD.ErrHandler = func(data string) {
			kinesisDownTSSLPD = time.Now()
			err := dlq.SendMessage(data)
			if err != nil {
				logError("Error while sending to KPL Error SQS from Slow Prod KPL", err)
			}
		}
	}

	// delay to allow KPL clients to connect on startup(we need to test to see if we can remove this)
	time.Sleep(5 * time.Second)

	if !testWithoutKPL {
		// KPL client startup
		infoLog("Starting Data Mart KPL client: %v:%v", kplClientDMT.Host, kplClientDMT.Port)
		err = kplClientDMT.Start()
		if err != nil {
			logError("Error starting Data Mart KPL client", err)
			panic(err)
		}

		infoLog("Starting Slow Prod KPL client: %v:%v", kplClientSLPD.Host, kplClientSLPD.Port)
		err = kplClientSLPD.Start()
		if err != nil {
			logError("Error starting Slow Prod KPL client", err)
			panic(err)
		}
	}

	// Long Poll on a channel
	sqsMessages := make(chan *sqsl.Message, sqsMaxMessages)
	go pollSqs(sqsMaxMessages, timeout, sqsSvc, sqsMessages)

	// SQS Messages returned on the channel
	for sqsMessage := range sqsMessages {
		// Marshall the SQS Body into an S3 Event
		s3Event := &events.S3Event{}
		err = json.Unmarshal([]byte(*sqsMessage.Body), s3Event)
		if err != nil {
			warnLog("Failed to Unmarshal SQS message to an S3 event", err)
			warnLog("SQS Message: ", *sqsMessage.Body)
			continue
		}

		// verify we have at least 1 record or continue
		if len(s3Event.Records) == 0 {
			warnLog("S3 Event has no records")
			continue
		}

		// Loop thru the S3 Records
		for _, s3Record := range s3Event.Records {
			s3Rec := s3Record.S3
			decodedObjectPath, _ := url.QueryUnescape(s3Rec.Object.Key)

			debugLog("Bucket Name", s3Rec.Bucket.Name, "Object Name", decodedObjectPath)

			// Read S3 object from S3 bucket
			s3Object, err := svc.GetObject(&s3.GetObjectInput{
				Bucket: aws.String(s3Rec.Bucket.Name),
				Key:    aws.String(decodedObjectPath),
			})
			if err != nil {
				warnLog("Unable to perform GetObject on S3 bucket: ", err)
				warnLog("S3 Bucket: ", s3Rec.Bucket.Name)
				warnLog("S3 Object: ", decodedObjectPath)
				continue
			}

			// Read the S3 Object and split into a slice of strings by newline
			s3ObjectData := new(bytes.Buffer)
			s3ObjectData.ReadFrom(s3Object.Body)
			dataRows := strings.Split(s3ObjectData.String(), "\n")

			// Loop thru rows in the S3 object
			for index := range dataRows {
				statsdClient.Increment(metricsPrefix + "-RecordsPushedToKDS")

				// convert the string to a JSON object that we can send on to KDS
				if dataRows[index] != "" && len(dataRows[index]) > 0 {
					jsonDec := json.NewDecoder(bytes.NewReader([]byte(dataRows[index])))
					jsonDec.UseNumber()
					jsonParsed, err := gabs.ParseJSONDecoder(jsonDec)
					if err != nil {
						warnLog("Error in ParseJSONDecoder", err)
						warnLog("Error on ", dataRows[index])
						continue
					}

					// Write each row to KDS via KPL client
					if !testWithoutKPL {
						// to Data Mart
						err = kplClientDMT.PutRecord(jsonParsed.String())
						if err != nil {
							warnLog("kplClient.PutRecord data mart error %v", err)
						}

						// to Slow Prod
						err = kplClientSLPD.PutRecord(jsonParsed.String())
						if err != nil {
							warnLog("kplClient.PutRecord slow prod error %v", err)
						}
					}
				}
			}
		}

		// Delete SQS Message
		sqsSvc.DeleteMessages(*sqsMessage.ReceiptHandle)
	}
}

// This implements the logic that does the long polling / pushing of messages into the channel
func pollSqs(sqsMaxMessages int, timeout int, sqsSvc *sqs.SQS, chn chan<- *sqsl.Message) {
	for {
		output, err := sqsSvc.ReceiveMessages(sqsMaxMessages, timeout)
		if err != nil {
			warnLog("Unable to ReceiveMessages on SQS: ", err)
		}

		for _, message := range output {
			chn <- message
		}
	}
}
