# Doppler Video Telemetry

### code

- The source code broken out by resource: fargate, kda, and lambda

### iac

- The infrastructure as code to create the resources

## Setup

This project assumes some prerequisites: provisioning of public and private VPCs/subnets is left to you,
and a registered domain name is required for exposing Doppler to the internet.

1. **Placeholders**

- The Doppler IAC (Infrastructure as Code) has been templated with the following placeholders:

  - `AWS_ACCOUNT`
  - `APP_NAME`
  - `DOMAIN_NAME`

- These values must be populated before proceeding. One method for doing so may be to simply recursively search and replace the doppler repo for these placeholders (e.g. `s/${AWS_ACCOUNT}/123456789/g`).

2. **Base Terraform**

- Navigate to `iac/base/`
- Populate `terraform.tfvars` with your application's config.
- Run `terraform init` and `terraform apply`
- Make note of the name of the generate S3 bucket.

3. **Create Doppler Environment(s)**

- Navigate to `iac/env/dev/`
- Populate `terraform.tfvars` with your application's config. The ARNs of your VPCs, private and public subnets, and your root domain name are needed at this stage.
- Run `terraform init` and `terraform apply`. This will provision an east and west region for the prod environment of Doppler.
- Make note of the ARNs for the us-east and us-west load balancers.
- Copy/paste the `prod/` directory and repeat the above steps for additional environments (e.g. dev, test, etc.) as desired.

## Authors

@smithatlanta - https://github.com/smithatlanta  
@vgiacomini - https://github.com/vgiacomini  
@juhu-wm - https://github.com/juhu-wm  
@KishonHamiltonTurner - https://github.com/KishonHamiltonTurner  
@verlin-turner - https://github.com/verlin-turner

# License

This repository is released under [the MIT license](https://en.wikipedia.org/wiki/MIT_License).
