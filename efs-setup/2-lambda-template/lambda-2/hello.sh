function handler () {
    EVENT_DATA=$1
    set +x
  
    cd /mnt/efs/ACD-Serverless-Leave-Approval

    sam build 

    sam deploy --stack-name $(jq -r '.StackName' parameters.json) --region $(jq -r '.Region' parameters.json) --parameter-overrides CognitoUserPoolDomain=$(jq -r '.CognitoUserPoolDomain' parameters.json) S3BucketName=$(jq -r '.S3BucketName' parameters.json)  --no-confirm-changeset --no-fail-on-empty-changeset --capabilities CAPABILITY_IAM --resolve-s3

    RESPONSE="{\"statusCode\": 200, \"body\": \"sam deployed\"}"
    echo $RESPONSE
}
