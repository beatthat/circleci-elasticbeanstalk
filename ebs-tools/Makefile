SHELL:=/bin/bash
PWD=$(shell pwd)
PROJECT_ROOT?=$(shell git rev-parse --show-toplevel 2> /dev/null)
PROJECT_NAME?=$(shell basename "$(PROJECT_ROOT)" | tr [:upper:] [:lower:])
BUILD=$(CURDIR)/build
HOME_DIR=$(shell cd ~; pwd)
BUILD_TAG?=$(shell git rev-parse HEAD)
###############################################################################
# The name of the Elastic Beanstalk App
# By default/convention, assumes the EBS app name matches the project name
###############################################################################
EB_APP?=$(PROJECT_NAME)
###############################################################################
# The name of the Elastic Beanstalk Env to which we will deploy
# By default/convention uses the git branch
# having the same name as the locally checked out branch.
# This helps enable eb rules that work withouthand configuration.
###############################################################################
EB_ENV?=$(shell git rev-parse --abbrev-ref HEAD)
EB_REGION?=us-east-1
DOCKER_ACCOUNT?=
DOCKER_SERVICES=$(PWD)/bin/docker_services.sh
EB=eb

clean:
	rm -rf build

##############################################################################
# Create a properties file that will be used to configure the final
# build/ebs/.elasticbeantstalk/config.yml
##############################################################################
build/ebs/config/.elasticbeanstalk_config.properties:
	mkdir -p build/ebs/config
	@echo "EB_REGION=$(EB_REGION)" > build/ebs/config/.elasticbeanstalk_config.properties
	@echo "EB_APP=$(EB_APP)" >> build/ebs/config/.elasticbeanstalk_config.properties
	@echo "EB_ENV=$(EB_ENV)" >> build/ebs/config/.elasticbeanstalk_config.properties
	@echo "EB_BUNDLE_ZIP=$(EB_BUNDLE_ZIP)" >> build/ebs/config/.elasticbeanstalk_config.properties
	@echo "" >> build/ebs/config/.elasticbeanstalk_config.properties


##############################################################################
# Create a properties file that will be used to configure the final
# build/ebs/bundle/Dockerrun.aws.json
##############################################################################
build/ebs/config/Dockerrun.aws.properties:
	mkdir -p build/ebs/config
	$(DOCKER_SERVICES) \
			--account $(DOCKER_ACCOUNT) \
			--docker-repo-prefix $(PROJECT_NAME) \
			--tag $(BUILD_TAG) \
			-o $(BUILD)/ebs/config/Dockerrun.aws.properties \
		properties

build/ebs/config: build/ebs/config/Dockerrun.aws.properties build/ebs/config/.elasticbeanstalk_config.properties

##############################################################################
# The contents of build/ebs/.elasticbeanstalk/config.yml
# will control the deployment to EBS
##############################################################################
build/ebs/.elasticbeanstalk/config.yml: build/ebs/config/.elasticbeanstalk_config.properties
	mkdir -p build/ebs
	cp -r $(PROJECT_ROOT)/ebs/.elasticbeanstalk build/ebs/.elasticbeanstalk
	python bin/apply_properties.py \
		$(BUILD)/ebs/config/.elasticbeanstalk_config.properties \
		$(BUILD)/ebs/.elasticbeanstalk/config.yml


build/ebs/.elasticbeanstalk: build/ebs/.elasticbeanstalk/config.yml


##############################################################################
# build/ebs/bundle is what gets bundled and deployed to EBS.
# Centrally, it contains Dockerrun.aws.json
# It will be populated with config and secrets, then zipped 
# into an archive and published to EBS
##############################################################################
build/ebs/bundle: build/ebs/config/Dockerrun.aws.properties
	mkdir -p build/ebs
	cp -r $(PROJECT_ROOT)/ebs/bundle $(BUILD)/ebs/bundle
	python bin/apply_properties.py \
		$(BUILD)/ebs/config/Dockerrun.aws.properties \
		$(BUILD)/ebs/bundle/Dockerrun.aws.json


build/ebs: build/ebs/.elasticbeanstalk/config.yml build/ebs/bundle


##############################################################################
# build/ebs/(bundle-name).zip is the actual file that gets published
# to EBS. It will contain Dockerrun.aws.json
##############################################################################
EB_BUNDLE_ZIP := $(EB_ENV)-$(BUILD_TAG).zip
$(EB_BUNDLE_ZIP): build/ebs
	cd build/ebs/bundle && \
		zip ../$(EB_BUNDLE_ZIP) -r *


build: build/ebs/config build/ebs/bundle build/ebs/.elasticbeanstalk

##############################################################################
# Build docker images for the services we're about to publish to ebs.
# These images will be tagged with the BUILD_TAG
##############################################################################
.PHONY: docker-build 
docker-build:
	$(DOCKER_SERVICES) \
			--account $(DOCKER_ACCOUNT) \
			--docker-repo-prefix $(PROJECT_NAME) \
			--tag $(BUILD_TAG) \
		build

.PHONY: docker-login 
docker-login:
ifeq ("$(DOCKER_ACCOUNT)","")
    echo "env var DOCKER_ACCOUNT"
	exit 1
endif
ifeq ("$(DOCKER_PASSWORD)","")
	echo "env var DOCKER_PASSWORD must be set for account ${DOCKER_ACCOUNT}"
	exit 1
endif
	echo $${DOCKER_PASSWORD} | docker login -u $(DOCKER_ACCOUNT) --password-stdin


##############################################################################
# Push docker images (to dockerhub.io) for the services we're about to publish to ebs.
# These images will be tagged with the BUILD_TAG
##############################################################################
.PHONY: docker-push 
docker-push: docker-login
	$(DOCKER_SERVICES) \
			--account $(DOCKER_ACCOUNT) \
			--docker-repo-prefix $(PROJECT_NAME) \
			--tag $(BUILD_TAG) \
		push


.PHONY: eb-deploy 
eb-deploy: $(EB_BUNDLE_ZIP)
	cd build/ebs && \
		$(EB) use $(EB_ENV) && \
		$(EB) deploy