#! /bin/bash
# Set up error handling
trap 'handle_error' ERR

git clone https://github.com/k3d-io/k3d.git 
echo "MOVING TO REPO"
cd  k3d 
echo ci-steup
make ci-setup
export GOPATH=$HOME/go && export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
echo "runing make file"
make gen-checksum build-cross
aws s3 sync _dist/ s3://rahul-yamamto-test/artifact/ 

echo "Deployment Finished"
RESPONSE="{\"statusCode\": 200, \"body\": \"Successfull\"}"
echo $RESPONSE