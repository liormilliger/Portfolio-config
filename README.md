# Portfolio-config

## Project Overview

This repo is a part of 3 repositories for deploying a blog application with a database using ArgoCD app-of-apps on AWS EKS using Terraform.

### Portfolio-infra at https://github.com/liormilliger/Portfolio-infra.git

with terraform IaC files that deployes AWS EKS cluster with ArgoCD

### Portfolio-app at https://github.com/liormilliger/Portfolio-app.git

with app files, Jenkinsfile for CI, Dockerfiles and docker-compose file for local testing

## About

- Portfolio-config contains the kubernetes configuration files for our full production deployment.
- It has /blog-app which is a helm chart of the application and DB deployment
- It has the App-of-apps application files for ArgoCD that listens to that repository


## Full Deployment Workflow Chart


![Workflow-Architecture](https://github.com/liormilliger/Portfolio-app/assets/64707466/477be583-fe86-4343-bee2-9209c57b2afe)


## Prerequisites

Before you begin, ensure you have the following:
- A cluster with at least 2 worker nodes
- Nodes should be with at least 2 cpu each and 8GB memory

## Helm Repo Updates
In order to work with the helm charts - We need to add the repos to our helm library:
`helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver`
`helm repo add bitnami https://charts.bitnami.com/bitnami`
`helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx`          
`helm repo add argo https://argoproj.github.io/argo-helm`
`helm repo add prometheus-community	https://prometheus-community.github.io/helm-charts`
`helm repo update`

## Contents:
- `app-of-apps.yaml` application file for ArgoCD
- `app-of-apps folder` with application files for ArgoCD:
  - application with DB
  - ingress controller
  - elasticsearch with kibana
  - fluentd
  - prometheus with grafana
  - `files folder` with values-files for the above
- `blog-app helm chart folder`
- `scripts folder` with scripts for manual installation of components

## Installations - STORAGE

We Install multiple applications and for some - dependencies are needed.
There is a script in /scripts/systems_up.sh that installs these - `sh ./scripts/systems_up.sh`
1. Establish connection to aws with `aws eks --region us-east-1 update-kubeconfig --name blog-cluster`
2. Installing storage-class-csi.yaml - `kubectl apply -f storage-class-csi.yaml`
3. Creating secret with this command:
- `kubectl create secret generic aws-secret \
--from-literal "key_id=<YOUR AWS KEY ID>" \
--from-literal "access_key=<YOUR AWS ACCESS KEY>"`
This secret will be used for the next step
4. Installing CSI driver - Container Storage Interface that allows k8s persistent volume claims to get EBS volumes in AWS
  we will install the chart:
  `helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver`

## Installations - Applications installation flow

We will use helm charts to deploy the applications. Some apps need values files and others configmaps that needs to be applied before installing the chart:
1. `helm install blog-app blog-app`
2. `helm install -n elastic --create-namespace elasticsearch bitnami/elasticsearch -f app-of-apps/files/my-es-values.yml`
3. `kubectl create namespace fluentd`
4. `kubectl apply -f ./app-of-apps/files/fluentd-cm-GPT.yaml`
5. `helm install -n fluentd fluentd bitnami/fluentd -f app-of-apps/files/fluentd-values.yaml`
6. `helm install -n kube-prometheus-stack --create-namespace kube-prometheus-stack prometheus-community/kube-prometheus-stack -f app-of-apps/files/prometheus-values.yaml`
7. `kubectl apply -f ./app-of-apps/files/prometheus-service-monitor.yaml`

## Usage and Operation

We are using here multiple applications installation, and the order of installation is imprtant.

From the root folder we can simply 

## 3-tier Microservices Application Architecture


![Uploading app-arch (1).jpg…]()

## Integration with Argo CD

Jenkins is making a change in `Portfolio-Config` repo - in file /blog-app/templates/app-deployment.yaml to update the application deployment image.

As ArgoCD listens to this repository, a seamless update of the application will be performed.

## Contributing

We welcome contributions! Please read our contributing guidelines for how to propose changes.

## License

This project is licensed under the [MIT License](LICENSE).


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
etheus-stack service/kube-prometheus-stack-grafana 9091:80

 
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
