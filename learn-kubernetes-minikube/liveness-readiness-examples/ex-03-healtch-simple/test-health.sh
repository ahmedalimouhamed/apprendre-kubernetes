#!/bin/bash

echo "=== Démarrage du test complet ==="
echo ""

echo "1. création de la configmap..."
kubectl apply -f configmap.yaml

echo "2. Création du pod..."
kubectl apply -f pod.yaml

echo "3. Observation du démarrage..."
echo ""
echo "=== Etat du pod (ctrl+c pour arrêter) ==="
echo ""

with_pod(){
    for i in {1..30}; do
        clear
        echo "Temps Ecoulé : ${i}s"
        echo "===================="
        kubectl get pod simple-health-app -o wide

        echo ""
        echo "=== Détails ==="
        kubectl describe pod simple-health-app | grep -A 10 "Conditions:"
        
        echo ""
        echo "=== Logs ==="
        kubectl logs simple-health-app --tail=3 2>/dev/null || echo "pas encore de logs..."

        echo ""
        echo "=== Endpoints ==="
        kubectl exec -it simple-health-app -- wget -q -O- http://localhost:8081/health 2>/dev/null || echo "Health endpoint non accessible"

        sleep 1
    done
}

with_pod

echo ""
echo "=== Test des Probes ==="
echo ""

echo "4. Test des endpoints HTTP:"
echo "   - Health: $(kubectl exec -it simple-health-app -- wget -q -O- http://localhost:8081/health)"
echo "   - Ready: $(kubectl exec -it simple-health-app -- wget -q -O- http://localhost:8081/ready)"
echo "   - Page web: $(kubectl exec -it simple-health-app -- wget -q -O- http://localhost:8081 | grep -o '<h1>[^<]*</h1>')"

echo ""
echo "5. Simulation d'un problème de santé..."
echo "   Désactivation du health endpoint..."
kubectl exec -it simple-health-app -- wget -q -O- http://localhost:8081/toggle/health

echo ""
echo "Attente 20 secondes pour observer l'effet..."
sleep 20

echo "=== Etat après problème ==="
kubectl get pod simple-health-app
kubecl describe pod simple-health-app | grep -A 5 "Events:"
echo ""
echo "6. Nettoyage..."
kubectl delete -f pod.yaml
kubectl delete -f configmap.yaml

echo "=== Fin du test ==="
