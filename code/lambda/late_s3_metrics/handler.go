// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"bytes"
	"context"
	"net/url"
	"strings"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudwatch"
	s3Service "github.com/aws/aws-sdk-go/service/s3"
	"github.com/google/uuid"
)

func lambdaHandler(ctx context.Context, s3Event events.S3Event) error {
	traceID := uuid.New()

	t1 := time.Now()

	// log the request.start
	debugLog(traceID, time.Since(t1), "evt", "start")

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	// Create S3 service client
	svcS3 := s3Service.New(sess)

	// Create CloudWatch client
	svcCW := cloudwatch.New(sess)

	// loop thru all the s3 event records passed in
	for _, record := range s3Event.Records {
		s3 := record.S3
		decodedObjectPath, _ := url.QueryUnescape(s3.Object.Key)

		debugLog(traceID, time.Since(t1), "Event Source", record.EventSource, "Event Time", record.EventTime, "Bucket Name", s3.Bucket.Name, "Object Name", decodedObjectPath)

		// Read S3 object from S3 bucket
		s3Obj, err := svcS3.GetObject(&s3Service.GetObjectInput{
			Bucket: aws.String(s3.Bucket.Name),
			Key:    aws.String("/" + decodedObjectPath),
		})
		if err != nil {
			errorLog("S3 Bucket: ", aws.String(s3.Bucket.Name))
			errorLog("S3 Object: ", aws.String(decodedObjectPath))
			errorLog("Unable to perform S3 GetObject: ", err)
			continue
		}

		// Break out the data by rows using newline
		buf := new(bytes.Buffer)
		buf.ReadFrom(s3Obj.Body)
		m := strings.Split(buf.String(), "}{")

		// Loop thru rows in the S3 object and count the number of records in the object
		ctr := 0
		for index := range m {
			if m[index] != "" && len(m[index]) > 0 {
				ctr = ctr + 1
			}
		}

		debugLog(traceID, time.Since(t1), "counter", ctr)
		combinedMetricName := metricPrefix + "-" + "late-record-count"
		_, err = svcCW.PutMetricData(&cloudwatch.PutMetricDataInput{
			Namespace: aws.String(metricNamespace),
			MetricData: []*cloudwatch.MetricDatum{
				&cloudwatch.MetricDatum{
					MetricName: aws.String(combinedMetricName),
					Unit:       aws.String("Count"),
					Value:      aws.Float64(float64(ctr)),
					Dimensions: []*cloudwatch.Dimension{
						&cloudwatch.Dimension{
							Name:  aws.String("metric_type"),
							Value: aws.String("counter"),
						},
					},
				},
			},
		})
		if err != nil {
			errorLog("Unable to perform CloudWatch putMetricData:", err)
			debugLog(traceID, time.Since(t1), "duration", time.Since(t1), "evt", "end")
			return err
		}
	}

	// log the request.end
	debugLog(traceID, time.Since(t1), "duration", time.Since(t1), "evt", "end")

	return nil
}
