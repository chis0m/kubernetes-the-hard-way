#!/bin/sh

SSH_KEY=~/.ssh/masterclass.cer

# infrastructure base name
NAME=MC-K8

#echo "\033[33m Begin installation of Containerd on worker nodes..\033[0m"
#for i in 0 1 2; do
#  instance="${NAME}-Cluster-Worker-${i}"
#  external_ip=$(aws ec2 describe-instances \
#    --filters "Name=tag:Name,Values=${instance}" \
#    --output text --query 'Reservations[].Instances[].PublicIpAddress')
#  chmod +x config/worker/containerd.sh
#  ssh -i ${SSH_KEY}  -o StrictHostKeyChecking=no ubuntu@${external_ip} "bash -s" < config/worker/containerd.sh
#done
#echo "\033[32m Installation successful\033[0m"

echo "\033[33m Begin installation of CNI on worker nodes..\033[0m"
for i in 0 1 2; do
  instance="${NAME}-Cluster-Worker-${i}"
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/worker/cni_installation.sh
  ssh -i ${SSH_KEY}  -o StrictHostKeyChecking=no ubuntu@${external_ip} "bash -s" < config/worker/cni_installation.sh
done
echo "\033[32m Installation successful\033[0m"

echo "\033[33m Begin configuration of bridge and kubelet on worker nodes..\033[0m"
for i in 0 1 2; do
  instance="${NAME}-Cluster-Worker-${i}"
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/worker/configure_kubelet.sh
  ssh -i ${SSH_KEY}  -o StrictHostKeyChecking=no ubuntu@${external_ip} "bash -s" < config/worker/configure_kubelet.sh
done
echo "\033[32m Configuration successful\033[0m"

echo "\033[33m Begin configuration of kube-proxy on worker nodes..\033[0m"
for i in 0 1 2; do
  instance="${NAME}-Cluster-Worker-${i}"
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/worker/configure_kubeproxy.sh
  ssh -i ${SSH_KEY}  -o StrictHostKeyChecking=no ubuntu@${external_ip} "bash -s" < config/worker/configure_kubeproxy.sh
done
echo "\033[32m Configuration successful\033[0m"

echo "\033[33m Enable kube-proxy...\033[0m"
for i in 0 1 2; do
  instance="${NAME}-Cluster-Worker-${i}"
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/worker/enable.sh
  ssh -i ${SSH_KEY}  -o StrictHostKeyChecking=no ubuntu@${external_ip} "bash -s" < config/worker/enable.sh
done
echo "\033[32m Worker Node Configuration Complete\033[0m"
