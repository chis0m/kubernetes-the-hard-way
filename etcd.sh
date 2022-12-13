#!/bin/sh

SSH_KEY=~/.ssh/masterclass.cer

# infrastructure base name
NAME=MC-K8

ETCD_ENCRYPTION_KEY=$(head -c 64 /dev/urandom | base64)

cat > etcd/encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ETCD_ENCRYPTION_KEY}
      - identity: {}
EOF

# Copy Encryption Config  to master nodes
echo "\033[33m Copying Encryption Config to masters nodes...\033[0m"
for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  scp -i ${SSH_KEY} \
    -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    etcd/encryption-config.yaml \
    ubuntu@${external_ip}:~/;
done

echo "\033[32m Encryption Config copied to master nodes\033[0m"


# Execute Installation script in the master nodes
echo "\033[33m Execute Etcd installation script..\033[0m"
for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x etcd/install_etcd.sh
  ssh -i ${SSH_KEY} \
   -o StrictHostKeyChecking=no \
    ubuntu@${external_ip} \
    "bash -s" < etcd/install_etcd.sh

done


# Enable Etcd in the master nodes
echo "\033[33m Enabling Etcd..\033[0m"
for i in 0 1 2; do
instance="${NAME}-Cluster-Master-${i}" \
  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
  chmod +x etcd/enable_etcd.sh
  ssh -i ${SSH_KEY} \
    -o StrictHostKeyChecking=no \
    ubuntu@${external_ip} \
    "bash -s" < etcd/enable_etcd.sh

#    if [ $i -eq 2 ]
#    then
#      # verify etcd installation
#      sudo ETCDCTL_API=3 etcdctl member list \
#        --endpoints=https://127.0.0.1:2379 \
#        --cacert=/etc/etcd/ca.pem \
#        --cert=/etc/etcd/master-kubernetes.pem \
#        --key=/etc/etcd/master-kubernetes-key.pem
#    fi

done

echo "\033[32m Etcd Enabled successfully\033[0m"

echo "\033[32m Etcd Installation script executed!!!\033[0m"

