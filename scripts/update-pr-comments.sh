#!/usr/bin/env bash

set -ux

S3_BUCKET="$1"

function get_pr_number() {
  status=$1
  for instance_id_yml in $(aws s3 ls s3://$S3_BUCKET/$status/ | awk '{print $NF}'); do
    aws s3 cp s3://$S3_BUCKET/$status/$instance_id_yml .
    cat $instance_id_yml
    DATE=$(grep 'date:' $instance_id_yml); DATE=${DATE//*date: /}; 
    PROJECT_GIT_CHECKOUT=$(grep 'project_git_checkout:' $instance_id_yml); PROJECT_GIT_CHECKOUT=${PROJECT_GIT_CHECKOUT//*project_git_checkout: /};
    INSTANCE_ID=$(grep 'instance_id:' $instance_id_yml); INSTANCE_ID=${INSTANCE_ID//*instance_id: /}; 
    PR_NUMBER=$(grep 'pr_number:' $instance_id_yml); PR_NUMBER=${PR_NUMBER//*pr_number: /}; 

    if [ "$status" == "4_FINISHED" ]; then
      aws s3 cp s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/$INSTANCE_ID/logs.txt .
    fi

    aws s3 rm s3://$S3_BUCKET/$status/$INSTANCE_ID
    echo "$PR_NUMBER" > PR_NUMBER
    break;
  done;
}

get_pr_number 2_STARTED
PR_NUMBER_2_STARTED=$(cat PR_NUMBER)
echo "PR_NUMBER_2_STARTED=${PR_NUMBER_2_STARTED}" >> $GITHUB_OUTPUT

get_pr_number 3_RUNNING
PR_NUMBER_3_RUNNING=$(cat PR_NUMBER)
echo "PR_NUMBER_3_RUNNING=${PR_NUMBER_3_RUNNING}" >> $GITHUB_OUTPUT

get_pr_number 4_FINISHED
PR_NUMBER_4_FINISHED=$(cat PR_NUMBER)
echo "PR_NUMBER_4_FINISHED=${PR_NUMBER_4_FINISHED}" >> $GITHUB_OUTPUT

echo "ECHIDNA_LOGS=$(cat logs.txt)" >> $GITHUB_OUTPUT