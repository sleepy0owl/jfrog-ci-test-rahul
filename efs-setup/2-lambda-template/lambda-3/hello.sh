function handler () {
    EVENT_DATA=$1
    set +x
  
    cd /mnt/efs/ACD-Serverless-Leave-Approval

    export PWD=$(pwd)

    npm install -C scripts/
    node scripts/updateInfo.js $PWD ap-south-1

    RESPONSE="{\"statusCode\": 200, \"body\": \"scripts completed\"}"
    echo $RESPONSE
    
}
