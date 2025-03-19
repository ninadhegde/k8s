#!/bin/bash

NAMESPACE="hegdek8s"
MINIKUBE_IP=$(minikube ip)

# Function to get NodePort dynamically
get_node_port() {
    local node_port=$(minikube kubectl -- get service rest-api-service -n $NAMESPACE -o=jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    if [[ -z "$node_port" ]]; then
        echo "❌ Error: Could not fetch NodePort. Ensure the service is running."
        return 1
    fi
    echo "$node_port"
}

while true; do
    echo "======================================"
    echo "🚀 Kubernetes Minikube Management Menu"
    echo "======================================"
    echo "1️⃣  Start Deployment"
    echo "2️⃣  Stop Deployment"
    echo "3️⃣  Delete Deployment"
    echo "4️⃣  Check Status"
    echo "5️⃣  Get Minikube IP"
    echo "6️⃣  Test API - GET /api/data"
    echo "7️⃣  Test API - POST /api/data"
    echo "8️⃣  Exit"
    echo "======================================"
    read -p "👉 Choose an option: " option

    case $option in
        1)
            echo "🔹 Starting Deployment..."
            ./deploy_k8s.sh  # Run deployment script
            echo "✅ Deployment Started!"
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
            echo "🌎 Minikube IP: $MINIKUBE_IP"
            ;;
        6)
            NODE_PORT=$(get_node_port)
            if [[ -n "$NODE_PORT" ]]; then
                API_URL="http://localhost:8080/api/data"
                echo "🔹 Testing GET API at $API_URL ..."
                curl -X GET "$API_URL"
            fi
            ;;
        7)
            NODE_PORT=$(get_node_port)
            if [[ -n "$NODE_PORT" ]]; then
                API_URL="http://localhost:8080/api/data"
                echo "🔹 Testing POST API at $API_URL ..."
                curl -X POST "$API_URL" -H "Content-Type: application/json" -d '{"name": "John Dota", "email": "john@example.com"}'
            fi
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

