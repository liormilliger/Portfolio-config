#!/bin/bash
echo "---===<{[ INSTALLING CSI STORAGE-CLASS ]}>===---"
echo ""
echo ""
kubectl apply -f storage-class-csi.yaml
echo ""
echo ""
echo "---===<{[ APPLYING SECRET Shhhhh ]}>===---"
echo ""
echo ""
sh ./scripts/secret-aws-ebs-csi-driver.sh
echo ""
echo ""
echo "---===<{[ INSTALLING CSI-DRIVER HELM CHART]}>===---"
echo ""
echo ""
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver
echo ""
echo ""
echo "---===<{[ F I N I S H E D   S C R I P T  I N S T A L L A T I O N S  ]}>===---"
echo ""
echo ""



