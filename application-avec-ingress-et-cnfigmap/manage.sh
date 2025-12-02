#!/bin/bash
NAMESPACE="projet-debutant"

case $1 in 
    "deploy")
        echo "Déployement de l'application..."
        kubectl apply -f .
        ;;
    "status")
        echo "Statut du déploiement:"
        kubectl get all -n $NAMESPACE
        ;;
    "logs")
        echo "📜 Affichage des logs du premier pod trouvé..."
        POD=$(kubectl get pods -n $NAMESPACE -o name | head -1)
        if [ -z "$POD" ]; then
            echo "❌ Aucun pod trouvé dans le namespace $NAMESPACE"
            exit 1
        fi
        kubectl logs -n $NAMESPACE $POD -f
        ;;
    "delete")
        echo "Suppression du déploiement..."
        kubectl delete -f . -n $NAMESPACE
        ;;
    *)
        echo "Usage: $0 (deploy|status|logs|delete)"
        ;;
esac