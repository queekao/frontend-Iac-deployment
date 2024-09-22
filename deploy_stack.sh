#!/bin/bash
PARAMS_FILE="$1"
START_TIME=$(date +%s)
LIFF_ID=""
if command -v aws &>/dev/null; then
    echo "AWS CLI is installed."
else
    echo "AWS CLI is not installed."
fi
# Check if liff_output.txt exists
if [ -f liff_output.txt ]; then
    LIFF_ID=$(grep 'Successfully created LIFF app' liff_output.txt | awk '{print $5}')
fi

source ./deploy_functions.sh
if [ -z "$PARAMS_FILE" ]; then
    echo "Usage: $0 deployParameters.json"
    exit 1
fi

check_jq_installed
# Create the deploy parameters variable
for var in STACK_NAME SYNC_FOLDER VERSION REGION TYPE TEMPLATE_FILE LINE_CHANNEL_SECRET LINE_CHANNEL_ID LIFF_NAME CLOUDFORMATION_PARAMETERS_FILE; do
    declare $var=$(jq -r --arg var "$var" '.[$var] // empty' "$PARAMS_FILE")
done
# Error handling for deployParameters.json
if [ "$TYPE" != "liff" ] && [ "$TYPE" != "normal" ]; then
    echo "Error: TYPE in deployParameters.json. must be either liff or normal 💥"
    exit 1
elif [ "$TYPE" = "normal" ] && [ "$REGION" != "us-east-1" ]; then
    echo "Error: If TYPE equal normal you must define REION in us-east-1 💥"
    exit 1
fi
if [ -z "$STACK_NAME" ] || [ -z "$SYNC_FOLDER" ] || [ -z "$VERSION" ] || [ -z "$REGION" ] || [ -z "$TYPE" ] || [ -z "$TEMPLATE_FILE" ] || [ -z "$CLOUDFORMATION_PARAMETERS_FILE" ]; then
    # Check required variables for all types
    echo "Error: Missing required input values from deployParameters.json. 💥"
    echo "Required Schema: {
    \"STACK_NAME\": \"your-stack-name\",
    \"SYNC_FOLDER\": \"your-sync-folder\",
    \"VERSION\": \"your-version\",
    \"REGION\": \"your-region\",
    \"TYPE\": \"your-deployment-type ['normal', 'liff']\",
    \"TEMPLATE_FILE\": \"your-cloudFormation-template-yaml-file\",
    \"CLOUDFORMATION_PARAMETERS_FILE\": \"your-cloudFormation-template-parameters-file\"
}"
    exit 1
fi
if [ "$TYPE" = "liff" ]; then
    # Additional checks for type 'liff'
    if [ -z "$LINE_CHANNEL_SECRET" ] || [ -z "$LINE_CHANNEL_ID" ] || [ -z "$LIFF_NAME" ]; then
        echo "Error: Missing required input values for LIFF type. 💥"
        echo "Required Schema for LIFF: {
        \"STACK_NAME\": \"your-stack-name\",
        \"SYNC_FOLDER\": \"your-sync-folder\",
        \"VERSION\": \"your-version\",
        \"REGION\": \"your-region\",
        \"TEMPLATE_FILE\": \"your-cloudFormation-template-yaml-file\",
        \"TYPE\": \"your-deployment-type ['normal', 'liff']\",
        \"CLOUDFORMATION_PARAMETERS_FILE\": \"your-cloudFormation-template-parameters-file\",
        \"LINE_CHANNEL_SECRET\": \"your-line-channel-secret\",
        \"LINE_CHANNEL_ID\": \"your-line-channel-id\",
        \"LIFF_NAME\": \"your-liff-name\"
    }"
        exit 1
    fi
fi

check_missing_keys $CLOUDFORMATION_PARAMETERS_FILE $TYPE
BUCKET_NAME=$(jq -r '.[] | select(.ParameterKey == "BucketName") | .ParameterValue' $CLOUDFORMATION_PARAMETERS_FILE)
CLOUDFRONT_INVALIDATION_LAMBDA_NAME=$(jq -r '.[] | select(.ParameterKey == "CloudFrontInvalidationLambdaName") | .ParameterValue' $CLOUDFORMATION_PARAMETERS_FILE)
# Initialize liff-cli
if [ "$TYPE" = "liff" ]; then
    STACK_NAME="${STACK_NAME}-${TYPE}"
    BUCKET_NAME="${BUCKET_NAME}-${TYPE}"
    CLOUDFRONT_INVALIDATION_LAMBDA_NAME="${CLOUDFRONT_INVALIDATION_LAMBDA_NAME}-${TYPE}"
    switch_to_node_v22.2.0 # For liff-cli requirement
    initialize_liff_cli $LINE_CHANNEL_ID $LINE_CHANNEL_SECRET
fi
# Check the cloudformation status if the stack already exist
STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query "Stacks[0].StackStatus" --output text 2>/dev/null)
if [ "$STACK_STATUS" != "CREATE_COMPLETE" ] && [ "$STACK_STATUS" != "UPDATE_COMPLETE" ] && [ -n "$STACK_STATUS" ]; then
    echo "Stack is not in CREATE_COMPLETE or UPDATE_COMPLETE state. Deleting the stack..."
    aws s3 rb s3://$BUCKET_NAME --force # This will forcefully delete the bucket even if the bucket has something because s3 might contain something that block s3 deletion
    aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
    # Wait for the stack to be deleted
    echo "Waiting for the stack to be deleted..."
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION
    # if cloudformation failed to deploy then delete liff and recreate
    if [ -n "$LIFF_ID" ] && [ "$TYPE" = "liff" ]; then
        liff-cli app delete \
            --channel-id $LINE_CHANNEL_ID \
            --liff-id $LIFF_ID
        rm cloudformationDeployment/liffApp/liff_${LIFF_NAME}.txt
    fi
fi

# Deploy the CloudFormation stack
aws cloudformation deploy \
    --template-file $TEMPLATE_FILE \
    --stack-name $STACK_NAME \
    --parameter-overrides file://$CLOUDFORMATION_PARAMETERS_FILE \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION

# Check if the the cloudformation deployed successfully.
if [ $? -eq 0 ]; then
    echo "CloudFormation stack deployed successfully."
    END_TIME=$(date +%s)
    DEPLOY_DURATION=$((END_TIME - START_TIME))
    # sync the build artifact to s3
    if ! aws s3 sync "$SYNC_FOLDER" "s3://$BUCKET_NAME/" --region "$REGION"; then
        echo "Error: Failed to sync folder $SYNC_FOLDER to S3 bucket $BUCKET_NAME. 💥"
    else
        echo "Successfully synced folder $SYNC_FOLDER to S3 bucket $BUCKET_NAME."
        # Invoke the Lambda function
        if ! aws lambda invoke --function-name $CLOUDFRONT_INVALIDATION_LAMBDA_NAME /dev/null; then
            echo "Error: Failed to invoke Lambda function $CLOUDFRONT_INVALIDATION_LAMBDA_NAME. 💥"
        else
            echo "Successfully invoke $CLOUDFRONT_INVALIDATION_LAMBDA_NAME."
        fi
    fi
    # Deploy to line liff app
    CLOUDFRONT_URL=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistribution'].OutputValue" --output text)
    if [ -n "$CLOUDFRONT_URL" ] && [ -z "$LIFF_ID" ] && [ "$TYPE" = "liff" ]; then
        liff-cli app create \
            --channel-id $LINE_CHANNEL_ID \
            --name $LIFF_NAME \
            --endpoint-url https://$CLOUDFRONT_URL \
            --view-type full >cloudformationDeployment/liffApp/liff_${LIFF_NAME}.txt
        if [ $? -ne 0 ]; then
            echo "Failed to create LIFF app."
            exit 1
        fi
        echo "LIFF app created successfully."
    elif [ "$TYPE" = "liff" ]; then
        echo "Can't acquire CloudFront url"
    fi
    echo "Deployment duration: $DEPLOY_DURATION seconds ✨"
else
    # Error handling of creation of resources for newly creating stack
    NEW_STACK_ID=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].StackId' --output text)
    NEW_STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $NEW_STACK_ID --query 'Stacks[0].StackStatus' --output text)
    END_TIME=$(date +%s)
    DEPLOY_DURATION=$((END_TIME - START_TIME))
    if [ "$NEW_STACK_STATUS" != "CREATE_COMPLETE" ]; then
        ERROR_REASON=$(aws cloudformation describe-stack-events --stack-name $NEW_STACK_ID --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].{Resource:ResourceStatusReason}' --output text)
        echo "Stack creation failed with the following error(s):"
        echo "$ERROR_REASON"
    else
        echo "Unknown errors occur 💥"
    fi
    echo "Deployment duration: $DEPLOY_DURATION seconds ✨"
    exit 1
fi
