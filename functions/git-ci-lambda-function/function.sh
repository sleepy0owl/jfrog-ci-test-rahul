# Define a function to handle errors
function handle_error() {
  echo "An error occurred. Exiting..."
  exit 1
}



function handler () {
    # Set up error handling
    trap 'handle_error' ERR

    EVENT_DATA=$1
    event_details="$AWS_LAMBDA_EVENT_BODY"

    timestamp=$(date +%Y%m%d%H%M%S)
    random_number=$(( RANDOM % 10000 ))
    unique_string="${timestamp}_${random_number}"

    echo "Unique string: $unique_string"
    
    echo "MOVING TO /tmp"

    mkdir -p /tmp/$unique_string
    cd /tmp/$unique_string

    echo "CLONING REPO"
    git clone $GITHUB_URL

    echo "MOVING TO REPO"
    cd ACD-Serverless-Leave-Approval
    
    echo "INSTALLING DEPENDENCIES"
    sam build 

    echo "DEPLOYING STACK"
    sam deploy --stack-name $STACK_NAME --region $REGION --parameter-overrides CognitoUserPoolDomain=$COGNITO_USER_POOL_DOMAIN S3BucketName=$BUCKET_NAME  --no-confirm-changeset --no-fail-on-empty-changeset --capabilities CAPABILITY_IAM --resolve-s3

    echo "CLEANING UP"
    cd ../..
    rm -rf $unique_string


    echo "Deployment Finished"

    RESPONSE="{\"statusCode\": 200, \"body\": \"Successfull\"}"
    echo $RESPONSE
    
}