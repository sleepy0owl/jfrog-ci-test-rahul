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

    export AWS_ACCESS_KEY_ID="ASIA57GLKGCHR3WY3KM3"
    export AWS_SECRET_ACCESS_KEY="telydCQQWlBXZm2qhil9XypAaQCetRw/vkBj5ZIR"
    export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEGoaCXVzLWVhc3QtMSJGMEQCIBPLKSSNd6e7PxjiEID4c8IrTFgxIU1qtbIeWlQQIkdHAiBSAsimizIX+5UWlgFvJzIIUKYQTIRSIqihWLePE9+ysSqZAwjC//////////8BEAAaDDk2MDM1MTU4MDMwMyIM+WW2SsfWSDvxaMGuKu0C5eXSmuEApQ5NYS0kxcW1WEZ55Gd/lt6g27tFi3YFbb6rlgRXXawVaz2IdzmV++lw9l5TacXDTHsbI1lejR1PbA40QI/xGm8INf01DqYHucM6C+Zso4ustoPZJZulIMZ0p3UwNZs7hnfoordvMOsb4J3BK7OX5pwrZgb+8+KnYoZCBn9tTN+Pv6eWkl+NDflDCJf8D7RWtqB9wK2imNqtxwgmq1Rx77xvJSomAWPMBSklMd4ogk0/QLxiRlgVVEWHcvV1C7b3QZYzNrIUBWlZ+lDbAUQMnCMZJTiLH2K27gpohGmziGmQSxsF4KwMUOAUOsYfCwnwV0asQ9LCAAf0Y5Dd/QI5kWNDsYIplREyRS4LSEAqAsxma7uU3ix3oH9CQEIuZih6VrcfOLvWFHexFTHF8q5UDW9k6LOMEfb2W2OFMtrGKrIDNQAkDNj0sKH3N+TChgXfNOwjbFLWeNdBL9eol6SlwvFat4sgTBIwyNvMpAY6pwEHMr1WyvEi+OsrCia0HGLlHQ+zg2VH7DWcgXNiiUwr7Pwbhb6pHkZrv/Ij7hOAdoIBGj3YaoxumnNHFpObbXGO+OQQef/CHfvlp2hkQcRAAJ7X28vBRy7LhAq3O1HBUvSnqAZQqX/lCqgy8e1+TERbSzIp5nztG1smXqVueGFbXCMstnUqY2cJdAhmt4nsc2jGnAk8fMXToSRF7F46SHmJxH1voSdFmA=="
    
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
