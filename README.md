circleci-elasticbeanstalk
================

This is an image for doing CI things on projects that use Elastic Beanstalk.

It contains:

- AWS CLI
- CircleCI deployment Makefile and scripts ( under `/ebs-tools`)

Variables
---------

The following environment variables must be defined within CI project settings:

- **AWS_ACCESS_KEY_ID**: AWS Access Key ID.
- **AWS_DEFAULT_REGION**: The AWS region to use.
- **AWS_SECRET_ACCESS_KEY**: AWS Secret Access Key.

Development
-----------

Currently, this image is semantically versioned. When making changes that you want to test in another project, create a branch and PR and then you can release a test tag one of two ways:

To build/push a tag of `circleci-elasticbeanstalk` for the current commit in your branch

- find the `docker_tag_commit` workflow for your commit in [circleci](https://circleci.com/gh/beatthat/workflows/circleci-elasticbeanstalk)
- approve the workflow
- this will create a tag like `${DOCKER_REGISTRY}/${DOCKER_ACCOUNT}/circleci-elasticbeanstalk:${COMMIT_SHA}`

To build/push a pre-release semver tag of `circleci-elasticbeanstalk` for the current commit in your branch

- create a [github release](https://github.com/beatthat/circleci-elasticbeanstalk/releases/new) **from your development branch** with tag format `/^\d+\.\d+\.\d+(-[a-z\d\-.]+)?$/` (e.g. `1.0.0-alpha.1`)
- find the `docker_tag_release` workflow for your git tag in [circleci](https://circleci.com/gh/beatthat/workflows/circleci-elasticbeanstalk)
- approve the workflow
- this will create a tag like `${DOCKER_REGISTRY}/${DOCKER_ACCOUNT}/circleci-elasticbeanstalk:1.0.0-alpha.1`

Releases
--------


Once your changes are approved and merged to master, you should create a release tag in semver format as follows:

- create a [github release](https://github.com/beatthat/circleci-elasticbeanstalk/releases/new) **from master** with tag format `/^\d+\.\d+\.\d$/` (e.g. `1.0.0`)
- find the `docker_tag_release` workflow for your git tag in [circleci](https://circleci.com/gh/beatthat/workflows/circleci-elasticbeanstalk)
- approve the workflow
- this will create a tag like `${DOCKER_REGISTRY}/${DOCKER_ACCOUNT}/circleci-elasticbeanstalk:1.0.0`
