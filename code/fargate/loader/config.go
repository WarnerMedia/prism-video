// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"os"
	"strconv"
)

func getTestWithoutKPL() bool {
	if testWithoutKPL := os.Getenv("TEST_WITHOUT_KPL"); testWithoutKPL != "" {
		if testWithoutKPL == "true" {
			return true
		}
	}

	return false
}

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

func getHostDMT() string {
	//allow for local testing in docker
	if host := os.Getenv("HOST_DMT"); host != "" {
		return host
	}
	return "127.0.0.1"
}

func getErrHostDMT() string {
	if host := os.Getenv("ERROR_SOCKET_HOST_DMT"); host != "" {
		return host
	}
	return "127.0.0.1"
}

func getSocketServerPortDMT() string {
	return os.Getenv("SOCKET_SERVER_PORT_DMT")
}

func getErrPortDMT() string {
	return os.Getenv("ERROR_SOCKET_PORT_DMT")
}

func getHostSLPD() string {
	//allow for local testing in docker
	if host := os.Getenv("HOST_SLPD"); host != "" {
		return host
	}
	return "127.0.0.1"
}

func getErrHostSLPD() string {
	if host := os.Getenv("ERROR_SOCKET_HOST_SLPD"); host != "" {
		return host
	}
	return "127.0.0.1"
}

func getSocketServerPortSLPD() string {
	return os.Getenv("SOCKET_SERVER_PORT_SLPD")
}

func getErrPortSLPD() string {
	return os.Getenv("ERROR_SOCKET_PORT_SLPD")
}
