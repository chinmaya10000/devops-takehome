# Python Flask App — DevOps Take-Home Task

This is a simple Python Flask web application used for the DevOps take-home assignment.  
The purpose of this app is to demonstrate containerization, deployment, and CI/CD automation — not complex application logic.

---

## 📋 Overview

The app exposes two HTTP endpoints:

| Endpoint    | Method | Description                                         |
|-------------|--------|-----------------------------------------------------|
| `/`         | GET    | Returns a greeting message                          |
| `/healthz`  | GET    | Health check endpoint (used by Kubernetes probes)   |

**Example Response:**
```
Hello from Chinmaya - DevOps Take-Home Task (Python Flask)!
```

---

## 🐳 Run Locally (Docker)

1. **Build the image**
   ```bash
   docker build -t flask-devops-task:latest .
   ```

2. **Run the container**
   ```bash
   docker run -p 8080:8080 flask-devops-task:latest
   ```

3. **Test endpoints**
   - [http://localhost:8080/](http://localhost:8080/)
   - [http://localhost:8080/healthz](http://localhost:8080/healthz)

---

## 🧱 Folder Structure
```
app/
├── app.py              # Flask application
├── requirements.txt    # Python dependencies
├── Dockerfile          # Multi-stage Dockerfile for building lightweight image
└── README.md           # This file
```

---

## ⚙️ Dockerfile Details

This project uses a multi-stage Dockerfile:

- **Stage 1 (Builder):** Installs dependencies in a virtual environment.
- **Stage 2 (Runtime):** Copies only necessary files to create a minimal image.
- **Security:** Runs as a non-root user for better security.
- **Healthcheck:** Includes a built-in HEALTHCHECK for container monitoring.
