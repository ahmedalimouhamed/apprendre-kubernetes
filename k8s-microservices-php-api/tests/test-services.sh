#!/bin/bash
NAMESPACE="microservices-demo"
OUTPUT="test-results.json"
declare -A results

function check_service(){
    local svc=$1
    local url=$2
    echo "Testing $svc..."
    if curl -s --max-time 5 $url >/dev/null; then
        results["$svc"]="OK"
    else
        results["$svc"]="FAILED"
    fi
}

check_service "php-api" "http://localhost:30000/api/"
check_service "phpmyadmin" "http://localhost:30007"
check_service "rabbitmq" "http://localhost:30009"
check_service "eureka" "http://localhost:30010"

echo "{" > $OUTPUT
for svc in "${!results[@]}"; do
    echo "\"$svc\": \"${results[$svc]}\"," >> $OUTPUT
done
echo "\"timestamp\": \"${date}\"}" >> $OUTPUT

cat $OUTPUT