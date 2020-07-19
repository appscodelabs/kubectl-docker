SHELL=/bin/bash -o pipefail

REGISTRY   ?= appscode
BIN        := kubectl
IMAGE      := $(REGISTRY)/$(BIN)
RELEASE    ?= 1.18
VERSION    ?= $(shell curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable-$(RELEASE).txt)

DOCKER_PLATFORMS := linux/386 linux/amd64 linux/arm64 linux/ppc64le linux/s390x
OS               ?= linux
ARCH             ?= amd64
TAG              = $(VERSION)_$(OS)_$(ARCH)

container-%:
	@$(MAKE) container                    \
	    --no-print-directory              \
	    OS=$(firstword $(subst _, ,$*))   \
	    ARCH=$(lastword $(subst _, ,$*))

push-%:
	@$(MAKE) push                         \
	    --no-print-directory              \
	    OS=$(firstword $(subst _, ,$*))   \
	    ARCH=$(lastword $(subst _, ,$*))

all-container: $(addprefix container-, $(subst /,_, $(DOCKER_PLATFORMS)))

all-push: $(addprefix push-, $(subst /,_, $(DOCKER_PLATFORMS)))

container:
	@echo "container: $(IMAGE):$(TAG)"
	@DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --platform $(OS)/$(ARCH) --build-arg OS=$(OS) --build-arg ARCH=$(ARCH) --build-arg VERSION=$(VERSION) --load --pull -t $(IMAGE):$(TAG) -f Dockerfile .
	@echo

push: container
	@docker push $(IMAGE):$(TAG)
	@echo "pushed: $(IMAGE):$(TAG)"
	@echo

.PHONY: manifest-version
manifest-version:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create -a $(IMAGE):$(VERSION) $(foreach PLATFORM,$(DOCKER_PLATFORMS),$(IMAGE):$(VERSION)_$(subst /,_,$(PLATFORM)))
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push $(IMAGE):$(VERSION)

.PHONY: manifest-release
manifest-release:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create -a $(IMAGE):v$(RELEASE) $(foreach PLATFORM,$(DOCKER_PLATFORMS),$(IMAGE):$(VERSION)_$(subst /,_,$(PLATFORM)))
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push $(IMAGE):v$(RELEASE)

.PHONY: docker-manifest
docker-manifest: manifest-version manifest-release

.PHONY: release
release:
	@$(MAKE) all-push docker-manifest --no-print-directory
