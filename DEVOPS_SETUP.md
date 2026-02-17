# DevOps Pipeline Setup Guide for tpFoyer-17

This guide will help you set up a complete CI/CD pipeline for the Spring Boot application using Jenkins, Docker, Kubernetes, SonarQube, and Nexus.

## 🏗️ Architecture Overview

```
GitHub → Jenkins → Maven (Compile/Test) → SonarQube → Nexus → Docker Build → Docker Run → Kubernetes
```

## 📋 Prerequisites

Before starting, ensure you have the following installed:

- ✅ Docker Desktop (with Kubernetes enabled)
- ✅ Git
- ✅ Maven 3.9+
- ✅ JDK 17
- ✅ kubectl (Kubernetes CLI)

## 🚀 Quick Start

### 1. Start All Services with Docker Compose

```bash
# Navigate to project directory
cd c:/Users/Malek.Ferjani/Downloads/tpFoyer-17/tpFoyer-17

# Start all services (Jenkins, SonarQube, Nexus, MySQL, etc.)
docker-compose up -d

# Check service status
docker-compose ps
```

### 2. Access the Services

After starting, access the following services:

| Service | URL | Initial Credentials |
|---------|-----|---------------------|
| Jenkins | http://localhost:8080 | Admin password in logs |
| SonarQube | http://localhost:9000 | admin/admin |
| Nexus | http://localhost:8081 | admin/admin123 |
| Docker Registry | http://localhost:5000 | N/A |
| Application | http://localhost:8082/tpFoyer17 | N/A |

### 3. Initial Service Configuration

#### A. Jenkins Setup

1. Get the initial admin password:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

2. Open http://localhost:8080 and complete the setup wizard
3. Install suggested plugins plus:
   - SonarQube Scanner
   - Nexus Artifact Uploader
   - Docker Pipeline
   - Kubernetes CLI
   - Email Extension Plugin

4. Configure Global Tools (Manage Jenkins → Global Tool Configuration):
   - **JDK**: Name: `JDK-17`, JAVA_HOME: Install automatically (Java 17)
   - **Maven**: Name: `Maven-3.9`, Install automatically (Maven 3.9.5)
   - **SonarQube Scanner**: Name: `SonarQube`, Install automatically (Latest)

5. Add Credentials (Manage Jenkins → Credentials):
   - **Nexus**: ID: `nexus-credentials`, Username: `admin`, Password: `admin123`
   - **Docker Registry**: If needed for private registry

6. Configure SonarQube (Manage Jenkins → Configure System):
   - Add SonarQube Server: Name: `SonarQube`, URL: `http://sonarqube:9000`
   - Generate token in SonarQube and add it to Jenkins

#### B. SonarQube Setup

1. Open http://localhost:9000
2. Login with `admin/admin` (you'll be prompted to change password)
3. Create a new project:
   - Project key: `tpFoyer`
   - Display name: `tpFoyer-17`
4. Generate a token for Jenkins integration:
   - Go to My Account → Security → Generate Token
   - Copy the token and add it to Jenkins

#### C. Nexus Setup

1. Open http://localhost:8081
2. Sign in with `admin` and get the initial password:
```bash
docker exec nexus cat /nexus-data/admin.password
```

3. Complete the setup wizard
4. Create repositories (if not exist):
   - **maven-releases**: Format: maven2, Type: hosted, Version policy: Release
   - **maven-snapshots**: Format: maven2, Type: hosted, Version policy: Snapshot

5. Configure `settings.xml` for Maven (create in `~/.m2/settings.xml`):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <servers>
        <server>
            <id>nexus-releases</id>
            <username>admin</username>
            <password>admin123</password>
        </server>
        <server>
            <id>nexus-snapshots</id>
            <username>admin</username>
            <password>admin123</password>
        </server>
    </servers>
</settings>
```

### 4. Create Jenkins Pipeline

1. In Jenkins, click "New Item"
2. Enter name: `tpFoyer-Pipeline`
3. Select "Pipeline" and click OK
4. Under "Pipeline" section:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/MALEKferjanii/devop_test.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
5. Click "Save"

### 5. Enable Kubernetes in Docker Desktop

1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait for Kubernetes to start

6. Verify Kubernetes is running:
```bash
kubectl cluster-info
kubectl get nodes
```

### 6. Deploy to Kubernetes

#### Deploy MySQL:
```bash
kubectl apply -f k8s/mysql-pv.yaml
kubectl apply -f k8s/mysql-deployment.yaml

# Wait for MySQL to be ready
kubectl get pods -w
```

#### Deploy Application:
```bash
# First, ensure your Docker image is available
# The Jenkins pipeline will build and push the image

# Then deploy the application
kubectl apply -f k8s/app-deployment.yaml

# Check status
kubectl get pods
kubectl get services
```

#### Access the Application:
```bash
# Get the NodePort
kubectl get service tpfoyer-service

# Access via: http://localhost:30082/tpFoyer17
```

### 7. Run the Pipeline

1. Go to Jenkins → tpFoyer-Pipeline
2. Click "Build Now"
3. Monitor the pipeline execution

The pipeline will:
1. ✅ Clone code from GitHub
2. ✅ Compile with Maven
3. ✅ Run tests
4. ✅ Analyze code with SonarQube
5. ✅ Package the application
6. ✅ Deploy to Nexus
7. ✅ Build Docker image
8. ✅ Push to Docker registry
9. ✅ Run Docker container
10. ✅ Deploy to Kubernetes

## 📊 Monitoring and Verification

### Check Application Health
```bash
# Via Docker
curl http://localhost:8082/tpFoyer17/actuator/health

# Via Kubernetes
kubectl port-forward service/tpfoyer-service 8082:8082
curl http://localhost:8082/tpFoyer17/actuator/health
```

### View Logs
```bash
# Docker logs
docker logs tpfoyer-app -f

# Kubernetes logs
kubectl logs -f deployment/tpfoyer-deployment
```

### Database Access
```bash
# Connect to MySQL in Kubernetes
kubectl exec -it <mysql-pod-name> -- mysql -u root -prootpassword tpFoyer17

# Or via Docker
docker exec -it tpfoyer-mysql mysql -u root -prootpassword tpFoyer17
```

## 🔧 Troubleshooting

### Jenkins can't connect to Docker
```bash
# Give Jenkins access to Docker socket
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### SonarQube out of memory
```bash
# Increase heap size in docker-compose.yml
# Already configured with: -Xms512m -Xmx512m
```

### Kubernetes pods not starting
```bash
# Check events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check if PersistentVolume is bound
kubectl get pv
kubectl get pvc
```

### Nexus repository not accessible
```bash
# Check if Nexus is running
docker ps | grep nexus

# Check logs
docker logs nexus
```

## 🔐 Security Notes

**⚠️ IMPORTANT: Change all default passwords in production!**

- Jenkins admin password
- SonarQube admin password  
- Nexus admin password
- MySQL root password
- Database credentials in Kubernetes secrets

## 📝 Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Nexus Repository Documentation](https://help.sonatype.com/repomanager3)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)

## 🎯 Next Steps

1. Configure email notifications in Jenkins
2. Set up webhooks in GitHub for automatic builds
3. Add more quality gates in SonarQube
4. Configure backup strategies for databases
5. Implement monitoring with Prometheus and Grafana
6. Set up SSL/TLS certificates
7. Configure resource limits and autoscaling in Kubernetes

---

**Happy DevOps! 🚀**
