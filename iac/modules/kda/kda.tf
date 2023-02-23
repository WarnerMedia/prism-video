resource "aws_cloudwatch_log_group" "kda" {
  name              = "/kda/service/${var.name}"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_cloudwatch_log_stream" "kda" {
  name           = var.name
  log_group_name = aws_cloudwatch_log_group.kda.name
}
resource "aws_kinesisanalyticsv2_application" "kda" {
  name                   = var.name
  runtime_environment    = "FLINK-1_13"
  service_execution_role = aws_iam_role.kda_role.arn

  cloudwatch_logging_options {
    log_stream_arn = aws_cloudwatch_log_stream.kda.arn
  }

  application_configuration {
    vpc_configuration {
      security_group_ids = [aws_security_group.nsg_kda.id]
      subnet_ids         = split(",", var.private_subnets)
    }

    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = var.s3_kda_arn
          file_key   = var.s3_object_key
        }
      }

      code_content_type = "ZIPFILE"
    }

    environment_properties {
      property_group {
        property_group_id = "FlinkApplicationProperties"

        property_map = var.environment_properties
      }
    }

    flink_application_configuration {
      checkpoint_configuration {
        configuration_type = "DEFAULT"
      }

      monitoring_configuration {
        configuration_type = "CUSTOM"
        log_level          = var.log_level
        metrics_level      = "APPLICATION"
      }

      parallelism_configuration {
        auto_scaling_enabled = true
        configuration_type   = "CUSTOM"
        parallelism          = var.kda_parallelism
        parallelism_per_kpu  = var.kda_parallelism_per_kpu
      }
    }
  }

  lifecycle {
    ignore_changes = [
      application_configuration
    ]
  }

  tags = var.tags
}

output "kda_app_name" {
  value = aws_kinesisanalyticsv2_application.kda.name
}

output "kda_app_arn" {
  value = aws_kinesisanalyticsv2_application.kda.arn
}


