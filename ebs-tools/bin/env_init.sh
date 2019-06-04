#!/usr/bin/env bash
cannonical () {
  local s=$1
  s=$(echo $s | tr [:upper:] [:lower:])
  s=$(echo $s | perl -pe 's/[^a-zA-Z0-9\-\n]+/-/g')
  echo $s
}
export BUILD_TAG=${BUILD_TAG:-${CIRCLE_SHA1}}
export EB_ENV=${EB_ENV:-${CIRCLE_BRANCH}}
REPO_NAME=$(cannonical ${CIRCLE_PROJECT_REPONAME})
export PROJECT_NAME=${PROJECT_NAME:-${REPO_NAME}}