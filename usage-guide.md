# Usage Guide for JPSS-2 Ground Station Mission Profile

This guide provides instructions on how to use the AWS Ground Station mission profile for JPSS-2 after deployment.

## Scheduling Contacts

### Using AWS Console

1. Navigate to the AWS Ground Station console
2. Select "Contacts" from the left navigation menu
3. Click "Reserve contact"
4. In the satellite dropdown, select "JPSS-2" or "NOAA-21"
5. Select the mission profile created by the CloudFormation stack
6. Choose an available contact time from the calendar view
7. Review the contact details and click "Reserve"

### Using AWS CLI

```bash
# List available contacts for the next 24 hours
aws groundstation list-contacts \
  --satellite-id <satellite-id> \
  --status AVAILABLE \
  --start-time $(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --end-time $(date -u -d "+1 day" +"%Y-%m-%dT%H:%M:%SZ") \
  --region us-west-2

# Reserve a contact
aws groundstation reserve-contact \
  --satellite-id <satellite-id> \
  --contact-id <contact-id> \
  --mission-profile-arn <mission-profile-arn> \
  --region us-west-2
```

## Monitoring Contacts

### Active Contacts

To view currently active contacts:

1. In the AWS Ground Station console, go to "Contacts"
2. Filter by "Status: EXECUTING"

Using AWS CLI:

```bash
aws groundstation list-contacts \
  --status EXECUTING \
  --region us-west-2
```

### Scheduled Contacts

To view upcoming scheduled contacts:

1. In the AWS Ground Station console, go to "Contacts"
2. Filter by "Status: SCHEDULED"

Using AWS CLI:

```bash
aws groundstation list-contacts \
  --status SCHEDULED \
  --region us-west-2
```

### Contact History

To view completed contacts:

1. In the AWS Ground Station console, go to "Contacts"
2. Filter by "Status: COMPLETED" or "Status: FAILED"

Using AWS CLI:

```bash
aws groundstation list-contacts \
  --status COMPLETED \
  --region us-west-2
```

## Accessing Downlinked Data

### Using AWS Console

1. Navigate to the S3 console
2. Select your JPSS-2 data bucket
3. Browse to the `jpss2-data/` prefix
4. Data is organized by contact ID

### Using AWS CLI

```bash
# List all data in the bucket
aws s3 ls s3://your-jpss2-data-bucket/jpss2-data/ --recursive

# Download specific data files
aws s3 cp s3://your-jpss2-data-bucket/jpss2-data/CONTACT_ID/ ./local-directory/ --recursive
```

## Data Processing Examples

### Basic Data Inspection

```bash
# Check file metadata
aws s3api head-object --bucket your-jpss2-data-bucket --key jpss2-data/CONTACT_ID/filename

# Download and inspect a specific file
aws s3 cp s3://your-jpss2-data-bucket/jpss2-data/CONTACT_ID/filename ./
```

### Setting Up Automated Processing

Example AWS Lambda function trigger on S3 object creation:

```yaml
Resources:
  ProcessingFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: index.handler
      Runtime: python3.9
      Events:
        S3Event:
          Type: S3
          Properties:
            Bucket: !Ref SatelliteDataBucket
            Events: s3:ObjectCreated:*
            Filter:
              S3Key:
                Prefix: jpss2-data/
```

## Canceling Contacts

### Using AWS Console

1. Navigate to the AWS Ground Station console
2. Go to "Contacts"
3. Select the scheduled contact you wish to cancel
4. Click "Cancel contact"
5. Confirm the cancellation

### Using AWS CLI

```bash
aws groundstation cancel-contact \
  --contact-id <contact-id> \
  --region us-west-2
```

## Best Practices

### Contact Scheduling

- Schedule contacts at least 24 hours in advance for better availability
- Consider scheduling multiple contacts to ensure data acquisition
- Review the satellite pass details (elevation, duration) when selecting contacts

### Data Management

- Implement lifecycle policies on your S3 bucket to manage storage costs
- Consider using S3 Intelligent-Tiering for cost optimization
- Set up automated workflows to process data as it arrives

Example S3 lifecycle configuration:

```bash
aws s3api put-bucket-lifecycle-configuration \
  --bucket your-jpss2-data-bucket \
  --lifecycle-configuration file://lifecycle-config.json
```

### Monitoring and Alerting

- Set up CloudWatch alarms for contact failures
- Create notifications for successful data deliveries
- Monitor S3 storage usage

Example CloudWatch alarm for failed contacts:

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name JPSS2-FailedContacts \
  --metric-name FailedContacts \
  --namespace AWS/GroundStation \
  --statistic Sum \
  --period 86400 \
  --evaluation-periods 1 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --alarm-actions <sns-topic-arn> \
  --dimensions Name=MissionProfileId,Value=<mission-profile-id> \
  --region us-west-2
```

## Troubleshooting Common Issues

### Contact Failures

If contacts fail consistently:
- Verify satellite availability and status
- Check mission profile configuration
- Review IAM permissions
- Ensure dataflow endpoint group is properly configured

### Missing Data

If data is not appearing in S3:
- Check IAM role permissions
- Verify S3 bucket policies
- Review CloudWatch logs for the Ground Station service
- Confirm the contact was successful

### Performance Issues

If data transfer is slow:
- Check network configuration
- Review S3 bucket settings
- Consider using S3 Transfer Acceleration for faster uploads
