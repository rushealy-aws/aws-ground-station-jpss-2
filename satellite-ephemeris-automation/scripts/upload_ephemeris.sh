#!/bin/bash
# Script to upload ephemeris files to S3 and trigger the automation workflow

# Check if required arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <oem-file> <satellite-id> <priority> [bucket-name]"
    echo "Example: $0 ./my-ephemeris.oem satellite-123 1 my-ephemeris-bucket"
    exit 1
fi

OEM_FILE=$1
SATELLITE_ID=$2
PRIORITY=$3
BUCKET_NAME=${4:-$(aws cloudformation describe-stacks --stack-name satellite-ephemeris-automation --query "Stacks[0].Outputs[?OutputKey=='EphemerisBucketName'].OutputValue" --output text)}

# Check if bucket name was provided or found
if [ -z "$BUCKET_NAME" ]; then
    echo "Error: Bucket name not provided and couldn't be retrieved from CloudFormation stack"
    exit 1
fi

# Check if file exists
if [ ! -f "$OEM_FILE" ]; then
    echo "Error: File $OEM_FILE does not exist"
    exit 1
fi

# Generate filename with current date
CURRENT_DATE=$(date +%Y-%m-%d)
FILENAME="${SATELLITE_ID}_${CURRENT_DATE}_${PRIORITY}.oem"
TEMP_FILE="/tmp/$FILENAME"

# Copy file to temp location with correct name
cp "$OEM_FILE" "$TEMP_FILE"

# Upload to S3
echo "Uploading ephemeris file to s3://$BUCKET_NAME/$FILENAME..."
aws s3 cp "$TEMP_FILE" "s3://$BUCKET_NAME/$FILENAME"

# Check upload status
if [ $? -eq 0 ]; then
    echo "Upload successful. Ephemeris update process initiated."
    echo "Check CloudWatch logs for processing status."
    
    # Wait a few seconds for processing
    echo "Waiting for processing..."
    sleep 5
    
    # Get the latest log events
    LOG_GROUP="/aws/lambda/EphemerisUpdateFunction"
    
    echo "Checking Lambda logs for results..."
    aws logs get-log-events \
        --log-group-name "$LOG_GROUP" \
        --log-stream-name "$(date +%Y/%m/%d)/[$LATEST]" \
        --limit 10 \
        --query "events[*].message" \
        --output text
    
    # Check ephemeris status
    echo "Current ephemeris status for satellite $SATELLITE_ID:"
    aws groundstation list-ephemerides \
        --satellite-id "$SATELLITE_ID" \
        --query "ephemerides[*].{ID:ephemerisId,Priority:priority,CreationTime:creationTime}" \
        --output table
else
    echo "Upload failed. Please check your AWS credentials and bucket permissions."
fi

# Clean up
rm "$TEMP_FILE"
