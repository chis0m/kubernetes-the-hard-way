#!/bin/bash
set -e

echo "\033[33m STARTING ETCD INSTALLATION...\033[0m"

# Download Etcd package
wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.4.15/etcd-v3.4.15-linux-amd64.tar.gz"

# Extract and Install the etcd package
tar -xvf etcd-v3.4.15-linux-amd64.tar.gz
sudo mv etcd-v3.4.15-linux-amd64/etcd* /usr/local/bin/

# Configure the etcd server
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo chmod 700 /var/lib/etcd
sudo cp ${HOME}/{ca.pem,master-kubernetes-key.pem,master-kubernetes.pem} /etc/etcd/

# Get Internal IP of the instance
export INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Set ETCD unique name. Each etcd member must have a unique name
ETCD_NAME=$(curl -s http://169.254.169.254/latest/user-data/ \
  | tr "|" "\n" | grep "^name" | cut -d"=" -f2)

echo ${ETCD_NAME}

# Set cluster names and addresses
CLUSTER0=MC-K8-Cluster-Master-0
CLUSTER1=MC-K8-Cluster-Master-1
CLUSTER2=MC-K8-Cluster-Master-2

ADDRESS0=https://10.0.0.10:2380
ADDRESS1=https://10.0.0.11:2380
ADDRESS2=https://10.0.0.12:2380

# Create Etcd Service
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${CLUSTER0}=${ADDRESS0},${CLUSTER1}=${ADDRESS1},${CLUSTER2}=${ADDRESS2} \\
  --cert-file=/etc/etcd/master-kubernetes.pem \\
  --key-file=/etc/etcd/master-kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/master-kubernetes.pem \\
  --peer-key-file=/etc/etcd/master-kubernetes-key.pem \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
