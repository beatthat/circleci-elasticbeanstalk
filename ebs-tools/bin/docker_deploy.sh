#!/bin/bash
#
# Builds and deploys a Docker image.

set -o errexit

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOCKER_REGISTRY=${DOCKER_REGISTRY}
DOCKER_REGISTRY_PREFIX=${DOCKER_REGISTRY}${DOCKER_REGISTRY:+/}
DOCKER_REPONAME=${DOCKER_REPONAME:-${CIRCLE_PROJECT_REPONAME}}

source ${DIR}/lib/getopts_long.bash

while getopts_long ":n: reponame:" OPT_KEY; do
  case ${OPT_KEY} in
    'n' | 'reponame' )
      DOCKER_REPONAME=$OPTARG
      ;;
    '?' )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    ':' )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

repo_url="${DOCKER_REGISTRY_PREFIX}${DOCKER_REPONAME}"
image_latest_tag="${repo_url}:latest"
image_sha_tag="${repo_url}:${CIRCLE_SHA1}"

echo "Building and deploying ${DOCKER_REPONAME} image ..."

# Log-in to ECR.
# eval "$(aws ecr get-login --no-include-email)"
echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_ACCOUNT} --password-stdin

# Populate some meta-data.
echo "${CIRCLE_BRANCH}/${CIRCLE_SHA1}" > build-info.txt

# Docker building and pushing.

docker pull "${image_latest_tag}" || true  # The latest image might not exist.

if [[ $DOCKERFILE = "" ]]; then
  docker build --cache-from "${image_latest_tag}" --tag "${image_sha_tag}" .
else
  docker build --cache-from "${image_latest_tag}" --tag "${image_sha_tag}" \
    --file "${DOCKERFILE}" .
fi

docker push "${image_sha_tag}"

if [[ $CIRCLE_BRANCH == "master" ]]; then
  docker tag "${image_sha_tag}" "${image_latest_tag}"
  docker push "${image_latest_tag}"
fi

# if this is a release, then push the release tag as a tag for the docker image
if [[ "${CIRCLE_TAG}" != "" ]]; then
  image_release_tag="${repo_url}:${CIRCLE_TAG}"
  docker tag "${image_sha_tag}" "${image_release_tag}"
  docker push "${image_release_tag}"
fi