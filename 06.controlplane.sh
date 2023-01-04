#!/bin/sh

SSH_KEY=~/.ssh/masterclass.cer

# infrastructure base name
NAME=MC-K8

# Setup Control plane in the master nodes
echo "\033[33m Setting up control plane..\033[0m"
for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/controlplane/apiserver.sh
  ssh -i ${SSH_KEY} \
   -o StrictHostKeyChecking=no \
    ubuntu@${external_ip} \
    "bash -s" < config/controlplane/apiserver.sh
done

for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/controlplane/manager.sh
  ssh -i ${SSH_KEY} \
   -o StrictHostKeyChecking=no \
    ubuntu@${external_ip} \
    "bash -s" < config/controlplane/manager.sh

done

for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/controlplane/scheduler.sh
  ssh -i ${SSH_KEY} \
   -o StrictHostKeyChecking=no \
    ubuntu@${external_ip} \
    "bash -s" < config/controlplane/scheduler.sh

done

for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/controlplane/enable.sh
  ssh -i ${SSH_KEY} \
   -o StrictHostKeyChecking=no \
    ubuntu@${external_ip} \
    "bash -s" < config/controlplane/enable.sh

done

# Configure RBAC ClusterRole on one of the master nodes
for i in 0; do
  instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
      --filters "Name=tag:Name,Values=${instance}" \
      --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/controlplane/rbac.sh
  ssh -i ${SSH_KEY}  -o StrictHostKeyChecking=no ubuntu@${external_ip} "bash -s" < config/controlplane/rbac.sh
done

echo "\033[32m Control plane setup successful\033[0m"
