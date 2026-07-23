MERN Stack GitOps & DevSecOps Deployment on AWS EKS(Complete Documentation)

This repository demonstrates the end-to-end implementation of a production-grade MERN (MongoDB, Express, React, Node.js) stack using Infrastructure as Code (IaC), Continuous Delivery (CD), Load Balancing, and GitOps automation.

Table of Contents
Prerequisites:

Project File Structure

Step 1: Infrastructure Provisioning (Terraform EKS)

Step 2: Cluster Connectivity & EBS CSI Configuration

Step 3: Secret Management & Sealed Secrets

Step 4: GitOps & ArgoCD Automation

Step 5: Kubernetes Manifests, Workloads & Load Balancer Deployment

Step 6: System Verification & Troubleshooting Commands

Step 7: Cluster Cleanup & Resource Destruction

1. Prerequisites

To set up this project locally or through a pipeline, ensure the following tools are installed:

Terraform (For provisioning cloud infrastructure)

AWS CLI (For configuring and managing the AWS account)

Kubectl (For managing the Kubernetes cluster)

Helm (Kubernetes package manager)

Kubeseal (For encrypting and managing secrets)

2. Project File Structure
The complete directory layout for this CD and infrastructure repository is structured as follows:

.
├── README.md                      # Project documentation
├── argocd-apps                    # ArgoCD GitOps application manifests
│   ├── mern-app.yaml              # MERN application synchronization config
│   ├── monitoring-app.yaml        # Prometheus and Grafana monitoring application
│   └── vault-app.yaml             # Secret and vault management application
├── ebs-csi-policy.json            # IAM policy for AWS EBS CSI driver
├── k8s-manifests                  # Core Kubernetes manifest files
│   ├── backend-deployment.yaml    # Node.js API deployment and health probes
│   ├── frontend-deployment.yaml   # React frontend and AWS LoadBalancer service
│   ├── mongo-statefulset.yaml     # MongoDB database and persistent volume
│   └── mongodb-sealedsecret.yaml  # Bitnami Sealed Secret (encrypted credentials)
└── terraform-eks                  # Infrastructure as Code (IaC)
    ├── main.tf                    # AWS EKS cluster and networking resources
    ├── outputs.tf                 # Terraform output variables
    ├── providers.tf               # AWS and Kubernetes provider configurations
    ├── terraform.tfstate          # Cluster state file
    └── variables.tf               # Configuration variables

3. Step 1: Infrastructure Provisioning (Terraform EKS)

Cloud infrastructure on AWS is provisioned using the Terraform scripts located inside the terraform-eks/ directory.

Commands to run the infrastructure:

cd terraform-eks
terraform init
terraform apply -auto-approve

The main.tf file provisions a production-ready EKS cluster along with the necessary VPC and subnets.

The ebs-csi-policy.json file configures the required AWS IAM policies for persistent storage within the cluster.

4. Step 2: Cluster Connectivity & EBS CSI Configuration
Once Terraform execution is complete, connect to the cluster from your local terminal:

aws eks update-kubeconfig --region us-west-2 --name mern-devsecops-cluster
kubectl cluster-info

5. Step 3: Secret Management & Sealed Secrets

Sensitive configuration data like database credentials are encrypted using Bitnami Sealed Secrets instead of being stored in plain text within Git:

1. Install the Sealed Secrets Controller (via Helm):
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm install sealed-secrets sealed-secrets/sealed-secrets-controller -n kube-system

2.Encrypt Sensitive Data (Kubeseal):

kubectl create secret generic mongodb-secret --dry-run=client \
  --from-literal=username='admin' \
  --from-literal=password='super-secret-password' \
  -o yaml > secret.yaml

kubeseal --format yaml --scope cluster-wide < secret.yaml > k8s-manifests/mongodb-sealedsecret.yaml

6. Step 4: GitOps & ArgoCD Automation

ArgoCD is utilized to ensure continuous delivery and automated state synchronization within the cluster.

1. Create Namespace and Install ArgoCD:

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
2. Access the Dashboard and Retrieve the Password:
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Command to view the password:
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

3. Sync Applications (argocd-apps/):
ArgoCD continuously syncs this Git repository with the cluster using the manifest files defined under argocd-apps/ (mern-app.yaml, monitoring-app.yaml, and vault-app.yaml).

7. Step 5: Kubernetes Manifests, Workloads & Load Balancer Deployment

The entire MERN stack is orchestrated using the manifests located in the k8s-manifests/ directory:

MongoDB (mongo-statefulset.yaml): Guarantees persistent database storage using StatefulSets and Persistent Volume Claims (PVC).

Backend (backend-deployment.yaml): Deploys the Node.js API server incorporating liveness/readiness probes and defined resource limits.

Frontend & Load Balancer (frontend-deployment.yaml): Deploys the React client and provisions a dedicated LoadBalancer service to handle external cloud traffic, enabling users to access the application directly via browser.

8. Step 6: System Verification & Troubleshooting Commands
Run the following commands to check whether the deployment was successful:

# Check all resources in the application namespace
kubectl get all -n mern-app

# Check the status of ArgoCD applications
kubectl get applications -n argocd

# Check logs or trace issues in application pods
kubectl logs -f deployment/mern-backend -n mern-app

9. Step 7: Cluster Cleanup & Resource Destruction
Once testing or project usage is complete, execute the following commands to safely tear down all resources:

1. Delete Kubernetes Application Namespaces:

kubectl delete namespace mern-app
kubectl delete namespace monitoring

2. Destroy Terraform Infrastructure:


