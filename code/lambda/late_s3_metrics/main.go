// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"github.com/aws/aws-lambda-go/lambda"
)

var metricPrefix string
var metricNamespace string

func init() {
	logger = createLogger()
	metricPrefix = getMetricPrefix()
	metricNamespace = getMetricNamespace()
}

func main() {
	lambda.Start(lambdaHandler)
}
