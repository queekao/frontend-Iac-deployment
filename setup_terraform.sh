# Check for required tools
declare -a req_tools=("terraform" "sed" "curl" "jq")
for tool in "${req_tools[@]}"; do
    if ! command -v "$tool" >/dev/null; then
        fail "It looks like '${tool}' is not installed; please install it and run this setup script again."
        exit 1
    fi
done
CREDENTIALS_FILE="$HOME/.terraform.d/credentials.tfrc.json"

# Credentials are located in App/Data/Roaming on Windows
if [[ "$OSTYPE" =~ ^msys || "$OSTYPE" =~ ^cygwin || "$OSTYPE" =~ ^win32 ]]; then
    CREDENTIALS_FILE="$APPDATA/terraform.d/credentials.tfrc.json"
fi
HOST="app.terraform.io"
TOKEN=$(jq -j --arg h "$HOST" '.credentials[$h].token' "$CREDENTIALS_FILE")
echo "Creating an organization and workspace..."
sleep 1
setup_organization() {
    curl https://$HOST/api/v2/organizations \
        --request POST \
        --silent \
        --header "Content-Type: application/vnd.api+json" \
        --header "Authorization: Bearer $TOKEN" \
        --data @infra/terraform/config/origanization.json
}

RESPONSE_ORGANIZATION=$(setup_organization)
RESPONSE_WORKSPACE=$(setup_workspace)
ORGANIZATION_NAME=$(echo $RESPONSE | jq -r '.data.attributes.name')
ERR_ORGANIZATION=$(echo $RESPONSE_ORGANIZATION | jq -r '.errors')
ERR_WORKSPACE=$(echo $RESPONSE_WORKSPACE | jq -r '.errors')
setup_workspace() {
    curl https://app.terraform.io/api/v2/organizations/$ORGANIZATION_NAME/workspaces
        --request POST \
        --silent \
        --header "Content-Type: application/vnd.api+json" \
        --header "Authorization: Bearer $TOKEN" \
        --data @infra/terraform/config/workspace.json \
}

if [[ -n $ERR_ORGANIZATION ]] && [[ -n $ERR_WORKSPACE ]]; then
    ERR_MSG_ORGANIZATION=$(echo $ERR_ORGANIZATION | jq -r '.[0].detail')
    ERR_MSG_WORKSPACE=$(echo $ERR_WORKSPACE | jq -r '.[0].detail')
    if [[ -n $ERR_MSG_ORGANIZATION ]] && [[ -n $ERR_MSG_WORKSPACE ]]; then
        fail "An error occurred: ${ERR_MSG_ORGANIZATION} or ${ERR_MSG_WORKSPACE}"
    else
        fail "An unknown error occurred: ${ERR_ORGANIZATION} or ${ERR_WORKSPACE}"
    fi
    exit 1
fi
