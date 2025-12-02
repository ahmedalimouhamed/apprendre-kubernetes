#!/bin/bash

echo "=== Test volume emptyDir ==="

echo "1. Création du pod ..."
kubectl apply -f emptyDir-test.yaml

echo "2. Attente du démarrage du pod ..."
sleep 10

echo "3. Etat du Pod:"
kubectl get pod chat-pod

echo "4. Logs du writer:"
kubectl logs chat-pod -c writer

echo "5. Logs du reader (Premières lignes):"
kubectl logs chat-pod -c reader --tail=5

echo "6. Liste des fichiers dans le volume partagé :"
kubectl exec chat-pod -c writer -- ls /shared/

echo "7. Contenu des fichiers:"
kubectl exec chat-pod -c writer -- cat /shared/status.txt
kubectl exec chat-pod -c writer -- cat /shared/messages.txt

echo "8. Nettoyage..."
kubectl delete pod chat-pod
echo "=== Fin du test ==="