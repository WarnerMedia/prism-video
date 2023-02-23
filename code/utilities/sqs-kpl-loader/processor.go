// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"doppler-video/pkg/sqs"
	"time"

	sqsl "github.com/aws/aws-sdk-go/service/sqs"
	statsd "github.com/etsy/statsd/examples/go"
	kpl "github.com/turnerlabs/kplclientgo"
)

var statsdClient *statsd.StatsdClient
var metricsPrefix string
var kplClient *kpl.KPLClient

func startProcess() {
	//create the SQS client
	sqsSvc := sqs.New(getSQSEndpoint())

	// statsdClient
	statsdClient = statsd.New("localhost", 8125)

	// prefix for all the statsd metrics
	metricsPrefix = getMetricPrefix()

	//create a KPL client
	kplClient = kpl.NewKPLClient(getHost(), getSocketServerPort())

	// Register error handler
	dlq := sqs.New(getDLQ())
	kplClient.ErrHost = getErrHost()
	kplClient.ErrPort = getErrPort()
	kplClient.ErrHandler = func(data string) {
		err := dlq.SendMessage(data)
		if err != nil {
			logError("Error while sending to KPL Error SQS", err)
		}
	}

	time.Sleep(5 * time.Second)

	//start it up
	infoLog("starting kpl client: %v:%v", kplClient.Host, kplClient.Port)
	err := kplClient.Start()
	if err != nil {
		logError("Error starting kpl client", err)
		panic(err)
	}

	debugLog("sending messages to: " + getSQSEndpoint())

	sqsMaxMessages := getMaxSQSMessages()
	timeout := getLongPollTimeout()

	// Long Poll on a channel
	// TODO: See if there is a way to move this into the sqs package so we don't have to carry the sqs dependency here
	chnMessages := make(chan *sqsl.Message, sqsMaxMessages)
	go pollSqs(sqsMaxMessages, timeout, sqsSvc, chnMessages)

	// Loop thru SQS Messages returned on the channel
	for message := range chnMessages {

		debugLog("message to send: " + *message.Body)

		err = kplClient.PutRecord(*message.Body)
		if err != nil {
			warnLog("kplClient.PutRecord error %v", err)
		} else {
			// Write each row to KDS
			statsdClient.Increment(metricsPrefix + "-RecordsPushedToKDS")

			// Delete SQS Message
			sqsSvc.DeleteMessages(*message.ReceiptHandle)
		}
	}
}

// This implements the logic that does the long polling / pushing o messages into the channel
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
