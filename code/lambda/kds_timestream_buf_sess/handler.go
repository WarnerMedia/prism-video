// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"context"
	"strconv"
	"strings"
	"time"

	"github.com/Jeffail/gabs/v2"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/cloudwatch"
	"github.com/aws/aws-sdk-go/service/kinesis"
	"github.com/aws/aws-sdk-go/service/timestreamwrite"
	deagg "github.com/awslabs/kinesis-aggregation/go/deaggregator"
	"github.com/google/uuid"
)

var traceID uuid.UUID
var t1 time.Time

// test
// The record batch count is set in terraform but you could get less than the batch count so you write out whatever you get.
// *** Note that with de-aggregation you could have 100 records compressed into 1 record so the record batch count really doesn't matter as much ***
// If an error is returned, the whole batch is retried.
// Don't fail if an error occurs while writing out metrics.
func lambdaHandler(ctx context.Context, kinesisEvent events.KinesisEvent) error {
	// log the request.start
	traceID = uuid.New()
	t1 = time.Now()

	debugLog(traceID, time.Since(t1), "evt", "start")

	// Creates De-Aggregation records
	krs, ctrDeAggs := createDeAggregatedRecords(kinesisEvent)

	debugLog(traceID, time.Since(t1), "DeAggsCount", ctrDeAggs)

	// This code deals with the issue of Flink(and I guess other KDS producing apps) that can compress multiple records into a single KDS record.
	// WE COULD FAIL HERE AND DO A RETRY
	dars, err := deagg.DeaggregateRecords(krs)
	if err != nil {
		errorLog(traceID, time.Since(t1), "Error performing DeAggregateRecords:", err, "evt", "end")

		errMet := logMetricsToCloudwatch("buf-sess-error-count", 1)
		if errMet != nil {
			errorLog(traceID, time.Since(t1), "Error performing CloudWatch putMetricData(BUF_ERROR_COUNT):", errMet, "evt", "end")
		}
		return err
	}

	// Create batches of 100 records from De-Aggregated for writes to Timestream
	ctrRecords, err := createTimestreamWritableBatches(dars, traceID, t1)
	// WE COULD FAIL HERE AND DO A RETRY
	if err != nil {
		errMet := logMetricsToCloudwatch("buf-sess-error-count", 1)
		if errMet != nil {
			errorLog(traceID, time.Since(t1), "Error performing CloudWatch putMetricData(BUF_ERROR_COUNT):", errMet, "evt", "end")
		}
		return err
	}

	debugLog(traceID, time.Since(t1), "RecordCount", ctrRecords)

	// write record count to cw so we have an idea of how many records we are writing out
	errMet := logMetricsToCloudwatch("buf-sess-record-count", ctrRecords)
	if errMet != nil {
		errorLog(traceID, time.Since(t1), "Error performing CloudWatch putMetricData(BUF_RECORD_COUNT):", errMet, "evt", "end")
	}

	// log the request.end
	debugLog(traceID, time.Since(t1), "duration", time.Since(t1), "evt", "end")

	errMetTime := logTimeMetricsToCloudwatch("buf-sess-process-time", int(time.Since(t1).Milliseconds()))
	if errMetTime != nil {
		errorLog(traceID, time.Since(t1), "Error performing CloudWatch putMetricData(BUF_PROCESS_TIME):", errMet, "evt", "end")
	}

	return nil
}

// Loop thru all the records received in the batch, creating a Kinesis Record for the De-Aggregation function.
func createDeAggregatedRecords(kRecs events.KinesisEvent) ([]*kinesis.Record, int) {
	krs := make([]*kinesis.Record, 0, len(kRecs.Records))
	ctrDeAggs := 0
	for _, record := range kRecs.Records {
		krs = append(krs, &kinesis.Record{
			ApproximateArrivalTimestamp: aws.Time(record.Kinesis.ApproximateArrivalTimestamp.UTC()),
			Data:                        record.Kinesis.Data,
			EncryptionType:              &record.Kinesis.EncryptionType,
			PartitionKey:                &record.Kinesis.PartitionKey,
			SequenceNumber:              &record.Kinesis.SequenceNumber,
		})
		ctrDeAggs = ctrDeAggs + 1
	}

	return krs, ctrDeAggs
}

// Loop thru each deaggregated record and build up a timestream record in batches of 100 and write them
func createTimestreamWritableBatches(dars []*kinesis.Record, traceID uuid.UUID, t1 time.Time) (int, error) {
	ctrRecords := len(dars)
	ctrBatch := 0
	var timeLags []time.Duration = nil
	var tsRecs []*timestreamwrite.Record = nil
	for i := 0; i < len(dars); i += 1 {
		jsonPayload, errParseJSON := gabs.ParseJSON(dars[i].Data)
		if errParseJSON != nil {
			errorLog(traceID, time.Since(t1), "Error performing Gabs ParseJSON:", errParseJSON, "Data", string(dars[i].Data), "Partition Key", string(*dars[i].PartitionKey), "evt", "end")
			return 0, errParseJSON
		}
		ctrBatch = ctrBatch + 1

		tsRec := buildTimestreamRecord(jsonPayload)
		tsRecs = append(tsRecs, tsRec)

		// add the difference between now annd the passed in approx arrival time to determine lag
		timeLags = append(timeLags, t1.UTC().Sub(*dars[i].ApproximateArrivalTimestamp))

		if ctrBatch == 100 || i == (ctrRecords-1) {
			if svcTSW != nil {
				errWriteRecordsToTimestream := writeRecordsToTimestream(tsRecs)
				if errWriteRecordsToTimestream != nil {
					errorLog(traceID, time.Since(t1), "Error performing Timestream WriteRecords:", errWriteRecordsToTimestream, "evt", "end")
					return ctrRecords, errWriteRecordsToTimestream
				}
				longestDuration := getLongestDuration(timeLags)
				errMet := logTimeMetricsToCloudwatch("buf-sess-lag", int(longestDuration))
				if errMet != nil {
					errorLog(traceID, time.Since(t1), "Error performing CloudWatch putMetricData(BUF_LAG):", errMet, "evt", "end")
				}
			}

			ctrBatch = 0
			tsRecs = nil
		}
	}
	return ctrRecords, nil
}

func getLongestDuration(timeLags []time.Duration) int64 {
	var longestDuration time.Duration
	for _, lag := range timeLags {
		if lag > longestDuration {
			longestDuration = lag
		}
	}
	return longestDuration.Milliseconds()
}

func buildTimestreamDimension(name string, value *gabs.Container) *timestreamwrite.Dimension {
	var validatedValue string

	if value == nil || len(value.String()) == 2 || value.String() == "\"null\"" || value.String() == "\"nil\"" {
		validatedValue = "psm.unk"
	} else {
		unquotedValue, errUnquote := strconv.Unquote(value.String())
		if errUnquote != nil {
			errorLog(traceID, time.Since(t1), "Error performing strconv.Unquote in buildTimestreamDimension:", errUnquote, "evt", "end")
			errMet := logMetricsToCloudwatch("buf-sess-error-count", 1)
			if errMet != nil {
				errorLog(traceID, time.Since(t1), "Error performing CloudWatch putMetricData(BUF_ERROR_COUNT):", errMet, "evt", "end")
			}
			validatedValue = "psm.unk"
		}
		validatedValue = unquotedValue
	}

	tsDim := timestreamwrite.Dimension{
		Name:  aws.String(name),
		Value: aws.String(validatedValue),
	}
	return &tsDim
}

func buildTimestreamDimensionNumber(name string, value *gabs.Container) *timestreamwrite.Dimension {
	tsDimension := timestreamwrite.Dimension{
		Name:  aws.String(name),
		Value: aws.String(value.String()),
	}
	return &tsDimension
}

func buildTimestreamMeasureValue(name string, value *gabs.Container, measureValueType string) *timestreamwrite.MeasureValue {
	tsMeasureValue := timestreamwrite.MeasureValue{
		Name:  aws.String(name),
		Value: aws.String(value.String()),
		Type:  aws.String(measureValueType),
	}
	return &tsMeasureValue

}

func buildNumberField(value *gabs.Container) *string {
	return aws.String(value.String())
}

func buildUnquotedField(value *gabs.Container, upcase bool) *string {
	var validatedValue string
	unquotedValue, errUnquote := strconv.Unquote(value.String())
	if errUnquote != nil {
		errorLog(traceID, time.Since(t1), "Error performing strconv.Unquote in buildUnquotedField:", errUnquote, "evt", "end")
		errMet := logMetricsToCloudwatch("buf-sess-error-count", 1)
		if errMet != nil {
			errorLog(traceID, time.Since(t1), "Error performing CloudWatch putMetricData(BUF_ERROR_COUNT):", errMet, "evt", "end")
		}
		validatedValue = "psm.unk"
	}
	validatedValue = unquotedValue

	if upcase {
		validatedValue = strings.ToUpper(validatedValue)
	}

	return aws.String(validatedValue)
}

func buildTimestreamRecord(event *gabs.Container) *timestreamwrite.Record {
	var tsDims = make([]*timestreamwrite.Dimension, 0)

	tsDim := buildTimestreamDimension("sessionId", event.Path("sessionId"))
	tsDims = append(tsDims, tsDim)
	tsDim = buildTimestreamDimension("awsregion", event.Path("awsregion"))
	tsDims = append(tsDims, tsDim)

	// Flags on the session
	tsDim = buildTimestreamDimensionNumber("attemptOccurred", event.Path("attemptOccurred"))
	tsDims = append(tsDims, tsDim)
	tsDim = buildTimestreamDimensionNumber("playOccurred", event.Path("playOccurred"))
	tsDims = append(tsDims, tsDim)
	tsDim = buildTimestreamDimensionNumber("sessionEnded", event.Path("sessionEnded"))
	tsDims = append(tsDims, tsDim)

	// error info on the session
	tsDim = buildTimestreamDimension("errorSeverity", event.Path("errorSeverity"))
	tsDims = append(tsDims, tsDim)
	tsDim = buildTimestreamDimension("errorCode", event.Path("errorCode"))
	tsDims = append(tsDims, tsDim)
	tsDim = buildTimestreamDimension("errorMessage", event.Path("errorMessage"))
	tsDims = append(tsDims, tsDim)

	var tsMeasureValues = make([]*timestreamwrite.MeasureValue, 0)

	tsMeasureValue := buildTimestreamMeasureValue("attemptCount", event.Path("attemptCount"), "DOUBLE")
	tsMeasureValues = append(tsMeasureValues, tsMeasureValue)
	tsMeasureValue = buildTimestreamMeasureValue("playCount", event.Path("playCount"), "DOUBLE")
	tsMeasureValues = append(tsMeasureValues, tsMeasureValue)

	tsRec := timestreamwrite.Record{
		Dimensions:       tsDims,
		Time:             buildNumberField(event.Path("latestWindow")),
		TimeUnit:         buildUnquotedField(event.Path("timeUnit"), true),
		MeasureName:      aws.String("metrics"),
		MeasureValueType: aws.String("MULTI"),
		MeasureValues:    tsMeasureValues,
	}

	return &tsRec
}

func writeRecordsToTimestream(tsRecs []*timestreamwrite.Record) error {
	writeRecordsInput := &timestreamwrite.WriteRecordsInput{
		DatabaseName: aws.String(getDatabaseName()),
		TableName:    aws.String(getTableName()),
		Records:      tsRecs,
	}

	_, err := svcTSW.WriteRecords(writeRecordsInput)

	return err
}

func logMetricsToCloudwatch(name string, ctr int) error {
	combinedMetricName := metricPrefix + "-" + name
	_, err := svcCW.PutMetricData(&cloudwatch.PutMetricDataInput{
		Namespace: aws.String(metricNamespace),
		MetricData: []*cloudwatch.MetricDatum{
			{
				MetricName: aws.String(combinedMetricName),
				Unit:       aws.String("Count"),
				Value:      aws.Float64(float64(ctr)),
				Dimensions: []*cloudwatch.Dimension{
					{
						Name:  aws.String("metric_type"),
						Value: aws.String("counter"),
					},
				},
			},
		},
	})

	return err
}

func logTimeMetricsToCloudwatch(name string, ctr int) error {
	combinedMetricName := metricPrefix + "-" + name
	_, err := svcCW.PutMetricData(&cloudwatch.PutMetricDataInput{
		Namespace: aws.String(metricNamespace),
		MetricData: []*cloudwatch.MetricDatum{
			{
				MetricName: aws.String(combinedMetricName),
				Unit:       aws.String("Milliseconds"),
				Value:      aws.Float64(float64(ctr)),
				Dimensions: []*cloudwatch.Dimension{
					{
						Name:  aws.String("metric_type"),
						Value: aws.String("counter"),
					},
				},
			},
		},
	})

	return err
}
