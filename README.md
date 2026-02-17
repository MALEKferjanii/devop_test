# tpFoyer-17 - Complete DevOps Pipeline

A Spring Boot application with a complete CI/CD pipeline using Jenkins, Docker, Kubernetes, SonarQube, and Nexus.

## 🚀 Project Overview

This is a **Spring Boot 3.1.3** application for foyer management with a complete DevOps automation pipeline.

### Technology Stack

- **Backend**: Spring Boot 3.1.3, Spring Data JPA, MySQL
- **Build Tool**: Maven 3.9+
- **Java Version**: JDK 17
- **Database**: MySQL 8.0
- **API Documentation**: SpringDoc OpenAPI (Swagger)
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: Jenkins
- **Code Quality**: SonarQube
- **Artifact Repository**: Nexus Repository Manager

## 📋 Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DevOps Pipeline Flow                           │
└─────────────────────────────────────────────────────────────────────────┘

   GitHub Repository
         │
         ▼
   ┌─────────────┐
   │   Jenkins   │ ←── Webhook Trigger
   └─────────────┘
         │
         ├─► 1. Clone Repository
         │
         ├─► 2. Maven Compile
         │
         ├─► 3. Maven Test (Unit Tests)
         │
         ├─► 4. SonarQube Analysis
         │       └─► Code Quality Gate
         │
         ├─► 5. Maven Package
         │
         ├─► 6. Deploy to Nexus
         │       └─► Artifact Repository
         │
         ├─► 7. Build Docker Image
         │
         ├─► 8. Push to Docker Registry
         │
         ├─► 9. Run Docker Container
         │
         └─► 10. Deploy to Kubernetes
                 ├─► MySQL Pod
                 └─► Application Pods (2 replicas)
```

## 🎯 Quick Start

### Prerequisites

- Docker Desktop with Kubernetes enabled
- Git
- JDK 17 (for local development)
- Maven 3.9+ (for local development)

### Option 1: One-Click Setup (Recommended)

```bash
# Windows
start-devops.bat

# This will start:
# - Jenkins (http://localhost:8080)
# - SonarQube (http://localhost:9000)
# - Nexus (http://localhost:8081)
# - MySQL (localhost:3306)
# - Docker Registry (http://localhost:5000)
```

### Option 2: Manual Setup

```bash
# 1. Start all services
docker-compose up -d

# 2. Wait for services to be ready (2-3 minutes)

# 3. Follow the detailed setup guide
# See DEVOPS_SETUP.md
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [DEVOPS_SETUP.md](DEVOPS_SETUP.md) | Complete DevOps setup guide |
| [k8s/README.md](k8s/README.md) | Kubernetes deployment guide |
| [Jenkinsfile](Jenkinsfile) | Jenkins pipeline configuration |
| [docker-compose.yml](docker-compose.yml) | Docker services orchestration |

## 🏗️ Project Structure

```
tpFoyer-17/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── tn/esprit/tpfoyer17/
│   │   └── resources/
│   │       └── application.properties
│   └── test/
├── k8s/                          # Kubernetes manifests
│   ├── mysql-pv.yaml
│   ├── mysql-deployment.yaml
│   ├── app-deployment.yaml
│   └── README.md
├── Dockerfile                    # Multi-stage Docker build
├── Jenkinsfile                   # CI/CD pipeline definition
├── docker-compose.yml            # Local DevOps environment
├── pom.xml                       # Maven configuration
├── start-devops.bat             # Quick start script
├── stop-devops.bat              # Stop all services
├── DEVOPS_SETUP.md              # Setup guide
└── README.md                     # This file
```

## 🔧 Local Development

### Run Locally (Without Docker)

1. **Start MySQL**:
   ```bash
   docker run -d --name mysql-local -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=tpFoyer17 -p 3306:3306 mysql:8.0
   ```

2. **Configure application.properties**:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/tpFoyer17
   spring.datasource.username=root
   spring.datasource.password=
   ```

3. **Run application**:
   ```bash
   mvn spring-boot:run
   ```

4. **Access**:
   - Application: http://localhost:8082/tpFoyer17
   - Swagger UI: http://localhost:8082/tpFoyer17/swagger-ui.html
   - Health Check: http://localhost:8082/tpFoyer17/actuator/health

### Build & Test

```bash
# Compile
mvn clean compile

# Run tests
mvn test

# Package
mvn package

# Run SonarQube analysis (requires SonarQube running)
mvn sonar:sonar

# Deploy to Nexus (requires Nexus running)
mvn deploy
```

## 🐳 Docker Operations

### Build Docker Image

```bash
# Build
docker build -t tpfoyer:latest .

# Tag for registry
docker tag tpfoyer:latest localhost:5000/tpfoyer:latest

# Push to registry
docker push localhost:5000/tpfoyer:latest
```

### Run with Docker Compose

```bash
# Start application + MySQL
docker-compose up -d app mysql

# View logs
docker-compose logs -f app

# Stop
docker-compose down
```

## ☸️ Kubernetes Operations

### Deploy to Kubernetes

```bash
# Deploy MySQL
kubectl apply -f k8s/mysql-pv.yaml
kubectl apply -f k8s/mysql-deployment.yaml

# Deploy Application
kubectl apply -f k8s/app-deployment.yaml

# Check status
kubectl get pods
kubectl get services

# Access application
curl http://localhost:30082/tpFoyer17/actuator/health
```

For detailed Kubernetes operations, see [k8s/README.md](k8s/README.md).

## 📊 Service URLs

After running `start-devops.bat`, access:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Application** | http://localhost:8082/tpFoyer17 | N/A |
| **Swagger UI** | http://localhost:8082/tpFoyer17/swagger-ui.html | N/A |
| **Health Check** | http://localhost:8082/tpFoyer17/actuator/health | N/A |
| **Jenkins** | http://localhost:8080 | See logs for initial password |
| **SonarQube** | http://localhost:9000 | admin/admin |
| **Nexus** | http://localhost:8081 | See logs for initial password |
| **Docker Registry** | http://localhost:5000 | N/A |

## 🔐 Security

### Default Credentials (Development Only)

**⚠️ WARNING: Change these in production!**

- **MySQL Root Password**: `rootpassword`
- **Database Name**: `tpFoyer17`
- **SonarQube**: `admin/admin`
- **Nexus**: Check with `docker exec nexus cat /nexus-data/admin.password`
- **Jenkins**: Check with `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

### Production Considerations

1. ✅ Use strong passwords
2. ✅ Enable HTTPS/TLS
3. ✅ Use Kubernetes Secrets for sensitive data
4. ✅ Implement RBAC (Role-Based Access Control)
5. ✅ Enable network policies
6. ✅ Regular security updates
7. ✅ Use non-root containers
8. ✅ Scan images for vulnerabilities

## 🧪 Testing

### Unit Tests

```bash
mvn test
```

### Integration Tests

```bash
mvn verify
```

### Code Coverage

```bash
mvn jacoco:report

# View report at: target/site/jacoco/index.html
```

## 📈 Monitoring & Health Checks

### Application Health

```bash
# Overall health
curl http://localhost:8082/tpFoyer17/actuator/health

# Database health
curl http://localhost:8082/tpFoyer17/actuator/health | jq '.components.db'

# Detailed health
curl http://localhost:8082/tpFoyer17/actuator/health

# Metrics
curl http://localhost:8082/tpFoyer17/actuator/metrics
```

### Available Actuator Endpoints

- `/actuator/health` - Application health status
- `/actuator/info` - Application information
- `/actuator/metrics` - Application metrics

## 🐛 Troubleshooting

### Jenkins Issues

```bash
# View logs
docker logs jenkins -f

# Get admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Reset if needed
docker-compose restart jenkins
```

### SonarQube Issues

```bash
# View logs
docker logs sonarqube -f

# Restart
docker-compose restart sonarqube sonardb
```

### Database Connection Issues

```bash
# Test MySQL connection
docker exec -it tpfoyer-mysql mysql -u root -prootpassword -e "SHOW DATABASES;"

# Check logs
docker logs tpfoyer-mysql -f
```

### Application Issues

```bash
# View application logs
docker logs tpfoyer-app -f

# Or in Kubernetes
kubectl logs -f deployment/tpfoyer-deployment

# Check health
curl http://localhost:8082/tpFoyer17/actuator/health
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 CI/CD Pipeline Stages

The Jenkins pipeline executes the following stages:

1. **Checkout**: Clone from GitHub
2. **Compile**: `mvn clean compile`
3. **Test**: `mvn test` with JUnit reports
4. **SonarQube Analysis**: Code quality and security analysis
5. **Quality Gate**: Ensures code meets quality standards
6. **Package**: `mvn package` to create JAR
7. **Deploy to Nexus**: Upload artifacts to Nexus repository
8. **Build Docker Image**: Multi-stage Docker build
9. **Push to Registry**: Push image to Docker registry
10. **Run Docker Container**: Start container for testing
11. **Deploy to Kubernetes**: Deploy to K8s cluster

## 🎯 Next Steps

1. ✅ Set up GitHub webhook for automatic builds
2. ✅ Configure email notifications
3. ✅ Add more test coverage
4. ✅ Implement integration tests
5. ✅ Set up Prometheus + Grafana monitoring
6. ✅ Configure SSL/TLS certificates
7. ✅ Implement autoscaling in Kubernetes
8. ✅ Set up database backups
9. ✅ Add API rate limiting
10. ✅ Implement authentication & authorization

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Malek Ferjani**

- GitHub: [@MALEKferjanii](https://github.com/MALEKferjanii)
- Repository: [devop_test](https://github.com/MALEKferjanii/devop_test.git)

## 🙏 Acknowledgments

- Spring Boot Team
- Jenkins Community
- SonarQube Team
- Sonatype Nexus
- Docker Inc.
- Kubernetes Community

---

**Happy Coding! 🚀**
