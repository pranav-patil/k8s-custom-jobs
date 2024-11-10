# Charts's path relative to the current directory.
CHARTS_DIR := charts
CHARTS := $(filter-out ./$(CHARTS_DIR)/packages, $(wildcard ./$(CHARTS_DIR)/*))
CHARTS_NAMES := $(notdir $(CHARTS))
TARGET_NAMESPACE := emprovise-system

DOCS_IMAGE_VERSION="v1.11.0"
LINT_IMAGE_VERSION="v3.8.0"

# Add third-party repos
.PHONY: add-repos
add-repos:
	helm repo add falcosecurity https://falcosecurity.github.io/charts
	helm repo update

# Lint all charts
.PHONY: lint
lint: helm-deps-update $(addprefix lint-, $(CHARTS_NAMES))

lint-%:
	@docker run \
	-it \
	-e HOME=/home/ct \
	--mount type=tmpfs,destination=/home/ct \
	--workdir=/data \
	--volume $$(pwd):/data \
	-u $$(id -u) \
	quay.io/helmpack/chart-testing:$(LINT_IMAGE_VERSION) \
	ct lint --config ./ct.yaml --charts ./charts/$*

# Package all charts
.PHONY: package
package:
	@for chart in $(CHARTS); do \
		if [ -d "$$chart" ]; then \
			echo "Packaging $$chart..."; \
			helm package "$$chart" --destination $(CHARTS_DIR)/packages; \
		fi; \
	done

# Deploy all charts
.PHONY: deploy
deploy: add-repos
	@for chart in $(CHARTS_DIR)/packages/*.tgz; do \
		release_name=$$(basename $$chart .tgz | sed -E 's/-[0-9]+(\.[0-9]+)*$$//'); \
  		echo "Deploying $$chart as release $$release_name..."; \
  		helm upgrade --install --namespace $(TARGET_NAMESPACE) --create-namespace \
  		$$release_name $$chart; \
	done

	helm install falco falcosecurity/falco --create-namespace --namespace falco


# Clean up packaged charts
.PHONY: clean
clean:
	rm -rf $(CHARTS_DIR)/packages/*.tgz

.PHONY: uninstall
uninstall:
	@for chart in $(CHARTS_DIR)/packages/*.tgz; do \
		release_name=$$(basename $$chart .tgz | sed -E 's/-[0-9]+(\.[0-9]+)*$$//'); \
		echo "Uninstalling release $$release_name..."; \
		helm uninstall "$$release_name" --namespace $(TARGET_NAMESPACE) || echo "Release $$release_name not found"; \
    done

	helm uninstall falco --namespace falco


.PHONY: docs
docs: $(addprefix docs-, $(CHARTS_NAMES))

docs-%:
	@docker run \
	--rm \
	--workdir=/helm-docs \
	--volume "$$(pwd):/helm-docs" \
	-u $$(id -u) \
	jnorwood/helm-docs:$(DOCS_IMAGE_VERSION) \
	helm-docs -c ./charts/$* -t ./README.gotmpl -o ./README.md

.PHONY: helm-deps-update
helm-deps-update: $(addprefix helm-deps-update-, $(CHARTS_NAMES))

helm-deps-update-%:
	helm dependency update ./charts/$*
