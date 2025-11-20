#!/bin/bash

kubectl create secret generic mon-secret --from-literal=username=admin --from-literal=password=mypassword
kubectl get secrets