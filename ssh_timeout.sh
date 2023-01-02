#!/bin/sh

SSH_KEY=~/.ssh/masterclass.cer

# infrastructure base name
NAME=MC-K8

echo "\033[33m Extending ssh timeout on worker nodes...\033[0m"

for i in 0 1 2; do
  instance="${NAME}-Cluster-Worker-${i}"
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')

  chmod +x config/ssh/timeout.sh
  ssh -i ${SSH_KEY} \
   -o StrictHostKeyChecking=no \
    ubuntu@${external_ip} \
    "bash -s" < config/ssh/timeout.sh
done


echo "\033[33m Extending ssh timeout on masters nodes...\033[0m"
for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x config/ssh/timeout.sh
  ssh -i ${SSH_KEY} \
   -o StrictHostKeyChecking=no \
    ubuntu@${external_ip} \
    "bash -s" < ssh/timeout.sh
done

echo "\033[32m SSH timeout extended \033[0m"
