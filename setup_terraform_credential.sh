declare -a req_tools=("sed" "jq")
for tool in "${req_tools[@]}"; do
    if ! command -v "$tool" >/dev/null; then
        fail "It looks like '${tool}' is not installed; please install it and run this setup script again."
        exit 1
    fi
done
aws sts get-session-token --duration-seconds 3600 >creds.json
#!/bin/bash
CREDENTIALS=$(jq -r '.Credentials' creds.json)

AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.SessionToken')
TFVARS_PATH="./infra/terraform/terraform.tfvars"
sed -i '' "s|aws_access_key = \".*\"|aws_access_key = \"$AWS_ACCESS_KEY_ID\"|" "$TFVARS_PATH"
sed -i '' "s|aws_secret_key = \".*\"|aws_secret_key = \"$AWS_SECRET_ACCESS_KEY\"|" "$TFVARS_PATH"
sed -i '' "s|token = \".*\"|token = \"$AWS_SESSION_TOKEN\"|" "$TFVARS_PATH"
