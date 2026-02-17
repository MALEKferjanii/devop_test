# Kubernetes Deployment Guide

This guide explains how to deploy the tpFoyer application to Kubernetes.

## 📋 Prerequisites

1. **Kubernetes Cluster**: Docker Desktop with Kubernetes enabled or Minikube
2. **kubectl**: Kubernetes command-line tool
3. **Docker Image**: Built and pushed to registry (Jenkins pipeline does this)

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────┐
│              Kubernetes Cluster                  │
│                                                  │
│  ┌─────────────────┐      ┌──────────────────┐  │
│  │  MySQL Pod      │      │  tpFoyer Pods    │  │
│  │  (StatefulSet)  │◄─────│  (Deployment)    │  │
│  │                 │      │  (2 replicas)    │  │
│  └─────────────────┘      └──────────────────┘  │
│         │                          │             │
│         │                          ▼             │
│  ┌──────▼──────────┐      ┌──────────────────┐  │
│  │  PersistentVol  │      │  LoadBalancer    │  │
│  │  (MySQL Data)   │      │  Service         │  │
│  └─────────────────┘      │  Port: 30082     │  │
│                            └──────────────────┘  │
└──────────────────────────────────────────────────┘
```

## 📁 Kubernetes Manifests

### 1. `mysql-pv.yaml`
- **PersistentVolume**: 5GB storage for MySQL data
- **PersistentVolumeClaim**: Storage claim for MySQL pod

### 2. `mysql-deployment.yaml`
- **Secret**: MySQL credentials (root password, database name)
- **Service**: ClusterIP service for internal communication
- **Deployment**: MySQL 8.0 with persistent storage
- **Health Checks**: Liveness and readiness probes

### 3. `app-deployment.yaml`
- **ConfigMap**: Application configuration (database URL, JPA settings)
- **Secret**: Database password
- **Service**: LoadBalancer exposing port 30082
- **Deployment**: Spring Boot app with 2 replicas
- **Init Container**: Waits for MySQL to be ready
- **Health Checks**: HTTP probes on /actuator/health

## 🚀 Deployment Steps

### Step 1: Verify Kubernetes Cluster
```bash
kubectl cluster-info
kubectl get nodes
```

### Step 2: Deploy MySQL

```bash
# Create PersistentVolume and PersistentVolumeClaim
kubectl apply -f k8s/mysql-pv.yaml

# Verify PV and PVC
kubectl get pv
kubectl get pvc

# Deploy MySQL
kubectl apply -f k8s/mysql-deployment.yaml

# Wait for MySQL to be ready
kubectl get pods -w

# Check MySQL logs
kubectl logs -f deployment/mysql-deployment
```

### Step 3: Deploy Application

```bash
# Deploy the application
kubectl apply -f k8s/app-deployment.yaml

# Wait for pods to be ready
kubectl get pods -w

# Check application logs
kubectl logs -f deployment/tpfoyer-deployment
```

### Step 4: Verify Deployment

```bash
# Check all resources
kubectl get all

# Check pod status
kubectl get pods

# Check services
kubectl get services

# Check endpoints
kubectl get endpoints
```

## 🔍 Accessing the Application

### Via NodePort (Recommended for local dev)
```bash
# The service is exposed on port 30082
curl http://localhost:30082/tpFoyer17/actuator/health
```

### Via Port Forwarding
```bash
# Forward local port to service
kubectl port-forward service/tpfoyer-service 8082:8082

# Access application
curl http://localhost:8082/tpFoyer17/actuator/health
```

### In Browser
Open: `http://localhost:30082/tpFoyer17`

## 🔧 Management Commands

### View Logs
```bash
# Application logs
kubectl logs -f deployment/tpfoyer-deployment

# MySQL logs
kubectl logs -f deployment/mysql-deployment

# Logs from specific pod
kubectl logs -f <pod-name>

# Logs from all pods in deployment
kubectl logs -f deployment/tpfoyer-deployment --all-containers=true
```

### Scale Application
```bash
# Scale to 3 replicas
kubectl scale deployment/tpfoyer-deployment --replicas=3

# Verify scaling
kubectl get pods
```

### Update Application
```bash
# After building new Docker image
kubectl set image deployment/tpfoyer-deployment tpfoyer=localhost:5000/tpfoyer:new-tag

# Or update the manifest and apply
kubectl apply -f k8s/app-deployment.yaml

# Check rollout status
kubectl rollout status deployment/tpfoyer-deployment

# View rollout history
kubectl rollout history deployment/tpfoyer-deployment
```

### Rollback Deployment
```bash
# Rollback to previous version
kubectl rollout undo deployment/tpfoyer-deployment

# Rollback to specific revision
kubectl rollout undo deployment/tpfoyer-deployment --to-revision=2
```

### Debug Pod Issues
```bash
# Describe pod for events and status
kubectl describe pod <pod-name>

# Get pod YAML
kubectl get pod <pod-name> -o yaml

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/sh

# Access MySQL in pod
kubectl exec -it <mysql-pod-name> -- mysql -u root -prootpassword tpFoyer17
```

### Check Resource Usage
```bash
# Resource usage by pods
kubectl top pods

# Resource usage by nodes
kubectl top nodes
```

## 🗑️ Cleanup

### Delete Application Only
```bash
kubectl delete -f k8s/app-deployment.yaml
```

### Delete MySQL Only
```bash
kubectl delete -f k8s/mysql-deployment.yaml
```

### Delete Everything (including data)
```bash
kubectl delete -f k8s/app-deployment.yaml
kubectl delete -f k8s/mysql-deployment.yaml
kubectl delete -f k8s/mysql-pv.yaml

# Verify cleanup
kubectl get all
kubectl get pv
kubectl get pvc
```

## 🔐 Security Considerations

### Current Credentials (Base64 encoded in manifests)

**⚠️ WARNING: These are for development only!**

- MySQL Root Password: `rootpassword`
- Database Name: `tpFoyer17`

### Change Production Credentials

To change credentials, encode new values:

```bash
# Encode new password
echo -n "your-new-password" | base64

# Update secrets in manifests
# mysql-deployment.yaml -> mysql-secret
# app-deployment.yaml -> app-secret
```

Or use kubectl to create secrets:

```bash
kubectl create secret generic mysql-secret \
  --from-literal=mysql-root-password='your-password' \
  --from-literal=mysql-database='tpFoyer17'

kubectl create secret generic app-secret \
  --from-literal=spring-datasource-password='your-password'
```

## 📊 Monitoring

### Health Checks

```bash
# Application health
curl http://localhost:30082/tpFoyer17/actuator/health

# Detailed health info
curl http://localhost:30082/tpFoyer17/actuator/health | jq

# Application metrics
curl http://localhost:30082/tpFoyer17/actuator/metrics
```

### Events Monitoring
```bash
# Watch events in real-time
kubectl get events --watch

# Events for specific namespace
kubectl get events --sort-by='.lastTimestamp'
```

## 🐛 Troubleshooting

### Pod Not Starting

1. Check pod status:
   ```bash
   kubectl describe pod <pod-name>
   ```

2. Common issues:
   - Image pull errors: Check registry accessibility
   - Insufficient resources: Check node capacity
   - ConfigMap/Secret not found: Ensure they're created first

### Database Connection Issues

1. Check MySQL is running:
   ```bash
   kubectl get pods | grep mysql
   ```

2. Test MySQL connectivity from app pod:
   ```bash
   kubectl exec -it <app-pod> -- sh
   nc -zv mysql-service 3306
   ```

3. Check MySQL logs:
   ```bash
   kubectl logs -f deployment/mysql-deployment
   ```

### Service Not Accessible

1. Check service endpoints:
   ```bash
   kubectl get endpoints tpfoyer-service
   ```

2. Verify service configuration:
   ```bash
   kubectl describe service tpfoyer-service
   ```

3. Test from within cluster:
   ```bash
   kubectl run test-pod --image=busybox -it --rm -- wget -O- http://tpfoyer-service:8082/tpFoyer17/actuator/health
   ```

## 📈 Production Best Practices

1. **Use Namespaces**: Separate environments (dev, staging, prod)
   ```bash
   kubectl create namespace tpfoyer-prod
   kubectl apply -f k8s/ -n tpfoyer-prod
   ```

2. **Resource Limits**: Already configured in manifests
   - Prevents resource hogging
   - Ensures predictable performance

3. **Readiness Probes**: Already configured
   - Traffic only to ready pods
   - Smooth rolling updates

4. **Liveness Probes**: Already configured
   - Automatic pod restart on failure
   - Self-healing capability

5. **Multiple Replicas**: Deploy with 2+ replicas for HA
   ```bash
   kubectl scale deployment/tpfoyer-deployment --replicas=3
   ```

6. **Persistent Storage**: Use proper storage class in production
   - Cloud provider storage (AWS EBS, Azure Disk, GCP PD)
   - Network-attached storage (NFS)

7. **Secrets Management**: Use external secret management
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault

8. **Ingress Controller**: For production routing
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: tpfoyer-ingress
   spec:
     rules:
     - host: tpfoyer.yourdomain.com
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: tpfoyer-service
               port:
                 number: 8082
   ```

---

**For detailed setup instructions, see [DEVOPS_SETUP.md](DEVOPS_SETUP.md)**
