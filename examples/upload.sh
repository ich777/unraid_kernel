#!/bin/bash
# Get current uname
UNAME=$(uname -r)

#Set your GitHub username either with a file or with variables like:
#export GITHUB_USER=NOTEFROMTOKEN
#export GITHUB_TOKEN=YOURTOKENHERE
#
# To create a token go to: https://github.com/settings/tokens click on Generate
# new token button, select Generate new token (classic) enter you credentials 
# enter a Note <- this will be the user name and make sure the token has access
# to:repo:status, public_repo, repo_deployment and workflow

#Set variables for GitHub Upload
GITHUB_USERNAME="ich777"
GITHUB_REPO_NAME="unraid-nct6687-driver"
GITHUB_TARGET="master"

# Create tag for release with description
github-release release \
  --user $GITHUB_USERNAME \
  --repo $GITHUB_REPO_NAME \
  --tag $UNAME \
  --name "$UNAME" \
  --description "NCT6687 plugin package(s) for Unraid Kernel v${UNAME%%-*} by ich777"

# Sleep a bit (to avoid upload issues)
sleep 5

# Change to direcotry where driver package is located
cd ${DATA_DIR}/$UNAME

# Upload all files in this directory to the before created tag
ls -1 | xargs -n1 -P0 -I{} -- \
github-release upload \
  --user $GITHUB_USERNAME \
  --repo $GITHUB_REPO_NAME \
  --tag $UNAME \
  --name {} \
  --file {}
