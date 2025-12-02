#!/bin/bash

echo "=== Test PV/PVC HostPath ==="

echo "1. Création PV, PVC et Pod..."
kubectl apply -f pv-hostpath.yaml

echo "2. Attente de la liaison..."
sleep 5

echo "3. Etat des resources:"
kubectl get pvc,pv,pod -o wide

echo "4. Vérification des données: "
kubectl exec simple-pv-pod -- cat /data/message.txt

echo "5. Ecriture de données supplémentaires..."
kubectl exec simple-pv-pod -- sh -c "echo 'Ajout: $(date)' >> /data/message.txt"
kubectl exec simple-pv-pod -- cat /data/message.txt

echo "6. Suppression du pod..."
kubectl delete pod simple-pv-pod --wait=false 2>/dev/null || true
sleep 3

echo "7. Recréation du pod..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: simple-pv-pod-2
spec:
  containers:
    - name: busybox
      image: busybox
      command: ["/bin/sh", "-c"]
      args: ["echo 'pod 2 démarre' > /data/message.txt && cat /data/message.txt && tail -f /dev/null"]
      volumeMounts:
        - name: pv-data
          mountPath: /data
  volumes:
    - name: pv-data
      persistentVolumeClaim:
        claimName: simple-local-pvc
EOF

sleep 10

echo "8. Vérification de la persistance: "
kubectl logs simple-pv-pod-2

echo "9. Nettoyage..."
kubectl delete pod simple-pv-pod-2 --wait=false 2>/dev/null || true
kubectl delete pvc simple-local-pvc --wait=false 2>/dev/null || true
kubectl delete pv simple-local-pv --wait=false 2>/dev/null || true


echo "=== Fin du test ==="
