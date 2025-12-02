#!/bin/bash
set -e

RESULT_FILES="results.json"
START_TIME=$(date +%s)
echo "Lancement du déploiement API + PostgreSQL"

#Utiliser Docker de minikube
eval $(minikube docker-env)

cd ../app
docker build -t postgres-api:1.0 .
cd ../k8s

#Déploiement Kubernetes
kubectl apply -f postgres-deployment.yaml
kubectl apply -f api-deployment.yaml

#Attendre la disponibilité
echo "Attente des pods..."
kubectl wait --for=condition=available deployment/api-deployment --timeout=180s

echo "Attente que PostgreSQL soit prêt..."
POSTGRES_POD=$(kubectl get pods -l app=postgres -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POSTGRES_POD -- bash -c '
until pg_isready -U postgres -d testdb > /dev/null 2>&1; do
  echo -n "."
  sleep 1
done
'
echo "PostgreSQL prêt"

IP=$(minikube ip)
PORT=$(kubectl get svc api-service -o jsonpath='{.spec.ports[0].nodePort}')

echo "API disponible sur : http://$IP:$PORT"

#Tests
TESTS_PASSED=0
TESTS_FAILED=0

function test_endpoint(){
    set +e
    local endpoint=$1
    local expected_key=$2
    echo "Test de l'endpoint $endpoint ..."
    response=$(curl -s -m 5 http://$IP:$PORT$endpoint)

    if echo "$response" | grep -q "$expected_key"; then
        echo "OK"
        ((TESTS_PASSED++))
    else
        echo "X FAIL"
        echo "Response was: $response"
        ((TESTS_FAILED++))
    fi
    set -e
}

test_endpoint "/" "API running"
test_endpoint "/users" "Alice"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

#Générateur du rapport JSON
cat > $RESULT_FILES << EOF
    {
        "timestamp": "$(date)",
        "tests": {
            "passed": $TESTS_PASSED,
            "failed": $TESTS_FAILED
        },
        "durations_seconds": $DURATION
    }
EOF

echo "Rapport généré: $RESULT_FILES"

#Afficher le rapport
cat $RESULT_FILES

#Nettoyage complet
echo "Suppression des resources kubernetes..."
kubectl delete -f api-deployment.yaml --ignore-not-found
kubectl delete -f postgres-deployment.yaml --ignore-not-found

echo "Nettoyage terminé."