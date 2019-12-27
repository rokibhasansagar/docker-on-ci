BUILDX_VER=v0.3.0
CI_NAME?=local
IMAGE_NAME=${DOCKER_USERNAME}/docker-on-ci
VERSION?=latest

install:
	mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
	curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx
	ls -Alhs /proc/sys/fs/binfmt_misc/ || true
	ls -Ahs /usr/bin/qemu-* || true

prepare: install
	docker buildx create --use
	docker buildx inspect --bootstrap

prepare-old: install
	docker context create old-style
	docker buildx create old-style --use

build-push:
	docker buildx build --compress --no-cache --rm --force-rm --push \
		--build-arg CI_NAME=${CI_NAME} \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%S%Z"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git remote get-url origin` \
		--build-arg VERSION='1.0' \
		--platform linux/amd64,linux/386,linux/arm64/v8,linux/arm/v7,linux/arm/v6,linux/ppc64le,linux/s390x \
		-t ${IMAGE_NAME}:${VERSION}-${CI_NAME} .
