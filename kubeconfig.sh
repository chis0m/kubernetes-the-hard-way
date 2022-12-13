#!/bin/sh

#read -p $'\e[32mInput Kubernetes Load balancer address\e[0m: ' KUBERNETES_API_SERVER_ADDRESS

# Get the kubernetes loadbalancer domain name
KUBERNETES_API_SERVER_ADDRESS=$(aws elbv2 describe-load-balancers \
--names MC-K8-NetworkLoadBalancer \
--output text --query 'LoadBalancers[].DNSName')

#KUBERNETES_API_SERVER_ADDRESS=MC-K8-NetworkLoadBalancer-a0a93fac0dfc9247.elb.us-east-1.amazonaws.com

# infrastructure base name
NAME=MC-K8

echo "\033[33m Generating the kubelet kube-config file...\033[0m"

for i in 0 1 2; do

instance="${NAME}-Cluster-Worker-${i}"
instance_hostname="ip-10-0-0-3${i}"

 # Set the kubernetes cluster in the kubeconfig file
  kubectl config set-cluster ${NAME} \
    --certificate-authority=k8pki/ca/ca.pem \
    --embed-certs=true \
    --server=https://$KUBERNETES_API_SERVER_ADDRESS:6443 \
    --kubeconfig=kubeconfig/${instance}.kubeconfig

# Set the user credentials in the kubeconfig file
  kubectl config set-credentials system:node:${instance_hostname} \
    --client-certificate=k8pki/kubelets/${instance}.pem \
    --client-key=k8pki/kubelets/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/${instance}.kubeconfig
#
# Set the context in the kubeconfig file
  kubectl config set-context default \
    --cluster=${NAME} \
    --user=system:node:${instance_hostname} \
    --kubeconfig=kubeconfig/${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=kubeconfig/${instance}.kubeconfig
done

echo "\033[32m kubelet kube-config file generated\033[0m"


echo "\033[33m Generating the kube-proxy kube-config file...\033[0m"

kubectl config set-cluster ${NAME} \
  --certificate-authority=k8pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_API_SERVER_ADDRESS}:6443 \
  --kubeconfig=kubeconfig/kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=k8pki/kubeproxy/kube-proxy.pem \
  --client-key=k8pki/kubeproxy/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kubeconfig/kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=${NAME} \
  --user=system:kube-proxy \
  --kubeconfig=kubeconfig/kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

echo "\033[32m kube-proxy kube-config file generated\033[0m"


echo "\033[33m Generating the kube-controller manager kube-config file...\033[0m"

kubectl config set-cluster ${NAME} \
  --certificate-authority=k8pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kubeconfig/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=k8pki/controller/kube-controller-manager.pem \
  --client-key=k8pki/controller/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kubeconfig/kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=${NAME} \
  --user=system:kube-controller-manager \
  --kubeconfig=kubeconfig/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kubeconfig/kube-controller-manager.kubeconfig

echo "\033[32m kube-controller file generated\033[0m"


echo "\033[33m Generating the Kube-Scheduler kube-config file...\033[0m"
kubectl config set-cluster ${NAME} \
  --certificate-authority=k8pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kubeconfig/kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=k8pki/scheduler/kube-scheduler.pem \
  --client-key=k8pki/scheduler/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kubeconfig/kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=${NAME} \
  --user=system:kube-scheduler \
  --kubeconfig=kubeconfig/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kubeconfig/kube-scheduler.kubeconfig

echo "\033[32m kube-proxy Kube-Scheduler file generated\033[0m"

echo "\033[33m Generating the admin kube-config file...\033[0m"
kubectl config set-cluster ${NAME} \
  --certificate-authority=k8pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_API_SERVER_ADDRESS}:6443 \
  --kubeconfig=kubeconfig/admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=k8pki/admin/admin.pem \
  --client-key=k8pki/admin/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=kubeconfig/admin.kubeconfig

kubectl config set-context default \
  --cluster=${NAME} \
  --user=admin \
  --kubeconfig=kubeconfig/admin.kubeconfig

kubectl config use-context default --kubeconfig=kubeconfig/admin.kubeconfig
echo "\033[32m kube-proxy admin file generated\033[0m"
