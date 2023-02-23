// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"os"
	"strconv"
)

func getLoggingLevel() string {
	return os.Getenv("LOG_LEVEL")
}

func getSQSEndpoint() string {
	return os.Getenv("SQS_ENDPOINT")
}

func getS3Bucket() string {
	return os.Getenv("S3_BUCKET")
}

func getMetricPrefix() string {
	return os.Getenv("METRIC_PREFIX")
}

// defaulting to 10
func getMaxSQSMessages() int {
	maxSQSMessages, err := strconv.Atoi(os.Getenv("MAX_SQS_MESSAGES"))
	if err != nil {
		return 10
	}
	return maxSQSMessages
}

// defaulting to 20
func getLongPollTimeout() int {
	longPollTimeout, err := strconv.Atoi(os.Getenv("LONG_POLL_TIMEOUT"))
	if err != nil {
		return 20
	}
	return longPollTimeout
}

func getDLQ() string {
	return os.Getenv("DLQ_URL")
}

func getHost() string {
	//allow for local testing in docker
	if host := os.Getenv("HOST"); host != "" {
		return host
	}
	return "127.0.0.1"
}

func getSocketServerPort() string {
	return os.Getenv("SOCKET_SERVER_PORT")
}

func getErrHost() string {
	if host := os.Getenv("ERROR_SOCKET_HOST"); host != "" {
		return host
	}
	return "127.0.0.1"
}

func getErrPort() string {
	if host := os.Getenv("ERROR_SOCKET_PORT"); host != "" {
		return host
	}
	return "3001"
}

func getDelayBy() int {
	delayBy, err := strconv.Atoi(os.Getenv("DELAY_BY"))
	if err != nil {
		return 0
	}

	return delayBy
}

func getRecordType() string {
	if recordType := os.Getenv("RECORD_TYPE"); recordType != "" {
		return recordType
	}
	return "RAW"
}

func convertToNewSchema() string {
	if convertToNewSchema := os.Getenv("CONVERT_TO_NEW_SCHEMA"); convertToNewSchema != "" {
		return convertToNewSchema
	}
	return "false"
}
