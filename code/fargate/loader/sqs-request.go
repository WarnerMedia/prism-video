// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

// sqs message struct

type SQSMsg struct {

	//required
	S3Bucket  string `json:"s3bucket"`
	S3Object  string `json:"s3object"`
	DateAdded int64  `json:"dateadded"`
}
