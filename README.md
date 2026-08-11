# FastAPI CI/CD with Docker, Jenkins & Kubernetes

A complete DevOps project demonstrating automated build, testing, containerization, Docker image publishing, and Kubernetes deployment of a FastAPI application.

## 🚀 Project Overview

This project implements a CI/CD pipeline where application code is stored in GitHub and Jenkins automatically builds, tests, containerizes, publishes, and deploys the application to Kubernetes.

The project includes:

- Docker containerization
- Jenkins Declarative Pipeline
- Automated application health testing
- Docker Hub image publishing
- Versioned Docker images
- Kubernetes rolling updates
- Liveness and readiness probes
- Resource requests and limits
- ConfigMaps and Secrets
- Kubernetes Service
- Kubernetes Ingress
- Prometheus monitoring
- Grafana dashboards
- CI/CD and Kubernetes troubleshooting

## 🏗️ Architecture

```text
                         ┌──────────────┐
                         │    GitHub    │
                         └──────┬───────┘
                                │
                                ▼
                         ┌──────────────┐
                         │   Jenkins    │
                         └──────┬───────┘
                                │
                 ┌──────────────┼──────────────┐
                 ▼              ▼              ▼
              Build           Test          Push
                 │              │              │
                 └──────────────┼──────────────┘
                                │
                                ▼
                         ┌──────────────┐
                         │  Docker Hub  │
                         └──────┬───────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Kubernetes    │
                       │                 │
                       │   Deployment    │
                       │       │         │
                       │       ▼         │
                       │      Pods       │
                       │       │         │
                       │       ▼         │
                       │    Service      │
                       │       │         │
                       │       ▼         │
                       │    Ingress      │
                       └───────┬─────────┘
                               │
                               ▼
                         ┌───────────┐
                         │  FastAPI  │
                         └───────────┘

                       Monitoring
                           │
                ┌──────────┴──────────┐
                ▼                     ▼
           Prometheus              Grafana
```

## 🛠️ Technologies Used

- Python
- FastAPI
- Uvicorn
- Git & GitHub
- Docker
- Jenkins
- Docker Hub
- Kubernetes
- ConfigMaps
- Kubernetes Secrets
- Kubernetes Service
- Kubernetes Ingress
- Liveness Probes
- Readiness Probes
- Resource Requests & Limits
- Prometheus
- Grafana
- Linux

## 📁 Project Structure

```text
python-flask-cicd/
│
├── app/
│   ├── app.py
│   └── requirements.txt
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── configmap.yaml
│
├── jenkins/
│   └── Dockerfile
│
├── Dockerfile
├── Jenkinsfile
├── .dockerignore
├── .gitignore
└── README.md
```

## 🔄 CI/CD Pipeline

The project uses a Jenkins Declarative Pipeline to automate the application lifecycle.

### Pipeline Flow

```text
GitHub
   ↓
Jenkins
   ↓
Docker Build
   ↓
Application Test
   ↓
Docker Hub Login
   ↓
Push Image
   ↓
Kubernetes Deployment
   ↓
Rolling Update
   ↓
Deployment Verification
```

### 1. Build

Jenkins builds the Docker image using the project's Dockerfile.

```bash
docker build -t yuki982/python-flask-cicd:${BUILD_NUMBER} .
```

The Jenkins `BUILD_NUMBER` is used as the Docker image tag so individual builds can be identified.

Example:

```text
yuki982/python-flask-cicd:24
```

### 2. Test

Jenkins starts the newly built Docker image as a temporary container.

The application exposes a health endpoint:

```text
/health
```

The pipeline uses `curl` with a retry mechanism to allow the application time to start.

```bash
curl -f http://python-flask-test:8000/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

If the health check fails, the pipeline stops before the image is pushed or deployed.

### 3. Docker Hub Login

Docker Hub credentials are stored securely in Jenkins Credentials.

The credentials are injected into the pipeline only when required and are not hardcoded into the Jenkinsfile.

### 4. Push

After successful testing, Jenkins pushes the versioned Docker image to Docker Hub.

Example:

```text
yuki982/python-flask-cicd:24
```

### 5. Deploy to Kubernetes

Jenkins updates the Kubernetes Deployment with the newly built image.

```bash
kubectl set image deployment/python-flask-cicd \
python-flask-cicd=yuki982/python-flask-cicd:${BUILD_NUMBER}
```

Kubernetes then performs a rolling update.

The pipeline waits for the rollout to complete:

```bash
kubectl rollout status deployment/python-flask-cicd
```

## 🐳 Docker

The FastAPI application is containerized using Docker.

### Dockerfile

The Dockerfile:

- Uses `python:3.13-slim` as the base image
- Creates `/app` as the working directory
- Copies `requirements.txt`
- Installs Python dependencies
- Copies the FastAPI application
- Exposes port `8000`
- Starts the application using Uvicorn

### Build the Image

```bash
docker build -t python-flask-cicd .
```

### Run the Container

```bash
docker run -p 8000:8000 python-flask-cicd
```

### Test the Application

```bash
curl http://localhost:8000/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

The application root endpoint is:

```text
http://localhost:8000/
```

## ☸️ Kubernetes

The FastAPI application is deployed to Kubernetes using a Deployment.

The Kubernetes Deployment provides:

- Pod management
- Self-healing
- Rolling updates
- Health checks
- Resource management

### Check the Deployment

```bash
kubectl get deployment python-flask-cicd
```

### Check Pods

```bash
kubectl get pods
```

### Check Rollout Status

```bash
kubectl rollout status deployment/python-flask-cicd
```

### Check Deployment Image

```bash
kubectl get deployment python-flask-cicd \
-o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

## ❤️ Health Checks

The Kubernetes Deployment uses both liveness and readiness probes.

### Liveness Probe

The liveness probe checks whether the application is functioning.

```text
/health
```

If the liveness probe repeatedly fails, Kubernetes can restart the container.

### Readiness Probe

The readiness probe checks whether the application is ready to receive traffic.

If the readiness probe fails, Kubernetes removes the Pod from Service traffic until it becomes ready.

## 📊 Resource Management

The Kubernetes Deployment defines CPU and memory requests and limits.

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"

  limits:
    cpu: "500m"
    memory: "256Mi"
```

Requests help Kubernetes schedule Pods, while limits define the maximum resources available to the container.

## ⚙️ ConfigMap

The project uses a ConfigMap for non-sensitive application configuration.

Example:

```yaml
APP_ENV: "production"
APP_NAME: "python-flask-cicd"
```

This separates configuration from the application container image.

## 🔐 Kubernetes Secrets

The Deployment is configured to consume sensitive configuration through a Kubernetes Secret.

```yaml
envFrom:
  - secretRef:
      name: python-flask-secret
```

Sensitive credentials should not be hardcoded into application manifests or committed to GitHub.

The actual Secret should be created separately in the Kubernetes cluster.

## 🌐 Kubernetes Service

A Kubernetes Service provides stable networking for the application and routes traffic to the appropriate Pods.

The FastAPI application listens on port:

```text
8000
```

The Service uses port `8000` and forwards traffic to the application's port `8000`.

The Service type used in this project is:

```text
NodePort
```

## 🌍 Ingress

The project uses an NGINX Ingress to route HTTP traffic to the FastAPI Service.

Configured hostname:

```text
python-flask.local
```

Ingress provides an HTTP entry point into the Kubernetes application and routes requests to the Kubernetes Service.

## 📈 Monitoring

The Kubernetes environment includes Prometheus and Grafana for monitoring.

### Prometheus

Prometheus collects and stores metrics as time-series data.

Metrics can be used to monitor:

- CPU usage
- Memory usage
- Request rate
- Error rate
- Application performance
- Kubernetes resources

### Grafana

Grafana connects to Prometheus and visualizes the collected metrics through dashboards.

This provides a visual way to monitor application and infrastructure health.

## 🧪 Troubleshooting

### Kubernetes

```bash
kubectl get pods
kubectl get deployments
kubectl get services
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events
```

### Docker

```bash
docker ps
docker images
docker logs <container>
docker exec -it <container> sh
```

### Deployment

```bash
kubectl rollout status deployment/python-flask-cicd
kubectl rollout history deployment/python-flask-cicd
```

### Common Kubernetes Problems

#### CrashLoopBackOff

Check the application logs:

```bash
kubectl logs <pod-name>
```

For logs from the previous container:

```bash
kubectl logs <pod-name> --previous
```

#### ImagePullBackOff

Check Pod events:

```bash
kubectl describe pod <pod-name>
```

Verify:

- Image name
- Image tag
- Docker Hub repository
- Registry authentication

#### Pod Not Ready

Check:

```bash
kubectl describe pod <pod-name>
```

Look at the readiness probe and Events section.

## 🎯 What I Learned

Through this project I gained practical experience with:

- Building CI/CD pipelines
- FastAPI application containerization
- Docker image versioning
- Automated health testing
- Jenkins Declarative Pipelines
- Secure Jenkins credentials
- Docker Hub image publishing
- Kubernetes deployments
- Rolling updates
- Kubernetes health checks
- Resource requests and limits
- ConfigMaps and Secrets
- Kubernetes networking
- Prometheus monitoring
- Grafana dashboards
- CI/CD troubleshooting
- Kubernetes troubleshooting

## 🚀 Future Improvements

Potential future improvements include:

- Helm chart integration
- Horizontal Pod Autoscaling
- Infrastructure provisioning using Terraform
- AWS cloud deployment
- Centralized logging
- Automated GitHub webhook triggers
- Production Kubernetes cluster deployment

## 👨‍💻 Author

**Om Ingle**

GitHub: https://github.com/omsingle

LinkedIn: https://www.linkedin.com/in/om-ingle-00403b417/