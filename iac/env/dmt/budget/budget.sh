#! /bin/bash
set -e

# push image to ECR repo
export AWS_PROFILE=<aws profile>
export AWS_DEFAULT_REGION=us-east-1

# aws budgets delete-budget \
#     --account-id <account number> \
#     --budget-name "Monthly Budget"

aws budgets create-budget \
    --account-id <account number> \
    --budget file://budget.json \
    --notifications-with-subscribers file://subscribers.json