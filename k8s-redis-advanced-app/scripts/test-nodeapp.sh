#!/bin/bash
set -e

echo "Deploiement Node.js + Redis sur Minikube"

#Utiliser le Docker de minikube
eval $(minikube docker-env)

#Build de l'image
cd ./app
docker build -t mynode-redis-app:1.0 .

#Appliquer les yaml
cd ../k8s
kubectl apply -f redis-deployment.yaml
kubectl apply -f nodeapp-deployment.yaml

#Attente que tout sois prêt
echo "Attente du deploiement des pods..."
kubectl wait --for=condition=available deployment/nodeapp-deployment --timeout=120s

#URL de service
minikube_ip=$(minikube ip)
node_port=$(kubectl get svc nodeapp-service -o=jsonpath='{.spec.ports[0].nodePort}')

echo "Application disponible sur : http://$minikube_ip:node_port"
echo "Testons l'application..."

#Tester 3 fois l'endpoint
for i in 1 2 3; do
    echo "Test $i:"
    curl -s http://$minikube_ip:$node_port
    echo ""
done