/**
 * main.tf
 * The main entry point for Terraform run
 * See variables.tf for common variables
 * See ecr.tf for creation of Elastic Container Registry for all environments
 * See state.tf for creation of S3 bucket for remote state
 */

/*
 * Outputs
 * Results from a successful Terraform run (terraform apply)
 * To see results after a successful run, use `terraform output [name]`
 */
output "ecr_repo_east" {
  value = module.us_east_1.docker_registry
}

output "ecr_repo_west" {
  value = module.us_west_2.docker_registry
}

# Returns the name of the S3 bucket that will be used in later Terraform files
output "bucket" {
  value = module.tf_remote_state.bucket
}
