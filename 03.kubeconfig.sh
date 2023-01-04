#!/bin/sh

#read -p $'\e[32mInput Kubernetes Load balancer address\e[0m: ' KUBERNETES_API_SERVER_ADDRESS

# Get the kubernetes load balancer domain name
KUBERNETES_API_SERVER_ADDRESS=$(aws elbv2 describe-load-balancers \
--names MC-K8-NetworkLoadBalancer \
--output text --query 'LoadBalancers[].DNSName')

# infrastructure base name
NAME=MC-K8

echo "\033[33m Generating the kubelet kube-config file...\033[0m"

for i in 0 1 2; do

instance="${NAME}-Cluster-Worker-${i}"
instance_hostname="ip-10-0-0-2${i}"

 # Set the kubernetes cluster in the kubeconfig file
  kubectl config set-cluster ${NAME} \
    --certificate-authority=output/pki/ca/ca.pem \
    --embed-certs=true \
    --server=https://$KUBERNETES_API_SERVER_ADDRESS:6443 \
    --kubeconfig=output/kubeconfig/${instance}.kubeconfig

# Set the user credentials in the kubeconfig file
  kubectl config set-credentials system:node:${instance_hostname} \
    --client-certificate=output/pki/kubelets/${instance}.pem \
    --client-key=output/pki/kubelets/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=output/kubeconfig/${instance}.kubeconfig
#
# Set the context in the kubeconfig file
  kubectl config set-context default \
    --cluster=${NAME} \
    --user=system:node:${instance_hostname} \
    --kubeconfig=output/kubeconfig/${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=output/kubeconfig/${instance}.kubeconfig
done

echo "\033[32m kubelet kube-config file generated\033[0m"


echo "\033[33m Generating the kube-proxy kube-config file...\033[0m"

kubectl config set-cluster ${NAME} \
  --certificate-authority=output/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_API_SERVER_ADDRESS}:6443 \
  --kubeconfig=output/kubeconfig/kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=output/pki/kubeproxy/kube-proxy.pem \
  --client-key=output/pki/kubeproxy/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=output/kubeconfig/kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=${NAME} \
  --user=system:kube-proxy \
  --kubeconfig=output/kubeconfig/kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=output/kubeconfig/kube-proxy.kubeconfig

echo "\033[32m kube-proxy kube-config file generated\033[0m"


echo "\033[33m Generating the kube-controller manager kube-config file...\033[0m"

kubectl config set-cluster ${NAME} \
  --certificate-authority=output/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=output/kubeconfig/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=output/pki/controller/kube-controller-manager.pem \
  --client-key=output/pki/controller/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=output/kubeconfig/kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=${NAME} \
  --user=system:kube-controller-manager \
  --kubeconfig=output/kubeconfig/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=output/kubeconfig/kube-controller-manager.kubeconfig

echo "\033[32m kube-controller file generated\033[0m"


echo "\033[33m Generating the Kube-Scheduler kube-config file...\033[0m"
kubectl config set-cluster ${NAME} \
  --certificate-authority=output/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=output/kubeconfig/kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=output/pki/scheduler/kube-scheduler.pem \
  --client-key=output/pki/scheduler/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=output/kubeconfig/kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=${NAME} \
  --user=system:kube-scheduler \
  --kubeconfig=output/kubeconfig/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=output/kubeconfig/kube-scheduler.kubeconfig

echo "\033[32m kube-proxy Kube-Scheduler file generated\033[0m"

echo "\033[33m Generating the admin kube-config file...\033[0m"
kubectl config set-cluster ${NAME} \
  --certificate-authority=output/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_API_SERVER_ADDRESS}:6443 \
  --kubeconfig=output/kubeconfig/admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=output/pki/admin/admin.pem \
  --client-key=output/pki/admin/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=output/kubeconfig/admin.kubeconfig

kubectl config set-context default \
  --cluster=${NAME} \
  --user=admin \
  --kubeconfig=output/kubeconfig/admin.kubeconfig

kubectl config use-context default --kubeconfig=output/kubeconfig/admin.kubeconfig
echo "\033[32m Admin file generated\033[0m"
