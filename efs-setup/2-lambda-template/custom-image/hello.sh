# Define a function to handle errors
function handle_error() {
  echo "An error occurred. Exiting..."
  exit 1
}



function handler () {
    # Set up error handling
    trap 'handle_error' ERR

    EVENT_DATA=$1
  

    cd /tmp
    git clone https://github.com/sandykumar93/ACD-Serverless-Leave-Approval.git

    cd ACD-Serverless-Leave-Approval

    export AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"
    export AWS_SESSION_TOKEN="AWS_SESSION_TOKEN"
    
    sam build 

    sam deploy --stack-name $(jq -r '.StackName' parameters.json) --region $(jq -r '.Region' parameters.json) --parameter-overrides CognitoUserPoolDomain=$(jq -r '.CognitoUserPoolDomain' parameters.json) S3BucketName=$(jq -r '.S3BucketName' parameters.json)  --no-confirm-changeset --no-fail-on-empty-changeset --capabilities CAPABILITY_IAM --resolve-s3

    export PWD=$(pwd)

    echo "testing this place"

    npm install -C scripts/
    node scripts/updateInfo.js $PWD ap-south-1

    echo "testing this place 2"
    
    ls

    yarn --cwd s3-website install
    yarn --cwd s3-website build
    aws s3 sync s3-website/build s3://$(jq -r '.S3BucketName' parameters.json)

    RESPONSE="{\"statusCode\": 200, \"body\": \"bruh\"}"
    echo $RESPONSE
    
}
