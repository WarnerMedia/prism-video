// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package sqs

import (
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/aws/aws-sdk-go/service/sqs/sqsiface"
	"github.com/cenkalti/backoff"
)

type SQS struct {
	sqs      sqsiface.SQSAPI // safe to use concurrently
	queueUrl *string
}

// New initializes a new SQS client instance.
func New(url string) *SQS {
	s := session.Must(session.NewSession())
	return &SQS{
		sqs:      sqs.New(s),
		queueUrl: aws.String(url),
	}
}

// SendMessage publishes a new message to the SQS queue,
// retrying with exponential backoff if errors are encountered.
func (c *SQS) SendMessage(message string) error {
	input := sqs.SendMessageInput{
		MessageBody: aws.String(message),
		QueueUrl:    c.queueUrl,
	}
	f := func() error {
		_, err := c.sqs.SendMessage(&input)
		return err
	}
	// Retry for a maximum of 4 minutes
	b := backoff.NewExponentialBackOff()
	b.MaxElapsedTime = 4 * time.Minute
	return backoff.Retry(f, b)
}

// ReceiveMessage reads up to 10 message from the SQS queue using Long Polling,
func (c *SQS) ReceiveMessages(maxNumberOfMessages int, waitTimeSeconds int) ([]*sqs.Message, error) {
	input := sqs.ReceiveMessageInput{
		QueueUrl:            c.queueUrl,
		MaxNumberOfMessages: aws.Int64(int64(maxNumberOfMessages)),
		WaitTimeSeconds:     aws.Int64(int64(waitTimeSeconds)),
	}

	result, err := c.sqs.ReceiveMessage(&input)
	if err != nil {
		return nil, err
	}

	return result.Messages, nil
}

// DeleteMessage removes the message from SQS
func (c *SQS) DeleteMessages(receiptHandle string) error {
	input := sqs.DeleteMessageInput{
		QueueUrl:      c.queueUrl,
		ReceiptHandle: aws.String(receiptHandle),
	}

	_, err := c.sqs.DeleteMessage(&input)
	if err != nil {
		return err
	}

	return nil
}
