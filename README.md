## Introduction

This project is aimed to demonstrate monitoring and tracing of microservices without modifying the application.Deployment is planned on AWS EKS.
We have 4 micro services in various java frameworks .By default none of the services have any metric or tracing capability.
The starting point of the associated micorservices is this repo, which is a springMVC framework project.An endpoint for eg./helloMVC is exposed from this project and is accesible outside the cluster.

The order of exection of the applications triggered by the endpoint hit are in following order:
SpringMVC->SpringBootwithTomcat->SpringBootWithJetty->EmbeddedJetty.
The other 3 repos used as part of this microservice architecture are:


Each application is containerized and stored the corresponding image in docker hub as of now.
For monitoring, we have added a custom written javaagent named "InfyBuddy" with each of the 4 applications. The code base of the custom agent is as:

For tracing,we haved added opentelemtry agent which is an opensource java agent with each of the application.Details about this opensource project can be found in 
https://github.com/open-telemetry/opentelemetry-java-instrumentation .As of now this project is in beta version.

## Prerequisites
EC2 instance creation in AWS
(All the below installations are moved to a script file(aws_lx.sh))

## Installation
1. Install git in EC2
	
	sudo yum install -y git
	
	To clone the repository 
	
	git clone https://infygit.ad.infosys.com/Keerthi_V03/awsmonitoringtracingsampleapps.git
	
2. Install docker in EC2

	sudo yum update -y
	
	sudo amazon-linux-extras install docker
	
	sudo yum install docker
	
	sudo service docker start
	
	sudo usermod -a -G docker ec2-user
	
	Reference:- https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#install_docker
	
3. Install eksctl in EC2

	curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
	
	sudo mv /tmp/eksctl /usr/local/bin

	Reference:- https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
	
4. Install kubectl in EC2

	curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
	
	chmod +x ./kubectl
	
	sudo mv ./kubectl /usr/local/bin/kubectl
	
	Reference:- https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux

5. Install Helm3 in EC2

	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
	
	chmod 700 get_helm.sh
	
	./get_helm.sh

	Reference:- https://devopscube.com/install-configure-helm-kubernetes/

6. Create cluster with eksctl 
	eksctl create cluster --name microcluster --region us-east-2 --nodegroup-name standard-workers --node-type t3.medium --nodes 10 --nodes-min 3 --nodes-max 15

7. Install Prometheus and Grafana

	helm repo add stable https://kubernetes-charts.storage.googleapis.com
	
	helm repo update
	
	helm install prometheus stable/prometheus --set server.service.type=LoadBalancer --set rbac.create=false
	
	helm install grafana stable/grafana --set adminPassword='admin' --set service.type=LoadBalancer
	
8. Install Jaeger

	helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
	
	helm repo update
     
      Reference:-  https://github.com/jaegertracing/helm-charts
       
## Application Deployment

1. Deploy application	
	From SpringMVCTomcat application folder, excute the command
	
	kubectl apply -f kubernetes_manifests.yaml
	
	The yaml file contains deployment details of all the 4 applications required for this project.
	
	After the deployment  hit the endpoint /helloMVC (http://{externalip}/mySpringApp/helloMVC) to generate a traffic
	
2. To scrape metrics by Prometheus
	From SpringMVCTomcat application folder, execute the command
	
	helm upgrade prometheus stable/prometheus --set server.service.type=LoadBalancer --set rbac.create=false -f prometheus.values.yaml
	
	We can either configure prometheus url in grafana via:
	
	 a. yaml file during helm install or helm upgrade as mentioned in https://www.eksworkshop.com/intermediate/240_monitoring/deploy-grafana/
	 
	 b. grafana ui  ->add datasource->prometheusservicename as listed in kubectl get services (eg :http://prometheus-server)   
	
	View the Grafana Dashboard by using the external ip and see the metrics of the 4 application.
	
	Metrics name                 Metrics type
	
	http_requests_api_total      Counter
	
	http_request_api_latency     Summary
	
3. To enable trace in application
	From SpringMVCTomcat application folder, excute the command
	
	helm install jaeger jaegertracing/jaeger -f jaeger_values.yaml
	
	View the jaeger Dashboard and select any of the services (say :MVC ) and find traces. We will see the entire flow of events across apllications within a trace.
