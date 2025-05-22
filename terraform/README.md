# Terraform Deployment for JPSS-2 Ground Station

This directory contains Terraform configurations to deploy the AWS Ground Station mission profile for the JPSS-2 satellite.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or newer)
- AWS CLI configured with appropriate credentials
- AWS Ground Station access and JPSS-2 satellite whitelisted for your account

## Files

- `main.tf` - Main Terraform configuration file containing all resource definitions
- `variables.tf` - Variable definitions with default values
- `outputs.tf` - Output values that will be displayed after deployment
- `versions.tf` - Terraform and provider version constraints

## Usage

### Initialize Terraform

```bash
terraform init
```

### Plan the Deployment

```bash
terraform plan -out=tfplan
```

### Apply the Configuration

```bash
terraform apply tfplan
```

### Customize Deployment

You can customize the deployment by overriding the default variable values:

```bash
terraform apply -var="bucket_name=my-custom-jpss2-bucket" -var="aws_region=us-east-1"
```

Alternatively, create a `terraform.tfvars` file:

```hcl
bucket_name = "my-custom-jpss2-bucket"
aws_region  = "us-east-1"
```

### Destroy Resources

When you no longer need the resources:

```bash
terraform destroy
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| aws_region | AWS region for Ground Station resources | us-west-2 |
| bucket_name | Name of the S3 bucket to store satellite data | jpss2-satellite-data |
| dataflow_endpoint_group_name | Name of the dataflow endpoint group | jpss2-dataflow-endpoint-group |
| mission_profile_name | Name of the mission profile | jpss2-mission-profile |
| contact_profile_name | Name of the contact profile | jpss2-contact-profile |
| tracking_config_name | Name of the tracking configuration | jpss2-tracking-config |
| tags | Common tags for all resources | Project = "JPSS-2", Environment = "Production", Managed_By = "Terraform" |

## Outputs

| Name | Description |
|------|-------------|
| mission_profile_arn | ARN of the created mission profile |
| dataflow_endpoint_group_arn | ARN of the created dataflow endpoint group |
| s3_bucket_name | Name of the S3 bucket for satellite data |
| s3_bucket_arn | ARN of the S3 bucket for satellite data |
