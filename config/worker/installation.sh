#!/bin/sh

# Create directories for to configure `kubelet`, `kube-proxy`, `cni`, and a directory to keep the kubernetes root ca file
sudo mkdir -p \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubernetes \
  /var/run/kubernetes

# Download and Install CNI
wget -q --show-progress --https-only --timestamping \
  https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz

# Install CNI into /opt/cni/bin/. We will be using Flannel
sudo tar -xvf cni-plugins-linux-amd64-v0.9.1.tgz -C /opt/cni/bin/

# Download binaries for kubectl, kube-proxy, and kubelet
wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubelet

chmod +x  kubectl kube-proxy kubelet
sudo mv  kubectl kube-proxy kubelet /usr/local/bin/
