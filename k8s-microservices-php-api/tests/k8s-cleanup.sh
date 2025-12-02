#!/bin/bash
kubectl delete all --all -n microservices-demo
kubectl delete namespace microservices-demo

echo "Environnement nettoyé"