#!/usr/bin/env bash

# Check if token code and MFA serial number are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <MFA_SERIAL_NUMBER> <MFA_TOKEN_CODE>"
    return 1
fi

# Assign input parameters
MFA_SERIAL_NUMBER="$1"
MFA_TOKEN_CODE="$2"

# Ensure not trying to use a session token to get a session token...
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

# Retrieve session token using the provided MFA serial number and token code
CREDENTIALS=$(aws sts get-session-token --serial-number "$MFA_SERIAL_NUMBER" --token-code "$MFA_TOKEN_CODE" --output json)

# Check if the command was successful
if [ $? -ne 0 ]; then
    echo "Failed to get session token. Make sure your AWS CLI is configured correctly."
    return 1
fi

# Extract credentials using jq
AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')

# Export credentials
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

# Display confirmation
echo "Temporary AWS credentials have been set! (Valid for approximately 12 hours)"
