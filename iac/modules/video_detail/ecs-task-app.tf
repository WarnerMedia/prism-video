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


resource "aws_appautoscaling_target" "scale_target_app" {
  depends_on         = [aws_ecs_service.app]
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.app.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances_app
  min_capacity       = var.ecs_autoscale_min_instances_app
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high_app" {
  depends_on          = [aws_ecs_service.app]
  alarm_name          = "${local.ns}-CPU-Utilization-High-${var.ecs_as_cpu_high_threshold_per}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_high_threshold_per

  dimensions = {
    ClusterName = local.ns
    ServiceName = "${local.ns}-app"
  }

  alarm_actions = [aws_appautoscaling_policy.up_app.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low_app" {
  depends_on          = [aws_ecs_service.app]
  alarm_name          = "${local.ns}-CPU-Utilization-Low-${var.ecs_as_cpu_low_threshold_per}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_low_threshold_per

  dimensions = {
    ClusterName = local.ns
    ServiceName = "${local.ns}-app"
  }

  alarm_actions = [aws_appautoscaling_policy.down_app.arn]
}

resource "aws_appautoscaling_policy" "up_app" {
  depends_on         = [aws_ecs_service.app]
  name               = "${local.ns}-scale-up-app"
  service_namespace  = aws_appautoscaling_target.scale_target_app.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target_app.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target_app.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.num_of_containers_to_add_during_scaling
    }
  }
}

resource "aws_appautoscaling_policy" "down_app" {
  depends_on         = [aws_ecs_service.app]
  name               = "${local.ns}-scale-down-app"
  service_namespace  = aws_appautoscaling_target.scale_target_app.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target_app.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target_app.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.num_of_containers_to_remove_during_scaledown
    }
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.ns}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  # defined in role.tf
  task_role_arn = aws_iam_role.app_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.container_name_app}",
    "image": "${var.default_backend_image}",
    "essential": true,
    "dependsOn": [
      {
        "containerName": "kpl",
        "condition": "START"
      }
    ],    
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${var.container_port_app},
        "hostPort": ${var.container_port_app}
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "${var.container_port_app}"
      },
      {
        "name": "HEALTHCHECK",
        "value": "${var.health_check_app}"
      },
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
        "value": "${var.app}"
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
        "name": "SOCKET_SERVER_PORT",
        "value": "3000"
      },
      {
        "name": "ERROR_SOCKET_PORT",
        "value": "3001"
      },
      {
        "name": "DLQ_URL",
        "value": "${aws_sqs_queue.dlq.id}"
      },
      {
        "name": "AWS_REGION",
        "value": "${var.region}"
      },
      {
        "name": "PAYLOAD_DISPLAY_ON_ERROR",
        "value": "${var.payload_display_on_error}"
      },
      {
        "name": "PAYLOAD_LIMIT",
        "value": "${var.payload_limit}"
      },
      {
        "name": "ENABLE_ENCRYPTION",
        "value": "${var.enable_encryption}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}-app",
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
    "name": "kpl",
    "image": "public.ecr.aws/v6s5y4v7/kplserver:v0.2.25",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "environment": ${jsonencode(var.ecs_task_kpl_env)},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}-app",
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
        "valueFrom": "${aws_ssm_parameter.cw_agent.name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}-app",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }  
]
DEFINITION

  tags = var.tags
}

resource "aws_ecs_service" "app" {
  name            = "${local.ns}-app"
  cluster         = aws_ecs_cluster.app.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.ecs_autoscale_min_instances_app

  network_configuration {
    security_groups = [aws_security_group.nsg_task_app.id]
    subnets         = split(",", var.private_subnets)
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = var.container_name_app
    container_port   = var.container_port_app
  }

  tags                    = var.tags
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  # workaround for https://github.com/hashicorp/terraform/issues/12634
  depends_on = [aws_alb_listener.http_app]

  # [after initial apply] don't override changes made to task_definition
  # from outside of terraform (i.e.; fargate cli)
  lifecycle {
    ignore_changes = [task_definition]
  }
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${local.ns}-ecs"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "cw_agent_server_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_readonly_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${local.ns}-app"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure statsd"
  name        = local.ns
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

