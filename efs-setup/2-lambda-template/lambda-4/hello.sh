function handler () {
    EVENT_DATA=$1
    
    # cd /mnt/efs/ACD-Serverless-Leave-Approval/s3-website

    # cp -r /mnt/efs/ACD-Serverless-Leave-Approval/ /tmp
    # cd /tmp/s3-website
    
    cp -r /mnt/efs/ACD-Serverless-Leave-Approval/s3-website /tmp
    cd /tmp/s3-website

    echo "here1"
    npm install --verbose

    echo "here2"
    npm build --verbose
    
    echo "here3"
    aws s3 sync build s3://$(jq -r '.S3BucketName' ../../mnt/efs/ACD-Serverless-Leave-Approval/parameters.json)
    
    RESPONSE="{\"statusCode\": 200, \"body\": \"bruh\"}"
    echo $RESPONSE
    
}

#when this is done 
# cp -r /mnt/efs/ACD-Serverless-Leave-Approval/s3-website /tmp
# cd /tmp/s3-website
# yarn install and build works, but when i run it. But when I move the entire acd folderm it does not woek