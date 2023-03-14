#!/usr/bin/env bash

set -eux

S3_BUCKET="$1"
PROJECT_GIT_CHECKOUT="$2"
PR_NUMBER="${3:-undefined}"

aws s3 cp s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/$PR_NUMBER/terraform.tfstate . || true
aws s3 cp s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/$PR_NUMBER/vars.tfvars . || true