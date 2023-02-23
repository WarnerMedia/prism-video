# app/env to scaffold
# common variables in all environments
app         = "doppler-video"
aws_profile = ""
internal    = false
kpl_port    = 3000
log_level   = "WARN"
saml_role   = ""

s3_bucket_to_read_from = "doppler-video-prd-raw-useast1"

tags = {
  application   = "doppler-video"
  customer      = "video-qos"
  contact-email = ""
  environment   = "ltpd"
  team          = "video-qos"
}

common_environment = "ltpd"
destination_region = "us-east-1"

# variables that differ in each environment
# us-east-1
environment_us_east_1     = "ltpduseast1"
region_us_east_1          = "us-east-1"
vpc_us_east_1             = "<vpc id in useast1>"
private_subnets_us_east_1 = "<private subnets within vpc in useast1>"
public_subnets_us_east_1  = "<public subnets within vpc in useast1>"
ecs_task_kpl_east_env = [
  {
    "name" : "KINESIS_STREAM",
    "value" : "<data stream name in account you want the data sent to>"
    }, {
    "name" : "PORT",
    "value" : "3000"
    }, {
    "name" : "ERROR_SOCKET_PORT",
    "value" : "3001"
    }, {
    "name" : "CROSS_ACCOUNT_ROLE",
    "value" : "<arn of the cross account role that allows us to send this data to another kinesis data stream>"
    }, {
    "name" : "AWS_DEFAULT_REGION",
    "value" : "us-east-1"
}]
