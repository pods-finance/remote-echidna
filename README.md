# remote-echidna

Run echidna on AWS with Terraform

## Description

This project creates the following infrastructure on AWS:

- [Security Group](./terraform/security_group.tf) with SSH access from anywhere, to allow for an easier debugging
- [S3 bucket](./terraform/s3_bucket.tf) with private access to store and load echidna's output between runs
- [IAM Policy](./terraform/iam_user.tf) with access to the S3 bucket
- [IAM User](./terraform/iam_user.tf) with the created IAM Policy
- [EC2 Instance](./terraform/ec2_instance.tf) that runs echidna on the desired git project and uses the IAM User credentials to upload results to S3

## Setup

#### 1. Create a `tfvars` file

Include the parameters required by [vars.tf](./terraform/vars.tf)

```
# vars.tfvars

ec2_instance_key_name = "key.pem"
project               = "echidna-project"
project_git_url       = "https://github.com/aviggiano/echidna-project.git"
project_git_checkout  = "main"
run_tests_cmd         = "yarn && echidna-test test/Contract.sol --contract Contract --config test/config.yaml"
```

### 2. Run terraform

```
terraform apply -var-file vars.tfvars
```

## Next steps

- [ ] Create AMI with all required software instead of [installing everything](./terraform/user_data.tftpl) at each time (would speed up about 1min)
