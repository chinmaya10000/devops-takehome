# Terraform: AWS EKS Cluster with NGINX Ingress

This folder contains Terraform code to provision a managed Kubernetes (EKS) cluster on AWS. The cluster includes:

- **VPC** with public/private subnets
- **EKS cluster**
- **Managed node groups**
- **NGINX Ingress Controller** to expose applications publicly

> **Note:** This Terraform module only provisions infrastructure. Deployment of applications (such as a Flask app) is done separately using Kubernetes manifests.

---

## Prerequisites

- AWS account with permissions for: EKS, EC2, VPC, IAM, CloudFormation
- AWS CLI installed and configured (`aws configure`)
- Terraform installed (v1.5+ recommended)
- `kubectl` installed

---

## Folder Structure

```
terraform/
├── main.tf        # EKS cluster, node groups, VPC, and NGINX Ingress
├── variables.tf   # Input variables for cluster configuration
├── outputs.tf     # Outputs like kubeconfig and NGINX LoadBalancer DNS
└── providers.tf   # AWS provider configuration
```

---

## Deployment Instructions

### 1. **Initialize Terraform**

```sh
cd terraform
terraform init
```

### 2. **Validate Terraform**

```sh
terraform validate
```

### 3. **Plan the Deployment**

```sh
terraform plan -out=tfplan
```

### 4. **Apply Terraform**

```sh
terraform apply tfplan
```

Terraform will provision the EKS cluster, networking, node groups, and NGINX Ingress Controller.

**Outputs include:**

- `kubeconfig` → configure kubectl
- `nginx_lb_dns` → public entry point for Ingress resources

---

## Post-Deployment Steps

### 1. **Configure kubectl**

```sh
aws eks --region <region> update-kubeconfig --name flask-app-cluster
```

### 2. **Verify Cluster**

```sh
kubectl get nodes
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### 3. **Access Applications**

Applications are exposed via the NGINX Ingress LoadBalancer.

Use the `nginx_lb_dns` output and configure your `/etc/hosts` to map Ingress hostnames if needed (e.g., `flask-app.local`).

---

## Design Notes

- **Managed EKS:** Easier cluster maintenance, security, and HA.
- **NGINX Ingress:** Provides a single public endpoint for routing multiple services.
- **Node Groups:** Managed, scalable, and ready for workloads.
- **Separation of Concerns:** Terraform handles infrastructure only; app deployment is separate.