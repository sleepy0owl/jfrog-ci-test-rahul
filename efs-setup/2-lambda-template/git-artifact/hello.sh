# Define a function to handle errors
function handle_error() {
  echo "An error occurred. Exiting..."
  exit 1
}

function check_or_create_tag() {
    repo_owner="<owner>"
    repo_name="<repository>"
    api_url="https://api.github.com/repos/${repo_owner}/${repo_name}/tags"

    # Make the API request
    response=$(curl -s ${api_url})

    # Check if the repository has tags
    if [ -z "${response}" ]; then
        # Repository doesn't have any tags, create a new tag
        current_datetime=$(date +'%Y%m%d%H%M%S')
        new_tag="v${current_datetime}"

        # Create the new tag
        git tag ${new_tag}
        git push origin ${new_tag}

        echo "Created new tag: ${new_tag}"
    else
        # Repository has tags, retrieve the latest tag name
        latest_tag=$(echo ${response} | jq -r '.[0].name')
        echo "Latest tag: ${latest_tag}"
    fi
}

# NEED TO GET THE GITHUB REF THAT TRIGGERED THE CI/CD
function handler(){
    # Set up error handling
    trap 'handle_error' ERR

    echo "$(pwd)"
    ls -la

    # Mount EFS file system
    # mkdir -p /mnt/efs
    # mount -t efs fs-0de610d45fec9a6de:/ /mnt/efs

    cd /mnt/efs/

    if [ -d "$directory" ]; then
      echo "Directory exists"
      cd ACD-Serverless-Leave-Approval
    else
      echo "Directory does not exist"
      git clone git clone https://github.com/sandykumar93/ACD-Serverless-Leave-Approval.git
      cd ACD-Serverless-Leave-Approval
    fi
    
    echo "Checking and creating tag"
    check_or_create_tag
    # Unmount EFS file system
    # umount /mnt/efs
    RESPONSE="{\"statusCode\": 200, \"body\": \"bruh\"}"
    echo $RESPONSE

}