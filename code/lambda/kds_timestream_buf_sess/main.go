// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudwatch"
	"github.com/aws/aws-sdk-go/service/timestreamwrite"
)

var metricPrefix string
var metricNamespace string
var timestreamRegion string
var svcTSW *timestreamwrite.TimestreamWrite
var svcCW *cloudwatch.CloudWatch

func init() {
	logger = createLogger()
	metricPrefix = getMetricPrefix()
	metricNamespace = getMetricNamespace()
	timestreamRegion = getTimestreamRegion()
	// Grab the current AWS session and create a Timestream and CloudWatch client
	sessCW := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	sessTS := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
		Config:            aws.Config{Region: aws.String(timestreamRegion)},
	}))

	svcTSW = timestreamwrite.New(sessTS)
	svcCW = cloudwatch.New(sessCW)
}

func main() {
	lambda.Start(lambdaHandler)
}
