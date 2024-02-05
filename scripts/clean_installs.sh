#!/bin/bash

echo "---===<{[ UNINSTALLING HELM CHARTS ]}>===---"
echo "----------------------------------------------------"
echo ""
echo ""
helm uninstall blog-app
echo ""
echo ""
helm uninstall -n kube-prometheus-stack kube-prometheus-stack
echo ""
echo ""
helm uninstall -n elastic elasticsearch
echo ""
echo ""
helm uninstall -n fluentd fluentd
echo ""
echo ""
helm uninstall aws-ebs-csi-driver
echo ""
echo ""
helm uninstall nginx-ingress
echo ""
echo ""
echo "---===<{[ CLEANING DEPENDENCIES AND BOOTUP ]}>===---"
echo "----------------------------------------------------"
echo ""
echo "---===<{[ UNINSTALLING DEPENDENCIES FILES ]}>===---"
echo ""
echo ""
kubectl delete sc gp2-csi-driver
echo ""
echo ""
kubectl delete configmap -n fluentd fluentd-config
echo ""
echo ""
kubectl delete servicemonitor blog-app-service-monitor -n kube-prometheus-stack 
echo ""
echo ""
echo "___________________________________________________"
echo "---===<{[ C L E A N U P   F I N I S H E D ]}>===---"
echo "==================================================="

