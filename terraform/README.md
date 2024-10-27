# Kubernetes Cluster Environment Setup

Kubernetes Custom Jobs provides examples of adding custom admission controller and running jobs using helm.

    terraform init
    terraform plan
    terraform apply -auto-approve -input=false
    ssh -i ~/.ssh/<STACK_NAME>-ec2-key.pem ubuntu@<EC2_INSTANCE_ID>.compute-1.amazonaws.com
    sftp -i ~/.ssh/<STACK_NAME>-ec2-key.pem ubuntu@<EC2_INSTANCE_ID>.compute-1.amazonaws.com

    aws sts get-caller-identity --region us-east-1
    kubectl create namespace emprovise-system
    kubectl delete secret docker-registry ecr-secret --namespace=emprovise-system
    
    kubectl create secret \
    docker-registry ecr-secret \
    --docker-server="<AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com" \
    --docker-username=AWS \
    --docker-password="$(aws ecr get-login-password --region us-east-1)" \
    --docker-email=emprovise@gmail.com \
    --namespace emprovise-system
    
    kubectl get secret ecr-secret --namespace=emprovise-system -o yaml
    kubectl secrets link default ecr-secret --for=pull --namespace=emprovise-system
    kubectl get pods -A
    kubectl get events -n emprovise-system
    kubectl get nodes --show-labels
    helm uninstall emprovise -n emprovise-system
    helm install emprovise --namespace emprovise-system --create-namespace --values ./overrides.yaml

## Google Cloud Platform (GCP) GKE Setup

Download [GCP SDK](https://cloud.google.com/sdk/docs/install-sdk) and extract its contents.
Then use install script `install.sh` to add gcloud CLI tools to your PATH. It will also install Python 3.11 required for GCP CLI.

    ./google-cloud-sdk/install.sh

To initialize the gcloud CLI, run gcloud init:

    ./google-cloud-sdk/bin/gcloud init

Ensure you've set up Google Cloud SDK, enabled Kubernetes Engine API, and set up application credentials:

    gcloud auth application-default login
    gcloud services enable container.googleapis.com

Get the latest version of GCloud components including GCloud CLI

    gcloud components update

Kubectl and other Kubernetes clients require an authentication plugin, [gke-gcloud-auth-plugin](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#install_plugin), which uses the Client-go Credential Plugins framework to provide authentication tokens to communicate with GKE clusters.
Before Kubernetes version 1.26 is released, gcloud CLI will start to require that the gke-gcloud-auth-plugin binary is installed. If not installed, existing installations of kubectl or other custom Kubernetes clients will stop working.

    gcloud components install gke-gcloud-auth-plugin

    gke-gcloud-auth-plugin --version

    gcloud container clusters get-credentials CLUSTER_NAME --region=COMPUTE_REGION

    kubectl get namespaces

To view the environment's kubeconfig, run the following command:

    kubectl config view

When we create a cluster using gcloud container clusters create-auto, an entry is automatically added to the kubeconfig file in your environment, and the current context changes to that cluster. For example:

    gcloud container clusters create-auto my-cluster

To view the current context for kubectl, run the following command:

    kubectl config current-context

GKE cluster can be deleted using clusters delete command as below:

    gcloud container clusters delete CLUSTER_NAME

