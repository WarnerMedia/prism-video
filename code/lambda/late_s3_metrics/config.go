// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"os"
)

func getLoggingLevel() string {
	return os.Getenv("LOG_LEVEL")
}

func getAWSRegion() string {
	if os.Getenv("REGION") == "" {
		return "us-east-1"
	}

	return os.Getenv("REGION")
}

func getMetricNamespace() string {
	return os.Getenv("METRIC_NAMESPACE")
}

func getMetricPrefix() string {
	return os.Getenv("METRIC_PREFIX")
}
