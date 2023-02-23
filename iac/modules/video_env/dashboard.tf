resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "${var.app}-${var.common_environment}"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "height": 6,
      "width": 6,
      "y": 32,
      "x": 6,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/ECS",
            "MemoryUtilization",
            "ServiceName",
            "${local.nsuseast1}-app",
            "ClusterName",
            "${local.nsuseast1}",
            {
              "color": "#1f77b4"
            }
          ],
          [
            ".",
            "CPUUtilization",
            ".",
            ".",
            ".",
            ".",
            {
              "color": "#9467bd"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-app",
            ".",
            "${local.nsuswest2}",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "MemoryUtilization",
            ".",
            ".",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-loader",
            ".",
            "${local.nsuseast1}"
          ],
          [
            "..."
          ]
        ],
        "region": "us-east-1",
        "period": 300,
        "title": "ECS Service Memory and CPU Utilization",
        "yAxis": {
          "left": {
            "min": 0,
            "max": 100
          }
        }
      }
    },
    {
      "height": 6,
      "width": 9,
      "y": 25,
      "x": 9,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "TargetGroup",
            "${module.source.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.source.lb_arn_suffix}",
            {
              "period": 60,
              "color": "#d62728",
              "stat": "Sum"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#bcbd22"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#98df8a"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#2ca02c"
            }
          ]
        ],
        "region": "us-west-2",
        "title": "Target us-west-2 ResponseCounts",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 25,
      "x": 18,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "TargetResponseTime",
            "LoadBalancer",
            "${module.source.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "p50"
            }
          ],
          [
            "...",
            {
              "period": 60,
              "stat": "p90",
              "color": "#c5b0d5"
            }
          ],
          [
            "...",
            {
              "period": 60,
              "stat": "p99",
              "color": "#dbdb8d"
            }
          ]
        ],
        "region": "us-west-2",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0,
            "max": 3
          }
        },
        "title": "ALB us-west-2 ResponseTimes"
      }
    },
    {
      "height": 6,
      "width": 9,
      "y": 25,
      "x": 0,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "LoadBalancer",
            "${module.source.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#d62728"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#bcbd22"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#98df8a"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#2ca02c"
            }
          ]
        ],
        "region": "us-west-2",
        "title": "ALB us-west-2 ResponseCounts",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 57,
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
          ],
          [
            "...",
            "${local.nsuseast1}-kds-late"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-kds-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-sess",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDS KPL RetriesPerRecord",
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 57,
      "x": 6,
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
          ],
          [
            "...",
            "${local.nsuseast1}-kds-late"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-kds-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-sess",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "us-east-1",
        "title": "KDS WriteProvisionedThroughputExceeded",
        "period": 60,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 45,
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
          ],
          [
            "...",
            "${local.nsuseast1}-kds-late"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-kds-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-sess",
            {
              "region": "us-west-2"
            }
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
      "y": 32,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "ECS/ContainerInsights",
            "CpuUtilized",
            "ServiceName",
            "${local.nsuseast1}-app",
            "ClusterName",
            "${local.nsuseast1}"
          ],
          [
            "...",
            "${local.nsuswest2}-app",
            ".",
            "${local.nsuswest2}",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-loader",
            ".",
            "${local.nsuseast1}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "ECS Service CpuUtilized(In Units not percentage)",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 32,
      "x": 12,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "ECS/ContainerInsights",
            "RunningTaskCount",
            "ServiceName",
            "${local.nsuseast1}-app",
            "ClusterName",
            "${local.nsuseast1}"
          ],
          [
            "...",
            "${local.nsuswest2}-app",
            ".",
            "${local.nsuswest2}",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-loader",
            ".",
            "${local.nsuseast1}"
          ]
        ],
        "region": "us-east-1",
        "title": "ECS Service RunningTaskCount",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 32,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "ECS/ContainerInsights",
            "MemoryUtilized",
            "ServiceName",
            "${local.nsuseast1}-app",
            "ClusterName",
            "${local.nsuseast1}"
          ],
          [
            "...",
            "${local.nsuswest2}-app",
            ".",
            "${local.nsuswest2}",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-loader",
            ".",
            "${local.nsuseast1}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "ECS Service MemoryUtilized",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 51,
      "x": 18,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "KinesisProducerLibrary",
            "AllErrors",
            "StreamName",
            "${local.nsuswest2}-kds-agg"
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
        "region": "us-west-2",
        "title": "KDS Agg KPL us-west-2",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 21,
      "y": 1,
      "x": 0,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#d62728"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#bcbd22"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#98df8a"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${module.source.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "Sum",
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "HTTPCode_Target_5XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "region": "us-west-2"
            }
          ]
        ],
        "region": "us-east-1",
        "title": "ALB ResponseCodeCounts",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 38,
      "x": 0,
      "type": "metric",
      "properties": {
        "region": "us-east-1",
        "metrics": [
          [
            "AWS/ECS",
            "CPUUtilization",
            "ClusterName",
            "${local.nsuseast1}",
            "ServiceName",
            "${local.nsuseast1}-app",
            {
              "stat": "Average"
            }
          ],
          [
            "...",
            "${local.nsuswest2}",
            ".",
            "${local.nsuswest2}-app",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuseast1}",
            ".",
            "${local.nsuseast1}-loader"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 60,
        "annotations": {
          "horizontal": [
            {
              "label": "CPUUtilization >= 70 for 1 datapoints within 1 minute",
              "value": 70
            }
          ]
        },
        "title": "ECS Service CPUUtilization >= 70%",
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 7,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "UnHealthyHostCount",
            "TargetGroup",
            "${module.destination.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.source.lb_tg_arn_suffix}",
            ".",
            "${module.source.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Average",
        "title": "Target UnHealthyHostCount",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 7,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HealthyHostCount",
            "TargetGroup",
            "${module.destination.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${module.source.lb_tg_arn_suffix}",
            ".",
            "${module.source.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Average",
        "title": "Target HealthyHostCount",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 7,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "TargetResponseTime",
            "TargetGroup",
            "${module.destination.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "color": "#ff7f0e"
            }
          ],
          [
            "...",
            "${module.source.lb_tg_arn_suffix}",
            ".",
            "${module.source.lb_arn_suffix}",
            {
              "region": "us-west-2",
              "color": "#9467bd"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Average",
        "title": "Target ResponseTime",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
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
            "AWS/ApplicationELB",
            "RequestCount",
            "TargetGroup",
            "${module.destination.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}"
          ],
          [
            "...",
            "${module.source.lb_tg_arn_suffix}",
            ".",
            "${module.source.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "Target RequestCount",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 13,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "TargetGroup",
            "${module.destination.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.source.lb_tg_arn_suffix}",
            ".",
            "${module.source.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "Target HTTP 5XXs",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 13,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_4XX_Count",
            "TargetGroup",
            "${module.destination.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.source.lb_tg_arn_suffix}",
            ".",
            "${module.source.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "Target HTTP 4XXs",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 13,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_3XX_Count",
            "TargetGroup",
            "${module.destination.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${module.source.lb_tg_arn_suffix}",
            ".",
            "${module.source.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "Target HTTP 3XXs",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 13,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_2XX_Count",
            "TargetGroup",
            "${module.destination.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${module.source.lb_tg_arn_suffix}",
            ".",
            "${module.source.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "period": 60,
        "region": "us-east-1",
        "stat": "Sum",
        "title": "Target HTTP 2XXs",
        "yAxis": {
          "left": {
            "min": 0
          }
        },
        "view": "timeSeries",
        "stacked": false
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 45,
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
          ],
          [
            "...",
            "${local.nsuseast1}-kds-late"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-kds-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-sess",
            {
              "region": "us-west-2"
            }
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
      "y": 45,
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
          ],
          [
            "...",
            "${local.nsuseast1}-kds-late"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-kds-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-sess",
            {
              "region": "us-west-2"
            }
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
      "width": 9,
      "y": 71,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/GlobalAccelerator",
            "NewFlowCount",
            "Accelerator",
            "${substr(aws_globalaccelerator_accelerator.video.id, -36, -1)}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "GA NewFlowCount",
        "stat": "Sum",
        "period": 60
      }
    },
    {
      "height": 6,
      "width": 9,
      "y": 71,
      "x": 15,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/GlobalAccelerator",
            "NewFlowCount",
            "Listener",
            "fbb6a9b2",
            "EndpointGroup",
            "us-west-2",
            "Accelerator",
            "${substr(aws_globalaccelerator_accelerator.video.id, -36, -1)}"
          ],
          [
            "...",
            "us-east-1",
            ".",
            "."
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "GA Flow Count by Region",
        "stat": "Sum",
        "period": 60
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 71,
      "x": 9,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/GlobalAccelerator",
            "NewFlowCount",
            "DestinationEdge",
            "IN",
            "Accelerator",
            "${substr(aws_globalaccelerator_accelerator.video.id, -36, -1)}"
          ],
          [
            "...",
            "ZA",
            ".",
            "."
          ],
          [
            "...",
            "SA",
            ".",
            "."
          ],
          [
            "...",
            "AU",
            ".",
            "."
          ],
          [
            "...",
            "KR",
            ".",
            "."
          ],
          [
            "...",
            "ME",
            ".",
            "."
          ],
          [
            "...",
            "NA",
            ".",
            "."
          ],
          [
            "...",
            "AP",
            ".",
            "."
          ],
          [
            "...",
            "EU",
            ".",
            "."
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "GA Flow Count By Edge location",
        "stat": "Sum",
        "period": 60
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 78,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "CWAgent",
            "${local.nsuseast1}-MissingMediaType",
            "metric_type",
            "counter"
          ],
          [
            ".",
            "${local.nsuseast1}-NotPost",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-UnsupportedMediaType",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-MissingRequiredField",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-UnableToDecodeBody",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-UnableToReadBody",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-TooLargePayload",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuseast1}-FailedSimpleValidation",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuswest2}-MissingMediaType",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-NotPost",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-UnsupportedMediaType",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-MissingRequiredField",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-UnableToDecodeBody",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-UnableToReadBody",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-TooLargePayload",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-FailedSimpleValidation",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "Custom API Error Counts - Other"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 78,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "CWAgent",
            "${local.nsuseast1}-IsGooglebot",
            "metric_type",
            "counter"
          ],
          [
            ".",
            "${local.nsuseast1}-IsAdsBot-Google",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuswest2}-IsGooglebot",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-IsAdsBot-Google",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "Custom API Error Counts - GoogleBots"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 78,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "CWAgent",
            "${local.nsuseast1}-Timer",
            "metric_type",
            "timing"
          ],
          [
            ".",
            "${local.nsuswest2}-Timer",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Average",
        "period": 60,
        "title": "Custom API timing - Happy path",
        "yAxis": {
          "left": {
            "label": "milliseconds",
            "showUnits": false
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 78,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "KDA_CUSTOM_METRICS",
            "AGG_PARSE_ERRORS",
            "metric_type",
            "counter"
          ],
          [
            "...",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "Custom KDA Agg - Bad KDA records thrown out",
        "yAxis": {
          "left": {
            "label": "",
            "showUnits": false
          }
        }
      }
    },
    {
      "height": 6,
      "width": 3,
      "y": 1,
      "x": 21,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "RequestCount",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}"
          ],
          [
            "...",
            "${module.source.lb_arn_suffix}",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "singleValue",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "ALB Requests Per Minute"
      }
    },
    {
      "height": 6,
      "width": 9,
      "y": 19,
      "x": 0,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#d62728"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#bcbd22"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#98df8a"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#2ca02c"
            }
          ]
        ],
        "region": "us-east-1",
        "title": "ALB us-east-1 ResponseCounts",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "height": 6,
      "width": 9,
      "y": 19,
      "x": 9,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "TargetGroup",
            "${module.destination.lb_tg_arn_suffix}",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "period": 60,
              "color": "#d62728",
              "stat": "Sum"
            }
          ],
          [
            ".",
            "HTTPCode_Target_4XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#bcbd22"
            }
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#98df8a"
            }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 60,
              "stat": "Sum",
              "color": "#2ca02c"
            }
          ]
        ],
        "region": "us-east-1",
        "title": "Target us-east-1 ResponseCounts",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 19,
      "x": 18,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/ApplicationELB",
            "TargetResponseTime",
            "LoadBalancer",
            "${module.destination.lb_arn_suffix}",
            {
              "period": 60,
              "stat": "p50"
            }
          ],
          [
            "...",
            {
              "period": 60,
              "stat": "p90",
              "color": "#c5b0d5"
            }
          ],
          [
            "...",
            {
              "period": 60,
              "stat": "p99",
              "color": "#dbdb8d"
            }
          ]
        ],
        "region": "us-east-1",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0,
            "max": 3
          }
        },
        "title": "ALB us-east-1 ResponseTimes"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 64,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "DeliveryToS3.Records",
            "DeliveryStreamName",
            "${local.nsuseast1}-firehose-raw",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-agg"
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-late"
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-sess",
            {
              "region": "us-west-2"
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
      "y": 64,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "KinesisMillisBehindLatest",
            "DeliveryStreamName",
            "${local.nsuseast1}-firehose-raw",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-agg"
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-late"
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-sess",
            {
              "region": "us-west-2"
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
      "y": 64,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "DeliveryToS3.Success",
            "DeliveryStreamName",
            "${local.nsuseast1}-firehose-raw",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-agg"
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-late"
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-sess",
            {
              "region": "us-west-2"
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
      "y": 51,
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
        "title": "KDS Agg KPL us-east-1",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 45,
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
          ],
          [
            "...",
            "${local.nsuseast1}-kds-late"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-kds-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-sess",
            {
              "region": "us-west-2"
            }
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
      "y": 91,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "uptime",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA Uptime",
        "period": 300,
        "yAxis": {
          "left": {
            "label": "Milliseconds",
            "showUnits": false
          }
        },
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 91,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "downtime",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA Downtime",
        "period": 300,
        "yAxis": {
          "left": {
            "label": "Milliseconds",
            "showUnits": false
          }
        },
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 97,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "KPUs",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
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
      "y": 91,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "fullRestarts",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
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
      "y": 97,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "heapMemoryUtilization",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA heapMemoryUtilization",
        "period": 60,
        "stat": "Average",
        "yAxis": {
          "left": {
            "label": "Percentage",
            "showUnits": false
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 109,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "lastCheckpointDuration",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA lastCheckpointDuration",
        "period": 300,
        "yAxis": {
          "left": {
            "label": "Milliseconds",
            "showUnits": false
          }
        },
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 103,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "numRecordsInPerSecond",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
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
      "y": 103,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "numRecordsOutPerSecond",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
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
      "y": 97,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "numberOfFailedCheckpoints",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
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
      "y": 97,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "numLateRecordsDropped",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
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
      "y": 103,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "currentInputWatermark",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
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
      "y": 109,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "millisBehindLatest",
            "Id",
            "${module.destination.kinesis_stream_id_raw}",
            "Application",
            "${module.destination.kda_app_name_agg}",
            "Flow",
            "Input"
          ],
          [
            "...",
            "${module.source.kinesis_stream_id_raw}",
            ".",
            "${module.source.kda_app_name_agg}",
            ".",
            {
              "region": "us-west-2"
            }
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
      "y": 122,
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
          ],
          [
            "...",
            "${local.nsuswest2}",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "SystemErrors",
            ".",
            ".",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
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
      "y": 122,
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
          ],
          [
            ".",
            ".",
            "TableName",
            "sessions",
            "DatabaseName",
            "${local.nsuseast1}",
            ".",
            "."
          ],
          [
            ".",
            ".",
            "TableName",
            "aggregations",
            "DatabaseName",
            "${local.nsuswest2}",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            ".",
            "TableName",
            "sessions",
            "DatabaseName",
            "${local.nsuswest2}",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
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
      "y": 51,
      "x": 0,
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
        "title": "KDS Raw KPL us-east-1",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 51,
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
            "${local.nsuswest2}-kds-raw"
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
        "region": "us-west-2",
        "title": "KDS Raw KPL us-west-2",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 51,
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
            "${local.nsuswest2}-kds-sess"
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
        "region": "us-west-2",
        "title": "KDS Sess KPL us-west-2",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 51,
      "x": 0,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "KinesisProducerLibrary",
            "AllErrors",
            "StreamName",
            "${local.nsuseast1}-kds-sess"
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
        "title": "KDS Sess KPL us-east-1",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 51,
      "x": 18,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "metrics": [
          [
            "KinesisProducerLibrary",
            "AllErrors",
            "StreamName",
            "${local.nsuswest2}-kds-late"
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
        "region": "us-west-2",
        "title": "KDS Late KPL us-west-2",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 51,
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
            "${local.nsuseast1}-kds-late"
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
        "title": "KDS Late KPL us-east-1",
        "period": 300
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 64,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Firehose",
            "DeliveryToS3.DataFreshness",
            "DeliveryStreamName",
            "${local.nsuseast1}-firehose-raw",
            {
              "color": "#2ca02c"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-agg"
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-late"
          ],
          [
            "...",
            "${local.nsuseast1}-firehose-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-firehose-sess",
            {
              "region": "us-west-2"
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
      "y": 122,
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
          ],
          [
            ".",
            ".",
            "TableName",
            "sessions",
            "DatabaseName",
            "${local.nsuseast1}",
            ".",
            "."
          ],
          [
            ".",
            ".",
            "TableName",
            "aggregations",
            "DatabaseName",
            "${local.nsuswest2}",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            ".",
            "TableName",
            "sessions",
            "DatabaseName",
            "${local.nsuswest2}",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
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
      "y": 91,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "cpuUtilization",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA cpuUtilization",
        "period": 60,
        "stat": "Average",
        "yAxis": {
          "left": {
            "label": "Percentage",
            "showUnits": false
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 109,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "lastCheckpointSize",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA lastCheckpointSize",
        "period": 300,
        "yAxis": {
          "left": {
            "showUnits": false,
            "label": "Bytes"
          }
        },
        "stat": "Average"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 121,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Timestream\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 90,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# KDA\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 77,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Custom Metrics\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 70,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Global Accelerator\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 63,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Firehose\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 44,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Kinesis Data Streams\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 31,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# ECS / Fargate\n"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 0,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# ALB / Target Groups\n"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 103,
      "x": 18,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "currentOutputWatermark",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
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
      "y": 109,
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
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2",
              "id": "aggow",
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
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2",
              "id": "aggiw",
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
              "id": "event_latency_prduswest2_kda_agg",
              "expression": "aggow - aggiw",
              "label": "Event Latency KDA Agg West",
              "visible": true,
              "region": "us-west-2",
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
      "y": 115,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/KinesisAnalytics",
            "managedMemoryUtilization",
            "Application",
            "${local.nsuseast1}-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kda-agg",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "title": "KDA managedMemoryUtilization",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 57,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/Kinesis",
            "ReadProvisionedThroughputExceeded",
            "StreamName",
            "${local.nsuseast1}-kds-raw",
            {
              "color": "#d62728"
            }
          ],
          [
            "...",
            "${local.nsuseast1}-kds-agg"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-late"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-sess"
          ],
          [
            "...",
            "${local.nsuswest2}-kds-raw",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-agg",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-late",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-sess",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "us-east-1",
        "title": "KDS ReadProvisionedThroughputExceeded",
        "period": 60,
        "stat": "Average",
        "yAxis": {
          "left": {
            "showUnits": true
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 57,
      "x": 18,
      "type": "metric",
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "metrics": [
          [
            "AWS/Kinesis",
            "SubscribeToShard.RateExceeded",
            "StreamName",
            "${local.nsuseast1}-kds-agg",
            "ConsumerName",
            "${local.nsuseast1}-kds-agg-buf"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-sess",
            ".",
            "${local.nsuseast1}-kds-agg-buf-sess"
          ],
          [
            "...",
            "${local.nsuseast1}-kds-raw",
            ".",
            "efo-kda-agg"
          ],
          [
            "...",
            "${local.nsuswest2}-kds-agg",
            ".",
            "${local.nsuswest2}-kds-agg-buf",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-sess",
            ".",
            "${local.nsuswest2}-kds-agg-buf-sess",
            {
              "region": "us-west-2"
            }
          ],
          [
            "...",
            "${local.nsuswest2}-kds-raw",
            ".",
            "efo-kda-agg",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "title": "KDS EFO Rate Exceeded",
        "period": 300
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 128,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# S3\n"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 129,
      "x": 0,
      "type": "metric",
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
            "${var.raw_target_bucket_name_us_east_1}"
          ],
          [
            "AWS/S3",
            "NumberOfObjects",
            "StorageType",
            "AllStorageTypes",
            "BucketName",
            "${var.agg_target_bucket_name_us_east_1}"
          ],
          [
            "AWS/S3",
            "NumberOfObjects",
            "StorageType",
            "AllStorageTypes",
            "BucketName",
            "${var.sess_target_bucket_name_us_east_1}"
          ]
        ],
        "period": 86400,
        "stat": "Average",
        "title": "S3 NumberOfObjects"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 136,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/SNS",
            "NumberOfMessagesPublished",
            "TopicName",
            "${local.nsuseast1}"
          ],
          [
            ".",
            "NumberOfNotificationsFailed",
            ".",
            "."
          ],
          [
            ".",
            "NumberOfNotificationsDelivered",
            ".",
            "."
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "SNS S3 Raw Event Delivered, Published, and Failed"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 135,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# SNS\n"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 143,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/SQS",
            "NumberOfMessagesReceived",
            "QueueName",
            "${local.nsuseast1}-buf-dlq"
          ],
          [
            ".",
            ".",
            "QueueName",
            "${local.nsuseast1}-buf-sess-dlq"
          ],
          [
            ".",
            ".",
            "QueueName",
            "${local.nsuswest2}-buf-dlq",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            ".",
            "QueueName",
            "${local.nsuswest2}-buf-sess-dlq",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "SQS Agg / Sess Buffer DLQ Messages Received"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 142,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# SQS\n"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 143,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/SQS",
            "NumberOfMessagesReceived",
            "QueueName",
            "${local.nsuseast1}-dlq"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "SQS Receiver DLQ Messages Received"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 143,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/SQS",
            "NumberOfMessagesReceived",
            "QueueName",
            "${local.nsuseast1}-outbound"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "SQS Outbound Messages Received"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 150,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Lambda",
            "Invocations",
            "FunctionName",
            "${local.nsuseast1}-kds-timestream-buf"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-kds-timestream-buf-sess"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-late-s3-metrics"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf-sess",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "Lambda Invocations"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 150,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Lambda",
            "Errors",
            "FunctionName",
            "${local.nsuseast1}-kds-timestream-buf"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-kds-timestream-buf-sess"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-late-s3-metrics"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf-sess",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "Lambda Errors"
      }
    },
    {
      "height": 1,
      "width": 24,
      "y": 149,
      "x": 0,
      "type": "text",
      "properties": {
        "markdown": "# Lambda\n"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 150,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Lambda",
            "Duration",
            "FunctionName",
            "${local.nsuseast1}-kds-timestream-buf"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-kds-timestream-buf-sess"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-late-s3-metrics"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf-sess",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "Lambda Duration"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 156,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Lambda",
            "ConcurrentExecutions",
            "FunctionName",
            "${local.nsuseast1}-kds-timestream-buf"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-kds-timestream-buf-sess"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-late-s3-metrics"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf-sess",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "Lambda Concurrent Executions"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 156,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Lambda",
            "Throttles",
            "FunctionName",
            "${local.nsuseast1}-kds-timestream-buf"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-kds-timestream-buf-sess"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuseast1}-late-s3-metrics"
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            ".",
            ".",
            "${local.nsuswest2}-kds-timestream-buf-sess",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "Lambda Throttles"
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 84,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "lambda-custom-metrics",
            "${local.nsuseast1}-buf-lag",
            "metric_type",
            "counter"
          ],
          [
            "lambda-custom-metrics",
            "${local.nsuseast1}-buf-sess-lag",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuswest2}-buf-lag",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-buf-sess-lag",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Average",
        "period": 60,
        "title": "Custom Lambda Agg / Sess Buf - lag",
        "yAxis": {
          "left": {
            "label": "",
            "showUnits": false
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 84,
      "x": 6,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "lambda-custom-metrics",
            "${local.nsuseast1}-buf-process-time",
            "metric_type",
            "counter"
          ],
          [
            "lambda-custom-metrics",
            "${local.nsuseast1}-buf-sess-process-time",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuswest2}-buf-process-time",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-buf-sess-process-time",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Average",
        "period": 60,
        "title": "Custom Lambda Agg / Sess Buf - process time",
        "yAxis": {
          "left": {
            "label": "",
            "showUnits": false
          }
        }
      }
    },
    {
      "height": 6,
      "width": 6,
      "y": 84,
      "x": 12,
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "lambda-custom-metrics",
            "${local.nsuseast1}-buf-record-count",
            "metric_type",
            "counter"
          ],
          [
            "lambda-custom-metrics",
            "${local.nsuseast1}-buf-sess-record-count",
            ".",
            "."
          ],
          [
            ".",
            "${local.nsuswest2}-buf-record-count",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ],
          [
            ".",
            "${local.nsuswest2}-buf-sess-record-count",
            ".",
            ".",
            {
              "region": "us-west-2"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 60,
        "title": "Custom Lambda Agg / Sess Buf - record count",
        "yAxis": {
          "left": {
            "label": "",
            "showUnits": false
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 129,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "S3 Replication Latency - West to East",
        "metrics": [
          [
            "AWS/S3",
            "ReplicationLatency",
            "SourceBucket",
            "${var.agg_target_bucket_name_us_west_2}",
            "DestinationBucket",
            "${var.agg_target_bucket_name_us_east_1}",
            "RuleId",
            "${local.nsuswest2}agg-repl-source-to-dest"
          ],
          [
            "...",
            "${var.late_target_bucket_name_us_west_2}",
            ".",
            "${var.late_target_bucket_name_us_east_1}",
            ".",
            "${local.nsuswest2}late-repl-source-to-dest"
          ],
          [
            "...",
            "${var.raw_target_bucket_name_us_west_2}",
            ".",
            "${var.raw_target_bucket_name_us_east_1}",
            ".",
            "${local.nsuswest2}raw-repl-source-to-dest"
          ],
          [
            "...",
            "${var.sess_target_bucket_name_us_west_2}",
            ".",
            "${var.sess_target_bucket_name_us_east_1}",
            ".",
            "${local.nsuswest2}sess-repl-source-to-dest"
          ]
        ]
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 129,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "us-east-1",
        "stat": "Sum",
        "period": 300,
        "title": "S3 Bytes Pending Replication - West to East",
        "metrics": [
          [
            "AWS/S3",
            "BytesPendingReplication",
            "SourceBucket",
            "${var.agg_target_bucket_name_us_west_2}",
            "DestinationBucket",
            "${var.agg_target_bucket_name_us_east_1}",
            "RuleId",
            "${local.nsuswest2}agg-repl-source-to-dest"
          ],
          [
            "...",
            "${var.late_target_bucket_name_us_west_2}",
            ".",
            "${var.late_target_bucket_name_us_east_1}",
            ".",
            "${local.nsuswest2}late-repl-source-to-dest"
          ],
          [
            "...",
            "${var.raw_target_bucket_name_us_west_2}",
            ".",
            "${var.raw_target_bucket_name_us_east_1}",
            ".",
            "${local.nsuswest2}raw-repl-source-to-dest"
          ],
          [
            "...",
            "${var.sess_target_bucket_name_us_west_2}",
            ".",
            "${var.sess_target_bucket_name_us_east_1}",
            ".",
            "${local.nsuswest2}sess-repl-source-to-dest"
          ]
        ]
      }
    }
  ]
}
EOF
}
