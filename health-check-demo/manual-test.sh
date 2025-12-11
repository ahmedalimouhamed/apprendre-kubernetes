#!/bin/bash
echo "=== tests menuels des probes ==="

echo ""
echo "1. test manuel de liveness probe:"

for pod in $(kubectl get pods -l app=health-demo -o name); do
    pod_name=${pod#pod/}
    echo "Pod: $pod_name"
    kubectl exec $pod_name -- sh -c /scripts/liveness-script.sh
    echo "Code de sortie: $?"
    echo ""
done

echo ""
echo "2. Test manuel de la rediness probe: "
for pod in $(kubectl get pods -l app=health-demo -o name); do
    pod_name=${pod#pod/}
    echo "Pod: $pod_name"
    kubectl exec $pod_name -- sh -c /scripts/readiness-script.sh
    echo "Code de sortie: $?"
    echo ""
done

echo ""
echo "3. Fichiers dans /tmp: "
for pod in $(kubectl get pods -l app=health-demo -o name); do
    pod_name=${pod#pod/}
    echo "Pod: $pod_name"
    kubectl exec $pod_name -- ls -la /tmp/
    echo ""
done

echo ""
echo "4. Simulation d'un problème (suppression du fichier /tmp/healthy): "
FIRST_POD=$(kubectl get pods -l app=health-demo -o name | head -1)
pod_name=${FIRST_POD#pod/}
echo "Sur le pod: $pod_name"
kubectl exec $pod_name -- rm /tmp/hralthy
echo "Fichier healthy supprimé"
echo "Attente 20 secondes pour voir la liveness probe agir..."
sleep 20

echo ""
echo "5. Nombre de démarrages:"
kubectl get pods -l app=health-demo -o wide
echo ""
echo "Détails:"
for pod in $(kubectl get pods -l app=health-demo -o name); do
    kubectl describe pod $pod | grep "Restart Count" | head -1
done