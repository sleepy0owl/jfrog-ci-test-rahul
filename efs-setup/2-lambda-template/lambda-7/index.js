const { execSync } = require("child_process");

exports.handler = async (event) => {
  console.log(
    execSync("cd /mnt/efs/ACD-Serverless-Leave-Approval/s3-website").toString()
  );
  console.log(execSync("ls").toString());
  console.log(
    execSync(
      "npm --cwd /mnt/efs/ACD-Serverless-Leave-Approval/s3-website  install --verbose"
    ).toString()
  );
  console.log(
    execSync(
      "npm  --cwd /mnt/efs/ACD-Serverless-Leave-Approval/s3-website build --verbose"
    ).toString()
  );
  console.log(
    execSync(
      "aws s3 sync /mnt/efs/ACD-Serverless-Leave-Approval/s3-website/build s3://$(jq -r '.S3BucketName' /mnt/efs/ACD-Serverless-Leave-Approval/parameters.json)"
    ).toString()
  );
  const response = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda!"),
  };
  return response;
};
