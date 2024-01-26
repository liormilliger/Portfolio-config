#!/bin/bash

echo "---===<{[ INSTALLING DEPENDENCIES FOR SUPPORT APPS ]}>===---"
echo ""

echo ""

echo "---===<{[ FLUENTD NS & CM]}>===---"
echo "----------------------------------"
echo ""
kubectl create namespace fluentd
kubectl apply -f ./app-of-apps/files/fluentd-cm-GPT.yaml
echo ""

# echo "---===<{[ PROMETHEUS SERVICE-MONITOR ]}>===---"
# echo "----------------------------------------------"
# echo ""
# kubectl create namespace kube-prometheus-stack
# echo ""
# kubectl apply -f ./app-of-apps/files/prometheus-service-monitor.yaml

echo ""

echo "---===<{[ INSTALLING APP-OF-APPS FOR ARGOCD ]}>===---"
echo "----------------------------------------------------"
echo ""
kubectl apply -f ./app-of-apps.yaml
echo ""

echo "---===<{[ F I N I S H E D   I N S T A L L I N G   D E P E N D E N C I E S ]}>===---"




