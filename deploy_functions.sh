# Check if jq is installed
check_jq_installed() {
    if ! command -v jq &>/dev/null; then
        echo "jq is not installed. Installing jq..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y jq
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        elif [[ "$OSTYPE" == "win32" ]]; then
            # TODO: Implement the window installation
            echo "Running on Windows"
        else
            echo "Unsupported OS. Please install jq manually."
            exit 1
        fi
    fi
}
# list the parameters
# load_parameters() {
#     PARAMS_FILE=$1
#     shift
#     for var in "$@"; do
#         declare "$var=$(jq -r --arg var "$var" '.[$var] // empty' "$PARAMS_FILE")"
#     done
# }
initialize_liff_cli() {
    local LINE_CHANNEL_ID="$1"
    local LINE_CHANNEL_SECRET="$2"

    if ! command -v liff-cli &>/dev/null; then
        npm install -g @line/liff-cli
    fi

    echo "Adding channel to LIFF CLI..."

    liff-cli channel add $LINE_CHANNEL_ID <<EOF
$LINE_CHANNEL_SECRET
EOF

    if [ $? -ne 0 ]; then
        echo "Failed to add channel to LIFF CLI."
        exit 1
    fi
}

# Check cloudFromationParameters.json for missing keys
check_missing_keys() {
    local PARAMETERS_FILE="$1"
    local TYPE="$2"
    local required_keys
    if [ "$TYPE" = "liff" ]; then
        required_keys=("CloudFrontInvalidationLambdaName" "BucketName" "CloudFrontName")
    elif [ "$TYPE" = "normal" ]; then
        required_keys=("CloudFrontInvalidationLambdaName" "BucketName" "CloudFrontName" "HostedZoneId" "DomainName")
    fi
    local missing_keys=()
    for key in "${required_keys[@]}"; do
        if ! jq -e --arg key "$key" '.[] | select(.ParameterKey == $key)' "$PARAMETERS_FILE" >/dev/null; then
            missing_keys+=("$key")
        fi
    done
    if [ ${#missing_keys[@]} -eq 0 ]; then
        echo "All required cloudFromation parameters are present."
    else
        echo "Missing parameter keys: ${missing_keys[@]}"
        exit 1
    fi
}

# Check nvm installation if it is not installed and switch to Node.js 22.2.0
switch_to_node_v22.2.0() {
    local DESIRED_NODE_VERSION="22.2.0"
    local CURRENT_NODE_VERSION=$(node -v | sed 's/v//')
    source ~/.zshrc 2>/dev/null
    if ! command -v nvm &>/dev/null; then
        echo "nvm not found, installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        # Source nvm script to make it available in the current shell
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
    if [ "$CURRENT_NODE_VERSION" == "$DESIRED_NODE_VERSION" ]; then
        echo "Node.js version is already $DESIRED_NODE_VERSION. No action needed."
    else
        echo "Switching to Node.js $DESIRED_NODE_VERSION..."
        nvm install $DESIRED_NODE_VERSION
        nvm use $DESIRED_NODE_VERSION
    fi
}
