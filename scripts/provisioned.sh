#!/usr/bin/env bash

set -eux

S3_BUCKET="$1"
PROJECT_GIT_CHECKOUT="$2"
INSTANCE_ID="$3"
PR_NUMBER="$4"

DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "date: $DATE" > 1_PROVISIONED.yml
echo "project_git_checkout: $PROJECT_GIT_CHECKOUT" >> 1_PROVISIONED.yml
echo "instance_id: $INSTANCE_ID" >> 1_PROVISIONED.yml
echo "pr_number: $PR_NUMBER" >> 1_PROVISIONED.yml

aws s3 cp 1_PROVISIONED.yml s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/$INSTANCE_ID/status/
aws s3 cp 1_PROVISIONED.yml s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/latest/status/
aws s3 cp 1_PROVISIONED.yml s3://$S3_BUCKET/1_PROVISIONED/$INSTANCE_ID
aws s3 cp terraform.tfstate s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/$PR_NUMBER/
aws s3 cp vars.tfvars s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/$PR_NUMBER/