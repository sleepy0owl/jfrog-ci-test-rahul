const { execSync } = require("child_process");

exports.handler = async (event) => {
  console.log(
    execSync("cp -r /mnt/efs/ACD-Serverless-Leave-Approval/s3-website  /tmp/ACD-Serverless-Leave-Approval").toString()
  );
  
  console.log(
    execSync(
      "yarn --cwd /tmp/ACD-Serverless-Leave-Approval install"
      // "npm install --prefix /tmp/ACD-Serverless-Leave-Approval"
    ).toString()
  );
  
  console.log(
    execSync(
      "yarn --cwd /tmp/ACD-Serverless-Leave-Approval build"
      // "npm install --prefix /tmp/ACD-Serverless-Leave-Approval"
    ).toString()
  );
  
  
  console.log(
    execSync(
      "aws s3 sync /tmp/ACD-Serverless-Leave-Approval/build s3://$(jq -r '.S3BucketName' /mnt/efs/ACD-Serverless-Leave-Approval/parameters.json)"
    ).toString()
  );
  const response = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda!"),
  };
  return response;
};
