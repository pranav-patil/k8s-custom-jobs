# Admin Controller

## Introduction

Admin Controller is a Kubernetes Hook which initiates Kube Bench scanning for Kubernetes clusters.
[envtest](https://github.com/kubernetes-sigs/controller-runtime/tree/master/pkg/envtest) is a testing environment that is provided by the [controller-runtime](https://github.com/kubernetes-sigs/controller-runtime) project.
Kubebuilder uses [envtest](https://github.com/kubernetes-sigs/controller-runtime/tree/master/pkg/envtest) to create a local Kubernetes API server, instantiate and run the controllers, and uses [Ginkgo](http://onsi.github.io/ginkgo/) as testing framework, [Gomega](https://onsi.github.io/gomega/) as matcher/assertion library.

### Prerequisites

Install the following pre-requisites before setting up admin-controller.

- [Go](https://golang.org/doc/install) for compiling the binary and the test
- [gosec](https://github.com/securego/gosec) for source code inspection
- [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) as the building block for this repo.

### Development Environment

Below are recommended tools for development

- [Visual Studio Code](https://code.visualstudio.com/)
- Visual Studio Code Plugins:
    - [Go](https://marketplace.visualstudio.com/items?itemName=ms-vscode.Go) - Language support
    - [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) - Helps avoid typos, which saves cycles in review
    - [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one) - Automatically updates Markdown Table of Contents
    - [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) - Automatic code formatter
- Go 1.23+ - Follow the [Go Getting Started docs](https://golang.org/doc/install) to prepare for Go development.
- [Kubebuilder](https://book.kubebuilder.io/quick-start.html) is a framework for building Kubernetes APIs using custom resource definitions (CRDs).
- [controller-runtime](https://github.com/kubernetes-sigs/controller-runtime) is a set of go libraries for building Controllers using in Kubebuilder.
- [Ginkgo](http://onsi.github.io/ginkgo/) is a Go testing framework using in Kubebuilder.
- [Gomega](https://onsi.github.io/gomega/) is a matcher/assertion library in Ginkgo.


[Override goroot variable](https://github.com/golang/vscode-go/issues/971#issuecomment-927666108) in Visual Studio Code.

1. Shift + Cmd + P
2. Search for: "open settings" and choose "Open Settings (JSON)"
<img width="608" alt="Screenshot 2021-09-27 at 11 41 15" src="https://user-images.githubusercontent.com/15876796/134876316-1b4fa926-ae95-4b16-81b7-669650ce1e45.png">

3. $ **go env** and  Copy **GOROOT** value (in my case its "/opt/homebrew/Cellar/go/1.17.1/libexec").
4. add new record to settings.json: "go.goroot": "Copied/GOROOT/path", in my case its: "go.goroot": "/opt/homebrew/Cellar/go/1.17.1/libexec",

<img width="426" alt="Screenshot 2021-09-27 at 11 53 19" src="https://user-images.githubusercontent.com/15876796/134876673-c4c21405-02c3-40fd-a09a-b34365f1035a.png">
            

### Create a new Kind and corresponding controller via Kubebuilder

Based on the [Kubebuilder Quick Start Guide](https://book.kubebuilder.io/quick-start.html) follow the below steps to set up the project.

1. Install [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder)

```
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/
```

2. Run `kubebuilder init` to create a controller project.

```
kubebuilder init --domain emprovise.com --owner "Emprovise Inc"  --repo github.com/pranav-patil/k8s-custom-jobs/admin-controller
```

4. Create a new API (group/version) as emprovise/v1 and the new Kind(CRD) Admin with corresponding controller

```
$ kubebuilder create api --group emprovise --version v1 --kind Admin

Create Resource [y/n]
y
Create Controller [y/n]
y
```

5. Generate the manifests such as Custom Resources (CRs) or Custom Resource Definitions (CRDs)

```
make manifests
```

#### Local

1. Install the CRDs into the cluster:

```
make install
```

2. Run the Admin controller

```
make run
```

```
make dev-build IMG=<some-registry>/<project-name>:tag
```

#### Multi-platform

Create a builder instance, only needs to be executed once

```
docker buildx create --use --name multi-platform --driver docker-container
make build IMG=<some-registry>/<project-name>:tag
```

### Push to the registry

Docker push images
**NOTE**: Replace the example AWS Account ID `012345678901` to set the `AWS_ACCOUNT_ID` environment variable.

```
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=012345678901

aws sts get-caller-identity --region $AWS_REGION

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/emprovise/admin-controller"

docker tag emprovise/admin-controller:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/emprovise/admin-controller:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/emprovise/admin-controller:latest

make docker-push IMG=<some-registry>/<project-name>:tag
```

### How to deploy in the cluster

Deploy controller in the configured Kubernetes cluster in ~/.kube/config

```
make deploy IMG=<some-registry>/<project-name>:tag
```

### How to test

`make docker-build` includes running test already. If you'd like to run in your local, you have to have [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) installed.

```
make test
```
