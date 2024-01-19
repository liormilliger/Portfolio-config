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
