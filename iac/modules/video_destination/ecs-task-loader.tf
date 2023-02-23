/**
 * Elastic Container Service (ecs)
 * This component is required to create the Fargate ECS service. It will create a Fargate cluster
 * based on the application name and enironment. It will create a "Task Definition", which is required
 * to run a Docker container, https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html.
 * Next it creates a ECS Service, https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html
 * It attaches the Load Balancer created in `lb.tf` to the service, and sets up the networking required.
 * It also creates a role with the correct permissions. And lastly, ensures that logs are captured in CloudWatch.
 *
 * When building for the first time, it will install a "default backend", which is a simple web service that just
 * responds with a HTTP 200 OK. It's important to uncomment the lines noted below after you have successfully
 * migrated the real application containers to the task definition.
 */

variable "default_backend_image" {
  default = "ghcr.io/warnermedia/fargate-default-backend:latest"
}

resource "aws_appautoscaling_target" "scale_target_loader" {
  depends_on         = [aws_ecs_service.loader]
  service_namespace  = "ecs"
  resource_id        = "service/${module.video_destination_detail.ecs_cluster_name}/${aws_ecs_service.loader.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances_loader
  min_capacity       = var.ecs_autoscale_min_instances_loader
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high_loader" {
  depends_on          = [aws_ecs_service.loader]
  alarm_name          = "${local.ns}-CPU-Utilization-High-${var.ecs_as_cpu_high_threshold_per}-loader"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_high_threshold_per

  dimensions = {
    ClusterName = local.ns
    ServiceName = "${local.ns}-loader"
  }

  alarm_actions = [aws_appautoscaling_policy.up_loader.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low_loader" {
  depends_on          = [aws_ecs_service.loader]
  alarm_name          = "${local.ns}-CPU-Utilization-Low-${var.ecs_as_cpu_low_threshold_per}-loader"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_low_threshold_per

  dimensions = {
    ClusterName = local.ns
    ServiceName = "${local.ns}-loader"
  }

  alarm_actions = [aws_appautoscaling_policy.down_loader.arn]
}

resource "aws_appautoscaling_policy" "up_loader" {
  depends_on         = [aws_ecs_service.loader]
  name               = "${local.ns}-scale-up-loader"
  service_namespace  = aws_appautoscaling_target.scale_target_loader.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target_loader.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target_loader.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "down_loader" {
  depends_on         = [aws_ecs_service.loader]
  name               = "${local.ns}-scale-down-loader"
  service_namespace  = aws_appautoscaling_target.scale_target_loader.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target_loader.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target_loader.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_ecs_task_definition" "loader" {
  family                   = "${local.ns}-loader"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = module.video_destination_detail.ecsTaskExecutionRoleARN

  # defined in role.tf
  task_role_arn = aws_iam_role.loader_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.container_name_loader}",
    "image": "${var.default_backend_image}",
    "essential": true,
    "dependsOn": [
      {
        "containerName": "kpl-dmt",
        "condition": "START"
      },
      {
        "containerName": "kpl-slpd",
        "condition": "START"
      }
    ],    
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${var.container_port_loader},
        "hostPort": ${var.container_port_loader}
      }
    ],
    "environment": [
      {
        "name": "ENABLE_LOGGING",
        "value": "true"
      },
      {
        "name": "LOG_LEVEL",
        "value": "${var.log_level}"
      },
      {
        "name": "PRODUCT",
        "value": "${local.ns}-loader"
      },
      {
        "name": "ENVIRONMENT",
        "value": "${var.environment}" 
      },
      {
        "name": "METRIC_PREFIX",
        "value": "${local.ns}"
      },
      {
        "name": "SOCKET_SERVER_PORT_DMT",
        "value": "3000"
      },
      {
        "name": "ERROR_SOCKET_PORT_DMT",
        "value": "3001"
      },
      {
        "name": "SOCKET_SERVER_PORT_SLPD",
        "value": "3010"
      },
      {
        "name": "ERROR_SOCKET_PORT_SLPD",
        "value": "3011"
      },
      {
        "name": "SQS_ENDPOINT",
        "value": "${aws_sqs_queue.outbound.id}"
      },
      {
        "name": "DLQ_URL",
        "value": "${aws_sqs_queue.loader-dlq.id}"
      },
      {
        "name": "MAX_SQS_MESSAGES",
        "value": "10"
      },
      {
        "name": "LONG_POLL_TIMEOUT",
        "value": "20"
      },
      {
        "name": "AWS_REGION",
        "value": "${var.region}"
      },
      {
        "name": "ENABLE_ENCRYPTION",
        "value": "${var.enable_encryption}"
      },
      {
        "name": "TEST_WITHOUT_KPL",
        "value": "${var.test_without_kpl}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}-loader",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 1024000,
        "hardLimit": 1024000
      }
    ]
  },
  {
    "name": "kpl-dmt",
    "image": "public.ecr.aws/v6s5y4v7/kplserver:v0.2.27",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "environment": ${jsonencode(var.ecs_task_kpl_dmt_env)},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}-loader",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 1024000,
        "hardLimit": 1024000
      }
    ]
  },
  {
    "name": "kpl-slpd",
    "image": "public.ecr.aws/v6s5y4v7/kplserver:v0.2.27",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 3010,
        "hostPort": 3010
      }
    ],
    "environment": ${jsonencode(var.ecs_task_kpl_slpd_env)},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}-loader",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 1024000,
        "hardLimit": 1024000
      }
    ]
  },
  {
    "name": "cloudwatch-agent",
    "image": "public.ecr.aws/cloudwatch-agent/cloudwatch-agent:latest",
    "essential": false,
    "secrets": [
      {
        "name": "CW_CONFIG_CONTENT",
        "valueFrom": "${aws_ssm_parameter.cw_agent_loader.name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}-loader",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }  
]
DEFINITION

  tags = var.tags
}

resource "aws_ecs_service" "loader" {
  name            = "${local.ns}-loader"
  cluster         = module.video_destination_detail.ecs_cluster_name
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.loader.arn
  desired_count   = var.ecs_autoscale_min_instances_loader
  network_configuration {
    security_groups = [aws_security_group.nsg_task_loader.id]
    subnets         = split(",", var.private_subnets)
  }

  tags                    = var.tags
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"


  # [after initial apply] don't override changes made to task_definition
  # from outside of terraform (i.e.; fargate cli)
  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_cloudwatch_log_group" "logs_loader" {
  name              = "/fargate/service/${local.ns}-loader"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy_loader" {
  role       = module.video_destination_detail.ecsTaskExecutionRoleName
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "cw_agent_server_policy_loader" {
  role       = module.video_destination_detail.ecsTaskExecutionRoleName
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_readonly_policy_loader" {
  role       = module.video_destination_detail.ecsTaskExecutionRoleName
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_ssm_parameter" "cw_agent_loader" {
  description = "Cloudwatch agent config to configure statsd"
  name        = "${local.ns}-loader"
  type        = "String"
  tags        = var.tags
  value       = <<EOF
{
  "metrics" : {
    "metrics_collected" : {
      "statsd" : {
        "service_address" : ":8125"
      }
    }
  }
}
EOF
}

