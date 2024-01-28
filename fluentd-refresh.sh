#/bin/bash

kubectl delete cm -n fluentd fluentd-config
kubectl apply -f app-of-apps/files/fluentd-cm-GPT.yaml
kubectl delete --all pods -n fluentd
kubectl get pods -n fluentd -o wide -w
