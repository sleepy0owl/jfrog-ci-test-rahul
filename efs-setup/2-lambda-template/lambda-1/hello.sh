function handler () {
    EVENT_DATA=$1
  
    cd /mnt/efs
    git clone https://github.com/sandykumar93/ACD-Serverless-Leave-Approval.git

    RESPONSE="{\"statusCode\": 200, \"body\": \"downloaded successfully\"}"
    echo $RESPONSE
}
