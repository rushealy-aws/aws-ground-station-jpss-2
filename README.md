# AWS Ground Station Mission Profile for JPSS-2 Satellite

This repository contains CloudFormation templates and documentation for setting up an AWS Ground Station mission profile for the JPSS-2 (Joint Polar Satellite System-2) satellite. The mission profile is configured to deliver downlinked data to an S3 bucket in the us-west-2 region.

## Overview

The JPSS-2 satellite (also known as NOAA-21) is part of the Joint Polar Satellite System, a collaborative program between NOAA and NASA. It provides global environmental data for weather forecasting and climate monitoring.

This project sets up:
- An S3 bucket to store downlinked satellite data
- A dataflow endpoint group for AWS Ground Station
- Required IAM roles and permissions
- Mission profile configuration for JPSS-2
- Contact profile with appropriate tracking configuration

## Prerequisites

- AWS Account with AWS Ground Station access
- AWS CLI installed and configured
- Permissions to create CloudFormation stacks, IAM roles, S3 buckets, and Ground Station resources
- AWS Ground Station onboarding completed (satellite must be whitelisted for your account)

## Deployment Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/jpss2-ground-station.git
cd jpss2-ground-station
```

### 2. Deploy the CloudFormation Stack

```bash
aws cloudformation deploy \
  --template-file templates/mission-profile.yaml \
  --stack-name jpss2-ground-station \
  --parameter-overrides \
    BucketName=your-jpss2-data-bucket \
    MissionProfileName=jpss2-mission-profile \
  --capabilities CAPABILITY_IAM \
  --region us-west-2
```

### 3. Verify Deployment

```bash
aws cloudformation describe-stacks \
  --stack-name jpss2-ground-station \
  --region us-west-2
```

## Usage Instructions

### Scheduling Contacts

Once the mission profile is deployed, you can schedule contacts with the JPSS-2 satellite:

1. Navigate to the AWS Ground Station console
2. Go to "Contacts" and click "Reserve contact"
3. Select the JPSS-2 satellite
4. Choose the mission profile created by this stack
5. Select available contact times
6. Review and confirm the reservation

### Accessing Downlinked Data

After a successful contact, data will be available in the S3 bucket:

```bash
aws s3 ls s3://your-jpss2-data-bucket/jpss2-data/
```

The data is organized with the following prefix structure:
```
jpss2-data/<mission-name>/<contact-id>/<data-files>
```

### Monitoring Contacts

You can monitor ongoing and scheduled contacts through:

1. AWS Ground Station console
2. CloudWatch metrics for Ground Station
3. CloudWatch logs for detailed operation information

## Customization

You can customize the deployment by modifying the parameters in the CloudFormation template:

- `BucketName`: Name of the S3 bucket to store satellite data
- `DataflowEndpointGroupName`: Name of the dataflow endpoint group
- `MissionProfileName`: Name of the mission profile
- `ContactProfileName`: Name of the contact profile
- `TrackingConfigName`: Name of the tracking configuration

## Troubleshooting

Common issues and solutions:

1. **Contact scheduling failures**: Verify that your AWS account has been whitelisted for the JPSS-2 satellite
2. **Data not appearing in S3**: Check IAM permissions and Ground Station role configuration
3. **Deployment failures**: Ensure you have the necessary permissions and that the region supports AWS Ground Station

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
