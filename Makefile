#----------------------------------------------------------------------------------
# Base
#----------------------------------------------------------------------------------

ROOTDIR := $(shell pwd)
OUTPUT_DIR ?= $(ROOTDIR)/_output

# If you just put your username, then that refers to your account at hub.docker.com
ifeq ($(IMAGE_REPO),) # Set quay.io/solo-io as default if IMAGE_REPO is unset
	IMAGE_REPO := ghcr.io/nmnellis
endif

# Kind of a hack to make sure _output exists
z := $(shell mkdir -p $(OUTPUT_DIR))


GCFLAGS := all="-N -l"

# Define Architecture. Default: amd64
# If GOARCH is unset, docker-build will fail
ifeq ($(GOARCH),)
	GOARCH := amd64
endif

ifeq ($(GOOS),)
	GOOS := linux
endif

GO_BUILD_FLAGS := GO111MODULE=on CGO_ENABLED=0 GOARCH=$(GOARCH)

#----------------------------------------------------------------------------------
# Repo setup
#----------------------------------------------------------------------------------
# must be a seperate target so that make waits for it to complete before moving on
.PHONY: mod-download
mod-download:
	go mod download

.PHONY: check-format
check-format:
	NOT_FORMATTED=$$(gofmt -l ./client/ ./cmd/ ./common/) && if [ -n "$$NOT_FORMATTED" ]; then echo These files are not formatted: $$NOT_FORMATTED; exit 1; fi

#----------------------------------------------------------------------------------
# Clean
#----------------------------------------------------------------------------------

# Important to clean before pushing new releases. Dockerfiles and binaries may not update properly
.PHONY: clean
clean:
	rm -rf _output
	rm -rf _test

#----------------------------------------------------------------------------------
# Istio Echo
#----------------------------------------------------------------------------------

ECHO_DIR=.
ECHO_OUTPUT_DIR=$(OUTPUT_DIR)/istio-echo

$(ECHO_OUTPUT_DIR)/echo-linux-$(GOARCH):
	$(GO_BUILD_FLAGS) GOOS=$(GOOS) go build -gcflags=$(GCFLAGS) -o $(ECHO_OUTPUT_DIR)/server $(ECHO_DIR)/cmd/server/main.go
	$(GO_BUILD_FLAGS) GOOS=$(GOOS) go build -gcflags=$(GCFLAGS) -o $(ECHO_OUTPUT_DIR)/client $(ECHO_DIR)/cmd/client/main.go

.PHONY: istio-echo
istio-echo: $(ECHO_OUTPUT_DIR)/echo-linux-$(GOARCH)

$(ECHO_OUTPUT_DIR)/Dockerfile.app: $(ECHO_DIR)/docker/Dockerfile.app
	cp $< $@

.PHONY: echo-docker
echo-docker: $(ECHO_OUTPUT_DIR)/echo-linux-$(GOARCH) $(ECHO_OUTPUT_DIR)/Dockerfile.app
	docker build $(ECHO_OUTPUT_DIR) -f $(ECHO_OUTPUT_DIR)/Dockerfile.app \
		--build-arg GOARCH=$(GOARCH) \
		-t $(IMAGE_REPO)/istio-echo:latest


#----------------------------------------------------------------------------------
# Build All
#----------------------------------------------------------------------------------
.PHONY: build
build: istio-echo
#----------------------------------------------------------------------------------
# Docker
#----------------------------------------------------------------------------------
#
#---------
#--------- Push
#---------

.PHONY: docker docker-push
docker: istio-echo-docker

# Depends on DOCKER_IMAGES, which is set to docker if RELEASE is "true", otherwise empty (making this a no-op).
# This prevents executing the dependent targets if RELEASE is not true, while still enabling `make docker`
# to be used for local testing.
# docker-push is intended to be run by CI
.PHONY: docker-push
docker-push: docker
	docker push $(IMAGE_REPO)/gateway:$(VERSION) && \
