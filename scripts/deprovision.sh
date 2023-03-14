#!/usr/bin/env bash

set -eux

S3_BUCKET="$1"

for instance_id_yml in $(aws s3 ls s3://$S3_BUCKET/4_FINISHED/ | awk '{print $NF}'); do
  echo $instance_id_yml
  aws s3 cp s3://$S3_BUCKET/4_FINISHED/$instance_id_yml .
  DATE=$(grep 'date:' $instance_id_yml); DATE=${DATE//*date: /};
  PROJECT_GIT_CHECKOUT=$(grep 'project_git_checkout:' $instance_id_yml); PROJECT_GIT_CHECKOUT=${PROJECT_GIT_CHECKOUT//*project_git_checkout: /};
  INSTANCE_ID=$(grep 'instance_id:' $instance_id_yml); INSTANCE_ID=${INSTANCE_ID//*instance_id: /};

  NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  DATEDIFF=$(( ($(date --date="$NOW" +%s) - $(date --date="$DATE" +%s) )/(60*60*24) ))

  if [ "$DATEDIFF" -gt 0 ]; then
    aws s3 cp s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/terraform.tfstate .
    aws s3 cp s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/vars.tfvars .

    terraform init
    terraform destroy -var-file vars.tfvars -no-color -input=false -auto-approve

    echo "date: $DATE" > 5_DEPROVISIONED.yml
    echo "project_git_checkout: $PROJECT_GIT_CHECKOUT" >> 5_DEPROVISIONED.yml
    echo "instance_id: $INSTANCE_ID" >> 5_DEPROVISIONED.yml
    
    aws s3 cp 5_DEPROVISIONED.yml s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/$INSTANCE_ID/status/
    aws s3 cp 5_DEPROVISIONED.yml s3://$S3_BUCKET/project_git_checkout/$PROJECT_GIT_CHECKOUT/latest/status/
    aws s3 rm s3://$S3_BUCKET/4_FINISHED/$INSTANCE_ID
  fi
done;

