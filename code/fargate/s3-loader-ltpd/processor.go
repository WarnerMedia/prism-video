// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"bytes"
	"doppler-video-telemetry/code/pkg/sqs"
	"encoding/json"
	"strconv"
	"strings"
	"time"

	"github.com/Jeffail/gabs/v2"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	sqsl "github.com/aws/aws-sdk-go/service/sqs"
	statsd "github.com/etsy/statsd/examples/go"
	kpl "github.com/turnerlabs/kplclientgo"
)

var statsdClient *statsd.StatsdClient
var metricsPrefix string
var kplClient *kpl.KPLClient
var kinesisDownTS time.Time
var recordType string

func startProcess() {
	//create the SQS client
	sess, err := session.NewSession()
	if err != nil {
		logError("creating aws session", err)
	}

	sqsSvc := sqs.New(getSQSEndpoint())

	// statsdClient
	statsdClient = statsd.New("localhost", 8125)

	// prefix for all the statsd metrics
	metricsPrefix = getMetricPrefix()

	// get the record type we are processing
	recordType = getRecordType()

	// create a KPL client
	kplClient = kpl.NewKPLClient(getHost(), getSocketServerPort())

	// Register error handler
	dlq := sqs.New(getDLQ())
	kplClient.ErrHost = getErrHost()
	kplClient.ErrPort = getErrPort()
	kplClient.ErrHandler = func(data string) {
		kinesisDownTS = time.Now()
		err := dlq.SendMessage(data)
		if err != nil {
			logError("Error while sending to KPL Error SQS", err)
		}
	}

	time.Sleep(5 * time.Second)

	//start it up
	infoLog("starting kpl client: %v:%v", kplClient.Host, kplClient.Port)
	err = kplClient.Start()
	if err != nil {
		logError("Error starting kpl client", err)
		panic(err)
	}

	debugLog("sending messages to: " + getSQSEndpoint())

	// Create S3 service client
	svc := s3.New(sess)

	sqsMaxMessages := getMaxSQSMessages()
	timeout := getLongPollTimeout()

	// Long Poll on a channel
	chnMessages := make(chan *sqsl.Message, sqsMaxMessages)
	go pollSqs(sqsMaxMessages, timeout, sqsSvc, chnMessages)

	delayByNano := getDelayBy() * 1000000000

	// Loop thru SQS Messages returned on the channel
	for message := range chnMessages {
		// Unmarshall SQS messsage into SQS object
		var sqsMsg SQSMsg
		err := json.Unmarshal([]byte(*message.Body), &sqsMsg)
		if err != nil {
			warnLog("Unable to Unmarshall JSON: ", err)
			warnLog("SQS Message: ", message)
		}

		// Read S3 object from S3 bucket
		theObj, err := svc.GetObject(&s3.GetObjectInput{
			Bucket: aws.String(sqsMsg.S3Bucket),
			Key:    aws.String(sqsMsg.S3Object),
		})
		if err != nil {
			warnLog("Unable to perform GetObject on S3 bucket: ", err)
			warnLog("S3 Bucket: ", sqsMsg.S3Bucket)
			warnLog("S3 Object: ", sqsMsg.S3Object)
		}

		// Break out the data by rows using newline
		buf := new(bytes.Buffer)
		buf.ReadFrom(theObj.Body)
		m := strings.Split(buf.String(), "\n")

		// Loop thru rows in the S3 object
		for index := range m {
			// Write each row to KDS
			statsdClient.Increment(metricsPrefix + "-RecordsPushedToKDS")

			if m[index] != "" && len(m[index]) > 0 {
				dec := json.NewDecoder(bytes.NewReader([]byte(m[index])))
				dec.UseNumber()
				jsonParsed, err := gabs.ParseJSONDecoder(dec)
				if err != nil {
					warnLog("Error in ParseJSONDecoder", err)
					warnLog("Error on ", m[index])
					continue
				}
				if recordType == "AGG" {
					newInWindow := time.Now().UnixNano() / 1000000
					newInWindowAsString := strconv.FormatInt(newInWindow, 10)
					gabsSet(newInWindowAsString, "inWindow", jsonParsed)
				} else {
					if delayByNano == 0 {
						// adjust various structure of the JSON using gabs functionality
					} else {
						// adjust various structure of the JSON using gabs functionality
					}
				}

				err = kplClient.PutRecord(jsonParsed.String())
				if err != nil {
					warnLog("kplClient.PutRecord error %v", err)
				}
			}
		}

		// Delete SQS Message
		sqsSvc.DeleteMessages(*message.ReceiptHandle)
	}
}

func gabsDelete(fullPath string, jsonParsed *gabs.Container) {
	if jsonParsed.Path(fullPath).Exists() {
		err := jsonParsed.Delete(fullPath)
		if err != nil {
			warnLog("Gabs Delete in gabsDelete %v", err, "fullPath", fullPath)
		}
	}
}

func gabsDeletePath(fullPath string, oldPath1 string, oldPath2 string, jsonParsed *gabs.Container) {
	if jsonParsed.Path(fullPath).Exists() {
		err := jsonParsed.Delete(oldPath1, oldPath2)
		if err != nil {
			warnLog("Gabs Delete in gabsDeletePath %v", err, "fullPath", fullPath)
		}
	}
}

func gabsSetDelete(fullPath string, newPath1 string, newPath2 string, oldPath1 string, oldPath2 string, jsonParsed *gabs.Container) {
	if jsonParsed.Path(fullPath).Exists() {
		_, err := jsonParsed.Set(jsonParsed.Path(fullPath).Data().(string), newPath1, newPath2)
		if err != nil {
			warnLog("Gabs Set in gabsSetDelete %v", err, "fullPath", fullPath, "newPath1", newPath1, "newPath2", newPath2)
		}
		err = jsonParsed.Delete(oldPath1, oldPath2)
		if err != nil {
			warnLog("Gabs Delete in gabsSetDelete %v", err, "oldPath1", oldPath1, "oldPath2", oldPath2)
		}
	}
}

func gabsSetExistingPath(fullPath string, newPath1 string, jsonParsed *gabs.Container) {
	if jsonParsed.Path(fullPath).Exists() {
		_, err := jsonParsed.Set(jsonParsed.Path(fullPath).Data().(string), newPath1)
		if err != nil {
			warnLog("Gabs Set in gabsSetExistingPath %v", err, "fullPath", fullPath, "newPath1", newPath1)
		}
	}
}

func gabsSetNewPath(newVal string, newPath1 string, newPath2 string, jsonParsed *gabs.Container) {
	_, err := jsonParsed.Set(newVal, newPath1, newPath2)
	if err != nil {
		warnLog("Gabs Set in gabsSetNewPath %v", err, "newVal", newVal, "newPath1", newPath1, "newPath2", newPath2)
	}
}

func gabsSet(newPath string, newVar string, jsonParsed *gabs.Container) {
	_, err := jsonParsed.Set(newPath, newVar)
	if err != nil {
		warnLog("Gabs Set in gabsSet %v", err, "newPath", newPath, "newVar", newVar)
	}
}

func gabsSetInt(newPath int64, newVar string, jsonParsed *gabs.Container) {
	_, err := jsonParsed.Set(newPath, newVar)
	if err != nil {
		warnLog("Gabs Set in gabsSetInt %v", err, "newPath", newPath, "newVar", newVar)
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
