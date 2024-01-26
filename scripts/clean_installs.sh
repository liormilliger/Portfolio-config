#!/bin/bash

echo "---===<{[ CLEANING DEPENDENCIES AND BOOTUP ]}>===---"
echo "----------------------------------------------------"
echo ""

echo "---===<{[ UNINSTALLING CSI STORAGE-CLASS ]}>===---"
echo ""
kubectl delete sc gp2-csi-driver
echo ""
echo "---===<{[ UNINSTALLING CSI-DRIVER HELM CHART]}>===---"
echo ""
helm uninstall aws-ebs-csi-driver
echo ""

echo "---===<{[ DELETING FLUENTD CONFIGMAP ]}>===---"
echo ""
kubectl delete configmap -n fluentd fluentd-config
echo ""
echo "---===<{[ DELETING PROMETHEUS SERVICE MONITOR ]}>===---"
echo ""
kubectl delete servicemonitor blog-app-service-monitor -n kube-prometheus-stack 
echo ""

echo "---===<{[ DELETING APP-OF-APPS FOR ARGOCD]}>===---"
echo ""
kubectl delete -n argocd application app-of-apps.yaml
echo ""
echo "___________________________________________________"
echo "---===<{[ C L E A N U P   F I N I S H E D ]}>===---"
echo "==================================================="

