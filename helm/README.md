# Helm Charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/grafana)](https://artifacthub.io/packages/search?repo=grafana)

The code is provided as-is with no warranties.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add grafana https://grafana.github.io/helm-charts
```

You can then run `helm search repo grafana` to see the charts.

<!-- Keep full URL links to repo files because this README syncs from main to gh-pages.  -->
Chart documentation is available in [grafana directory](https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md).


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

