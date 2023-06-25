import { execSync } from "child_process";

export const lambdaHandler = async (event) => {
  const directoryPath = "/mnt/efs";

  try {
    // console.log(execSync("yarn --prefix /mnt/efs/ACD-Serverless-Leave-Approval/s3-website build").toString())
    console.log(
      execSync(
        "ls /mnt/efs/ACD-Serverless-Leave-Approval/s3-website"
      ).toString()
    );

    console.log(
      execSync(
        "ls -al /mnt/efs/ACD-Serverless-Leave-Approval/s3-website/node_modules"
      ).toString()
    );
    const remove = execSync(
      "rm -rf /mnt/efs/ACD-Serverless-Leave-Approval/s3-website/node_modules"
    ).toString();

    // console.log(directoryContents)
    // const mv =  execSync("mv /mnt/efs/ACD-Serverless-Leave-Approval /mnt/efs/ACD-Serverless-Leave-Approval4r").toString();
    // const perm = execSync("chmod -R 777 /mnt/efs").toString();
    // const deletesuff =  execSync("rm -r /mnt/efs/ACD-Serverless-Leave-Approval2").toString();

    // console.log(deletesuff)

    const response = {
      statusCode: 200,
      body: JSON.stringify("bruh"),
    };
    return response;
  } catch (error) {
    const response = {
      statusCode: 500,
      body: JSON.stringify("Error listing directory contents."),
    };
    return response;
  }
};
