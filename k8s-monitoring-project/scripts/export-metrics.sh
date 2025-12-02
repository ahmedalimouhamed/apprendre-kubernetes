#!/bin/bash
set -e

NAMESPACE="monitoring-project"
OUTPUT_DIR="./exports"
TIMESTAMP=$(dae +%Y%m%d_%H%M%S)

echo "Exporting des métriques..."
echo "=========================="

create_export_dir(){
    mkdir -p "$OUTPUT_DIR"
    echo "Répertoire d'export : $OUTPUT_DIR"
}

export_pod_info(){
    echo "Export des informations des pods..."
    kubectl get pods -n $NAMESPACE -o json > "$OUTPUT_DIR/pods_${TIMESTAMP}.json"

    #export formaté
    kubectl get pods -n $NAMESPACE -o wide > "$OUTPUT_DIR/pods_${TIMESTAMP}.txt"
    echo "Informations des pods exportées"
}

export_services(){
    echo "Export des services..."
    kubectl get services -n $NAMESPACE -o json > "$OUTPUT_DIR/services_${TIMESTAMP}.json"
    echo "Services exportés"
}

export_metrics(){
    echo "Export des métriques de performance..."

    #Vérification si metrics-server est installé
    if kubectl top nodes >/dev/null 2>&1; then
        kubectk top pods -n $NAMESPACE > "$OUTPUT_DIR/metrics_${TIMESTAMP}.txt"
        echo "Métriques exportées"
    else
        echo "Metrics-server non disponibles"
    fi
}

create_summary_report() {
    echo "📋 Création du rapport de synthèse..."
    
    cat > "$OUTPUT_DIR/summary_${TIMESTAMP}.json" << EOF
{
    "export_timestamp": "$(date -Iseconds)",
    "namespace": "$NAMESPACE",
    "cluster_info": {
        "pods_total": $(kubectl get pods -n $NAMESPACE --no-headers | wc -l),
        "pods_running": $(kubectl get pods -n $NAMESPACE --no-headers | grep -c 'Running'),
        "services_count": $(kubectl get services -n $NAMESPACE --no-headers | wc -l),
        "deployments_count": $(kubectl get deployments -n $NAMESPACE --no-headers | wc -l)
    },
    "export_files": [
        "pods_${TIMESTAMP}.json",
        "services_${TIMESTAMP}.json",
        "metrics_${TIMESTAMP}.txt",
        "summary_${TIMESTAMP}.json"
    ]
}
EOF

    echo "✅ Rapport de synthèse créé"
}

show_export_summary() {
    echo ""
    echo "📦 Résumé de l'exportation:"
    echo "============================"
    ls -la "$OUTPUT_DIR"/*"${TIMESTAMP}"*
    echo ""
    echo "📊 Données exportées:"
    cat "$OUTPUT_DIR/summary_${TIMESTAMP}.json" | jq '.cluster_info'
}

main() {
    create_export_dir
    export_pod_info
    export_services
    export_metrics
    create_summary_report
    show_export_summary
    echo "🎉 Exportation terminée!"
}

main "$@"