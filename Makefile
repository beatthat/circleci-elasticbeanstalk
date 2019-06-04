SHELL:=/bin/bash
CURDIR=$(shell pwd)
PROJECT_ROOT=$(shell git rev-parse --show-toplevel 2> /dev/null)
PROJECT_NAME=$(shell basename "$(PROJECT_ROOT)" | tr [:upper:] [:lower:])
BUILD=$(CURDIR)/build
CONFIG=$(PROJECT_ROOT)/config
HOME_DIR=$(shell cd ~; pwd)
GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
GIT_HASH:=$(shell git rev-parse HEAD)
GIT_STATUS=$(shell git status -s)
DOCKER_PASSWORD_FILE:="$(HOME)/.docker/$(DOCKER_ACCOUNT).password"
DOCKER_ACCOUNT?=larrykirschner
DOCKER_REPO?=circleci-elasticbeanstalk
DOCKER_TAG?=latest
DOCKER_IMAGE?=${DOCKER_ACCOUNT}/${DOCKER_REPO}:${DOCKER_TAG}
DOCKER_CONTAINER=${DOCKER_REPO}
DOCKER_PASSWORD_FILE := "$(HOME)/.docker/$(DOCKER_ACCOUNT).password"

##############################################################################
# Build docker images for the services we're about to publish to ebs.
# These images will be tagged with the git commit hash 
# that we have cloned into build/clone
##############################################################################
.PHONY: docker-build 
docker-build:
	docker build -t ${DOCKER_IMAGE} .


##############################################################################
#
# Tries to ensure user is logged in to docker image repo (dockerhub by default)
# as  user DOCKER_USER.
#
# Will trigger an interactive prompt for password *unless* user has stored
# their password in ~/.docker/$(DOCKER_USER).password
#
# e.g. echo mypasswordhere > ~/.docker/uscict.password && chmod 600 ~/.docker/uscict.password
##############################################################################
.PHONY: docker-login 
docker-login:
ifneq ("$(wildcard $(DOCKER_PASSWORD_FILE))","")
	@echo "store your docker password at $(DOCKER_PASSWORD_FILE) so you won't have to enter it again"
	docker login -u $(DOCKER_ACCOUNT)
else
	cat $(DOCKER_PASSWORD_FILE) | docker login -u $(DOCKER_ACCOUNT) --password-stdin
endif


##############################################################################
# Push docker images (to dockerhub.io) for the services we're about to publish to ebs.
# These images will be tagged with the git commit hash 
# that we have cloned into build/clone
##############################################################################
.PHONY: docker-push 
docker-push: docker-login
	docker push ${DOCKER_IMAGE}
