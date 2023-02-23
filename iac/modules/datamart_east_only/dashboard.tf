resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "${var.app}-${var.common_environment}"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "height": 6,
      "width": 6,
      "y": 7,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "KinesisProducerLibrary",
            "RetriesPerRecord",
            "StreamName",
            "${local.nsuseast1}-kds-raw"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-agg"
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
      "y": 7,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "WriteProvisionedThroughputExceeded",
            "StreamName",
            "${local.nsuseast1}-kds-raw",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-kds-agg"
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
      "y": 1,
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
            "${local.nsuseast1}-kds-raw"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-agg"
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
      "y": 1,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.SuccessfulRecords",
            "StreamName",
            "${local.nsuseast1}-kds-raw"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-agg"
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
      "y": 1,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.FailedRecords",
            "StreamName",
            "${local.nsuseast1}-kds-raw"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-agg"
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
      "y": 21,
      "x": 0,
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
      "y": 14,
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
      "y": 14,
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
      "y": 14,
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
      "y": 7,
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
            "${local.nsuseast1}-kds-agg"
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
      "y": 1,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "PutRecords.Success",
            "StreamName",
            "${local.nsuseast1}-kds-raw"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-agg"
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
      "y": 28,
      "x": 0,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "uptime",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "region": "us-east-1",
        "title": "KDA Uptime",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 28,
      "x": 6,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "downtime",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "region": "us-east-1",
        "title": "KDA Downtime",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 34,
      "x": 6,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "KPUs",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "region": "us-east-1",
        "title": "KDA Number of KPUs",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 28,
      "x": 12,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "fullRestarts",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "region": "us-east-1",
        "title": "KDA fullRestarts",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 34,
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
      "y": 46,
      "x": 6,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "lastCheckpointDuration",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "region": "us-east-1",
        "title": "KDA lastCheckpointDuration",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 40,
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
      "y": 40,
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
      "y": 34,
      "x": 0,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "numberOfFailedCheckpoints",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "region": "us-east-1",
        "title": "KDA numberOfFailedCheckpoints",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 34,
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
      "y": 40,
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
      "y": 46,
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
      "y": 7,
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
            "${local.nsuseast1}-kds-raw"
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
      "y": 14,
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
      "y": 28,
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
      "y": 46,
      "x": 0,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "lastCheckpointSize",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ]
        ],
        "region": "us-east-1",
        "title": "KDA lastCheckpointSize",
        "period": 300
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 27,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# KDA\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 20,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Custom Metrics\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 13,
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
        "markdown": "# Kinesis Data Streams\n"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 40,
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
      "y": 46,
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
            "${local.nsuseast1}-kda-agg",
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
          ],
          [
            {
              "id": "event_latency_prduseast1_kda_buf",
              "expression": "bufoe - bufie",
              "label": "Event Latency KDA Buf East",
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
      "height": 1,
      "width": 24,
      "y": 52,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# S3\n"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 53,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "start": "-P14D",
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
    }
  ]
}
EOF
}
