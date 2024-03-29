# This file is optional and can be used to set personal information without committing them to the repository.
MY_ENV_FILE ?= $(WORKDIR)/.env
ifneq (,$(wildcard $(MY_ENV_FILE)))
    include .env
endif

## Variables

BINARY_YQ = $(UTILITY_BIN_PATH)/yq
BINARY_HELM = $(UTILITY_BIN_PATH)/helm
BINARY_HELMIFY = $(UTILITY_BIN_PATH)/helmify

# The productive tag of the image
IMAGE ?=

K3S_CLUSTER_FQDN?=k3ces.local
K3S_LOCAL_REGISTRY_PORT?=30099
K3CES_REGISTRY_URL_PREFIX="${K3S_CLUSTER_FQDN}:${K3S_LOCAL_REGISTRY_PORT}"

# Variables for the temporary yaml files. These are used as template to generate a development resource containing
# the current namespace and the dev image.
K8S_RESOURCE_TEMP_FOLDER ?= $(TARGET_DIR)/make/k8s
K8S_RESOURCE_TEMP_YAML ?= $(K8S_RESOURCE_TEMP_FOLDER)/$(ARTIFACT_ID)_$(VERSION).yaml
K8S_HELM_TARGET ?= $(K8S_RESOURCE_TEMP_FOLDER)/helm
K8S_HELM_RESSOURCES ?= k8s/helm

##@ K8s - Variables

.PHONY: check-all-vars
check-all-vars: check-k8s-image-env-var check-k8s-artifact-id check-etc-hosts check-insecure-cluster-registry check-k8s-namespace-env-var ## Conduct a sanity check against selected build artefacts or local environment

.PHONY: check-k8s-namespace-env-var
check-k8s-namespace-env-var:
	@$(call check_defined, NAMESPACE, k8s namespace)

.PHONY: check-k8s-image-env-var
check-k8s-image-env-var:
	@$(call check_defined, IMAGE, docker image tag)

.PHONY: check-k8s-artifact-id
check-k8s-artifact-id:
	@$(call check_defined, ARTIFACT_ID, app/dogu name)

.PHONY: check-etc-hosts
check-etc-hosts:
	@grep -E "^.+\s+${K3S_CLUSTER_FQDN}\$$" /etc/hosts > /dev/null || \
		(echo "Missing /etc/hosts entry for ${K3S_CLUSTER_FQDN}" && exit 1)

.PHONY: check-insecure-cluster-registry
check-insecure-cluster-registry:
	@grep "${K3CES_REGISTRY_URL_PREFIX}" /etc/docker/daemon.json > /dev/null || \
		(echo "Missing /etc/docker/daemon.json for ${K3CES_REGISTRY_URL_PREFIX}" && exit 1)

##@ K8s - Resources

${K8S_RESOURCE_TEMP_FOLDER}:
	@mkdir -p $@

.PHONY: k8s-delete
k8s-delete: k8s-generate $(K8S_POST_GENERATE_TARGETS) ## Deletes all dogu related resources from the K8s cluster.
	@echo "Delete old dogu resources..."
	@kubectl delete -f $(K8S_RESOURCE_TEMP_YAML) --wait=false --ignore-not-found=true --namespace=${NAMESPACE}

# The additional targets executed after the generate target, executed before each apply and delete. The generate target
# produces a temporary yaml. This yaml is accessible via K8S_RESOURCE_TEMP_YAML an can be changed before the apply/delete.
K8S_POST_GENERATE_TARGETS ?=
# The additional targets executed before the generate target, executed before each apply and delete.
K8S_PRE_GENERATE_TARGETS ?= k8s-create-temporary-resource

.PHONY: k8s-generate
k8s-generate: ${BINARY_YQ} $(K8S_RESOURCE_TEMP_FOLDER) $(K8S_PRE_GENERATE_TARGETS) ## Generates the final resource yaml.
	@echo "Applying general transformations..."
	@sed -i "s/'{{ .Namespace }}'/$(NAMESPACE)/" $(K8S_RESOURCE_TEMP_YAML)
	@$(BINARY_YQ) -i e "(select(.kind == \"Deployment\").spec.template.spec.containers[]|select(.image == \"*$(ARTIFACT_ID)*\").image)=\"$(IMAGE_DEV)\"" $(K8S_RESOURCE_TEMP_YAML)
	@echo "Done."

.PHONY: k8s-apply
k8s-apply: k8s-generate $(K8S_POST_GENERATE_TARGETS) ## Applies all generated K8s resources to the current cluster and namespace.
	@echo "Apply generated K8s resources..."
	@kubectl apply -f $(K8S_RESOURCE_TEMP_YAML) --namespace=${NAMESPACE}

##@ K8s - Helm

${K8S_HELM_RESSOURCES}/Chart.yaml: ${BINARY_HELM} ## Creates the Chart.yaml-template if missing
	@echo "Create Chart.yaml..."
	@mkdir -p ${K8S_HELM_RESSOURCES}/tmp/
	@${BINARY_HELM} create ${K8S_HELM_RESSOURCES}/tmp/${ARTIFACT_ID}
	@cp ${K8S_HELM_RESSOURCES}/tmp/${ARTIFACT_ID}/Chart.yaml ${K8S_HELM_RESSOURCES}/
	@rm -dr ${K8S_HELM_RESSOURCES}/tmp
	@sed -i 's/appVersion: ".*"/appVersion: "0.0.0-replaceme"/' ${K8S_HELM_RESSOURCES}/Chart.yaml
	@sed -i 's/version: .*/version: 0.0.0-replaceme/' ${K8S_HELM_RESSOURCES}/Chart.yaml

.PHONY: k8s-helm-generate
k8s-helm-generate: k8s-generate ${K8S_HELM_RESSOURCES}/Chart.yaml ${BINARY_HELMIFY} $(K8S_RESOURCE_TEMP_FOLDER) $(K8S_PRE_GENERATE_TARGETS) ## Generates the final helm chart.
	@echo "Generate helm chart..."
	@rm -drf ${K8S_HELM_TARGET}  # delete folder, so Chart.yaml is newly created from template
	@mkdir -p ${K8S_HELM_TARGET}
	@cat $(K8S_RESOURCE_TEMP_YAML) | ${BINARY_HELMIFY} ${K8S_HELM_TARGET}
	@cp ${K8S_HELM_RESSOURCES}/Chart.yaml ${K8S_HELM_TARGET}
	@sed -i 's/appVersion: "0.0.0-replaceme"/appVersion: "${VERSION}"/' ${K8S_HELM_TARGET}/Chart.yaml
	@sed -i 's/version: 0.0.0-replaceme/version: ${HELM_CHART_VERSION}/' ${K8S_HELM_TARGET}/Chart.yaml

.PHONY: k8s-helm-apply
k8s-helm-apply: ${BINARY_HELM} image-import k8s-helm-generate $(K8S_POST_GENERATE_TARGETS) ## Generates and installs the helm chart.
	@echo "Apply generated helm chart"
	@${BINARY_HELM} upgrade -i ${ARTIFACT_ID} ${K8S_HELM_TARGET}

.PHONY: k8s-helm-package
k8s-helm-package: ${BINARY_HELM}  k8s-helm-generate $(K8S_POST_GENERATE_TARGETS) ## Generates and packages the helm chart.
	@echo "Package generated helm chart"
	@${BINARY_HELM} package ${K8S_HELM_TARGET} --app-version ${VERSION} -d ${K8S_HELM_TARGET}

.PHONY: k8s-helm-delete
k8s-helm-delete: ${BINARY_HELM} ## Uninstalls the current helm chart.
	@echo "Uninstall helm chart"
	@${BINARY_HELM} uninstall ${ARTIFACT_ID}

.PHONY: k8s-helm-reinstall
k8s-helm-reinstall: k8s-helm-delete k8s-helm-apply ## Uninstalls the current helm chart and reinstalls it.

##@ K8s - Docker

.PHONY: docker-build
docker-build: check-k8s-image-env-var ## Builds the docker image of the K8s app.
	@echo "Building docker image..."
	DOCKER_BUILDKIT=1 docker build . -t $(IMAGE)

.PHONY: docker-dev-tag
docker-dev-tag: check-k8s-image-dev-var docker-build ## Tags a Docker image for local K3ces deployment.
	@echo "Tagging image with dev tag..."
	DOCKER_BUILDKIT=1 docker tag ${IMAGE} ${IMAGE_DEV}

.PHONY: check-k8s-image-dev-var
check-k8s-image-dev-var:
ifeq (${IMAGE_DEV},)
	@echo "Missing make variable IMAGE_DEV detected. It should look like \$${K3CES_REGISTRY_URL_PREFIX}/docker-image:tag"
	@exit 19
endif

.PHONY: image-import
image-import: check-all-vars check-k8s-artifact-id docker-dev-tag ## Imports the currently available image into the cluster-local registry.
	@echo "Import ${IMAGE_DEV} into K8s cluster ${K3S_CLUSTER_FQDN}..."
	@docker push ${IMAGE_DEV}
	@echo "Done."

## Functions

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

${BINARY_YQ}: $(UTILITY_BIN_PATH) ## Download yq locally if necessary.
	$(call go-get-tool,$(BINARY_YQ),github.com/mikefarah/yq/v4@v4.25.1)

${BINARY_HELM}: $(UTILITY_BIN_PATH) ## Download helm locally if necessary.
	$(call go-get-tool,$(BINARY_HELM),helm.sh/helm/v3/cmd/helm@latest)

${BINARY_HELMIFY}: $(UTILITY_BIN_PATH)  ## Download helmify locally if necessary.
	$(call go-get-tool,$(BINARY_HELMIFY),github.com/arttor/helmify/cmd/helmify@latest)