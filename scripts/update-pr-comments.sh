#!/usr/bin/env bash

set -ux

S3_BUCKET="$1"

function get_pr_number() {
  status=$1
  for instance_id_yml in $(aws s3 ls s3://$S3_BUCKET/$status/ | awk '{print $NF}'); do
    echo $instance_id_yml
    aws s3 cp s3://$S3_BUCKET/$status/$instance_id_yml .
    DATE=$(grep 'date:' $instance_id_yml); DATE=${DATE//*date: /}; 
    INSTANCE_ID=$(grep 'instance_id:' $instance_id_yml); INSTANCE_ID=${INSTANCE_ID//*instance_id: /}; 
    PR_NUMBER=$(grep 'pr_number:' $instance_id_yml); PR_NUMBER=${PR_NUMBER//*pr_number: /}; 

    aws s3 rm s3://$S3_BUCKET/$status/$INSTANCE_ID
    echo $PR_NUMBER
    break;
  done;
}

PR_NUMBER_2_STARTED="$(get_pr_number 2_STARTED)"
echo "PR_NUMBER_2_STARTED=$PR_NUMBER_2_STARTED" >> $GITHUB_ENV

PR_NUMBER_3_RUNNING="$(get_pr_number 3_RUNNING)"
echo "PR_NUMBER_3_RUNNING=$PR_NUMBER_3_RUNNING" >> $GITHUB_ENV

PR_NUMBER_4_FINISHED="$(get_pr_number 4_FINISHED)"
echo "PR_NUMBER_4_FINISHED=$PR_NUMBER_4_FINISHED" >> $GITHUB_ENV