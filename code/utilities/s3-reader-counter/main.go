// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"bytes"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

func convertAndBuffer(datePart int) string {

	if datePart < 10 {
		return "0" + strconv.Itoa(datePart)
	}
	return strconv.Itoa(datePart)
}

func main() {
	sess, err := session.NewSession()
	if err != nil {
		fmt.Println("creating aws session", err)
	}

	// Create S3 service client
	svcS3 := s3.New(sess)

	// Build the start date range and end range of the data we want to copy over leveaging the go time stuff
	start := time.Date(2022, 4, 4, 17, 0, 0, 0, time.UTC)
	end := time.Date(2022, 4, 4, 18, 0, 0, 0, time.UTC)
	//	end := time.Date(2022, 4, 4, 20, 0, 0, 0, time.UTC)

	if end.Before(start) {
		fmt.Println("End time is before start time")
	}

	bucket := "doppler-video-prd-raw-useast1"
	var ctr int
	// As long as the start date doesn't equal the end date, we'll add an hour and iterate through our files
	for !start.Equal(end) {
		prefixStart := "main/year=" + convertAndBuffer(start.Year()) + "/month=" + convertAndBuffer(int(start.Month())) + "/day=" + convertAndBuffer(start.Day()) + "/hour=" + convertAndBuffer(start.Hour())

		// Example iterating over at most 20 pages of a ListObjectsV2 operation.
		pageNum := 0
		err := svcS3.ListObjectsV2Pages(&s3.ListObjectsV2Input{Bucket: aws.String(bucket), Prefix: aws.String(prefixStart)},
			func(page *s3.ListObjectsV2Output, lastPage bool) bool {
				for _, item := range page.Contents {
					theObj, err := svcS3.GetObject(&s3.GetObjectInput{
						Bucket: aws.String(bucket),
						Key:    aws.String(*item.Key),
					})
					if err != nil {
						fmt.Println("Unable to getobject", err)
					}

					// Break out the data by rows using newline
					buf := new(bytes.Buffer)
					buf.ReadFrom(theObj.Body)
					m := strings.Split(buf.String(), "\n")

					ctr = ctr + (len(m) - 1)
				}

				pageNum++
				return pageNum <= 20
			})
		if err != nil {
			fmt.Println("Unable to list items in bucket", err)
		}
		start = start.Add(time.Hour)
	}

	fmt.Println("TOTAL---------------")
	fmt.Println(ctr)
	fmt.Println("--------------------")
}
