 #!/bin/bash
 
 # Log the script execution for debugging
 exec > /var/log/user-data.log 2>&1
 
 # Update system and install required packages
 sudo apt-get update -y
 sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2
 
 # Install Docker
 echo "Installing Docker..."
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
 sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
 sudo apt-get update -y
 sudo apt-get install -y docker-ce docker-ce-cli containerd.io curl unzip
 
 # Start and enable Docker
 sudo systemctl start docker
 sudo systemctl enable docker
 
 # Add the 'ubuntu' user to the docker group so it doesn't require 'sudo' for Docker commands
 sudo usermod -aG docker ubuntu
 
 # Install AWS-CLI
 curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
 unzip awscliv2.zip
 sudo ./aws/install
 aws --version
 rm -rf awscliv2.zip aws
 
 # Install Kind
 echo "Installing kind..."
 curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
 chmod +x ./kind
 sudo mv ./kind /usr/local/bin/kind
 
 # Install kubectl (Kubernetes CLI)
 echo "Installing kubectl..."
 curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
 chmod +x kubectl
 sudo mv kubectl /usr/local/bin/kubectl
 
 # Install K9s
 wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb && sudo apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb
 
 # Install Helm
 echo "Installing Helm..."
 curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
 sudo apt-get install -y apt-transport-https --no-install-recommends
 echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
 sudo apt-get update -y
 sudo apt-get install -y helm
 
 # Enable command completion for kubectl and helm
 echo "source <(kubectl completion bash)" >> ~/.bashrc
 echo "source <(helm completion bash)" >> ~/.bashrc
 
 # Create Kind cluster
 echo "Creating Kubernetes cluster using Kind..."
 kind create cluster --name sample-cluster
 
 # Check if Kind cluster was created successfully
 if [ $? -ne 0 ]; then
     echo "Kind cluster creation failed. Exiting..."
     exit 1
 fi
 
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
 
 # Output the cluster info
 kubectl get nodes
 kubectl get svc
 kubectl get pods
 
 # Restart the system to apply docker group changes and other settings
 sudo reboot
