import os
from datetime import date

import requests
import boto3

aws_region          = os.getenv('AWS_REGION', "eu-north-1")
github_repositories = os.getenv('GITHUB_REPOSITORIES')
include_prerelease  = os.getenv('INCLUDE_PRERELEASE', "False")
environment         = os.getenv('ENV', "dev")

dynamodb_versions = boto3.resource('dynamodb', region_name=aws_region).Table(f'stay_updated_{environment}')

# Convert tag name to version ex. v4.0 -> 40
def version_to_int(tag_name):
  return int(tag_name.replace("v", "").replace(".",""))

# Get repo latest release
def get_release(owner, repo, include_prerelease):
  headers  = {'Accept': 'application/vnd.github.v3+json'}
  response = requests.get(f'https://api.github.com/repos/{owner}/{repo}/releases/latest', headers=headers).json()
  is_prerelease = bool(response["prerelease"])
  if (include_prerelease == False & is_prerelease == True):
    return ''
  
  return response

# Get latest version from DynamoDB
def get_version(repo):
  response = dynamodb_versions.get_item(
    Key={'Name': f'{repo}'},
  )
  
  if 'Item' in response:
    return version_to_int(response['Item']['Version'])

  return 0

# Update version in DynamoDB
def update_version(repo, version):
  dynamodb_versions.update_item(
    Key={'Name': f'{repo}'},
    AttributeUpdates={
      'Version': {
        'Value': version
      },
    }
  )

# Create change log file
def create_changelog_file(repo, release_tag_name, url, release_body):
  path           = "./changelogs"
  changelog_file = date.today().strftime(f'{path}/%Y-%m-%d.md')

  if not os.path.exists(path):
    os.makedirs(path)

  with open(changelog_file, "a") as changelog:
    changelog.write(f'## [{repo} ({release_tag_name})]({url})\n')
    changelog.write(release_body)
    changelog.write("\n\n<br>\n\n")

if __name__ == "__main__":
  for github_repository in github_repositories.split(','):
    owner   = github_repository.split('/')[0]
    repo    = github_repository.split('/')[1]
    release = get_release(owner, repo, include_prerelease)

    if release != '':
      release_body     = release['body']
      release_tag_name = release['tag_name']
      url              = release['html_url']

      if version_to_int(release['tag_name']) > get_version(repo):
        print(f'There is new {owner}/{repo} version:', release_tag_name)
        #update_version(repo, release_tag_name)
        create_changelog_file(repo, release_tag_name, url, release_body)
        
