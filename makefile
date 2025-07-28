# ---- config -------------------------------------------------------
IMAGE_REPO ?= opengpunetwork/provider-suite
CONTEXT    ?= .

CPU_DOCKERFILE  ?= Dockerfile.cpu
ROCM_DOCKERFILE ?= Dockerfile.rocm
CUDA_DOCKERFILE ?= Dockerfile.cuda

# default: fresh rebuilds and refresh base images
BUILD_FLAGS ?= --no-cache --pull

DOCKER ?= docker

# ---- phony targets ------------------------------------------------
.PHONY: all build-all push-all \
        build-cpu build-rocm build-cuda \
        push-cpu  push-rocm  push-cuda \
        login clean publish

# default = build everything
all: build-all

# ---- build --------------------------------------------------------
build-all: build-cpu build-rocm build-cuda

build-cpu:
	$(DOCKER) build $(BUILD_FLAGS) -f $(CPU_DOCKERFILE)  -t $(IMAGE_REPO):cpu  $(CONTEXT)

build-rocm:
	$(DOCKER) build $(BUILD_FLAGS) -f $(ROCM_DOCKERFILE) -t $(IMAGE_REPO):rocm $(CONTEXT)

build-cuda:
	$(DOCKER) build $(BUILD_FLAGS) -f $(CUDA_DOCKERFILE) -t $(IMAGE_REPO):cuda $(CONTEXT)

# ---- push ---------------------------------------------------------
push-all: push-cpu push-rocm push-cuda

push-cpu:
	$(DOCKER) push $(IMAGE_REPO):cpu

push-rocm:
	$(DOCKER) push $(IMAGE_REPO):rocm

push-cuda:
	$(DOCKER) push $(IMAGE_REPO):cuda

# ---- misc ---------------------------------------------------------
login:
	$(DOCKER) login

clean:
	-$(DOCKER) rmi $(IMAGE_REPO):cpu $(IMAGE_REPO):rocm $(IMAGE_REPO):cuda || true

# ---- one-shot build + push for all images -------------------------
publish:
	@$(MAKE) build-all
	@$(MAKE) push-all
