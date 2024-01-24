echo "---===<{[ CREATING NAMESPACE ]}>===---"
echo ""
echo ""
kubectl create namespace kube-prometheus-stack
echo ""
echo ""
echo "---===<{[ INSTALLING PROMETHEUS STACK HELM CHART ]}>===---"
echo ""
echo ""
helm install -n kube-prometheus-stack kube-prometheus-stack prometheus-community/kube-prometheus-stack -f ./app-of-apps/files/prometheus-values.yaml
echo ""
echo ""
echo "---===<{[ INSTALLING SERVICEMONITOR ]}>===---"
echo ""
echo ""
kubectl apply -f ./app-of-apps/files/prometheus-service-monitor.yaml
echo ""
echo ""