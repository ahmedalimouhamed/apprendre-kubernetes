#!/bin/bash

echo "=== Test PV/PVC avec Stockage Local ==="

echo "0. Préparation du répértoire local..."
minikube ssh "sudo mkdir -p /data/local-pv && sudo chmod 777 /data/local-pv"

echo "1. Création des resources kubernetes..."
kubectl apply -f local-storage.yaml

echo "2. Attente du démarrage..."
sleep 10

echo "3. Etat des resources."
echo "--- PV:"
kubectl get pv

echo "--- PVC:"
kubectl get pvc

echo "--- Pod:"
kubectl get pod pv-test-app

echo "4. Exécution des scripts d'initialisation..."
kubectl exec pv-test-app -- sh -c "cp /config-scripts/init.sh /tmp/init.sh && chmod +x /tmp/init.sh && /tmp/init.sh"

echo "5. Création du service..."
kubectl expose pod pv-test-app --type=NodePort --port=80

echo "6. obtention de l'url..."
SERVICE_URL=$(minikube service pv-test-app --url)
echo "URL du service: $SERVICE_URL"

echo "7. Test de la page web..."
curl -s $SERVICE_URL

echo -e "\n8. Simulation d'un redémarrage du pod..."
kubectl delete pod pv-test-app


cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pv-test-app-2
spec:
  containers:
    - name: app
      image: nginx:alpine
      volumeMounts:
        - name: data-volume
          mountPath: /usr/share/nginx/html
  volumes:
    - name: data-volume
      persistentVolumeClaim:
        claimName: local-pvc
EOF


sleep 10

echo "9. Verification de la persistance des donnés..."
kubectl exec pv-test-app-2 -- cat /usr/share/nginx/html/counter.txt

echo "10. Incrémentation du compteur..."
kubectl exec pv-test-app-2 -- sh -c 'echo $(( $(cat /usr/share/nginx/html/counter.txt) + 1 )) > /usr/share/nginx/html/counter.txt'
kubectl exec pv-test-app-2 -- cat /usr/share/nginx/html/counter.txt

echo "11. Données sur le node (Minikube) : "
minikube ssh "ls -la /data/local-pv && cat /data/local-pv/counter.txt"

echo -e "\n12. Test de suppression du PVC..."
kubectl delete pvc local-pvc --wait=false 2>/dev/null || true

sleep 2
echo "PVC supprimé. le PV devrait être en statut 'Released'"
kubectl get pv 


echo -e "\n13. Recréation du pvc..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc-2
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: pv-test-app-3
spec:
  containers:
    - name: app
      image: nginx:alpine
      volumeMounts:
        - name: data-volume
          mountPath: /usr/share/nginx/html
  volumes:
    - name: data-volume
      persistentVolumeClaim:
        claimName: local-pvc-2
EOF

sleep 10

echo "Etat après recréation: "
kubectl get pv,pvc,pod

echo -e "\n14. Nettoyage..."
kubectl delete pod pv-test-app-2 pv-test-app-3 --wait=false 2>/dev/null || true
kubectl delete pvc local-pvc-2 --wait=false 2>/dev/null || true
kubectl delete pv local-pv --wait=false 2>/dev/null || true
kubectl delete storageclass local-storage --wait=false 2>/dev/null || true
kubectl delete configmap init-scripts --wait=false 2>/dev/null || true
kubectl delete service pv-test-app --wait=false 2>/dev/null || true

echo "=== Fin du test ==="
