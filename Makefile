# import deploy file
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# import config file
cfg ?= config.env
include $(cfg)
export $(shell sed 's/=.*//' $(cfg))

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

NEXUS_REPO		        :=$(OWNER):$(NEXUS_PORT)
TAG				:=$(IMAGE_NAME):$(IMAGE_VERSION)
DOCKER_IMAGE_NAME		:=$(NEXUS_REPO)/$(IMAGE_NAME)
FILE_TAR                        :=./$(IMAGE_NAME).tar
FILE_GZ                         :=$(FILE_TAR).gz
UNAME_S                         :=$(shell uname -apps)
ifeq ($(UNAME_S),Linux)
    APP_HOST                    :=localhost
endif
ifeq ($(UNAME_S),Darwin)
    APP_HOST                    :=$(shell docker-appmachine ip default)
endif

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
build: ## Build the release container.
	docker build -t $(IMAGE_NAME) --build-arg NEXUS_VERSION=$(IMAGE_VERSION) .

build-nc: ## Build the container without caching
	docker build --no-cache -t $(IMAGE_NAME) --build-arg NEXUS_VERSION=$(NEXUS_VERSION) .

run: ## Run container on port configured in `config.env`
	docker run -d -p $(PORT1):8081 -p $(PORT2):8082 -p $(PORT3):8083 --name nexus --restart=always -v ~/rpi-nexus/nexus-data:/usr/local/nexus/data --name=nexus $(IMAGE_NAME)

dev: build-nc run ## Run container in development mode

up: build run ## Run container on port configured in `config.env` (Alias to run)

stop: ## Stop and remove a running container
	docker stop nexus; docker rm nexus

publish: tag publish-latest publish-version ## Publish the `{version}` and `latest` tagged containers to Nexus Repository

publish-latest: tag-latest ## Publish the `latest` tagged container to Nexus Repository
	@echo 'publish latest to Nexus Repository'
	docker push $(DOCKER_IMAGE_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container to Nexus repository
	@echo 'publish $(IMAGE_VERSION) to Nexus Repository'
	docker push $(DOCKER_IMAGE_NAME):$(IMAGE_VERSION)

tag: tag-latest tag-version ## Generate container tags for the `{version}` and `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(IMAGE_NAME):latest $(DOCKER_IMAGE_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(IMAGE_VERSION)'
	docker tag $(IMAGE_NAME):latest $(DOCKER_IMAGE_NAME):$(IMAGE_VERSION)

save: ## Save the container as a gzip file
	docker image save $(DOCKER_IMAGE_NAME):$(IMAGE_VERSION) > $(FILE_TAR)
	@[ -f $(FILE_TAR) ] && gzip $(FILE_TAR) || true

load: ## Load the container from a gzip file
	@[ -f $(FILE_GZ) ] && gunzip $(FILE_GZ) || true
	@[ -f $(FILE_TAR) ] && docker load -i $(FILE_TAR) && gzip $(FILE_TAR) || true

sonar: ## Run sonar to analyze code
	sonar-scanner

dangling: ## Remove temporary images
	@docker rmi $$(docker images -a -q -f dangling=true)

remove: ## Remove current image
	docker rmi -f $(IMAGE_NAME)

rebuild: remove build ## Remove and build

removecontainers: ## Stop and remove all containers
	docker stop $$(docker ps -a -q) && docker rm $$(docker ps -a -q)

clean: ## Remove node_modules
	@rm -rf node_modules

create-dir: ## create nexus-data directory
	mkdir ~/projetos/dados/nexus-data
	sudo chown -R 200:200 ~/projetos/dados/nexus-data

repo-login: ## Auto login to dockerhub
	docker login -u $(NEXUS_REPO_USER) -p $(NEXUS_REPO_PASS) raspberrypi4.local:$(PORT2)
	docker login -u $(NEXUS_REPO_USER) -p $(NEXUS_REPO_PASS) raspberrypi4.local:$(PORT3)

nexus-pass: ##  buscando a senha no servidor
	docker exec -it nexus cat /usr/local/sonatype-work/nexus3/admin.password

pull: ## faz download da última versão do repositório
	docker pull $(DOCKER_IMAGE_NAME):latest

log: ## see logs
	docker logs -f nexus
