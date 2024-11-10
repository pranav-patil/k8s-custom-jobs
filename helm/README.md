# Helm Charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Run the below commands to add `Helm` third-party repositories, lint the charts, package and deploy the packaged charts to the cluster.

```console
make add-repos
make lint
make clean
make package
make deploy
```

To uninstall the Helm charts use the below command to remove Helm charts.

```console
make uninstall
```

## Chart Testing

Install [CT tools](https://github.com/helm/chart-testing/blob/main/README.md) for Chart Linting and Testing.
We install the CT Tool using HomeBrew as below:

    brew install chart-testing

## Kustomize

Install Kustomize using HomeBrew on Mac

    brew install kustomize

Alternatively we can download the Kustomize pre-complied binary using below command:

    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash


Kustomize allows to generate YAML with resources in current directory containing Kubernetes configuration.

    kustomize build ~/someApp
    kustomize build ~/someApp | kubectl apply -f -

