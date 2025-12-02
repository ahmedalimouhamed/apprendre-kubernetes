#!/usr/bin/env bats

setup() {
    export NAMESPACE="monitoring-project"
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

@test "Vérification du namespace" {
    run kubectl get namespace "$NAMESPACE"
    assert_success
    assert_output --partial "$NAMESPACE"
}

@test "Vérification des pods en cours d'exécution" {
    run kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Running
    assert_success
    [ "$(echo "$output" | grep -c "Running")" -ge 2 ]
}

@test "Vérification des services" {
    run kubectl get services -n "$NAMESPACE"
    assert_success
    assert_output --partial "web-service"
    assert_output --partial "api-service"
}

@test "Vérification des deployments" {
    run kubectl get deployments -n "$NAMESPACE"
    assert_success
    assert_output --partial "web-app"
    assert_output --partial "rest-api"
}

@test "Vérification des configmaps" {
    run kubectl get configmaps -n "$NAMESPACE"
    assert_success
    assert_output --partial "app-config"
}

@test "Vérification des secrets" {
    run kubectl get secrets -n "$NAMESPACE"
    assert_success
    assert_output --partial "app-secrets"
}
