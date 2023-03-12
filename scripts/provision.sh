#!/usr/bin/env bash

set -eux

S3_BUCKET="$1"
PROJECT_GIT_CHECKOUT="$2"

aws s3 cp s3://$S3_BUCKET/$PROJECT_GIT_CHECKOUT/terraform.tfstate .