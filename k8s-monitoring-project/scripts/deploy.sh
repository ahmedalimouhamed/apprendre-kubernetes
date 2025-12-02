#!/bin/bash

set -e

echo "Déploiement du projet de monitoring kubrnetes..."
echo "================================================"

#vérification des prérequis
check_prerequisites(){
    echo "Vérification des prérequis..."
    command -v kubectl >/dev/null 2>&1 || { echo "X kubectl n'est pas installé"; exit 1; }
    command -v docker >/dev/null 2>&1 || { echo "X docker n'est pas installé"; exit 1; }
    kubectl cluster-info >/dev/null 2>&1 || { echo "X Impossible de se connecter au cluster Kuberntes"; exit 1; }
    echo "Prérequis Vérifies"
}

build_images(){
    echo "Constrction des images Docker..."

    #Constructin de l'image de l'application API
    if [ -d "api" ]; then
        docker build -t my-app-api:latest api/
    fi

    echo "Images construites"
}

deploy_infrastructure(){
    echo "Déploiement de l'infastructure..."

    #Application des manifests dans l'ordre
    for manifest in namespace.yaml configmap.yaml secrets.yaml deployment-api.yaml service-api.yaml deployment-app.yaml service-app.yaml cronjob-exporter.yaml; do
        if [ -f "manifests/$manifest" ]; then
            echo "Application de manifest"
            kubectl apply -f manifest/$manifest
        fi
    done

    echo "Infrastructure déployée"
}

wait_for_services(){
    echo "Attente du démarrage des services..."

    #Attente des pods
    kubectl wait --for=condition=ready pod -l app=rest-api -n monitoring-project --timeout=120s
    kubectl wait --for=condition=ready pod -l app=web-app -n monitoring-project --timeout=120s
    echo "Services démarrés"
}

show_status(){
    echo "Status du déploiement :"
    echo "======================"
    kubectl get pods -n monitoring-project
    echo ""
    kubectl get svc -n monitoring-project
    echo ""
    kubectl get cronjobs -n monitoring-project
}

main(){
    check_prerequisites
    build_images
    deploy_infrastructure
    wait_for_services
    show_status
    echo "  Déploiement termniné avec succès!"
}

main "$@"