#!/bin/bash

# Create Kind cluster
echo "Creating Kubernetes cluster using Kind..."
cat <<EOF | kind create cluster --wait=5m --name=test-cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
- role: worker
- role: worker
EOF

# Wait until the Kubernetes API server is available
echo "Waiting for the Kind cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

if [ $? -ne 0 ]; then
    echo "Cluster is not ready. Exiting..."
    exit 1
fi

# Create Kubernetes Deployment and Service for nginx
echo "Creating Kubernetes resources (nginx Deployment and Service)..."
cat <<EOF > /home/ubuntu/nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx-service
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30080
  selector:
    app: nginx
  type: NodePort
EOF

# Apply the Kubernetes resources
kubectl apply -f /home/ubuntu/nginx-deployment.yaml

mkdir -p ~/.kube
kind get kubeconfig --name="test-cluster" > ~/.kube/config
chown ubuntu:ubuntu ~/.kube/config

# Output the cluster info
kubectl get nodes
kubectl get svc
kubectl get pods
