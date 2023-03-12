#!/usr/bin/env bash

set -eux

S3_BUCKET="$1"
PROJECT_GIT_CHECKOUT="$2"
INSTANCE_ID="$3"

DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "date: $DATE" > 5_DEPROVISIONED.yml
aws s3 cp 5_DEPROVISIONED.yml s3://$S3_BUCKET/$PROJECT_GIT_CHECKOUT/$INSTANCE_ID/status/
aws s3 cp 5_DEPROVISIONED.yml s3://$S3_BUCKET/$PROJECT_GIT_CHECKOUT/latest/status/
aws s3 cp s3://$S3_BUCKET/$PROJECT_GIT_CHECKOUT/terraform.tfstate .