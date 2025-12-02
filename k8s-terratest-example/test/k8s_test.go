package test

import (
    "testing"
    "time"

    "github.com/gruntwork-io/terratest/modules/k8s"
    "github.com/stretchr/testify/assert"
)

func TestK8sDeployment(t *testing.T) {
    t.Parallel()

    options := k8s.NewKubectlOptions("", "", "default")

    // Appliquer les manifests
    k8s.KubectlApply(t, options, "../deployment.yaml")
    k8s.KubectlApply(t, options, "../service.yaml")

    // Attendre que les pods soient disponibles
    k8s.WaitUntilNumPodsCreated(t, options, k8s.NewPodFilter("app=nginx"), 2, 60, 5*time.Second)
    pods := k8s.ListPods(t, options, "app=nginx")
    assert.Equal(t, 2, len(pods))

    // Vérifier que chaque pod est en état "Running"
    for _, pod := range pods {
        k8s.WaitUntilPodAvailable(t, options, pod.Name, 30, 2*time.Second)
        podObj := k8s.GetPod(t, options, pod.Name)
        assert.Equal(t, "Running", string(podObj.Status.Phase))
    }

    // Vérifier que le Service existe
    service := k8s.GetService(t, options, "nginx-service")
    assert.NotNil(t, service)
}
