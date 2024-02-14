#!/bin/bash

kubectl delete cm -n elastic fluentd-config                                                    
helm uninstall fluentd -n elastic

kubectl apply -f app-of-apps/files/fluentd-cm.yaml                                                  
helm install -n elastic fluentd bitnami/fluentd -f app-of-apps/files/fluentd-values.yaml