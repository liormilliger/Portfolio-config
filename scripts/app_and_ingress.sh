#!/bin/bash
echo "---===<{[ CONNECTING TO AWS ]}>===---"
echo ""
echo ""
aws eks --region us-east-1 update-kubeconfig --name blog-cluster
echo ""
echo ""
echo "---===<{[ INSTALLING BLOG APP HELM CHART ]}>===---"
echo ""
echo ""
helm install blog-app ./blog-app
echo ""
echo ""
echo "---===<{[ INSTALLING INGRESS-CONTROLLER HELM CHART ]}>===---"
echo ""
echo ""
helm install ingress-controller ingress-nginx/ingress-nginx
echo ""
echo ""
echo "---===<{[ F I N I S H E D   S C R I P T  I N S T A L L A T I O N S  ]}>===---"
echo ""
echo ""