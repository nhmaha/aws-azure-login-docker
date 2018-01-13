ifeq ($@, create-ecr-repo)
ifndef AWS_REGION
  $(error AWS_REGION is undefined)
endif
endif

ifndef CREDENTIALS_ROOT
  CREDENTIALS_ROOT=~/.aws
endif

APP_NAME=aws-azure-login
VERSION=$(shell git rev-parse --short HEAD)
VERSION=latest

REPO=nhmaha/$(APP_NAME)

default: update-stack

build:
	docker build -t $(REPO):$(VERSION) .
	docker tag $(REPO):$(VERSION) $(REPO):latest
	docker tag $(REPO):$(VERSION) $(APP_NAME):latest

push: build
	docker push $(REPO):$(VERSION)
	docker push $(REPO):latest

login: build
	mkdir -p $(CREDENTIALS_ROOT)
	docker run --rm -p80:80 --name aws-azure-login -e TENNANT_ID=9864e03f-6a48-4ed4-9b87-d3d0afb56740 -e EMAIL_ADDRESS=$(EMAIL_ADDRESS) -v $(CREDENTIALS_ROOT):/home/pptruser/.aws/ --cap-add SYS_ADMIN -ti nhmaha/aws-azure-login

shell: setup_volume
	docker run --rm -p80:80 --name $(APP_NAME) -v `pwd`/container_volume:/home/pptruser/.aws/ --cap-add SYS_ADMIN -ti $(APP_NAME) /bin/bash
