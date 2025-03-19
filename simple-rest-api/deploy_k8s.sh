#!/bin/bash

# Create directory for YAML files
mkdir -p k8s-deployment && cd k8s-deployment

echo "🚀 Creating Kubernetes YAML files..."

# Namespace YAML
cat <<EOF > namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hegdek8s
EOF

# MongoDB Deployment & Service
cat <<EOF > mongo-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo
  namespace: hegdek8s
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
      - name: mongo
        image: ninadhegde/hegde_tech:mongo
        ports:
        - containerPort: 27017
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          value: "admin"
        - name: MONGO_INITDB_ROOT_PASSWORD
          value: "password"
---
apiVersion: v1
kind: Service
metadata:
  name: mongo-service
  namespace: hegdek8s
spec:
  selector:
    app: mongo
  ports:
    - protocol: TCP
      port: 27017
      targetPort: 27017
  clusterIP: None
EOF

# Node.js App Deployment & Service
cat <<EOF > app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-rest-api
  namespace: hegdek8s
spec:
  replicas: 1
  selector:
    matchLabels:
      app: simple-rest-api
  template:
    metadata:
      labels:
        app: simple-rest-api
    spec:
      containers:
      - name: simple-rest-api
        image: ninadhegde/hegde_tech:simple-rest-api
        ports:
        - containerPort: 5000
        env:
        - name: PORT
          value: "5000"
        - name: MONGO_URI
          value: "mongodb://mongo-service:27017/demoapi"
---
apiVersion: v1
kind: Service
metadata:
  name: rest-api-service
  namespace: hegdek8s
spec:
  selector:
    app: simple-rest-api
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: NodePort
EOF

# Ingress for External Access
cat <<EOF > ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rest-api-ingress
  namespace: hegdek8s
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: minikube.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: rest-api-service
            port:
              number: 80
EOF

echo "✅ YAML files created!"

# Enable Minikube Ingress
minikube addons enable ingress

# Apply all Kubernetes YAML configurations
minikube kubectl -- apply -f namespace.yaml
minikube kubectl -- apply -f mongo-deployment.yaml
minikube kubectl -- apply -f app-deployment.yaml
minikube kubectl -- apply -f ingress.yaml

echo "🚀 Deployment Complete! Run 'kubectl get pods -n hegdek8s' to check status."
