#!/usr/bin/env bash

set -eux

S3_BUCKET="$1"
PROJECT_GIT_CHECKOUT="$2"
URL="$3"
GITHUB_TOKEN="$4"

aws s3 cp s3://$S3_BUCKET/$PROJECT_GIT_CHECKOUT/terraform.tfstate . || true
curl \
  -X POST \
  $URL \
  -H "Content-Type: application/json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  --data '{ "body": "remote-echidna: download terraform state" }'