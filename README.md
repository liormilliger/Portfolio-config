# Portfolio-app

## Project Overview

This repo is a part of 3 repositories for deploying a blog application with a database using ArgoCD app-of-apps on AWS EKS using Terraform.

### Portfolio-infra at https://github.com/liormilliger/Portfolio-infra.git

with terraform IaC files that deployes AWS EKS cluster with ArgoCD

### Portfolio-config at https://github.com/liormilliger/Portfolio-config.git

with kubernetes configuration files

## About

- Portfolio-app is a development repo with dev and test options for a 3-tier application with a database and proxy-server.
- It has the application files, Dockerfiles to create images and a docker-compose file to deploy as microservices with docker-compose,
for local deployment and testing.
- It also has the Jenkinsfile for CI
To Deploy the whole infrastructure, change to Portfolio-infra and perform `terraform init`
- This repo has a webhook to Jenkins - whenever there is a push to this repo, it initiates a build, test and push of a new app image to an ECR


## Full Deployment Workflow Chart


![Workflow-Architecture](https://github.com/liormilliger/Portfolio-app/assets/64707466/477be583-fe86-4343-bee2-9209c57b2afe)


## Prerequisites

Before you begin, ensure you have the following:
- Docker and docker-compose installed
- Jenkins installed and configured with your repository
- AWS account
- AWS ECR for storing images

## Docker-compose file

The docker-compose file deploys 3 microservices - application, database and nginx
- The application service can be exposed on port 5000 (hashed) and belongs to both frontend and backend networks
- The MongoDB is exposed within the backend network on port 27017 (default) and is being injected with an init file
- The Nginx is being used both as a reverse proxy and also serves static files, and exposes the app on port 80 on the frontend network
- Nginx image has a Dockerfile that takes the static files from the app

## Usage

Deployment of the 3-tier microservices application, simply `docker compose up --build`
and check `localhost` in the browser to get the app's UI

## 3-tier Microservices Application Architecture

![app-arch](https://github.com/liormilliger/Portfolio-app/assets/64707466/a9032045-5ab6-45d3-bd7c-77d455ada1be)


## Jenkinsfile
### Configuration
- Configure Jenkins with the proper credentials for your AWS account and this repo (SSH)
- Install plugins for sshagent, AWS, docker and git
- Build a Multibranch Pipeline for further development
- Configure a webhook with this repository
- See the environment section and make sure it is adjusted with your values

### Stages

- Jenkins will build an image of the app,
- Then it will build a local microservices app with the docker-compose file
- For the next stage the microservices will go through a series of tests
- If tests go well - the image will be tagged and pushed to the ECR
- Since ArgoCD listens to the `Portfolio-config` repository, and in order to maintain CD, Jenkinsfile will update the application deployment file in `Portfolio-config` with the latest image
- Next stage is giving the app some time up for development or testing purposes - change it as you wish
- And to take down the testing environment, jenkins shuts down the microservices and perform a cleanup
- NOTES - Jenkinsfile can be further developed to contain versioning and push new images by branches
- NOTES - Jenkinsfile can be further developed to send messages for success/failure of tests



## Integration with Argo CD

Jenkins is making a change in `Portfolio-Config` repo - in file /blog-app/templates/app-deployment.yaml to update the application deployment image.

As ArgoCD listens to this repository, a seamless update of the application will be performed.

## Contributing

We welcome contributions! Please read our contributing guidelines for how to propose changes.

## License

This project is licensed under the [MIT License](LICENSE).

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
