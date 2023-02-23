// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/aws/aws-lambda-go/events"
)

func Test_LambdaHandler(t *testing.T) {
	rawJSON := `{}` // Raw S3 Event Records

	var inputEvent events.S3Event
	if err := json.Unmarshal([]byte(rawJSON), &inputEvent); err != nil {
		t.Errorf("could not unmarshal event. details: %v", err)
	}

	err := lambdaHandler(context.Background(), inputEvent)
	if err != nil {
		t.Errorf("lambdaHandler failed. details: %v", err)
	}
}
