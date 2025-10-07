# DevOps Take-Home Task: Automated Kubernetes Deployment

This repository demonstrates a complete DevOps workflow for deploying a Python Flask application to a Kubernetes cluster using Infrastructure as Code (Terraform), Docker, Kubernetes manifests, and CI/CD pipelines.

It also includes bonus features: container image scanning, optional Kustomize for templating, and a monitoring stack with Prometheus & Grafana.

---

## Project Overview

- **Application:** Python Flask “Hello World” with `/` and `/healthz` endpoints.
- **Infrastructure:** AWS EKS cluster with VPC, subnets, managed node groups, and NGINX Ingress.
- **Containerization:** Dockerized Flask app with CI/CD image scan (Trivy).
- **Deployment Management:** Kubernetes manifests (Deployment, Service, Ingress).
- **Monitoring:** Prometheus & Grafana installed for observability.
- **CI/CD:** GitHub Actions pipeline for SAST scanning (Bandit), Docker build/push, image scan, and Kubernetes deployment.
- **Bonus:** Optional Kustomize overlay for environment-specific deployment.

---

## Folder Structure

```
devops-takehome/
├── README.md
├── .github/
│   └── workflows/
│       └── ci-cd.yaml
├── terraform/                 # EKS provisioning
│   ├── main-eks.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
├── app/                       # Flask app source code
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── k8s/                       # Plain manifests (used by CI/CD)
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── kustomize/                 # Bonus: Kustomize configuration
    ├── base/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── ingress.yaml
    │   └── kustomization.yaml
    └── overlays/
        └── dev/
            └── kustomization.yaml
```

---

## Prerequisites

- AWS account with EKS permissions
- AWS CLI, Terraform, Docker, kubectl installed
- GitHub account for Actions
- Docker Hub account

---

## Terraform: Provision EKS Cluster

Navigate to terraform/ folder:

```sh
cd terraform
terraform init
terraform plan 
terraform apply --auto-approve
```

Configure kubectl:

```sh
aws eks --region <region> update-kubeconfig --name <cluster_name>
```

Verify cluster:

```sh
kubectl get nodes
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

> NGINX LoadBalancer DNS is the public entry point for your applications.

---

## CI/CD: Automated Docker Build, Scan & Deployment

The full CI/CD workflow is automated in GitHub Actions. Every push to the main branch triggers the following stages:

### 1. SAST Scan (Bandit)
- Scans Python code for security issues.
- Generates a JSON report uploaded as an artifact.

### 2. Docker Build & Push
- Builds the Flask Docker image from `app/Dockerfile`.
- Tags the image for your Docker Hub repository.
- Pushes the image to the registry.

### 3. Image Scan (Trivy)
- Scans the built Docker image for vulnerabilities.
- Generates a security report for review.

### 4. Kubernetes Deployment (Plain manifests)
- Updates kubectl configuration to connect to the EKS cluster.
- Applies plain Kubernetes manifests from the k8s/ folder:
    ```sh
    kubectl apply -f k8s/
    kubectl rollout status deployment/flask-app
    ```

#### Secrets Required

- `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` → Access to EKS
- `DOCKER_USERNAME` & `DOCKER_PASSWORD` → Docker Hub authentication

---

## Optional Kustomize Deployment (Bonus)

Kustomize allows environment-specific customization without modifying the base manifests.

- Base manifests: `kustomize/base/`
- Overlays (e.g., dev environment): `kustomize/overlays/dev/`

Apply Kustomize overlay:

```sh
kubectl apply -k kustomize/overlays/dev/
kubectl rollout status deployment/flask-app
```

This is optional and mainly for different environments (e.g., dev, staging, prod).

---

## Monitoring: Prometheus & Grafana

To provide observability:

### Installation

Create a namespace for monitoring:

```sh
kubectl create namespace monitoring
```

Install Prometheus & Grafana using Helm:

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus --namespace monitoring

# Install Grafana
helm install grafana prometheus-community/grafana \
  --namespace monitoring \
  --set adminPassword='Admin123!' \
  --set service.type=LoadBalancer
```

Get Grafana LoadBalancer URL:

```sh
kubectl get svc -n monitoring grafana
```

Access Grafana dashboard in browser:

```
http://<grafana-loadbalancer-dns>:3000
```

Default login: `admin` / `Admin123!`

Add Prometheus as a data source if not auto-configured.

---

## Design Choices

- **Managed EKS:** Easier cluster maintenance and high availability
- **NGINX Ingress:** Single public endpoint for multiple services
- **Dockerized App:** Lightweight, reproducible container
- **CI/CD & SAST:** Automated testing, scanning, and deployment
- **Monitoring:** Prometheus & Grafana for metrics and observability
- **Image Scan:** Trivy ensures secure container images
- **Kustomize:** Optional templating for environment-specific overrides

---

## Optional Enhancements / Extra Credit

- Enable Cluster Autoscaler for dynamic node scaling
- Configure TLS/HTTPS via ACM and NGINX annotations
- Secrets management using Kubernetes Secrets or AWS Secrets Manager
- Advanced logging stack (ELK, Loki)

---

## Live Application

**URL:** `<replace-with-NGINX-LB-DNS-or-your-domain>`

Update this once LoadBalancer is provisioned.

---