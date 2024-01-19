#!/bin/bash

echo "---===<{[ CONNECTING TO AWS ]}>===---"

aws eks --region us-east-1 update-kubeconfig --name blog-cluster

echo "---===<{[ INSTALLING CSI STORAGE-CLASS ]}>===---"

kubectl apply -f storage-class-csi.yaml

echo "---===<{[ APPLYING SECRET Shhhhh ]}>===---"

sh ./secret-aws-ebs-csi-driver.sh

echo "---===<{[ INSTALLING CSI-DRIVER HELM CHART]}>===---"

helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver

# echo "---===<{[ INSTALLING BLOG-APP HELM CHART ]}>===---"
# helm install blog-app blog-app

# echo "---===<{[ INSTALLING APP-OF-APPS FOR ARGOCD]}>===---"
# kubectl apply -f app-of-apps.yaml

echo "---===<{[ F I N I S H ]}>===---"




