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


resource "aws_appautoscaling_target" "scale_target_reader" {
  depends_on         = [aws_ecs_service.reader]
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.util.name}/${aws_ecs_service.reader.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances_reader
  min_capacity       = var.ecs_autoscale_min_instances_reader
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high_reader" {
  depends_on          = [aws_ecs_service.reader]
  alarm_name          = "${local.ns}-CPU-Utilization-High-${var.ecs_as_cpu_high_threshold_per}-reader"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_high_threshold_per

  dimensions = {
    ClusterName = local.ns
    ServiceName = "${local.ns}-reader"
  }

  alarm_actions = [aws_appautoscaling_policy.up_reader.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low_reader" {
  depends_on          = [aws_ecs_service.reader]
  alarm_name          = "${local.ns}-CPU-Utilization-Low-${var.ecs_as_cpu_low_threshold_per}-reader"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_low_threshold_per

  dimensions = {
    ClusterName = local.ns
    ServiceName = "${local.ns}-reader"
  }

  alarm_actions = [aws_appautoscaling_policy.down_reader.arn]
}

resource "aws_appautoscaling_policy" "up_reader" {
  depends_on         = [aws_ecs_service.reader]
  name               = "${local.ns}-scale-up-reader"
  service_namespace  = aws_appautoscaling_target.scale_target_reader.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target_reader.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target_reader.scalable_dimension

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

resource "aws_appautoscaling_policy" "down_reader" {
  depends_on         = [aws_ecs_service.reader]
  name               = "${local.ns}-scale-down-reader"
  service_namespace  = aws_appautoscaling_target.scale_target_reader.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target_reader.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target_reader.scalable_dimension

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

resource "aws_ecs_task_definition" "reader" {
  family                   = "${local.ns}-reader"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  # defined in role.tf
  task_role_arn = aws_iam_role.reader_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.container_name_reader}",
    "image": "${var.default_backend_image}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${var.container_port_reader},
        "hostPort": ${var.container_port_reader}
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
        "value": "${local.ns}-reader"
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
        "name": "SQS_ENDPOINT",
        "value": "${aws_sqs_queue.util.id}"
      },
      {
        "name": "SQS_JOB_ENDPOINT",
        "value": "${aws_sqs_queue.job.id}"
      },
      {
        "name": "S3_BUCKET",
        "value": "${var.s3_bucket_to_read_from}"
      },
      {
        "name": "AWS_REGION",
        "value": "${var.region}"
      } 
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}-reader",
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
        "valueFrom": "${aws_ssm_parameter.cw_agent_reader.name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${local.ns}-reader",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }  
]
DEFINITION

  tags = var.tags
}

resource "aws_ecs_service" "reader" {
  name            = "${local.ns}-reader"
  cluster         = aws_ecs_cluster.util.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.reader.arn
  desired_count   = var.ecs_autoscale_min_instances_reader
  network_configuration {
    security_groups = [aws_security_group.nsg_task_reader.id]
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

resource "aws_cloudwatch_log_group" "logs_reader" {
  name              = "/fargate/service/${local.ns}-reader"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy_reader" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "cw_agent_server_policy_reader" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_readonly_policy_reader" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_ssm_parameter" "cw_agent_reader" {
  description = "Cloudwatch agent config to configure statsd"
  name        = "${local.ns}-reader"
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

