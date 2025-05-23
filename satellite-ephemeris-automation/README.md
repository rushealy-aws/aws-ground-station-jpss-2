# Satellite Ephemeris Automation

This repository contains an automated workflow for updating satellite ephemeris in AWS Ground Station by uploading OEM (Orbit Ephemeris Message) files to an S3 bucket.

## Overview

The workflow automatically processes new OEM files uploaded to a designated S3 bucket and updates the satellite ephemeris in AWS Ground Station. This automation eliminates manual ephemeris updates and ensures your satellite tracking data remains current.

## Architecture

![Architecture Diagram](architecture.png)

The solution uses the following AWS services:
- Amazon S3 for OEM file storage
- AWS Lambda for processing
- Amazon EventBridge for event-driven triggers
- AWS Ground Station for ephemeris updates
- AWS CloudWatch for monitoring and logging

## Prerequisites

- AWS Account with AWS Ground Station access
- Satellite already registered with AWS Ground Station
- IAM permissions for S3, Lambda, and Ground Station
- OEM files in CCSDS-compliant format

## Setup Instructions

### 1. Deploy the CloudFormation Stack

```bash
aws cloudformation deploy \
  --template-file cloudformation/ephemeris-automation.yaml \
  --stack-name satellite-ephemeris-automation \
  --parameter-overrides \
    SatelliteId=your-satellite-id \
    BucketName=your-ephemeris-bucket \
  --capabilities CAPABILITY_IAM
```

### 2. Configure OEM File Naming Convention

Name your OEM files using the following format:
```
satellite-id_YYYY-MM-DD_priority.oem
```

Example: `satellite-123_2025-05-23_1.oem`

The priority is a number where lower values indicate higher priority (1 is highest).

## Usage

### Uploading New Ephemeris Files

1. Prepare your OEM file following CCSDS standards
2. Name the file according to the convention
3. Upload to the S3 bucket:

```bash
aws s3 cp your-satellite_2025-05-23_1.oem s3://your-ephemeris-bucket/
```

The workflow will automatically:
1. Detect the new file
2. Extract satellite ID and priority from filename
3. Validate the OEM format
4. Update the ephemeris in AWS Ground Station
5. Log the result in CloudWatch

### Monitoring Updates

Monitor ephemeris updates through CloudWatch Logs:

```bash
aws logs get-log-events \
  --log-group-name /aws/lambda/EphemerisUpdateFunction \
  --log-stream-name $(date +%Y/%m/%d)
```

### Verifying Ephemeris Status

Check the status of your ephemeris:

```bash
aws groundstation list-ephemerides \
  --satellite-id your-satellite-id
```

## Workflow Components

### S3 Event Notification

The S3 bucket is configured to trigger a Lambda function whenever a new `.oem` file is uploaded.

### Lambda Function

The Lambda function:
1. Parses the filename to extract metadata
2. Downloads the OEM file
3. Validates the format
4. Calls AWS Ground Station API to update the ephemeris
5. Logs the result

### CloudWatch Alarms

CloudWatch alarms monitor:
1. Failed ephemeris updates
2. Invalid OEM files
3. Lambda function errors

## Troubleshooting

### Common Issues

1. **Invalid OEM Format**
   - Check that your OEM file follows CCSDS standards
   - Verify the file is not corrupted

2. **Permission Errors**
   - Ensure the Lambda execution role has proper permissions
   - Check S3 bucket policies

3. **Failed Updates**
   - Verify the satellite ID is correct
   - Check that the ephemeris data is within valid time ranges

## Advanced Configuration

### Scheduled Ephemeris Updates

To set up scheduled ephemeris updates:

1. Create an EventBridge rule:

```bash
aws events put-rule \
  --name DailyEphemerisCheck \
  --schedule-expression "cron(0 0 * * ? *)" \
  --state ENABLED
```

2. Configure the rule to trigger your Lambda function.

### Multiple Satellite Support

To support multiple satellites:

1. Use a consistent naming convention with satellite IDs
2. The Lambda function will process files for different satellites based on the filename

## Security Considerations

- Encrypt OEM files at rest using S3 server-side encryption
- Use IAM roles with least privilege
- Enable S3 versioning to maintain history of ephemeris files
- Implement S3 lifecycle policies to archive old ephemeris files

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a pull request.
