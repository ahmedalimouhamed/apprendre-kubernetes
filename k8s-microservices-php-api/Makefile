NAMESPACE=microservices-demo

build:
	docker build -t php-micro:1.0 ./php-api
	minikube image load php-micro:1.0

deploy:
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/mysql-deployment.yaml
	kubectl apply -f k8s/php-api-deployment.yaml
	kubectl apply -f k8s/nginx-deployment.yaml
	kubectl apply -f k8s/phpmyadmin-deployment.yaml
	kubectl apply -f k8s/rabbitmq-deployment.yaml

test:
	bash tests/test-services.sh http://$$(minikube ip):30080

logs:
	kubectl get all -n $(NAMESPACE) -o json > logs.json
	@echo "Logs exported to logs.json"

clean:
	kubectl delete namespace $(NAMESPACE)
	@echo "Namespace $(NAMESPACE) deleted"
