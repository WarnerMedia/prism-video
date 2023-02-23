// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"doppler-video-telemetry/code/pkg/sqs"
	"encoding/json"
	"strconv"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	statsd "github.com/etsy/statsd/examples/go"
)

func convertAndBuffer(datePart int) string {

	if datePart < 10 {
		return "0" + strconv.Itoa(datePart)
	}
	return strconv.Itoa(datePart)
}

var statsdClient *statsd.StatsdClient

var metricsPrefix string

type Job struct {
	StartYear  string `json:"start_year"`
	StartMonth string `json:"start_month"`
	StartDay   string `json:"start_day"`
	StartHour  string `json:"start_hour"`
	EndYear    string `json:"end_year"`
	EndMonth   string `json:"end_month"`
	EndDay     string `json:"end_day"`
	EndHour    string `json:"end_hour"`
}

func getYearStart(job Job) int {
	if job.StartYear == "" {
		return -1
	}

	res, err := strconv.Atoi(job.StartYear)
	if err != nil {
		return -1
	}

	return res
}

func getYearEnd(job Job) int {
	if job.EndYear == "" {
		return -1
	}

	res, err := strconv.Atoi(job.EndYear)
	if err != nil {
		return -1
	}

	return res
}

func getMonthStart(job Job) int {
	if job.StartMonth == "" {
		return -1
	}

	res, err := strconv.Atoi(job.StartMonth)
	if err != nil {
		return -1
	}

	return res
}

func getMonthEnd(job Job) int {
	if job.EndMonth == "" {
		return -1
	}

	res, err := strconv.Atoi(job.EndMonth)
	if err != nil {
		return -1
	}

	return res
}

func getDayStart(job Job) int {
	if job.StartDay == "" {
		return -1
	}

	res, err := strconv.Atoi(job.StartDay)
	if err != nil {
		return -1
	}

	return res
}

func getDayEnd(job Job) int {
	if job.EndDay == "" {
		return -1
	}

	res, err := strconv.Atoi(job.EndDay)
	if err != nil {
		return -1
	}

	return res
}

func getHourStart(job Job) int {
	if job.StartHour == "" {
		return -1
	}

	res, err := strconv.Atoi(job.StartHour)
	if err != nil {
		return -1
	}

	return res
}

func getHourEnd(job Job) int {
	if job.EndHour == "" {
		return -1
	}

	res, err := strconv.Atoi(job.EndHour)
	if err != nil {
		return -1
	}

	return res
}

func startProcess() {
	debugLog("SQS Job Endpoint", getSQSJobEndpoint())
	debugLog("SQS Endpoint", getSQSEndpoint())
	debugLog("S3 Bucket", getS3Bucket())

	sess, err := session.NewSession()
	if err != nil {
		errorLog("creating aws session", err)
	}

	for {
		sqsReceiver := sqs.New(getSQSJobEndpoint())

		msgs, err := sqsReceiver.ReceiveMessages(1, 10)
		if err != nil {
			errorLog("In receive message", err)
		}

		// if we don't get an error then we have a message so lets process.
		if len(msgs) > 0 {

			// cast the body to the struct with the year, month, day, hour start / end stuff
			job := Job{}
			err := json.Unmarshal([]byte(*msgs[0].Body), &job)
			if err != nil {
				errorLog("In Unmarshall", err)
			}

			// statsdClient
			statsdClient = statsd.New("localhost", 8125)

			// prefix for all the statsd metrics
			metricsPrefix = getMetricPrefix()

			// Create S3 service client
			svc := s3.New(sess)

			// Build the start date range and end range of the data we want to copy over leveaging the go time stuff
			start := time.Date(getYearStart(job), time.Month(getMonthStart(job)), getDayStart(job), getHourStart(job), 0, 0, 0, time.UTC)
			end := time.Date(getYearEnd(job), time.Month(getMonthEnd(job)), getDayEnd(job), getHourEnd(job), 0, 0, 0, time.UTC)

			debugLog("Start DateTime", start)
			debugLog("End DateTime", end)

			if end.Before(start) {
				errorLog("End time is before start time")
			}

			bucket := getS3Bucket()

			//create the SQS producer
			sqsProducer := sqs.New(getSQSEndpoint())

			// As long as the start date doesn't equal the end date, we'll add an hour and iterate through our files
			for !start.Equal(end) {
				prefixStart := "main/year=" + convertAndBuffer(start.Year()) + "/month=" + convertAndBuffer(int(start.Month())) + "/day=" + convertAndBuffer(start.Day()) + "/hour=" + convertAndBuffer(start.Hour())

				// Get the list of items
				resp, err := svc.ListObjectsV2(&s3.ListObjectsV2Input{Bucket: aws.String(bucket), Prefix: aws.String(prefixStart)})
				if err != nil {
					warnLog("Unable to list items in bucket", err)
				}

				for _, item := range resp.Contents {
					statsdClient.Increment(metricsPrefix + "-ObjectsPushedToS3")

					var sqsMsg SQSMsg

					sqsMsg.S3Bucket = bucket
					sqsMsg.S3Object = *item.Key
					sqsMsg.DateAdded = time.Now().Unix()

					sqsMsgByte, err := json.Marshal(sqsMsg)
					if err != nil {
						warnLog("Unable to Marshall JSON: ", err)
						continue
					}

					err = sqsProducer.SendMessage(string(sqsMsgByte))
					if err != nil {
						warnLog("Unable to send to SQS: ", err)
					}
				}
				start = start.Add(time.Hour)
			}
			err = sqsReceiver.DeleteMessages(*msgs[0].ReceiptHandle)
			if err != nil {
				warnLog("In delete message", err)
			}
		}
	}
}
