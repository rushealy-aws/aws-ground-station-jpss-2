# Deployment Guide for JPSS-2 Ground Station Mission Profile

This guide provides detailed instructions for deploying and configuring the AWS Ground Station mission profile for the JPSS-2 satellite.

## Prerequisites

Before deploying this solution, ensure you have:

1. An AWS account with AWS Ground Station access
2. AWS CLI installed and configured with appropriate credentials
3. Permission to create the following resources:
   - CloudFormation stacks
   - IAM roles and policies
   - S3 buckets
   - AWS Ground Station resources (configs, mission profiles, dataflow endpoint groups)
4. Completed AWS Ground Station onboarding process
5. JPSS-2 satellite whitelisted for your AWS account

## Step-by-Step Deployment

### 1. Prepare Your Environment

Ensure your AWS CLI is configured for the us-west-2 region:

```bash
aws configure set region us-west-2
```

### 2. Customize Parameters (Optional)

Edit the CloudFormation template parameters in `templates/mission-profile.yaml` if you need to customize:

- S3 bucket name
- Resource naming conventions
- Contact pre/post pass durations
- Minimum viable contact duration

### 3. Deploy the CloudFormation Stack

```bash
aws cloudformation deploy \
  --template-file templates/mission-profile.yaml \
  --stack-name jpss2-ground-station \
  --parameter-overrides \
    BucketName=your-jpss2-data-bucket-name \
    MissionProfileName=jpss2-mission-profile \
  --capabilities CAPABILITY_IAM \
  --region us-west-2
```

### 4. Verify Resource Creation

After deployment completes, verify that all resources were created successfully:

```bash
aws cloudformation describe-stacks \
  --stack-name jpss2-ground-station \
  --query "Stacks[0].Outputs" \
  --region us-west-2
```

Verify the S3 bucket creation:

```bash
aws s3 ls s3://your-jpss2-data-bucket-name/
```

Verify the mission profile creation:

```bash
aws groundstation list-mission-profiles --region us-west-2
```

### 5. Configure AWS Ground Station Console (Optional)

For a more visual approach:

1. Open the AWS Management Console
2. Navigate to AWS Ground Station
3. Go to "Mission profiles" to verify your mission profile is listed
4. Go to "Dataflow endpoint groups" to verify your endpoint group is configured

## Post-Deployment Configuration

### Satellite Reservation

To schedule contacts with JPSS-2:

1. In the AWS Ground Station console, go to "Contacts"
2. Click "Reserve contact"
3. Select JPSS-2/NOAA-21 from the satellite list
4. Choose your mission profile
5. Select an available contact time
6. Review and confirm the reservation

### Monitoring Setup

Set up monitoring for your Ground Station operations:

1. Create CloudWatch alarms for contact success/failure
2. Set up notifications for completed downlinks
3. Configure S3 event notifications for new data arrivals

```bash
aws s3api put-bucket-notification-configuration \
  --bucket your-jpss2-data-bucket-name \
  --notification-configuration file://notification-config.json
```

### Data Processing Pipeline (Optional)

Consider setting up a data processing pipeline:

1. Configure S3 event notifications to trigger AWS Lambda
2. Use Lambda to process incoming satellite data
3. Store processed results in a separate S3 bucket or database
4. Set up visualization tools for the processed data

## Troubleshooting

### Common Issues

1. **CloudFormation Deployment Failures**
   - Check IAM permissions
   - Verify resource naming (ensure bucket names are globally unique)
   - Check if the region supports all required services

2. **Contact Scheduling Failures**
   - Verify satellite is whitelisted for your account
   - Check mission profile configuration
   - Ensure ground station availability in your region

3. **Data Delivery Issues**
   - Check IAM role permissions
   - Verify S3 bucket policies
   - Check dataflow endpoint group configuration

### Support Resources

- AWS Ground Station Documentation: https://docs.aws.amazon.com/ground-station/
- AWS Support Center: https://console.aws.amazon.com/support/
- AWS Ground Station Forum: https://forums.aws.amazon.com/

## Clean Up

To remove all resources when no longer needed:

```bash
aws cloudformation delete-stack \
  --stack-name jpss2-ground-station \
  --region us-west-2
```

Note: This will delete all resources created by the stack, including the S3 bucket and its contents. Make sure to back up any important data before deletion.
