# frontend-Iac-deployment

This is an frontend deployment strategy by utilizing cloudFormation to automatically
create S3、CloudFront、Route53(A Record)、Lambda(For creating CloudFront invalidation)
with `deploy_stack.sh` and deleting stack with `delete_stack.sh`

## Prerequisites

Before using this template, make sure you have the following toolkits installed:

1. **[AWS CLI](https://aws.amazon.com/cli/)**: Required for interacting with AWS services.

   - Installation command:
     ```bash
     brew install awscli
     ```

2. **[jq](https://stedolan.github.io/jq/)**: Necessary for processing JSON data on the command line.
   - Installation command:
     ```bash
     brew install jq
     ```
3. > You need to modify the `foodApp.json` or `foodAppLiff.json` to match your environment settings in both directories before running the commands below. Alternatively, you can define your own application settings, as it is not restricted to my default build folder.

## Configuration

```plaintext
├── build                               # The sync folder that will eventually sync to S3
├── cloudFormationDeployment/           # Contain the CloudFormation deployment toolkits
│   ├── cloudFormationParameters/       #
│   │   ├── foodApp.json/               # The cloudformation parameters
│   │   └── foodAppLiff.json/           # The cloudformation parameters with liff app(no route 53)
│   ├── deploymentParameters/           # The Parameters for both deploy_stack.sh and delete_stack.sh
│   │   ├── foodApp.json/               # The shell script parameters
│   │   └── foodAppLiff.json/           # The shell script parameters with liff app(no route 53)
│   └──  deploy-s3-cloudFront.yml/      # The cloudformation template
├── FoodApp                             # Original react application
├── deploy_function.sh                  # Some helper function for deployment
├── delete_stack.sh                     # Using for delete the stack
└── deploy_stack.sh                     # Using for deploy the stack
```

### Deploy normal frontend stack

```bash
./deploy_stack.sh ./cloudFormationDeployment/deploymentParameters/foodApp.json
```

### Deploy liff frontend stack

```bash
./deploy_stack.sh ./cloudFormationDeployment/deploymentParameters/foodAppLiff.json
```

### Delete normal frontend stack

```bash
./delete_stack.sh ./cloudFormationDeployment/deploymentParameters/foodApp.json
```

### Delete liff frontend stack

```bash
./delete_stack.sh ./cloudFormationDeployment/deploymentParameters/foodAppLiff.json
```

> ⚠️ **Note**: The region of cloudformation parameters can only be `us-east-1` if you are deploying
> with the `normal` type because I create an ACM for attacting to the cloudfront it only can be `us-east-1`
> As for liff you can create at the region you want

### Commit Rules

- **feat**: A new feature
- **fix**: A bug fix
- **update**: A modification but not adding new feature
- **perf**: A code change that improves performance
- **refactor**: A code change that neither fixes a bug nor adds refactor the code
