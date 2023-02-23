resource "aws_sns_topic" "alert_topic" {
  name = "${var.app}-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "alert_subscription_slack" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "https"
  endpoint  = "<slack endpoint>"
}

resource "aws_sns_topic_subscription" "alert_subscription_email" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = "<email address>"
}

# ALB Alarms
resource "aws_cloudwatch_metric_alarm" "too_many_requests" {
  depends_on          = [module.video_source_detail.lb_arn_suffix]
  alarm_name          = "${local.ns}-too-many-requests"
  alarm_description   = "Request count has crossed 10k per second"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "HTTPCode_Target_2XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.too_many_requests_threshold
  tags                = var.tags
  dimensions = {
    LoadBalancer = module.video_source_detail.lb_arn_suffix
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "too_many_5xx_response" {
  depends_on          = [module.video_source_detail.lb_arn_suffix]
  alarm_name          = "${local.ns}-too-many-5xx-response"
  alarm_description   = "Service is returning too many 5xx response"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.too_many_5xx_response_threshold
  tags                = var.tags
  dimensions = {
    LoadBalancer = module.video_source_detail.lb_arn_suffix
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  depends_on          = [module.video_source_detail.lb_arn_suffix]
  alarm_name          = "${local.ns}-high-response-time"
  alarm_description   = "Service response time is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.high_response_time_threshold
  tags                = var.tags
  dimensions = {
    LoadBalancer = module.video_source_detail.lb_arn_suffix
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

# Fargate Containers Alarms
resource "aws_cloudwatch_metric_alarm" "high_running_task_count" {
  depends_on          = [module.video_source_detail.ecs_cluster_name, module.video_source_detail.ecs_service_name]
  alarm_name          = "${local.ns}-high-running-task-count"
  alarm_description   = "Number of running task is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = var.high_running_task_count_threshold
  tags                = var.tags
  dimensions = {
    ClusterName = module.video_source_detail.ecs_cluster_name
    ServiceName = module.video_source_detail.ecs_service_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

# ECS Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  depends_on          = [module.video_source_detail.ecs_cluster_name, module.video_source_detail.ecs_service_name]
  alarm_name          = "${local.ns}-high-cpu-utilization"
  alarm_description   = "CPU Utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.high_cpu_utilization_threshold
  tags                = var.tags
  dimensions = {
    ClusterName = module.video_source_detail.ecs_cluster_name
    ServiceName = module.video_source_detail.ecs_service_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_memory_utilization" {
  depends_on          = [module.video_source_detail.ecs_cluster_name, module.video_source_detail.ecs_service_name]
  alarm_name          = "${local.ns}-high-memory-utilization"
  alarm_description   = "Memory utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.high_memory_utilization_threshold
  tags                = var.tags
  dimensions = {
    ClusterName = module.video_source_detail.ecs_cluster_name
    ServiceName = module.video_source_detail.ecs_service_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

# KDS Alarms
resource "aws_cloudwatch_metric_alarm" "high_raw_kds_putrecs_failedrecs" {
  depends_on          = [module.video_source_detail.kinesis_stream_name_raw]
  alarm_name          = "${local.ns}-kds-raw-putrecords-failedrecords"
  alarm_description   = "Raw KDS PutRecords FailedRecords is High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "PutRecords.FailedRecords"
  namespace           = "AWS/Kinesis"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.high_raw_kds_putrecs_failedrecs_threshold
  tags                = var.tags
  dimensions = {
    StreamName = module.video_source_detail.kinesis_stream_name_raw
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_agg_kds_putrecs_failedrecs" {
  depends_on          = [module.video_source_detail.kinesis_stream_name_sess]
  alarm_name          = "${local.ns}-kds-agg-putrecords-failedrecords"
  alarm_description   = "Agg KDS PutRecords FailedRecords is High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "PutRecords.FailedRecords"
  namespace           = "AWS/Kinesis"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.high_agg_kds_putrecs_failedrecs_threshold
  tags                = var.tags
  dimensions = {
    StreamName = module.video_source_detail.kinesis_stream_name_sess
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_raw_kpl_retries" {
  depends_on          = [module.video_source_detail.kinesis_stream_name_raw]
  alarm_name          = "${local.ns}-kds-raw-high-number-kpl-retries"
  alarm_description   = "High Number of Raw KPL Retries"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "RetriesPerRecord"
  namespace           = "KinesisProducerLibrary"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.high_raw_kpl_retries_threshold
  tags                = var.tags
  dimensions = {
    StreamName = module.video_source_detail.kinesis_stream_name_raw
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_agg_kpl_retries" {
  depends_on          = [module.video_source_detail.kinesis_stream_name_sess]
  alarm_name          = "${local.ns}-kds-agg-high-number-kpl-retries"
  alarm_description   = "High Number of Agg KPL Retries"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "RetriesPerRecord"
  namespace           = "KinesisProducerLibrary"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.high_agg_kpl_retries_threshold
  tags                = var.tags
  dimensions = {
    StreamName = module.video_source_detail.kinesis_stream_name_sess
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// Number of records  in Raw DLQ
resource "aws_cloudwatch_metric_alarm" "kds_raw_dlq_count_high" {
  alarm_name          = "${local.ns}-kds-raw-dlq-count-high"
  alarm_description   = "The number of records in the Raw dead letter queue is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "120"
  statistic           = "Average"
  threshold           = "100"
  tags                = var.tags
  dimensions = {
    QueueName = module.video_source_detail.sqs_raw_dlq_id
  }
  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}


# KDA Alarms

// downtime
resource "aws_cloudwatch_metric_alarm" "kda_downtime_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-downtime-agg"
  alarm_description   = "Downtime occurred in Aggregator Flink App"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "downtime"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"
  tags                = var.tags
  dimensions = {
    Application = module.video_source_detail.kinesis_kda_name_agg
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// numberOfFailedCheckpoints
resource "aws_cloudwatch_metric_alarm" "kda_failed_checkpoints_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-failed-checkpoints-agg"
  alarm_description   = "Checkpoints Failed for Aggregator Flink App"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "numberOfFailedCheckpoints"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Average"
  threshold           = "3"
  tags                = var.tags
  dimensions = {
    Application = module.video_source_detail.kinesis_kda_name_agg
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
}

// numRecordsOutPerSecond
resource "aws_cloudwatch_metric_alarm" "kda_records_out_per_sec_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-records-out-per-sec-agg"
  alarm_description   = "Number of records written per second is below threshold for Aggregator Flink App"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  datapoints_to_alarm = "5"
  metric_name         = "numRecordsOutPerSecond"
  namespace           = "AWS/KinesisAnalytics"
  period              = "900"
  statistic           = "Average"
  threshold           = var.kda_records_out_per_sec_agg_threshold
  tags                = var.tags
  dimensions = {
    Application = module.video_source_detail.kinesis_kda_name_agg
  }

  actions_enabled           = var.kda-records-out-per-sec-agg-enabled
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// millisBehindLatest
resource "aws_cloudwatch_metric_alarm" "kda_millis_behind_latest_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-millis-behind-latest-agg"
  alarm_description   = "Aggregator Flink App is behind the latest record"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "millisBehindLatest"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Average"
  threshold           = var.kda_millis_behind_latest_agg_threshold
  tags                = var.tags
  dimensions = {
    Application = module.video_source_detail.kinesis_kda_name_agg
    Id          = "${local.nsunder}_kds_raw"
    Flow        = "Input"
  }

  actions_enabled           = var.kda-millis-behind-latest-agg-enabled
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// lastCheckpointDuration
resource "aws_cloudwatch_metric_alarm" "kda_last_checkpoint_dur_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-last-checkpoint-dur-agg"
  alarm_description   = "Checkpoint duration for Aggregator Flink App is taking longer than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "lastCheckpointDuration"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Maximum"
  threshold           = var.kda_last_checkpoint_dur_agg_threshold
  tags                = var.tags
  dimensions = {
    Application = module.video_source_detail.kinesis_kda_name_agg
  }

  actions_enabled           = var.kda-last-checkpoint-dur-agg-enabled
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// lastCheckpointSize
resource "aws_cloudwatch_metric_alarm" "kda_last_checkpoint_size_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-last-checkpoint-size-agg"
  alarm_description   = "Checkpoint size for Aggregator Flink App has grown larger than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "lastCheckpointSize"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Maximum"
  threshold           = var.kda_last_checkpoint_size_agg_threshold
  tags                = var.tags
  dimensions = {
    Application = module.video_source_detail.kinesis_kda_name_agg
  }

  actions_enabled           = var.kda-last-checkpoint-size-agg-enabled
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// heapMemoryUtilization
resource "aws_cloudwatch_metric_alarm" "kda_heap_memory_util_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-heap-memory-util-agg"
  alarm_description   = "Heap Memory Utilization for Aggregator Flink App is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "heapMemoryUtilization"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Average"
  threshold           = var.kda_heap_memory_util_agg_threshold
  tags                = var.tags
  dimensions = {
    Application = module.video_source_detail.kinesis_kda_name_agg
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
}

// cpuUtilization
resource "aws_cloudwatch_metric_alarm" "kda_cpu_util_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-cpu-util-agg"
  alarm_description   = "CPU Utilization for Aggregator Flink App is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  datapoints_to_alarm = "2"
  metric_name         = "cpuUtilization"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Average"
  threshold           = var.kda_cpu_util_agg_threshold
  tags                = var.tags
  dimensions = {
    Application = module.video_source_detail.kinesis_kda_name_agg
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// threadsCount
resource "aws_cloudwatch_metric_alarm" "kda_threads_count_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-threads-count-agg"
  alarm_description   = "Thread Count for Aggregator Flink App is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "threadsCount"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Maximum"
  threshold           = var.kda_threads_count_agg_threshold
  tags                = var.tags
  dimensions = {
    Application = module.video_source_detail.kinesis_kda_name_agg
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// (oldGenerationGCTime * 100)/60 over 1 min period')
resource "aws_cloudwatch_metric_alarm" "kda_max_exp_gc_time_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-max-exp-gc-time-agg"
  alarm_description   = "The GarbageCollectionTime exceeded the maximum expected for the Aggregator Flink App"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  threshold           = var.kda_max_exp_gc_time_agg_threshold
  tags                = var.tags

  metric_query {
    id          = "e1"
    expression  = "(m1 * 100)/60"
    label       = "Maximum Expected Garbage Collection Time"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "oldGenerationGCTime"
      namespace   = "AWS/KinesisAnalytics"
      period      = "60"
      stat        = "Maximum"

      dimensions = {
        Application = module.video_source_detail.kinesis_kda_name_agg
      }
    }
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// RATE(oldGenerationGCCount)
resource "aws_cloudwatch_metric_alarm" "kda_max_exp_gc_cnt_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-max-exp-gc-cnt-agg"
  alarm_description   = "The GarbageCollectionCount Rate exceeded the maximum expected for the Aggregator Flink App"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  threshold           = var.kda_max_exp_gc_cnt_agg_threshold
  tags                = var.tags

  metric_query {
    id          = "e1"
    expression  = "RATE(m1)"
    label       = "Maximum Expected Garbage Collection Count"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "oldGenerationGCCount"
      namespace   = "AWS/KinesisAnalytics"
      period      = "60"
      stat        = "Maximum"

      dimensions = {
        Application = module.video_source_detail.kinesis_kda_name_agg
      }
    }
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// currentOutputWatermark - currentInputWatermark
resource "aws_cloudwatch_metric_alarm" "kda_min_exp_water_agg" {
  depends_on          = [module.video_source_detail.kinesis_kda_name_agg]
  alarm_name          = "${local.ns}-kda-min-exp-water-agg"
  alarm_description   = "The Aggregator Flink App is processing increasingly older events"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  threshold           = var.kda_min_exp_water_agg_threshold
  tags                = var.tags

  metric_query {
    id          = "e1"
    expression  = "m1-m2"
    label       = "Minimum Expected Watermark"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "currentOutputWatermark"
      namespace   = "AWS/KinesisAnalytics"
      period      = "60"
      stat        = "Minimum"

      dimensions = {
        Application = module.video_source_detail.kinesis_kda_name_agg
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "currentInputWatermark"
      namespace   = "AWS/KinesisAnalytics"
      period      = "60"
      stat        = "Minimum"

      dimensions = {
        Application = module.video_source_detail.kinesis_kda_name_agg
      }
    }
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

# Timestream Alarms
// System Errors >= 50
resource "aws_cloudwatch_metric_alarm" "timestream_system_err" {
  depends_on          = [module.video_source_detail.timestream_db_name]
  alarm_name          = "${local.ns}-timestream-system-errors"
  alarm_description   = "System Errors exceeded threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "SystemErrors"
  namespace           = "AWS/Timestream"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.timestream_system_err_threshold
  tags                = var.tags
  dimensions = {
    DatabaseName = module.video_source_detail.timestream_db_name
    Operation    = "WriteRecords"
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// User Errors >= 50
resource "aws_cloudwatch_metric_alarm" "timestream_user_err" {
  depends_on          = [module.video_source_detail.timestream_db_name]
  alarm_name          = "${local.ns}-timestream-user-errors"
  alarm_description   = "User Errors exceeded threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "UserErrors"
  namespace           = "AWS/Timestream"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.timestream_user_err_threshold
  tags                = var.tags
  dimensions = {
    DatabaseName = module.video_source_detail.timestream_db_name
    Operation    = "WriteRecords"
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// SuccessfulRequestLatency >= 2000ms
resource "aws_cloudwatch_metric_alarm" "timestream_tbl_suc_req_latency" {
  depends_on          = [module.video_source_detail.timestream_db_name, module.video_source_detail.timestream_session_name]
  alarm_name          = "${local.ns}-timestream-tbl-suc-req-latency"
  alarm_description   = "Successful Request Latency for WriteRecords is taking longer than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "SuccessfulRequestLatency"
  namespace           = "AWS/Timestream"
  period              = "300"
  statistic           = "Average"
  threshold           = var.timestream_tbl_suc_req_latency_threshold
  tags                = var.tags
  dimensions = {
    DatabaseName = module.video_source_detail.timestream_db_name
    TableName    = module.video_source_detail.sessions_table_name
    Operation    = "WriteRecords"
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// KDS Buffer Aggregations Lambda 

// Errors
resource "aws_cloudwatch_metric_alarm" "lambda_buf_agg_error" {
  alarm_name          = "${local.ns}-lambda-buf-agg-errors"
  alarm_description   = "Error Count for the Aggregations Lambda KDS to Timestream Buffer is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "${local.ns}-buf-error-count"
  namespace           = "lambda-custom-metrics"
  period              = "60"
  statistic           = "Sum"
  threshold           = var.timestream_buf_error_threshold
  tags                = var.tags
  dimensions = {
    metric_type = "counter"
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// Number of records in Buffer DLQ
resource "aws_cloudwatch_metric_alarm" "lambda_sqs_agg_dlq_count_high" {
  alarm_name          = "${local.ns}-lambda-buf-agg-dlq-count-high"
  alarm_description   = "The number of records in the Aggregations Lambda KDS to Timestream Buffer dead letter queue is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"
  tags                = var.tags
  dimensions = {
    QueueName = module.video_source_detail.sqs_lambda_dlq_buf_sess_id
  }
  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// KDS Buffer Sessions Lambda 

// Errors
resource "aws_cloudwatch_metric_alarm" "lambda_buf_sess_error" {
  alarm_name          = "${local.ns}-lambda-buf-sess-errors"
  alarm_description   = "Error Count for the Sessions Lambda KDS to Timestream Buffer is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "${local.ns}-buf-sess-error-count"
  namespace           = "lambda-custom-metrics"
  period              = "60"
  statistic           = "Sum"
  threshold           = var.timestream_buf_error_threshold
  tags                = var.tags
  dimensions = {
    metric_type = "counter"
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// Number of records in Buffer DLQ
resource "aws_cloudwatch_metric_alarm" "lambda_sqs_sess_dlq_count_high" {
  alarm_name          = "${local.ns}-lambda-buf-sess-dlq-count-high"
  alarm_description   = "The number of records in the Sessions Lambda KDS to Timestream Buffer dead letter queue is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"
  tags                = var.tags
  dimensions = {
    QueueName = module.video_source_detail.sqs_lambda_dlq_buf_sess_id
  }
  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "kda_not_pushing_to_aggregate_kds" {
  alarm_name          = "${local.ns}-kda-not-pushing-to-aggregate-kds"
  alarm_description   = "Flink has not sent any records to aggregate KDS in the last 5 minutes.  Please verify the Flink Agggregator is running."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "KinesisRecordsDataPut"
  namespace           = "KinesisProducerLibrary"
  period              = "300"
  statistic           = "Average"
  threshold           = "10"
  tags                = var.tags
  dimensions = {
    StreamName = module.video_source_detail.kinesis_stream_name_sess
  }
  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "kda_not_pushing_to_session_kds" {
  alarm_name          = "${local.ns}-kda-not-pushing-to-session-kds"
  alarm_description   = "Flink has not sent any records to session KDS in the last 5 minutes.  Please verify the Flink Agggregator is running."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "KinesisRecordsDataPut"
  namespace           = "KinesisProducerLibrary"
  period              = "300"
  statistic           = "Average"
  threshold           = "10"
  tags                = var.tags
  dimensions = {
    StreamName = module.video_source_detail.kinesis_stream_name_sess
  }
  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

