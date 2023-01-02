#!/bin/sh

# Create the Kubernetes configuration directory
sudo mkdir -p /etc/kubernetes/config

# Download and install the official Kubernetes release binaries
wget -q --show-progress --https-only --timestamping \
"https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-apiserver" \
"https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-controller-manager" \
"https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-scheduler" \
"https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl"

chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

# Configure the Kubernetes API Server
sudo mkdir -p /var/lib/kubernetes/
sudo mv ${HOME}/{ca.pem,ca-key.pem,master-kubernetes-key.pem,master-kubernetes.pem,service-account-key.pem,service-account.pem,encryption-config.yaml} \
     /var/lib/kubernetes/

# Get the internal IP Address
export INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Set Etcd addresses
ADDRESS0=https://10.0.0.10:2379
ADDRESS1=https://10.0.0.11:2379
ADDRESS2=https://10.0.0.12:2379

# Create the kube-apiserver.service
cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
  --advertise-address=${INTERNAL_IP} \
  --allow-privileged=true \
  --apiserver-count=3 \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/audit.log \
  --authorization-mode=Node,RBAC \
  --bind-address=0.0.0.0 \
  --client-ca-file=/var/lib/kubernetes/ca.pem \
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --etcd-cafile=/var/lib/kubernetes/ca.pem \
  --etcd-certfile=/var/lib/kubernetes/master-kubernetes.pem \
  --etcd-keyfile=/var/lib/kubernetes/master-kubernetes-key.pem\
  --etcd-servers=https://10.0.0.10:2379,https://10.0.0.11:2379,https://10.0.0.12:2379 \
  --event-ttl=1h \
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \
  --kubelet-client-certificate=/var/lib/kubernetes/master-kubernetes.pem \
  --kubelet-client-key=/var/lib/kubernetes/master-kubernetes-key.pem \
  --runtime-config='api/all=true' \
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \
  --service-account-signing-key-file=/var/lib/kubernetes/service-account-key.pem \
  --service-account-issuer=https://${INTERNAL_IP}:6443 \
  --service-cluster-ip-range=10.32.0.0/24 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/var/lib/kubernetes/master-kubernetes.pem \
  --tls-private-key-file=/var/lib/kubernetes/master-kubernetes-key.pem \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
