resource "local_file" "fargate_yml" {
  filename = "${local.ns}/fargate.yml"
  content = yamlencode({
    cluster = aws_ecs_cluster.app.name
    service = aws_ecs_service.app.name
  })
}
