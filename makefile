# ---- config -------------------------------------------------------
IMAGE_REPO ?= opengpunetwork/provider-suite
CONTEXT    ?= .

CPU_DOCKERFILE  ?= Dockerfile.cpu
ROCM_DOCKERFILE ?= Dockerfile.rocm
CUDA_DOCKERFILE ?= Dockerfile.cuda

# default: fresh rebuilds and refresh base images
BUILD_FLAGS ?= --no-cache --pull

DOCKER ?= docker

# ---- multi-arch buildx config -------------------------------------
PLATFORMS ?= linux/amd64,linux/arm64
BUILDX ?= $(DOCKER) buildx


.PHONY: build-all build-cpu build-rocm build-cuda publish-all publish-cpu publish-rocm publish-cuda publish

# ---- multi-arch build targets ------------------------------------
build-all: build-cpu build-rocm build-cuda

build-cpu:
	$(BUILDX) build $(BUILD_FLAGS) --platform $(PLATFORMS) -f $(CPU_DOCKERFILE) -t $(IMAGE_REPO):cpu $(CONTEXT) --load

build-rocm:
	$(BUILDX) build $(BUILD_FLAGS) --platform $(PLATFORMS) -f $(ROCM_DOCKERFILE) -t $(IMAGE_REPO):rocm $(CONTEXT) --load

build-cuda:
	$(BUILDX) build $(BUILD_FLAGS) --platform $(PLATFORMS) -f $(CUDA_DOCKERFILE) -t $(IMAGE_REPO):cuda $(CONTEXT) --load

# ---- multi-arch build+push (publish) targets ----------------------
publish-all: publish-cpu publish-rocm publish-cuda

publish-cpu:
	$(BUILDX) build $(BUILD_FLAGS) --platform $(PLATFORMS) -f $(CPU_DOCKERFILE) -t $(IMAGE_REPO):cpu $(CONTEXT) --push

publish-rocm:
	$(BUILDX) build $(BUILD_FLAGS) --platform $(PLATFORMS) -f $(ROCM_DOCKERFILE) -t $(IMAGE_REPO):rocm $(CONTEXT) --push

publish-cuda:
	$(BUILDX) build $(BUILD_FLAGS) --platform $(PLATFORMS) -f $(CUDA_DOCKERFILE) -t $(IMAGE_REPO):cuda $(CONTEXT) --push

