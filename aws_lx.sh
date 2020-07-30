#!/bin/bash
sudo yum -y update

echo "Install Java JDK 8"
yum remove -y java
yum install -y java-1.8.0-openjdk

echo "Install git"
sudo yum install -y git


echo "Install docker"
sudo yum update -y
sudo amazon-linux-extras install docker
sudo yum install docker
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "Install  ekctl"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin


echo "Install  kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "Install  helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh



eksctl create cluster --name microcluster --region us-east-2 --nodegroup-name standard-workers --node-type t3.medium --nodes 10 --nodes-min 3 --nodes-max 15


helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update
git clone https://github.com/Keerthi1985/SpringMVCTomcat.git

cd SpringMVCTomcat/mySpringApp
helm install prometheus-blackbox-exporter stable/prometheus-blackbox-exporter
helm install prometheus stable/prometheus --set server.service.type=LoadBalancer -f prometheus.values.yaml
sleep 120
helm install grafana stable/grafana --set adminPassword='admin' --set service.type=LoadBalancer
sleep 2
helm install jaeger jaegertracing/jaeger -f jaeger_values.yaml
sleep 120
kubectl apply -f kubernetes_sql.yaml
sleep 15
kubectl apply -f kubernetes_manifests.yaml
sleep 15
echo "ALL DEPLOYMENT COMPLETED"
