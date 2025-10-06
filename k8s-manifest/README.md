# Flask App Kubernetes Deployment

This repository contains Kubernetes manifests to deploy a Flask application with a production-ready setup including Deployment, Service, and Ingress. The manifests are configured with probes, resource limits, and environment variables.

## Prerequisites

- Kubernetes cluster (cloud-managed cluster)
- kubectl CLI installed and configured
- NGINX Ingress Controller installed in your cluster (for Ingress)
- Docker image available at:  
  `400014682771.dkr.ecr.us-east-2.amazonaws.com/flask-app:latest`

## Folder Structure

```
.
├── deployment.yaml   # Deployment manifest with probes and resources
├── service.yaml      # Service manifest (LoadBalancer)
├── ingress.yaml      # Ingress manifest for routing traffic
└── README.md
```

## Deployment Instructions

Apply the Deployment, Service, and Ingress manifests:

```sh
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

Check the status of Pods:

```sh
kubectl get pods
```

Verify Service:

```sh
kubectl get svc flask-service
```

Verify Ingress (if using Minikube, add host entry in `/etc/hosts`):

```
<MINIKUBE_IP> flask-app.local
```

Then open [http://flask-app.local](http://flask-app.local) in your browser.

## Configuration Details

### Deployment

- **Replicas:** 2
- **Container Port:** 8080
- **Environment Variable:** `FLASK_ENV=production`
- **Probes:** Liveness and Readiness on `/healthz`
- **Resource Requests:** CPU 100m, Memory 128Mi
- **Resource Limits:** CPU 250m, Memory 256Mi

### Service

- **Type:** LoadBalancer
- **Port:** 80 → 8080

### Ingress

- **Ingress Class:** NGINX
- **Host:** flask-app.local
- **Routes `/` path to `flask-service`**

## Testing

Once deployed, you can test the application by accessing the LoadBalancer IP or the Ingress host.

- **Health endpoint:**  
  `http://<host>/healthz`

## Notes

- Make sure your cluster has NGINX Ingress Controller installed before applying the Ingress manifest.
- Adjust resource requests/limits based on your cluster capacity.
- For cloud environments, replace LoadBalancer type with NodePort if necessary.