# AWS Ground Station Mission Profile for JPSS-2 Satellite

This repository contains CloudFormation templates, Terraform configurations, and documentation for setting up an AWS Ground Station mission profile for the JPSS-2 (Joint Polar Satellite System-2) satellite. The mission profile is configured to deliver downlinked data to an S3 bucket in the us-west-2 region.

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

You can deploy this project using either CloudFormation or Terraform.

### Option 1: CloudFormation Deployment

1. Clone the Repository
```bash
git clone https://github.com/yourusername/jpss2-ground-station.git
cd jpss2-ground-station
```

2. Deploy the CloudFormation Stack
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

3. Verify Deployment
```bash
aws cloudformation describe-stacks \
  --stack-name jpss2-ground-station \
  --region us-west-2
```

### Option 2: Terraform Deployment

1. Clone the Repository
```bash
git clone https://github.com/yourusername/jpss2-ground-station.git
cd jpss2-ground-station/terraform
```

2. Initialize Terraform
```bash
terraform init
```

3. Plan the Deployment
```bash
terraform plan -out=tfplan
```

4. Apply the Configuration
```bash
terraform apply tfplan
```

5. Verify the Deployment
The Terraform output will show the ARNs and names of created resources. You can also verify through the AWS Console.

For detailed Terraform deployment instructions and customization options, see the [Terraform README](terraform/README.md).

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

### Common Issues and Solutions

1. **Contact Scheduling Failures**
   - Verify AWS account has been whitelisted for JPSS-2 satellite
   - Check if the ground station location is available during requested time
   - Ensure mission profile configuration is correct
   - Verify contact duration meets minimum requirements
   - Check for any service quotas or limits that may be reached

2. **Data Not Appearing in S3**
   - Check IAM role permissions:
     - Verify Ground Station role has proper S3 access
     - Ensure bucket policy allows Ground Station writes
   - Validate S3 bucket configuration:
     - Confirm bucket exists in correct region
     - Check bucket versioning and encryption settings
   - Review dataflow endpoint configuration
   - Monitor CloudWatch logs for data delivery issues

3. **Failed Contacts**
   - Dataflow Endpoint Issues:
     - Verify EC2 instance was started before contact start time
     - Confirm dataflow endpoint software is running
     - Check network connectivity and security groups
   - Ground Station Agent Issues:
     - Ensure agent is running before contact start
     - Verify agent has proper permissions
     - Don't shut down EC2 instance within 15 seconds of contact end
   - Review CloudWatch metrics for antenna tracking

4. **Failed to Schedule Contacts**
   - Common causes:
     - Invalid ephemeris data
     - Scheduling conflicts with other contacts
     - Ground station maintenance
     - Insufficient contact duration
   - Solutions:
     - Update satellite ephemeris data
     - Try alternate time slots or ground stations
     - Adjust contact duration parameters

5. **No Data Received During Contact**
   - Check satellite visibility and elevation
   - Verify antenna pointing and tracking configuration
   - Review frequency and bandwidth settings
   - Monitor signal strength metrics
   - Check for RF interference or weather issues

6. **Dataflow Endpoint Group Health Issues**
   - Verify endpoint connectivity:
     - Check security group rules
     - Validate network ACLs
     - Test endpoint reachability
   - Monitor endpoint status:
     - Check CloudWatch metrics
     - Review endpoint logs
     - Verify endpoint configuration

### Monitoring and Debugging

1. **CloudWatch Metrics**
   - Monitor key metrics:
     - Contact success rate
     - Data throughput
     - Signal strength
     - Antenna tracking accuracy

2. **CloudWatch Logs**
   - Review log groups:
     - Ground Station service logs
     - Dataflow endpoint logs
     - Agent application logs

3. **AWS Ground Station Console**
   - Check contact status and history
   - Monitor upcoming scheduled contacts
   - Review configuration settings
   - Verify resource health

### Best Practices

1. **Pre-Contact Checklist**
   - Verify all IAM permissions
   - Check endpoint health status
   - Confirm resource availability
   - Review contact parameters

2. **During Contact**
   - Monitor real-time metrics
   - Watch for error notifications
   - Track data flow progress

3. **Post-Contact Analysis**
   - Review contact logs
   - Analyze performance metrics
   - Document any issues
   - Implement necessary fixes

### Getting Help

If you encounter issues not covered here:
1. Check AWS Ground Station documentation
2. Review AWS Ground Station quotas and limits
3. Contact AWS Support
4. Post on AWS re:Post with tag 'ground-station'

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
