#!/bin/sh

SSH_KEY=~/.ssh/masterclass.cer

# infrastructure base name
NAME=MC-K8

# Copy to kube config file to worker nodes
echo "\033[33m Copying Kube config to worker nodes...\033[0m"

for i in 0; do
  instance="${NAME}-Cluster-Worker-${i}"
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  scp -i ${SSH_KEY} \
    -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    output/kubeconfig/{${instance}.kubeconfig,kube-proxy.kubeconfig} \
    ubuntu@${external_ip}:~/; \
done

for i in 1; do
  instance="${NAME}-Cluster-Worker-${i}"
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  scp -i ${SSH_KEY} \
    -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    output/kubeconfig/{${instance}.kubeconfig,kube-proxy.kubeconfig} \
    ubuntu@${external_ip}:~/; \
done

for i in 2; do
  instance="${NAME}-Cluster-Worker-${i}"
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  scp -i ${SSH_KEY} \
    -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    output/kubeconfig/{${instance}.kubeconfig,kube-proxy.kubeconfig} \
    ubuntu@${external_ip}:~/; \
done

echo "\033[32m Kube config files copied to worker nodes\033[0m"


# Copy to kube config files to master nodes
echo "\033[33m Copying Config files to masters nodes...\033[0m"
for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  scp -i ${SSH_KEY} \
    -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    output/kubeconfig/{kube-controller-manager.kubeconfig,kube-scheduler.kubeconfig,admin.kubeconfig} \
    ubuntu@${external_ip}:~/;
done

echo "\033[32m Config files copied to master nodes\033[0m"
