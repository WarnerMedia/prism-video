// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.package main
import (
	"os"
)

func getLoggingLevel() string {
	return os.Getenv("LOG_LEVEL")
}

func getSQSEndpoint() string {
	return os.Getenv("SQS_ENDPOINT")
}

func getSQSJobEndpoint() string {
	return os.Getenv("SQS_JOB_ENDPOINT")
}

func getS3Bucket() string {
	return os.Getenv("S3_BUCKET")
}

func getMetricPrefix() string {
	return os.Getenv("METRIC_PREFIX")
}

