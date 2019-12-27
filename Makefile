BUILDX_VER=v0.3.0
CI_NAME?=local
IMAGE_NAME=${DOCKER_USERNAME}/udemy-dl
VERSION?=latest

install:
	mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
	curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx

prepare: install
	docker buildx create --use

prepare-old: install
	docker context create old-style
	docker buildx create old-style --use

build-push:
	docker buildx build --push \
		--build-arg CI_NAME=${CI_NAME} \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%S%Z"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git remote get-url origin` \
		--build-arg VERSION='1.0' \
		--platform linux/arm/v7,linux/arm64/v8,linux/386,linux/amd64 \
		-t ${IMAGE_NAME}:${VERSION}-${CI_NAME} .
