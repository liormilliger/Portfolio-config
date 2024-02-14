#!/bin/bash

kubectl delete cm -n fluentd fluentd-config                                                    
helm uninstall fluentd -n fluentd

kubectl apply -f app-of-apps/fluentd-cm.yaml                                                  
helm install -n fluentd fluentd bitnami/fluentd -f app-of-apps/files/fluentd-values.yaml