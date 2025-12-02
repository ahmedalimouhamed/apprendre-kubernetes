.PHONY: deploy test clean export monitor

NAMESPACE=monitoring-project
APP_NAME=app-monitor

#Déploiment
deploy:
	@echo "Création du namespace..."
	kubectl apply -f manifests/namespace.yaml
	@echo "Déploiment des scripts et configmaps..."
	kubectl apply -f manifests/secrets.yaml -f manifests/configmap.yaml
	@echo "Déploiement de l'application..."
	kubectl apply -f manifests/deployment-app.yaml -f manifests/service-app.yaml
	@echo "Déploiement de l'API..."
	kubectl apply -f manifests/deployment-api.yaml -f manifests/service-api.yaml
	#@echo "Déploiement de l'ingress..."
	#kubectl apply -f manifests/ingress.yaml
	@echo "Déploiement du cronjob..."
	kubectl apply -f manifests/cronjob-exporter.yaml
	@echo "Déploiement terminé"

#Tests
test:
	@echo "Lancement des tests..."
	./scripts/test-health.sh
	bats tests/test-deployment.bats
	bats tests/test-api.bats

#Tess complets
test-all: test
	bats tests/test-export.bats
	@echo "Tous les tests sont passés"

#Exports des metriques
export:
	@echo "Exportation des métriques..."
	./scripts/export-metrics.sh

#Monitoring en temps réel
monitor:
	@echo "Surveillance des pods..."
	watch -n 5 "kubectl get pods -n $(NAMESPACE) && echo && kubectl get svc -n $(NAMESPACE)"

#Nettoyage
clean:
	@echo "Nettoyage de l'environnement..."
	./scripts/cleanup.sh
	bats tests/test-cleanup.bats

#Installation des dépendances
depenndences:
	@echo "Installation de kubectl, bats..."
	#Commands d'installation selon l'OS 