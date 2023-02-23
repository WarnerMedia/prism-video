resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "${var.app}-${var.common_environment}"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "height": 6,
      "width": 6,
      "y": 8,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "KinesisProducerLibrary",
            "RetriesPerRecord",
            "StreamName",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_raw}"
          ],
          [
            "...",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_sess}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KPL RetriesPerRecord",
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 8,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "WriteProvisionedThroughputExceeded",
            "StreamName",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_raw}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_sess}"
          ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "us-east-1",
        "title": "KDS WriteProvisionedThroughputExceeded",
        "period": 1,
        "stat": "Maximum"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 2,
      "x": 12,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.Latency",
            "StreamName",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_raw}"
          ],
          [
            "...",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_sess}"
          ]
        ],
        "region": "us-east-1",
        "title": "KDS PutRecords.Latency",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 2,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.SuccessfulRecords",
            "StreamName",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_raw}"
          ],
          [
            "...",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_sess}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "KDS PutRecords.SuccessfulRecords"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 2,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.FailedRecords",
            "StreamName",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_raw}"
          ],
          [
            "...",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_sess}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "KDS PutRecords.FailedRecords"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 22,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "lambda-custom-metrics",
            "${local.nsuseast1}-buf-record-count",
            "metric_type",
            "counter"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "Lambda Buffer records written to Timestream"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 15,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "DeliveryToS3.Records",
            "DeliveryStreamName",
            "${local.nsuseast1}-firehose-agg",
            {
              "color": "#2ca02c"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Firehose DeliveryToS3.Records",
        "stat": "Average",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 15,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "KinesisMillisBehindLatest",
            "DeliveryStreamName",
            "${local.nsuseast1}-firehose-agg",
            {
              "color": "#2ca02c"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Firehose KinesisMillisBehindLatest",
        "stat": "Average",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 15,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "DeliveryToS3.Success",
            "DeliveryStreamName",
            "${local.nsuseast1}-firehose-agg",
            {
              "color": "#2ca02c"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Firehose DeliveryToS3.Success",
        "stat": "Average",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 8,
      "x": 6,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "KinesisProducerLibrary",
            "AllErrors",
            "StreamName",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_sess}"
          ],
          [
            ".",
            "BufferingTime",
            ".",
            "."
          ],
          [
            ".",
            "KinesisRecordsDataPut",
            ".",
            "."
          ],
          [
            ".",
            "KinesisRecordsPut",
            ".",
            "."
          ],
          [
            ".",
            "RetriesPerRecord",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsDataPut",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsPending",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsPut",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsReceived",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordExpired",
            ".",
            "."
          ]
        ],
        "region": "us-east-1",
        "title": "us-east-1 Agg KPL",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 2,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.Success",
            "StreamName",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_raw}"
          ],
          [
            "...",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_sess}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "KDS PutRecords.Success"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 29,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "uptime",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA Uptime",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 29,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "downtime",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA Downtime",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 35,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "KPUs",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA Number of KPUs",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 29,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "fullRestarts",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA fullRestarts",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 35,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "heapMemoryUtilization",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA heapMemoryUtilization",
        "period": 60,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 47,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "lastCheckpointDuration",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA lastCheckpointDuration",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 41,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "numRecordsInPerSecond",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA numRecordsInPerSecond",
        "period": 60,
        "stat": "Sum"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 41,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "numRecordsOutPerSecond",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA numRecordsOutPerSecond",
        "period": 60,
        "stat": "Sum"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 35,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "numberOfFailedCheckpoints",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA numberOfFailedCheckpoints",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 35,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "numLateRecordsDropped",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA numLateRecordsDropped",
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 41,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "currentInputWatermark",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA currentInputWatermark",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 47,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "millisBehindLatest",
            "Id",
            "${local.nsuseast1}_kds_raw",
            "Application",
            "${local.nsuseast1}-kda-agg",
            "Flow",
            "Input"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA millisBehindLatest Avg",
        "period": 60,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 54,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Timestream",
            "SystemErrors",
            "DatabaseName",
            "${local.nsuseast1}",
            "Operation",
            "WriteRecords"
          ],
          [
            ".",
            "UserErrors",
            ".",
            ".",
            ".",
            "."
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Timestream WriteRecord UserErrors SystemErrors",
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 54,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Timestream",
            "SuccessfulRequestLatency",
            "TableName",
            "aggregations",
            "DatabaseName",
            "${local.nsuseast1}",
            "Operation",
            "WriteRecords"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Timestream WriteRecords SuccessfulRequestLatency Count",
        "period": 300,
        "stat": "SampleCount"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 8,
      "x": 12,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "KinesisProducerLibrary",
            "AllErrors",
            "StreamName",
            "${module.slow_prod_destination_east_only.kinesis_stream_name_raw}"
          ],
          [
            ".",
            "BufferingTime",
            ".",
            "."
          ],
          [
            ".",
            "KinesisRecordsDataPut",
            ".",
            "."
          ],
          [
            ".",
            "KinesisRecordsPut",
            ".",
            "."
          ],
          [
            ".",
            "RetriesPerRecord",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsDataPut",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsPending",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsPut",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordsReceived",
            ".",
            "."
          ],
          [
            ".",
            "UserRecordExpired",
            ".",
            "."
          ]
        ],
        "region": "us-east-1",
        "title": "us-east-1 Raw KPL",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 15,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "DeliveryToS3.DataFreshness",
            "DeliveryStreamName",
            "${local.nsuseast1}-firehose-agg",
            {
              "color": "#2ca02c"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Firehose DeliveryToS3.DataFreshness",
        "stat": "Average",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 54,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Timestream",
            "SuccessfulRequestLatency",
            "TableName",
            "aggregations",
            "DatabaseName",
            "${local.nsuseast1}",
            "Operation",
            "WriteRecords"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Timestream WriteRecords SuccessfulRequestLatency Avg",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 29,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "cpuUtilization",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA cpuUtilization",
        "period": 60,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 47,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "lastCheckpointSize",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA lastCheckpointSize",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 53,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Timestream\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 28,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# KDA\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 21,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Custom Metrics\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 14,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Firehose\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 0,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Lambda\n"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 41,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "currentOutputWatermark",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA currentOutputWatermark",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 47,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "currentOutputWatermark",
            "Application",
            "${local.nsuseast1}-kda-agg",
            {
              "id": "aggoe",
              "visible": false
            }
          ],
          [
            ".",
            "currentInputWatermark",
            ".",
            ".",
            {
              "id": "aggie",
              "visible": false
            }
          ],
          [
            {
              "id": "event_latency_prduseast1_kda_agg",
              "expression": "aggoe - aggie",
              "label": "Event Latency KDA Agg East",
              "visible": true,
              "region": "us-east-1",
              "period": 300
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA EventTimeLatency",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 22,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "lambda-custom-metrics",
            "${local.nsuseast1}-late-record-count",
            "metric_type",
            "counter"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "Lambda Late Record Count for KDA Agg"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 22,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "lambda-custom-metrics",
            "${local.nsuseast1}-buf-process-time",
            "metric_type",
            "counter"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "Lambda Buffer Process Time"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 61,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/SQS",
            "NumberOfMessagesReceived",
            "QueueName",
            "${local.nsuseast1}-buf-dlq"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "Lambda Buffer DLQ Count",
        "stat": "Sum",
        "period": 300
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 60,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# SQS\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 67,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# S3\n"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 68,
      "x": 0,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "start": "-PT72H",
        "end": "P0D",
        "region": "us-east-1",
        "metrics": [
          [
            "AWS/S3",
            "NumberOfObjects",
            "StorageType",
            "AllStorageTypes",
            "BucketName",
            "${var.agg_target_bucket_name_us_east_1}"
          ]
        ],
        "period": 86400,
        "stat": "Average",
        "title": "NumberOfObjects"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 1,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Kinesis Data Streams\n"
      }
    }
  ]
}
EOF
}
