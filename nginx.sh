#!/bin/sh

SSH_KEY=~/.ssh/masterclass.cer

# infrastructure base name
NAME=MC-K8

# Configure nginx for
echo "\033[33m Configure nginx for health checks in masters nodes...\033[0m"
for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/nginx/config.sh
  ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${external_ip} "bash -s" < config/nginx/config.sh
done

echo "\033[32m Configure nginx successfulyl\033[0m"
