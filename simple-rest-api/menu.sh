#!/bin/bash

NAMESPACE="hegdek8s"

while true; do
    echo "======================================"
    echo "🚀 Kubernetes Minikube Management Menu"
    echo "======================================"
    echo "1️⃣  Start Deployment"
    echo "2️⃣  Stop Deployment"
    echo "3️⃣  Delete Deployment"
    echo "4️⃣  Check Status"
    echo "5️⃣  Get Minikube IP"
    echo "6️⃣  Exit"
    echo "======================================"
    read -p "👉 Choose an option: " option

    case $option in
        1)
            echo "🔹 Starting Deployment..."
            ./deploy_k8s.sh
            ;;
        2)
            echo "🛑 Stopping Deployment..."
            kubectl scale deployment simple-rest-api --replicas=0 -n $NAMESPACE
            kubectl scale deployment mongo --replicas=0 -n $NAMESPACE
            echo "✅ Deployment Stopped!"
            ;;
        3)
            echo "🚨 Deleting Deployment..."
            kubectl delete namespace $NAMESPACE
            echo "✅ Namespace & All Deployments Deleted!"
            ;;
        4)
            echo "📌 Checking Status..."
            kubectl get pods -n $NAMESPACE
            ;;
        5)
            echo "🌎 Minikube IP:"
            minikube ip
            ;;
        6)
            echo "👋 Exiting..."
            exit 0
            ;;
        *)
            echo "❌ Invalid option, please try again."
            ;;
    esac
done
