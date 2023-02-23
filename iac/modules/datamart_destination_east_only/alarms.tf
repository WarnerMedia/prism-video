resource "aws_sns_topic" "alert_topic" {
  name = "${var.app}-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "alert_subscription_slack" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "https"
  endpoint  = ""
}

resource "aws_sns_topic_subscription" "alert_subscription_email" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = ""
}

# KDS Alarms

resource "aws_cloudwatch_metric_alarm" "high_sess_kds_putrecs_failedrecs" {
  depends_on          = [module.kds-sess.kinesis_data_stream_name]
  alarm_name          = "${local.ns}-kds-sess-putrecords-failedrecords"
  alarm_description   = "Sess KDS PutRecords FailedRecords is High"
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
    StreamName = module.kds-sess.kinesis_data_stream_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_raw_kpl_retries" {
  depends_on          = [module.kds-raw.kinesis_data_stream_name]
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
    StreamName = module.kds-raw.kinesis_data_stream_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_sess_kpl_retries" {
  depends_on          = [module.kds-sess.kinesis_data_stream_name]
  alarm_name          = "${local.ns}-kds-agg-high-number-kpl-retries"
  alarm_description   = "High Number of Sess KPL Retries"
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
    StreamName = module.kds-sess.kinesis_data_stream_name
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
  depends_on          = [module.kda-agg.kda_app_name]
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
    Application = module.kda-agg.kda_app_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// numberOfFailedCheckpoints
resource "aws_cloudwatch_metric_alarm" "kda_failed_checkpoints_agg" {
  depends_on          = [module.kda-agg.kda_app_name]
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
    Application = module.kda-agg.kda_app_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// numRecordsOutPerSecond
resource "aws_cloudwatch_metric_alarm" "kda_records_out_per_sec_agg" {
  depends_on          = [module.kda-agg.kda_app_name]
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
    Application = module.kda-agg.kda_app_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// millisBehindLatest
resource "aws_cloudwatch_metric_alarm" "kda_millis_behind_latest_agg" {
  depends_on          = [module.kda-agg.kda_app_name]
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
    Application = module.kda-agg.kda_app_name
    Id          = "${local.nsunder}_kds_raw"
    Flow        = "Input"
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// lastCheckpointDuration
resource "aws_cloudwatch_metric_alarm" "kda_last_checkpoint_dur_agg" {
  depends_on          = [module.kda-agg.kda_app_name]
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
    Application = module.kda-agg.kda_app_name
  }

  actions_enabled           = "false"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// lastCheckpointSize
resource "aws_cloudwatch_metric_alarm" "kda_last_checkpoint_size_agg" {
  depends_on          = [module.kda-agg.kda_app_name]
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
    Application = module.kda-agg.kda_app_name
  }

  actions_enabled           = "false"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// heapMemoryUtilization
resource "aws_cloudwatch_metric_alarm" "kda_heap_memory_util_agg" {
  depends_on          = [module.kda-agg.kda_app_name]
  alarm_name          = "${local.ns}-kda-heap-memory-util-agg"
  alarm_description   = "Heap Memory Utilization for Aggregator Flink App is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "heapMemoryUtilization"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Maximum"
  threshold           = var.kda_heap_memory_util_agg_threshold
  tags                = var.tags
  dimensions = {
    Application = module.kda-agg.kda_app_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// cpuUtilization
resource "aws_cloudwatch_metric_alarm" "kda_cpu_util_agg" {
  depends_on          = [module.kda-agg.kda_app_name]
  alarm_name          = "${local.ns}-kda-cpu-util-agg"
  alarm_description   = "CPU Utilization for Aggregator Flink App is higher than expected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "cpuUtilization"
  namespace           = "AWS/KinesisAnalytics"
  period              = "300"
  statistic           = "Average"
  threshold           = var.kda_cpu_util_agg_threshold
  tags                = var.tags
  dimensions = {
    Application = module.kda-agg.kda_app_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// threadsCount
resource "aws_cloudwatch_metric_alarm" "kda_threads_count_agg" {
  depends_on          = [module.kda-agg.kda_app_name]
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
    Application = module.kda-agg.kda_app_name
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

// (oldGenerationGCTime * 100)/60 over 1 min period')
resource "aws_cloudwatch_metric_alarm" "kda_max_exp_gc_time_agg" {
  depends_on          = [module.kda-agg.kda_app_name]
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
        Application = module.kda-agg.kda_app_name
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
  depends_on          = [module.kda-agg.kda_app_name]
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
        Application = module.kda-agg.kda_app_name
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
  depends_on          = [module.kda-agg.kda_app_name]
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
        Application = module.kda-agg.kda_app_name
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
        Application = module.kda-agg.kda_app_name
      }
    }
  }

  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "kda_not_pushing_to_session_kds" {
  alarm_name          = "${local.ns}-kda-not-pushing-to-session-kds"
  alarm_description   = "Flink has not sent any records to KDS in the last 5 minutes.  Please verify the Flink Aggregator is running."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "KinesisRecordsDataPut"
  namespace           = "KinesisProducerLibrary"
  period              = "300"
  statistic           = "Average"
  threshold           = "10"
  tags                = var.tags
  dimensions = {
    StreamName = module.kds-sess.kinesis_data_stream_name
  }
  actions_enabled           = "true"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alert_topic.arn]
  ok_actions                = [aws_sns_topic.alert_topic.arn]
  treat_missing_data        = "notBreaching"
}
