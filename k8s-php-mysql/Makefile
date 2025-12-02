NAMESPACE=php-mysql

build:
	docker build -t php-mysql-app:1.0 ./app
	minikube image load php-mysql-app:1.0

deploy:
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/mysql.yaml
	kubectl apply -f k8s/php-app.yaml
	kubectl apply -f k8s/phpmyadmin.yaml

test:
	bash app/tests/test_api.sh http://$$(minikube ip):30080

logs:
	kubectl get all -n $(NAMESPACE) -o json > logs.json
	@echo "logs exported to logs.json"

clean:
	kubectl delete namespace $(NAMESPACE)
	@echo "Namespace $(NAMESPACE) deleted"