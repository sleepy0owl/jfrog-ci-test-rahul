function handler () {
    EVENT_DATA=$1
    
    
    cd /mnt/efs
    git clone https://github.com/Raalzz/step-function-react.git

  
    cd /mnt/efs/step-function-react

    npm install
    npm build
    # aws s3 sync build s3://$(jq -r '.S3BucketName' parameters.json)

    RESPONSE="{\"statusCode\": 200, \"body\": \"bruh\"}"
    echo $RESPONSE
    
}
