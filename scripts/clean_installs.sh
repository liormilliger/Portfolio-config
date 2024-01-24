#!/bin/bash


echo "---===<{[ UNINSTALLING CSI STORAGE-CLASS ]}>===---"

kubectl delete sc gp2-csi-driver

echo "---===<{[ UNINSTALLING CSI-DRIVER HELM CHART]}>===---"
helm uninstall aws-ebs-csi-driver


echo "---===<{[ UNINSTALLING HELM CHART FOR ELASTICSEARCH & KIBANA ]}>===---"

helm uninstall -n elastic elasticsearch

echo "---===<{[ DELETING FLUENTD CONFIGMAP ]}>===---"

kubectl delete configmap -n fluentd fluentd-config


echo "---===<{[ UNINSTALLING HELM CHART FOR FLUENTD ]}>===---"

helm uninstall -n fluentd fluentd

# echo "---===<{[ INSTALLING BLOG-APP HELM CHART ]}>===---"
# helm install blog-app blog-app

# echo "---===<{[ DELETING APP-OF-APPS FOR ARGOCD]}>===---"
# kubectl delete -n argocd application app-of-apps.yaml
