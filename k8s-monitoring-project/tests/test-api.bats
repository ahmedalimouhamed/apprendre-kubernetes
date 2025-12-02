#!/usr/bin/env bats

setup() {
    export NAMESPACE="monitoring-project"
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

get_api_pod() {
    kubectl get pods -n "$NAMESPACE" -l app=rest-api -o jsonpath='{.items[0].metadata.name}'
}

@test "Test de santé de l'API" {
    POD_NAME=$(get_api_pod)
    run kubectl exec -n "$NAMESPACE" "$POD_NAME" -- wget -qO- http://localhost:3000/health
    assert_success
    assert_output --partial "healthy"
}

@test "Test de readiness de l'API" {
    POD_NAME=$(get_api_pod)
    run kubectl exec -n "$NAMESPACE" "$POD_NAME" -- wget -qO- http://localhost:3000/ready
    assert_success
    assert_output --partial "ready"
}

@test "Test des endpoints de l'API" {
    POD_NAME=$(get_api_pod)
    run kubectl exec -n "$NAMESPACE" "$POD_NAME" -- wget -qO- http://localhost:3000/info
    assert_success
    assert_output --partial "version"
}

@test "Test des logs de l'API" {
    POD_NAME=$(get_api_pod)
    run kubectl logs -n "$NAMESPACE" "$POD_NAME" --tail=10
    assert_success
    refute_output --partial "ERROR"
    refute_output --partial "CRITICAL"
}
