# remote-echidna

Run echidna on AWS with Terraform

## Description

This project creates a virtual machine, together with other required AWS resources, for each echidna job. The instance starts up, install all required components, runs the fuzz tests, and automatically shuts itself down afterwards.

## Setup

### Manual steps:

1. Create a [S3 bucket](./terraform/s3_bucket.tf) with private access to store and load echidna's output between runs
2. Create a [private key](./terraform/ec2_instance.tf) used to connect to the remote instance if needed

### Automated steps:

This project creates the following infrastructure on AWS:

- [Security Group](./terraform/security_group.tf) with SSH access from anywhere, to allow for an easier debugging
- [IAM Policy](./terraform/iam_user.tf) with access to the S3 bucket
- [IAM User](./terraform/iam_user.tf) with the created IAM Policy
- [EC2 Instance](./terraform/ec2_instance.tf) that runs echidna on the desired git project and uses the IAM User credentials to upload results to S3

## Usage with GitHub Actions

Create a GitHub Action on your CI that reuses remote-echidna's [workflow](./.github/workflows/remote-echidna.yml). See a [sample project](https://github.com/aviggiano/remote-echidna-demo) here

```
name: Push

on:
  pull_request:
    types: [opened, synchronize]
  push:
    branches:
      - main

jobs:
  remote-echidna:
    name: Run remote-echidna
    uses: aviggiano/remote-echidna/.github/workflows/remote-echidna.yml@v1
    with:
      project: "remote-echidna-demo"
      project_git_url: "https://github.com/${{github.repository}}.git"
      project_git_checkout: ${{ github.head_ref || github.ref_name }}
      run_tests_cmd: "echidna-test contracts/Contract.sol --contract Contract --config config.yaml || true"
    secrets:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_REGION: ${{ secrets.AWS_REGION }}
      REMOTE_ECHIDNA_S3_BUCKET: ${{ secrets.REMOTE_ECHIDNA_S3_BUCKET }}
      REMOTE_ECHIDNA_EC2_INSTANCE_KEY_NAME: ${{ secrets.REMOTE_ECHIDNA_EC2_INSTANCE_KEY_NAME }}
```

3. Configure the required input parameters below

### Inputs

| Parameter                              | Description                                                                  | Example                                                                                  | Required |
| -------------------------------------- | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- | -------- |
| `project`                              | Your project name                                                            | `remote-echidna-demo`                                                                    | Yes      |
| `project_git_url`                      | Project Git URL                                                              | `https://github.com/aviggiano/remote-echidna-demo.git`                                   | Yes      |
| `project_git_checkout`                 | Project Git checkout (branch or commit hash)                                 | `main`                                                                                   | Yes      |
| `run_tests_cmd`                        | Command to run echidna tests                                                 | `echidna-test contracts/Contract.sol --contract Contract --config config.yaml \|\| true` | Yes      |
| `REMOTE_ECHIDNA_S3_BUCKET`             | S3 Bucket name to store and load echidna's output between runs               | `remote-echidna-demo-bucket`                                                             | Yes      |
| `REMOTE_ECHIDNA_EC2_INSTANCE_KEY_NAME` | EC2 instance key name. Needs to be manually created first on the AWS console | `key.pem`                                                                                | Yes      |

## Output

The job status is stored on a S3 bucket, alongside echidna's output:

1. Provisioned
2. Started
3. Running
4. Finished
5. Deprovisioned

Some of these states are managed from within the instance (2 -> 3 -> 4), while others are managed through Github actions (1 -> 2, 4 -> 5).

In order to visualize echidna's output, the easiest way is to download the logs from S3:

```
aws s3 cp s3://$REMOTE_ECHIDNA_S3_BUCKET/${project_git_checkout}/latest/cloud-init-output.log .
```

## Next steps

- [ ] Create a better way to visualize echidna output
- [ ] Create a better way to monitor echidna ETA (depends on [crytic/echidna#975](https://github.com/crytic/echidna/issues/975))
- [ ] Create AMI with all required software instead of [installing everything](./terraform/user_data.tftpl) at each time (would speed up about 1min)
