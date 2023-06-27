import os
import requests
import datetime
import subprocess
import boto3
from botocore.exceptions import ClientError


class CustomException(Exception):
    def __init__(self, message):
        super().__init__(message)

def get_github_token() -> str:
    secret_name = "jfrog/github/token"
    region_name = "ap-south-1"
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name="secretsmanager",
        region_name=region_name
    )
    try:
        github_token = client.get_secret_value(
            SecretId=secret_name
        )
        return github_token
    except ClientError as e:
        print(e)
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise CustomException('Github token can not be fetched from secrets')

def get_latest_commit_sha(owner: str, repo_name: str, github_token: str) -> str:
    try:
        # Set the base URL for the GitHub API
        base_url = f"https://api.github.com/repos/{owner}/{repo_name}"

        # Get the latest commit
        commits_url = f"{base_url}/commits"
        response = requests.get(commits_url, headers={"Authorization": f"Bearer {github_token}"})
        response.raise_for_status()
        latest_commit_sha = response.json()[0]["sha"]

        print(f"Latest commit SHA: {latest_commit_sha}")

        return latest_commit_sha
    except Exception as e:
        print(e)
        raise CustomException("Failed to get latest commit SHA")

def check_or_create_tag(owner: str, repo_name: str, github_token) -> bool:
    try:
        base_url = f"https://api.github.com/repos/{owner}/{repo_name}"

        # Get all tags 
        response = requests.get(f"{base_url}/tags").json()
        print(response)

        current_datetime = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        new_tag = f"v{current_datetime}"
        
        target_commit_sha = get_latest_commit_sha(owner, repo_name, github_token)
        print("target commit sha", target_commit_sha, sep=" :: ")
        
        print("Creating tag")
        tag_data = {
            "tag": new_tag,
            "message": f"Creating tag {new_tag}",
            "object": target_commit_sha,
            "type": "commit"
        }
        tag_url = f"{base_url}/git/tags"
        response = requests.post(tag_url, headers={"Authorization": f"Bearer {github_token}"}, json=tag_data)
        response.raise_for_status()
        tag_sha = response.json()["sha"]
        print("Tag sha", tag_sha, sep=" :: ")

        print("Creating ref")
        ref_data = {
            "ref": f"refs/tags/{new_tag}",
            "sha": tag_sha
        }
        ref_url = f"{base_url}/git/refs"
        response = requests.post(ref_url, headers={"Authorization": f"Bearer {github_token}"}, json=ref_data)
        response.raise_for_status()

        print("Push ref tags to remote")
        push_url = f"{base_url}/git/refs/tags/{new_tag}"
        response = requests.patch(push_url, headers={"Authorization": f"Bearer {github_token}"}, json=ref_data)
        response.raise_for_status()
        print(f"Created new tag: {new_tag}")
        return True
    except Exception as e:
        print(e)
        return False

def create_release_note(owner: str, repo: str, github_token: str) -> str:
    try:
        # Set the base URL for the GitHub API
        # Set the base URL for the GitHub API
        base_url = f"https://api.github.com/repos/{owner}/{repo}"

        # Retrieve the latest release
        tags_url = f"{base_url}/tags"
        response = requests.get(tags_url, headers={"Authorization": f"Bearer {github_token}"})
        response.raise_for_status()
        tags = response.json()


        if len(tags) == 1:
            print("Not enough releases found.")
            release_tag = tags[0]["name"]
            # Retrieve all the commits
            commits_url = f"{base_url}/commits"
            response = requests.get(commits_url, headers={"Authorization": f"Bearer {github_token}"})
            response.raise_for_status()
            commits = response.json()

            release_note = f"Initial release ({release_tag}):\n\n"
            for commit in commits:
                release_note += f"- {commit['commit']['message']}\n"
        else:
            latest_release_tag = tags[0]["name"]
            previous_release_tag = tags[1]["name"]

            # Retrieve the commits between the latest two releases
            commits_url = f"{base_url}/compare/{previous_release_tag}...{latest_release_tag}"
            response = requests.get(commits_url, headers={"Authorization": f"Bearer {github_token}"})
            response.raise_for_status()
            commits = response.json()["commits"]

            # Generate the release note from commit messages
            release_note = f"Changelog between {previous_release_tag} and {latest_release_tag}:\n\n"
            for commit in commits:
                release_note += f"- {commit['commit']['message']}\n"

        # Create the release note
        return release_note
    except Exception as e:
        print(e)
        raise CustomException("Failed to create release note!")

def create_github_release(owner: str, repo_name: str, githu_token: str, dist_path: str) -> bool:
    try:
        base_url = f"https://api.github.com/repos/{owner}/{repo_name}"

        print("Getting latest tag")
        # Retrieve the tags
        tags_url = f"{base_url}/tags"
        response = requests.get(tags_url, headers={"Authorization": f"Bearer {githu_token}"})
        response.raise_for_status()
        tags = response.json()

        # Get the latest tag
        latest_tag = tags[0]["name"]

        print(f"The latest tag is: {latest_tag}")

        release_note = create_release_note(owner, repo_name, githu_token)
        # Create the release payload
        release_payload = {
            "tag_name": latest_tag,
            "name": latest_tag,
            "body": release_note
        }

        print("Making release")
        # Make the API request to create the release
        response = requests.post(f"{base_url}/releases", json=release_payload, headers={"Authorization": f"Bearer {githu_token}"})

        # Extract the release ID from the response
        release_id = response.json().get("id")

        print(f"Created release {latest_tag} with ID {release_id}")
        upload_url = response.json().get("upload_url").replace("{?name,label}", "")
        print(f"upload url :: {upload_url}")
        if dist_path is not None:
            print(os.getcwd())
            os.chdir(f'/mnt/efs/{repo_name}/{dist_path}')
            list_dir = os.listdir(f'/mnt/efs/{repo_name}/{dist_path}')
            print(list_dir)
            if list_dir:
                for name in list_dir:
                    if not os.path.isdir(name):
                        # open the file & upload 
                        # setting the content type as octet-stream but it may vary 
                        with open(name, 'rb') as file:
                            response = requests.post(f"{upload_url}?name={name}", data=file, headers={"Authorization": f"Bearer {githu_token}", "Content-Type": "application/octet-stream"})
            else:
                print(f"Directory {dist_path} is empty!")
        else:
            print("Dist path is None")

        return True
    except Exception as e:
        print(e)
        return False

def handler(event, context):
    try:
        print(event)
        print(context)
        dist_path = event.get("asset_path")
        owner =  event.get("repo_owner")
        repository = event.get("repo_name")
        github_token = get_github_token()
        print(github_token)
        efs_mount = "/mnt/efs/"

        # Change to the EFS directory
        os.chdir(efs_mount)

        if os.path.isdir(repository):
            print("Directory exists")
            os.chdir(repository)
        else:
            raise CustomException(f"Repo {repository} does exist on {efs_mount}")
        # subprocess.run(["git", "config", "--global", "user.name", owner])
        # subprocess.run(["git", "config", "--global", "--add", "safe.directory", f"{efs_mount}{repository}"])
        result = check_or_create_tag(owner, repository, github_token)

        if result:
            result = create_github_release(owner, repository, github_token, dist_path)

            if result:
                print("Successfully made release and uploaded assets")
            else:
                raise CustomException("Failed to make new release")
        else:
            raise CustomException("Failed to create new tag")
        # Unmount EFS file system
        # subprocess.run(["umount", "/mnt/efs"])

        response = {"statusCode": 200, "body": "Success"}
        return response
    except  Exception as e:
        print(e)