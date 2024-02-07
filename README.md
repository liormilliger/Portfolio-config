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
- It has a /scripts folder with installations of all components for automated manual deployment

## Full Deployment Workflow Chart


![Workflow-Architecture](https://github.com/liormilliger/Portfolio-app/assets/64707466/477be583-fe86-4343-bee2-9209c57b2afe)


## Prerequisites

Before you begin, ensure you have the following:
- A cluster with at least 2 worker nodes
- Nodes should be with at least 2 cpu each and 8GB memory
- kubectl installed

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
- **app-of-apps folder** with application files for ArgoCD:
  - application with DB
  - ingress controller
  - elasticsearch with kibana
  - fluentd
  - prometheus with grafana
  - **files folder** with values-files for the above
- **blog-app helm chart folder**
- **scripts folder** with scripts for manual installation of components

## Installations - STORAGE

For manual installation, we will start with these -

establishing a connection between the CLI and our AWS EKS cluster

Installing storage related components

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
2. `helm install ingress-controller ingress-nginx/ingress-nginx`
3. `helm install -n elastic --create-namespace elasticsearch bitnami/elasticsearch -f app-of-apps/files/my-es-values.yml`
4. `kubectl create namespace fluentd`
5. `kubectl apply -f ./app-of-apps/files/fluentd-cm.yaml`
6. `helm install -n fluentd fluentd bitnami/fluentd -f app-of-apps/files/fluentd-values.yaml`
7. `helm install -n kube-prometheus-stack --create-namespace kube-prometheus-stack prometheus-community/kube-prometheus-stack -f app-of-apps/files/prometheus-values.yaml`
8. `kubectl apply -f ./app-of-apps/files/prometheus-service-monitor.yaml`

## Installations with scripts

In scripts folder we have scripts that we
***execute from root folder.**

Scripts are divided by their stacks and should be installed by a certain order:

1. `sh ./scripts/app_and_ingress.sh`
2. `sh ./scripts/storage.sh`
3. `sh ./scripts/install_efk.sh`
4. `sh ./scripts/prom_stack.sh`

There is also a script that installs all by that order - `sh ./scripts/bootup.sh`

And another script to clean ***ALL*** installations - `sh /scripts/clean_installs.sh`

## Components Overview - App

### Blog-app

This is our application Helm Chart that deploys the application with the MongoDB.
- The app is being deployed as a deployment with one Replica as it is not expected to be used by a lot of users, but it can be scaled up.
- The app service exposes the app internally, but also exposes the /metrics route for Prometheus monitoring app by using annotations.
- The MongoDB is being deployed as a StatefulSet - a unique deployment that enables synchronous connection between the pods.
- The MongoDB service is of type None, which gives stable, unique network identifiers for the MongoDB rather than an IP address.
- The db-init-config ConfigMap initializes the MongoDB with some data.
- configmap file tells our app how to communicate with the MongoDB (referenced in the app-deployment file).
- Ingress component exposes our app by service name and port to the loadbalancer created by the ingress-controller helm chart.

### Ingress controller

The ingress controller simply launches an application loadbalancer in our cloud and connects to the ingress component to expose services

### EFK Stack - Logging

The EFK stack consists of 3 applications - Elasticsearch, Fluentd and Kibana

**Fluentd** is being deployed as a DeamonSet on each node, with values file that sets it as a forwarder and connects it to the config file that resides in the fluentd config map. In the configmap we define the sources, filters and the destinations to which it sends the logs it collects (in our case - Elasticsearch)

**ElasticSearch** is being deployed as a StatefulSet with Master and Data pods with a values file that also enables deployment of Kibana as a sub-chart. It calls for PVs with PVCs for each of its pods, using the CSI Driver. Elasticsearch allows for logs query within its UI.

**Kibana** is being deployed as a dependency chart of Elasticsearch through Elasticsearch's values file, and allows visualisation of Elasticsearch's logs query.

### Prometheus Stack

Prometheus stack is being used for monitoring, includes Prometheus and Grafana deployment. Prometheus collects metrics from the cluster's components and can be set to send alerts. Grafana is a visualization tool in which we can customize dashboards to display the cluster's metrics. Our app exposes metrics for Prometheus on /metrics route, but a ServiceMonitor component is also required here to send the metrics connect between our app metrics and Prometheus.

### Using Grafana

Port-forward Grafana, get the user and password (secret) to login

1. In home page go to "Add your first Data Source"
2. Choose prometheus
3. Name it and define hostname as http://<svc/kube-prometheus-stack-prometheus>:9090
4. Save and Test (Success??)
5. Go to DASHBOARDS menu and choose NEW > NEW DASHBOARDS
6. Add Visualisation > Choose your <data source name>
7. Metric - http_requests_total // pod // blog-app

## Port-Forwarding

ArgoCD 

`kubectl port-forward -n argocd service/argocd-server 8282:80`

Kibana

`kubectl port-forward -n elastic service/elasticsearch-kibana 5601`

Grafana

`kubectl port-forward -n kube-prometheus-stack service/kube-prometheus-stack-grafana 8585:80`

## Integration with Argo CD

As ArgoCD listens to this repository, everytime a push is being made to this repository
and make any change to the components launched by ArgoCD - ArgoCD makes the necessary change to its deployment.

In our workflow - whenever a new app image is being created, Jenkins is connecting to this repository
and changes the app image in the app-deployment file.

## Contributing

We welcome contributions! Please read our contributing guidelines for how to propose changes.

## License

This project is licensed under the [MIT License](LICENSE).


