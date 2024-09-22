#!/bin/bash
LIFF_ID=""
if command -v aws &>/dev/null; then
    echo "AWS CLI is installed."
else
    echo "AWS CLI is not installed."
fi
if [ -f liff_output.txt ]; then
    LIFF_ID=$(grep 'Successfully created LIFF app' liff_output.txt | awk '{print $5}')
fi

source ./deploy_functions.sh
if [ -z "$1" ]; then
    echo "Usage: $0 <stack-name>"
    exit 1
fi

check_jq_installed
PARAMS_FILE="$1"
for var in STACK_NAME TYPE LINE_CHANNEL_SECRET LINE_CHANNEL_ID LIFF_NAME CLOUDFORMATION_PARAMETERS_FILE; do
    declare $var=$(jq -r --arg var "$var" '.[$var] // empty' "$PARAMS_FILE")
done
START_TIME=$(date +%s)
BUCKET_NAME=$(jq -r '.[] | select(.ParameterKey == "BucketName") | .ParameterValue' $CLOUDFORMATION_PARAMETERS_FILE)
# Error handling
if [ -z "$STACK_NAME" ] || [ -z "$BUCKET_NAME" ]; then
    echo "Error: Missing required input values from deployParameters.json. 💥"
    echo "Required Schema: {
    \"STACK_NAME\": \"your-stack-name\",
    \"TYPE\": \"your-deployment-type ['normal', 'liff']\",
    \"CLOUDFORMATION_PARAMETERS_FILE\": \"your-cloudformation-template-parameters-file\"
}"
    exit 1
fi
if [ "$TYPE" = "liff" ]; then
    # Additional checks for type 'liff'
    if [ -z "$LINE_CHANNEL_SECRET" ] || [ -z "$LINE_CHANNEL_ID" ] || [ -z "$LIFF_NAME" ]; then
        echo "Error: Missing required input values for LIFF type. 💥"
        echo "Required Schema for LIFF: {
        \"STACK_NAME\": \"your-stack-name\",
        \"TYPE\": \"your-deployment-type ['normal', 'liff']\",
        \"CLOUDFORMATION_PARAMETERS_FILE\": \"your-cloudFormation-template-parameters-file\",
        \"LINE_CHANNEL_SECRET\": \"your-line-channel-secret\",
        \"LINE_CHANNEL_ID\": \"your-line-channel-id\",
        \"LIFF_NAME\": \"your-liff-name\"
    }"
        exit 1
    fi
fi
# Initialize liff-cli
if [ "$TYPE" = "liff" ]; then
    STACK_NAME="${STACK_NAME}-${TYPE}"
    BUCKET_NAME="${BUCKET_NAME}-${TYPE}"
    switch_to_node_v22.2.0 # For liff-cli requirement
    initialize_liff_cli $LINE_CHANNEL_ID $LINE_CHANNEL_SECRET
fi

# Delete the CloudFormation stack and s3 bucket and liff
echo "Deleting Bucket: $BUCKET_NAME"
aws s3 rb s3://$BUCKET_NAME --force
echo "Deleting CloudFormation stack: $STACK_NAME"
aws cloudformation delete-stack --stack-name $STACK_NAME
echo "Waiting for the stack to be deleted..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME
if [ -n "$LIFF_ID" ] && [ "$TYPE" = "liff" ]; then
    liff-cli app delete \
        --channel-id $LINE_CHANNEL_ID \
        --liff-id $LIFF_ID
    rm cloudformationDeployment/liffApp/liff_${LIFF_NAME}.txt
fi

if [ $? -eq 0 ]; then
    END_TIME=$(date +%s)
    DELETE_DURATION=$((END_TIME - START_TIME))
    echo "Stack $STACK_NAME has been deleted successfully."
    echo "Deletion duration: $DELETE_DURATION seconds ✨"
else
    echo "Failed to delete stack $STACK_NAME."
fi
