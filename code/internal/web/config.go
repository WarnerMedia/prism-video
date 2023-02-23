// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package web

import (
	"os"
	"strconv"
)

func getRegion() string {
	region := os.Getenv("AWS_REGION")
	if region == "" {
		panic("AWS_REGION is not set")
	}
	return region
}

func getEnvironment() string {
	environ := os.Getenv("ENVIRONMENT")
	if environ == "" {
		panic("ENVIRONMENT is not set")
	}
	return environ
}

func getPayloadLimit() int64 {
	payloadLimit := os.Getenv("PAYLOAD_LIMIT")
	if payloadLimit == "" {
		return 100000
	}

	intPayloadLimit, err := strconv.Atoi(payloadLimit)
	if err != nil {
		return 100000
	}
	return int64(intPayloadLimit)
}

func displayPayloadOnError() bool {
	payloadLimit := os.Getenv("PAYLOAD_DISPLAY_ON_ERROR")
	if payloadLimit == "" {
		return false
	}

	if payloadLimit == "false" {
		return false
	}

	if payloadLimit == "true" {
		return true
	}

	return false
}
