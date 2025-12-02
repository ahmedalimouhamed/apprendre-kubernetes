#!/bin/bash
set -e
eval $(minikube docker-env)

cd ../auth && docker build -t auth-service:1.0 .
cd ../data && docker build -t data-service:1.0 .
cd ../gateway && docker build -t gateway-service:1.0 .
cd ../k8s

kubectl apply -f redis.yaml
kubectl apply -f auth.yaml
kubectl apply -f data.yaml
kubectl apply -f gateway.yaml

kubectl wait --for=condition=available deployment/gateway-deployment --timeout=120s

IP=$(minikube ip)
PORT=$(kubectl get svc gateway-service -o=jsonpath='{.spec.ports[0].nodePort}')

echo "Testing on http://$IP:$PORT"


curl -s http://$IP:$PORT/login
curl -s http://$IP:$PORT/visits
curl -s http://$IP:$PORT

#Nettoyage 
read -p "Press Enter to clean up..."
kubectl delete -f .