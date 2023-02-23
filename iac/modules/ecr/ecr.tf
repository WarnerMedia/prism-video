/*
 * ecr.tf
 * Creates a Amazon Elastic Container Registry (ECR) for the application
 * https://aws.amazon.com/ecr/
 */

resource "aws_ecr_repository" "app" {
  name                 = var.app
  image_tag_mutability = var.image_tag_mutability
}

# Returns the name of the ECR registry, this will be used later in various scripts
output "docker_registry" {
  value = aws_ecr_repository.app.repository_url
}
