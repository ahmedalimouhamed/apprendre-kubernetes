#!/bin/bash
echo "=== Test Liveness Probe ==="

kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml

echo "Attende du démarrage des pods..."
sleep 5

echo "=== Evenements ==="
kubectl get events --field-selector involvedObject.name=health-app --sort-by='.lastTimestamp'

echo ""
echo "=== Etat des pods ==="
watch_pods(){
    while true; do
        clear
        echo "Etat pods (ctrl+c pour arrêter):"
        echo "-------------------------------"

        kubectl get pods -l app=health-demo -o wide
        echo ""
        echo "Détails des probes: "
        echo "-------------------"

        for pod in $(kubectl get pods -l app=health-demo -o name); do
            echo "Details pour $pod:"
            kubectl describe pod $pod | grep -A 10 "Liveness" | head -5
            kubectl describe pod $pod | grep -A 10 "Readiness" | head -5
            echo ""
        done
        sleep 3
    done
}

watch_pods 