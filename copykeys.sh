#!/bin/sh

SSH_KEY=~/.ssh/masterclass.cer

# infrastructure base name
NAME=MC-K8

# Copy to Certificate to worker nodes
echo "\033[33m Copying certificates to worker nodes...\033[0m"

for i in 0 1 2; do
  instance="${NAME}-Cluster-Worker-${i}"
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  scp -i ${SSH_KEY} \
    -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    k8pki/ca/ca.pem k8pki/kubelets/${instance}-key.pem k8pki/kubelets/${instance}.pem ubuntu@${external_ip}:~/; \
done

echo "\033[32m Certificates copied to worker nodes\033[0m"

# Copy to Certificate to master nodes
echo "\033[33m Copying certificates to masters nodes...\033[0m"
for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  scp -i ${SSH_KEY} \
    -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    k8pki/ca/ca.pem k8pki/ca/ca-key.pem \
    k8pki/sa/service-account-key.pem k8pki/sa/service-account.pem \
    k8pki/master/master-kubernetes.pem k8pki/master/master-kubernetes-key.pem ubuntu@${external_ip}:~/;
done

echo "\033[32m Certificates copied to master nodes\033[0m"
