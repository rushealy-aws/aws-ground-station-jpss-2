# Ephemeris Update Notification System

This document describes the notification system for the satellite ephemeris automation solution.

## Overview

The notification system provides real-time alerts for ephemeris update events through multiple channels:
- Email notifications
- SMS alerts
- Slack messages
- CloudWatch alarms

## Architecture

The system uses:
- Amazon SNS for message distribution
- AWS Lambda for Slack integration
- CloudWatch for metrics and alarms
- Custom metrics for detailed monitoring

## Notification Types

### Success Notifications

Sent when an ephemeris update succeeds, including:
- Satellite ID
- File name
- Ephemeris ID
- Priority
- Timestamp

Example:
```
Subject: Ephemeris Update Success - satellite-123
Message:
Ephemeris successfully updated for satellite satellite-123.

File: satellite-123_2025-05-23_1.oem
Bucket: my-ephemeris-bucket
Priority: 1
Ephemeris ID: eph-abc123
Timestamp: 2025-05-23T19:00:00Z
```

### Failure Notifications

Sent when an ephemeris update fails, including:
- Error details
- File name
- Timestamp
- Stack trace (if available)

Example:
```
Subject: Ephemeris Update Failed - satellite-123
Message:
Failed to update ephemeris.

File: satellite-123_2025-05-23_1.oem
Error: Invalid OEM format: Missing required header CREATION_DATE
Timestamp: 2025-05-23T19:00:00Z
```

## CloudWatch Alarms

### 1. Failed Ephemeris Updates (Lambda Errors)
- Triggers when Lambda function errors occur
- 5-minute evaluation period
- Threshold: ≥ 1 error

### 2. Successful Updates
- Monitors successful ephemeris updates
- Custom metric in CustomMetrics/Ephemeris namespace
- 5-minute evaluation period
- Threshold: ≥ 1 success

### 3. Failed Updates (Custom Metric)
- Tracks failed updates separately from Lambda errors
- Custom metric in CustomMetrics/Ephemeris namespace
- 5-minute evaluation period
- Threshold: ≥ 1 failure

## Setup Instructions

### 1. Deploy Main Template

```bash
aws cloudformation deploy \
  --template-file cloudformation/main-template.yaml \
  --stack-name satellite-ephemeris-automation \
  --parameter-overrides \
    SatelliteId=your-satellite-id \
    BucketName=your-ephemeris-bucket \
    NotificationEmail=your-email@example.com \
  --capabilities CAPABILITY_IAM
```

### 2. Add Additional Subscriptions

```bash
aws cloudformation deploy \
  --template-file cloudformation/subscription-template.yaml \
  --stack-name ephemeris-notifications \
  --parameter-overrides \
    NotificationTopicArn=<topic-arn-from-main-stack> \
    EmailAddress=another-email@example.com \
    SmsNumber=+1234567890 \
    SlackWebhookUrl=https://hooks.slack.com/services/... \
  --capabilities CAPABILITY_IAM
```

## Subscription Management

### Adding Email Subscribers
```bash
aws sns subscribe \
  --topic-arn <topic-arn> \
  --protocol email \
  --notification-endpoint new-email@example.com
```

### Adding SMS Subscribers
```bash
aws sns subscribe \
  --topic-arn <topic-arn> \
  --protocol sms \
  --notification-endpoint +1234567890
```

### Removing Subscribers
```bash
aws sns unsubscribe --subscription-arn <subscription-arn>
```

## Customizing Notifications

### Modifying Message Format

Edit the Lambda function code in the main template:
- `send_notification` function controls message format
- Customize subject and message content
- Add additional context or formatting

### Adding New Notification Channels

1. Create a new Lambda function for the channel
2. Subscribe the Lambda to the SNS topic
3. Add necessary IAM permissions
4. Update monitoring and logging

## Monitoring and Troubleshooting

### Viewing Notification History
```bash
aws cloudwatch get-metric-statistics \
  --namespace CustomMetrics/Ephemeris \
  --metric-name SuccessfulUpdates \
  --statistics Sum \
  --period 300 \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S)
```

### Checking Subscription Status
```bash
aws sns list-subscriptions-by-topic --topic-arn <topic-arn>
```

### Common Issues

1. **Missing Notifications**
   - Check SNS delivery status
   - Verify subscription confirmation
   - Check Lambda execution logs

2. **False Alarms**
   - Review CloudWatch alarm thresholds
   - Check metric filters
   - Verify alarm conditions

3. **Delayed Notifications**
   - Check Lambda timeout settings
   - Monitor SNS delivery delays
   - Review network connectivity

## Best Practices

1. **Message Format**
   - Keep messages concise
   - Include relevant context
   - Use consistent formatting

2. **Subscription Management**
   - Regularly audit subscribers
   - Remove unused subscriptions
   - Document subscription changes

3. **Monitoring**
   - Set appropriate thresholds
   - Monitor notification latency
   - Track delivery success rates

4. **Security**
   - Use encryption in transit
   - Implement least privilege
   - Regularly rotate credentials

## Support and Maintenance

### Regular Tasks
- Review and update subscriptions
- Monitor delivery success rates
- Update message formats as needed
- Audit notification patterns

### Emergency Procedures
1. Check CloudWatch logs
2. Verify SNS topic status
3. Review subscription health
4. Check Lambda function logs
5. Verify IAM permissions
