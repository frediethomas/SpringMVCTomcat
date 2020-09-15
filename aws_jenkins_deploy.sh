#!/bin/bash

eksctl create cluster --name microcluster --region us-east-2 --nodegroup-name standard-workers --node-type t3.medium --nodes 10 --nodes-min 3 --nodes-max 15

cd mySpringApp
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
