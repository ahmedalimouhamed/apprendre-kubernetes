#!/bin/bash

echo "=== Test ConfigMap Volume ==="

echo "1. Création des resources..."
kubectl apply -f configmap-app.yaml

echo "2. Attente du démarrage..."
sleep 15

echo "3. Etat du pod :"
kubectl get pod configmap-app

echo "4. Configuration du port-forward..."
kubectl port-forward pod/configmap-app 8081:80 & 
PORT_FORWARD_PID=$!

sleep 5

echo "5. Test de la page web..."
curl -s http://localhost:8081

echo -e "\n6. Liste des fichiers de configuration:"
curl -s http://localhost:8081/config/ | grep -o 'href="[^"]*"' | cut -d '"' -f2

echo -e "\n7. Contenu des fichiers dans le container:"
kubectl exec configmap-app -- ls -la /etc/app-config
kubectl exec configmap-app -- cat /etc/app-config/app.properties
kubectl exec configmap-app -- cat /etc/app-config/logging.properties

echo -e "\n8. Modification du Config à chaud..."
kubectl patch configmap app-config --type='json' -p='[{"op": "replace", "path": "/data/index.html", "value": "<html><body><h1>ConfigMap Modifié</h1></body></html>"}]'

echo "Attente de la propagation de la modification..."
sleep 30

echo "Attente de la propagation de la modification..."

sleep 30

echo "9. Vérification de la modification..."
curl -s http://localhost:8081

echo -e "\n10. Nettoyage..."
kill $PORT_FORWARD_PID
kubectl delete pod configmap-app
kubectl delete configmap app-config nginx-config

echo "=== Fin du test ==="
