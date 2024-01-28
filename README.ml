-------------------[ STRUCTURE ]-----------------------

This application works with 3 different repos you can clone at:
(Now these repos are provate so cloning is not possible)

CONFIG-REPO - Stores kubernetes files
https://github.com/liormilliger/Portfolio-config.git

INFRA-REPO - Stores Terraform files
https://github.com/liormilliger/Portfolio-infra.git

APPLICATION-REPO - Stores Application files, Jenkinsfile, Dockerfiles and docker-compose for local deployment
https://github.com/liormilliger/Portfolio-app.git


____________________/ INITIAL CHECKS \______________

Before applying Terraform infrastructure, make sure to make the nessecary changes:

1. Update Terraform's variables and ingress in security module with your IP
2. Update Terraform's main variables with your IP
Terraform/
security.tf - ingress - PORTS
variables.tf - check the IPS

-----------------------[ SYSTEMS UP ]---------------------------

1. Apply terraform insfrastructure from the infra-repo
terraform plan
terraform apply -auto-approve

After terraform will successfully finish laying the infrastructure -

2. Start services with scripts in config-repo (k8s):
sh ./scripts/systems_up.sh
sh ./scripts/dependencies-installs.sh

These two will install:
Communication permission with AWS,
CSI storage class
CSI secret to allow operations on AWS
CSI-DRIVER Helm chart
---
Fluentd namespace and configmap
app-of-apps.yaml for ArgoCD

-------------------------[ CLUSTER ]---------------------------------------

After the cluster is up - we use this command to enable working with kubectl:

aws eks --region us-east-1 update-kubeconfig --name blog-cluster

-------------------------------[ HELM-INSTALL ]--------------------------------------------

helm install blog-app blog-app

- - - - - - [ To install helm elasticsearch ] - - - - - -
[STAGE1]
kubectl apply -f storage-class-csi.yaml

[STAGE2]
#kubectl create secret generic aws-secret \
#--from-literal "key_id=${AWS_ACCESS_KEY_ID}" \
#--from-literal "access_key=${AWS_SECRET_ACCESS_KEY}"

-------------------------------[ PORT-FORWARDING ]--------------------------------------------

[[JENKINS - 8080 (on its own instance)]]

ArgoCD - 8282
kubectl port-forward -n argocd service/argocd-server 8282:80

KIBANA - 8585
kubectl port-forward -n elastic service/elasticsearch-kibana 8585:5601

Grafana - 9091
kubectl port-forward -n kube-prometheus-stack service/kube-prometheus-stack-grafana 9091:80

 
-------------------------------[ ARGO APP-OF-APPS INSTALL ]--------------------------------------------

Portforward ArgoCD, get the user and password to login

ArgoCD Initialization:

Connect REPO - git@github.com:liormilliger/Portfolio-config.git
SSH for GitHub - cat ~/.ssh/github_argocd_ssh

=========================================================
Operating Grafana UI

Port-forward Grafana, get the user and password to login

1. In home page go to "Add your first Data Source"
2. Choose prometheus
3. Name it and hostname http://<svc/kube-prometheus-stack-prometheus>:9090
4. Save and Test
5. Go to DASHBOARDS menu and choose NEW > NEW DASHBOARDS
6. Add Visualisation > Choose your <data source name>
7. Metric - http_requests_total // pod // blog-app

===========================================================

Operating in Kibana

Port-forward Kibana, get user and password to login

1. Go to discovery
2. Choose the logs you want to see 
3. Go to dashboard to see the logs in a dashboard
