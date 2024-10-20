# k8s-custom-jobs
Kubernetes Custom Jobs provides examples of adding custom admission controller and running jobs using helm.


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

