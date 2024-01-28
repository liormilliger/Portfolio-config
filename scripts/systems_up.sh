#!/bin/bash

echo "---===<{[ CONNECTING TO AWS ]}>===---"
echo ""

aws eks --region us-east-1 update-kubeconfig --name blog-cluster
echo ""

echo "---===<{[ INSTALLING CSI STORAGE-CLASS ]}>===---"
echo ""

kubectl apply -f storage-class-csi.yaml
echo ""

echo "---===<{[ APPLYING SECRET Shhhhh ]}>===---"
echo ""

sh ./scripts/secret-aws-ebs-csi-driver.sh
echo ""

echo "---===<{[ INSTALLING CSI-DRIVER HELM CHART]}>===---"
echo ""

helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver
echo ""

echo "---===<{[ F I N I S H E D   I N I T I A L   S C R I P T ]}>===---"

echo ""
echo ""



