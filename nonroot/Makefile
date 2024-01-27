SHELL=/bin/bash -o pipefail

REGISTRY   ?= appscode
BIN        := kubectl-nonroot
IMAGE      := $(REGISTRY)/$(BIN)
RELEASE    ?= 1.20
VERSION    ?= $(shell curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable-$(RELEASE).txt)
SRC_REG    ?=

DOCKER_PLATFORMS := linux/amd64 linux/arm64
PLATFORM         ?= $(firstword $(DOCKER_PLATFORMS))
TAG              = $(VERSION)_$(subst /,_,$(PLATFORM))

container-%:
	@$(MAKE) container \
	    --no-print-directory \
	    PLATFORM=$(subst _,/,$*)

push-%:
	@$(MAKE) push \
	    --no-print-directory \
	    PLATFORM=$(subst _,/,$*)

all-container: $(addprefix container-, $(subst /,_,$(DOCKER_PLATFORMS)))

all-push: $(addprefix push-, $(subst /,_,$(DOCKER_PLATFORMS)))

ifeq (,$(SRC_REG))
container:
	@echo "container: $(IMAGE):$(TAG)"
	@docker buildx build --platform $(PLATFORM) --build-arg VERSION=$(VERSION) --load --pull -t $(IMAGE):$(TAG) -f Dockerfile .
	@echo
else
container:
	@echo "container: $(IMAGE):$(TAG)"
	@docker tag $(SRC_REG)/$(BIN):$(TAG) $(IMAGE):$(TAG)
	@echo
endif

push: container
	@docker push $(IMAGE):$(TAG)
	@echo "pushed: $(IMAGE):$(TAG)"
	@echo

.PHONY: manifest-version
manifest-version:
	docker manifest create -a $(IMAGE):$(VERSION) $(foreach PLATFORM,$(DOCKER_PLATFORMS),$(IMAGE):$(VERSION)_$(subst /,_,$(PLATFORM)))
	docker manifest push $(IMAGE):$(VERSION)

.PHONY: manifest-release
manifest-release:
	docker manifest create -a $(IMAGE):v$(RELEASE) $(foreach PLATFORM,$(DOCKER_PLATFORMS),$(IMAGE):$(VERSION)_$(subst /,_,$(PLATFORM)))
	docker manifest push $(IMAGE):v$(RELEASE)
	docker manifest create -a $(IMAGE):$(RELEASE) $(foreach PLATFORM,$(DOCKER_PLATFORMS),$(IMAGE):$(VERSION)_$(subst /,_,$(PLATFORM)))
	docker manifest push $(IMAGE):$(RELEASE)

.PHONY: docker-manifest
docker-manifest: manifest-version manifest-release

.PHONY: release
release:
	@$(MAKE) all-push docker-manifest --no-print-directory
