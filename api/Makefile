DOCKER_REGISTRY ?= sprql
DOCKER_IMAGE ?= addressbook-api
IMAGE_TAG ?= latest

build:
	docker build --rm --force-rm --pull -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG} .

push:
	docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}
