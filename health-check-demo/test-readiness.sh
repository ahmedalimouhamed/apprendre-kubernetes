#!/bin/bash
echo "=== Test Readiness Probe ==="

kubectl apply -f service-health.yaml
echo ""

test_readiness(){
    local pod=$1
    echo "Test sur $pod: "

    if kubectl logs $pod 1 > /dev/null | grep -q "Application prête à servir"; then
        echo "SUCCESS: $pod est prêt"
    else
        echo "ERROR: $pod n'est pas prêt"
    fi

    local ready=$(kubectl get pod $pod -o jsonpath='{.status.containerStatuses[0].ready}')

    if [ "$ready" = "true" ]; then
        echo "pod marque comme prêt"
    else
        echo "pod marque comme non prêt"
    fi

    echo ""
}

echo "=== Evolution de la readiness ==="
for i in {i..15}; do
    echo "---  Test $i (seconde $(($i * 3))) ---"
    for pod in $(kubectl get pods -l app=health-demo -o name); do
        test_readiness $pod
    done
    sleep 3 
done

echo "=== FINAL ==="
kubectl get pods -l app=health-demo -o wide
echo ""
echo "Endpoints du service: "
kubectl get endpoints health-service