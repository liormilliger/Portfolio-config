#!/bin/bash



echo "---===<{[ INSTALLING HELM CHART FOR ELASTICSEARCH & KIBANA ]}>===---"

helm install -n elastic --create-namespace elasticsearch bitnami/elasticsearch -f app-of-apps/files/my-es-values.yml


echo "---===<{[ CREATING FLUENTD NAMESPACE ]}>===---"

kubectl create ns fluentd

echo "---===<{[ INSTALLING CONFIGMAP FOR FLUENTD ]}>===---"

kubectl apply -f app-of-apps/fluentd-cm.yml


echo "---===<{[ INSTALLING HELM CHART FOR FLUENTD ]}>===---"

helm install -n fluentd fluentd bitnami/fluentd -f app-of-apps/files/fluentd-values.yaml 
