# ---- Docker container metadata ---- #
PACKAGE       := example
CONTAINER     := pythia-qa-registry
REGISTRY      := $(QA_DOCKER_REGISTRY)
TAG           ?= latest

# ---- files to include in change detection, default is all versioned files ---- #
DEPS = $(shell git ls-files -z)

# ---- build metadata ---- #
COMMIT := $(shell git rev-parse HEAD)
EMAIL  := $(shell git config user.email)
NAME   := $(shell git config user.name)
DATE   := $(shell date +"%Y%m%dT%H%M")

.PHONY: clean
clean:
	rm .built version.json || true

# .built assembles but does not test the project; upon successful completion .built metafile is created
.built: . $(DEPS)
	touch $@

# publish container to specific registry
.PHONY: publish
publish: docker
	@echo "Tagging '$(CONTAINER)' as '$(TAG)' and pushing into $(REGISTRY)"
	$(shell aws ecr get-login --no-include-email --region eu-west-1)
	docker tag $(CONTAINER) $(REGISTRY)/$(CONTAINER):$(TAG)
	docker push $(REGISTRY)/$(CONTAINER):$(TAG) || echo "hint: use 'docker login $(REGISTRY)' to authenticate"

# build the actual package with some injected metadata in version.json
.PHONY: docker
docker: version.json

# build package with injected version.json metadata
version.json: .built
	@echo "{\"package\": \"$(PACKAGE)\", \
			\"commit\": \"$(COMMIT)\", \
			\"date\": \"$(DATE)\", \
			\"by\": {\
				\"name\": \"$(NAME)\", \
				\"email\": \"$(EMAIL)\"\
			}}" | python -m json.tool > $@
	docker build -t $(CONTAINER) --no-cache --pull=true . || rm $@
