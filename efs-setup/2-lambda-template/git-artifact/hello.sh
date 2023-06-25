# Define a function to handle errors
function handle_error() {
  echo "An error occurred. Exiting..."
  exit 1
}

function check_or_create_tag() {
    repo_owner="sleepy0owl"
    repo_name="ACD-Serverless-Leave-Approval"
    api_url="https://api.github.com/repos/${repo_owner}/${repo_name}/tags"

    # Make the API request
    response=$(curl -s ${api_url})

    # Check if the repository has tags
    if [ -z "${response}" ]; then
        # Repository doesn't have any tags, create a new tag
        current_datetime=$(date +'%Y%m%d%H%M%S')
        new_tag="v${current_datetime}"

        # Create the new tag
        git tag "${new_tag}"
        git push origin "${new_tag}"

        echo "Created new tag: ${new_tag}"

    else
        # Repository has tags, retrieve the latest tag name
        latest_tag=$(echo "${response}" | jq -r '.[0].name')
        echo "Latest tag: ${latest_tag}"

    fi
}

function create_github_release() {
    repo_owner="sleepy0owl"
    repo_name="ACD-Serverless-Leave-Approval"
    api_url="https://api.github.com/repos/${repo_owner}/${repo_name}/releases"

    # Retrieve the latest tag
    latest_tag=$(git describe --tags --abbrev=0)

    # Retrieve the commits between the latest tag and the previous tag
    previous_tag=$(git describe --tags --abbrev=0 "${latest_tag}"^)
    commit_range="${previous_tag}..${latest_tag}"
    commit_logs=$(git log --pretty=format:"- %s" "${commit_range}")

    # Create a temporary directory for packaging
    temp_dir=$(mktemp -d)

    # Copy the source code to the temporary directory
    cp -R . "${temp_dir}/${repo_name}"

    # Create a zip file of the source code
    zip_file="${temp_dir}/${repo_name}.zip"
    cd "${temp_dir}" || exit
    zip -r "${zip_file}" "${repo_name}"

    # Create the release payload
    release_payload=$(cat <<EOF
{
    "tag_name": "${latest_tag}",
    "name": "${latest_tag}",
    "body": "${commit_logs}"
}
EOF
)

    # Make the API request to create the release
    response=$(curl -s -X POST -H "Authorization: Bearer ${GITHUB_TOKEN}" -H "Content-Type: application/json" -d "${release_payload}" ${api_url})

    # Extract the release ID from the response
    release_id=$(echo "${response}" | jq -r '.id')

    # Upload the zip file as a release asset
    upload_url=$(echo "${response}" | jq -r '.upload_url' | sed -e 's/{?name,label}//')
    upload_response=$(curl -s -X POST -H "Authorization: Bearer ${GITHUB_TOKEN}" -H "Content-Type: application/zip" --data-binary @"${zip_file}" "${upload_url}?name=${repo_name}.zip")

    echo "Created release ${latest_tag} with ID ${release_id}"
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

    cd /mnt/efs/ || exit
    ls -la

    directory="ACD-Serverless-Leave-Approval"
    if [ -d "$directory" ]; then
      echo "Directory exists"
      cd ACD-Serverless-Leave-Approval/ || exit
    else
      echo "Directory does not exist"
      git clone git clone https://github.com/sleepy0owl/ACD-Serverless-Leave-Approval.git
      cd ACD-Serverless-Leave-Approval/ || exit
    fi
    git config --global --add safe.directory /mnt/efs/ACD-Serverless-Leave-Approval
    
    echo "Checking and creating tag"
    check_or_create_tag

    echo "Creating Github release"
    create_github_release
    # Unmount EFS file system
    # umount /mnt/efs
    RESPONSE="{\"statusCode\": 200, \"body\": \"bruh\"}"
    echo "$RESPONSE"
}