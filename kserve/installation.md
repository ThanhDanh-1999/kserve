# Install istio, knative, kserve:
  ./rnd_quick_install.sh


# Setup config:

kubectl patch --namespace knative-serving configmap/config-gc \
  --type merge \
  --patch '{"data":{"max-non-active-revisions":"0","min-non-active-revisions":"0","retain-since-create-time":"disabled","retain-since-last-active-time":"disabled"}}'


kubectl patch --namespace knative-serving configmap/config-autoscaler \
  --type merge \
  --patch '{"data":{"allow-zero-initial-scale":"true","initial-scale":"0","scale-down-delay":"1800s"}}'

kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec": {"type": "ClusterIP"}}'

kubectl patch cm config-deployment --patch '{"data":{"queue-sidecar-image":"kserve/qpext:latest"}}' -n knative-serving
