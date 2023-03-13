#!/usr/bin/env bash

set -eux

S3_BUCKET="$1"
PROJECT_GIT_CHECKOUT="$2"
INSTANCE_ID="$3"

DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "date: $DATE" > 1_PROVISIONED.yml
echo "project_git_checkout: $PROJECT_GIT_CHECKOUT" >> 1_PROVISIONED.yml
echo "instance_id: $INSTANCE_ID" >> 1_PROVISIONED.yml

aws s3 cp 1_PROVISIONED.yml s3://$S3_BUCKET/$PROJECT_GIT_CHECKOUT/$INSTANCE_ID/status/
aws s3 cp 1_PROVISIONED.yml s3://$S3_BUCKET/$PROJECT_GIT_CHECKOUT/latest/status/
aws s3 cp terraform.tfstate s3://$S3_BUCKET/$PROJECT_GIT_CHECKOUT/
aws s3 cp vars.tfvars s3://$S3_BUCKET/$PROJECT_GIT_CHECKOUT/