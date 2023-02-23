// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"crypto/md5"
	"encoding/json"
	"fmt"
	"math/rand"
	"strconv"
	"testing"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/golang/protobuf/proto"
	"github.com/google/uuid"

	deagg "github.com/awslabs/kinesis-aggregation/go/deaggregator"
	rec "github.com/awslabs/kinesis-aggregation/go/records"
	"github.com/stretchr/testify/assert"
)

// Generate an aggregate record in the correct AWS-specified format
// https://github.com/awslabs/amazon-kinesis-producer/blob/master/aggregation-format.md
func generateAggregateRecord(numRecords int) []byte {

	aggr := &rec.AggregatedRecord{}
	// Start with the magic header
	aggRecord := []byte("\xf3\x89\x9a\xc2")
	partKeyTable := make([]string, 0)

	// Create proto record with numRecords length
	for i := 0; i < numRecords; i++ {
		unixTimeMilli := time.Now().UnixNano() / 1000000
		aggJSONP1 := `{"sessionId": "12345678-d721-4fc2-9402-05ae03a96550","wmukid": "awsregion": "us-east-1","latestWindow": "`
		aggJSONP2 := `","attemptCount": 0, "playCount": 0, "attemptOccurred": false,"playOccurred": false,"sessionEnded": false,"timeUnit": "MILLISECONDS"}`
		rawJSONAgg := aggJSONP1 + strconv.FormatInt(unixTimeMilli, 10) + aggJSONP2

		var partKey uint64
		var hashKey uint64
		partKey = uint64(i)
		hashKey = uint64(i) * uint64(10)
		r := &rec.Record{
			PartitionKeyIndex:    &partKey,
			ExplicitHashKeyIndex: &hashKey,
			Data:                 []byte(rawJSONAgg),
			Tags:                 make([]*rec.Tag, 0),
		}

		aggr.Records = append(aggr.Records, r)
		partKeyVal := "test" + fmt.Sprint(i)
		partKeyTable = append(partKeyTable, partKeyVal)
	}

	aggr.PartitionKeyTable = partKeyTable
	// Marshal to protobuf record, create md5 sum from proto record
	// and append both to aggRecord with magic header
	data, _ := proto.Marshal(aggr)
	md5Hash := md5.Sum(data)
	aggRecord = append(aggRecord, data...)
	aggRecord = append(aggRecord, md5Hash[:]...)
	return aggRecord
}

func generateKinesisEvent(numRecords int) events.KinesisEvent {
	rawJSONP1 := `{
		"Records": [
			{
				"kinesis": {
					"kinesisSchemaVersion": "1.0",
					"partitionKey": "1",
					"sequenceNumber": "49590338271490256608559692538361571095921575989136588898",
					"data": `
	rawJSONP2 := `, "approximateArrivalTimestamp": 1607497475.000
				},
				"eventSource": "aws:kinesis",
				"eventVersion": "1.0",
				"eventID": "shardId-000000000006:49590338271490256608559692538361571095921575989136588898",
				"eventName": "aws:kinesis:record",
				"invokeIdentityArn": "arn:aws:iam::123456789012:role/lambda-kinesis-role",
				"awsRegion": "us-east-1",
				"eventSourceARN": "arn:aws:kinesis:us-east-1:123456789012:stream/lambda-stream"
			}
		],
		"window": {
			"start": "2020-12-09T07:04:00Z",
			"end": "2020-12-09T07:06:00Z"
		},
		"state": {
			"1": 282,
			"2": 715
		},
		"shardId": "shardId-000000000006",
		"eventSourceARN": "arn:aws:kinesis:us-east-1:123456789012:stream/lambda-stream",
		"isFinalInvokeForWindow": false,
		"isWindowTerminatedEarly": false
	}`

	test := generateAggregateRecord(numRecords)
	test1, _ := json.Marshal(test)
	rawJSON := rawJSONP1 + string(test1) + rawJSONP2

	var inputEvent events.KinesisEvent
	json.Unmarshal([]byte(rawJSON), &inputEvent)

	return inputEvent
}

func TestCreateDeAggRecords(t *testing.T) {
	min := 1
	max := 10
	n := rand.Intn(max-min) + min
	evt := generateKinesisEvent(n)

	recs, ctr := createDeAggregatedRecords(evt)

	assert.Equal(t, ctr, len(recs))
}

func TestCreateTimestreamWritableBatchesExactly1(t *testing.T) {
	ctrGenRecs := 1
	evt := generateKinesisEvent(ctrGenRecs)

	krs, _ := createDeAggregatedRecords(evt)
	traceID := uuid.New()
	t1 := time.Now()

	dars, _ := deagg.DeaggregateRecords(krs)

	ctrRecs, _ := createTimestreamWritableBatches(dars, traceID, t1)

	// validate in / out
	assert.Equal(t, ctrGenRecs, ctrRecs)
}

func TestCreateTimestreamWritableBatchesExactly100(t *testing.T) {
	ctrGenRecs := 100
	evt := generateKinesisEvent(ctrGenRecs)

	krs, _ := createDeAggregatedRecords(evt)
	traceID := uuid.New()
	t1 := time.Now()

	dars, _ := deagg.DeaggregateRecords(krs)

	ctrRecs, _ := createTimestreamWritableBatches(dars, traceID, t1)

	// validate in / out
	assert.Equal(t, ctrGenRecs, ctrRecs)
}

func TestCreateTimestreamWritableBatchesLessThan100(t *testing.T) {
	ctrGenRecs := 50
	evt := generateKinesisEvent(ctrGenRecs)

	krs, _ := createDeAggregatedRecords(evt)
	traceID := uuid.New()
	t1 := time.Now()

	dars, _ := deagg.DeaggregateRecords(krs)

	ctrRecs, _ := createTimestreamWritableBatches(dars, traceID, t1)

	// validate in / out
	assert.Equal(t, ctrGenRecs, ctrRecs)
}

func TestCreateTimestreamWritableBatchesMoreThan100(t *testing.T) {
	ctrGenRecs := 250
	evt := generateKinesisEvent(ctrGenRecs)

	krs, _ := createDeAggregatedRecords(evt)
	traceID := uuid.New()
	t1 := time.Now()

	dars, _ := deagg.DeaggregateRecords(krs)

	ctrRecs, _ := createTimestreamWritableBatches(dars, traceID, t1)

	// validate in / out
	assert.Equal(t, ctrGenRecs, ctrRecs)
}
