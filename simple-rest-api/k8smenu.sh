#!/bin/bash

NAMESPACE="hegdek8s"
API_URL="http://$(minikube ip)/"  # Change if needed

while true; do
    echo "======================================"
    echo "🚀 Kubernetes Minikube Management Menu"
    echo "======================================"
    echo "1️⃣  Start Deployment"
    echo "2️⃣  Stop Deployment"
    echo "3️⃣  Delete Deployment"
    echo "4️⃣  Check Status"
    echo "5️⃣  Get Minikube IP"
    echo "6️⃣  Test API - GET /"
    echo "7️⃣  Test API - POST /data"
    echo "8️⃣  Exit"
    echo "======================================"
    read -p "👉 Choose an option: " option

    case $option in
        1)
            echo "🔹 Starting Deployment..."
            ./deploy_k8s.sh
            ;;
        2)
            echo "🛑 Stopping Deployment..."
            minikube kubectl -- scale deployment simple-rest-api --replicas=0 -n $NAMESPACE
            minikube kubectl -- scale deployment mongo --replicas=0 -n $NAMESPACE
            echo "✅ Deployment Stopped!"
            ;;
        3)
            echo "🚨 Deleting Deployment..."
            minikube kubectl -- delete namespace $NAMESPACE
            echo "✅ Namespace & All Deployments Deleted!"
            ;;
        4)
            echo "📌 Checking Status..."
            minikube kubectl -- get pods -n $NAMESPACE
            ;;
        5)
            echo "🌎 Minikube IP:"
            minikube ip
            ;;
        6)
            echo "🔹 Testing GET API..."
            curl -X GET "$API_URL"
            ;;
        7)
            echo "🔹 Testing POST API..."
            curl -X POST "$API_URL/data" -H "Content-Type: application/json" -d '{"name": "John Doe", "email": "john@example.com"}'
            ;;
        8)
            echo "👋 Exiting..."
            exit 0
            ;;
        *)
            echo "❌ Invalid option, please try again."
            ;;
    esac
done
