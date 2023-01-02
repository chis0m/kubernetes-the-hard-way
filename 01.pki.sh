#!/bin/sh
set -e

# Get the kubernetes loadbalancer domain name
KUBERNETES_PUBLIC_ADDRESS=$(aws elbv2 describe-load-balancers \
--names MC-K8-NetworkLoadBalancer \
--output text --query 'LoadBalancers[].DNSName')

echo "\033[32m K8 Address retrieved: ${KUBERNETES_PUBLIC_ADDRESS} \033[0m"

# Get default dns name
DNSName=$(aws ec2 describe-dhcp-options \
     --output text --query "DhcpOptions[*].DhcpConfigurations[0].Values[0].Value")

echo "\033[32m K8 DNS retrieved: ${DNSName}\033[0m"

# exit if KUBERNETES_PUBLIC_ADDRESS is empty
if [ -z "${KUBERNETES_PUBLIC_ADDRESS}" ] || [ -z "${DNSName}" ]
then
  echo "\033[31m Required values are missing\033[0m"
  exit
fi

# project working directory
PROJECT_DIR=$(pwd)

# infrastructure base name
NAME=MC-K8

# Create all needed folders for the public key infrastructure
mkdir -p output/pki && cd output/pki
mkdir -p {ca,master,scheduler,kubeproxy,controller,kubelets,admin,sa}

echo "\033[33m Generating Certificate Authority...\033[0m"
# Generate keys of Certificate Authority
cat > ca/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca/ca-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Lagos",
      "O": "Acellware",
      "OU": "Devops kubernetes",
      "ST": "Lagos"
    }
  ]
}
EOF

cfssl gencert -initca ca/ca-csr.json | cfssljson -bare ca/ca

echo "\033[32m Certificate Authority generated!\033[0m"

# Generate keys for Master node
echo "\033[33m Generating master node keys...\033[0m"

cat > master/master-kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
   "hosts": [
   "127.0.0.1",
   "10.32.0.1",
   "10.0.0.10",
   "10.0.0.11",
   "10.0.0.12",
   "ip-10-0-0-10",
   "ip-10-0-0-11",
   "ip-10-0-0-12",
   "ip-10-0-0-10.${DNSName}",
   "ip-10-0-0-11.${DNSName}",
   "ip-10-0-0-12.${DNSName}",
   "${KUBERNETES_PUBLIC_ADDRESS}",
   "kubernetes",
   "kubernetes.default",
   "kubernetes.default.svc",
   "kubernetes.default.svc.cluster",
   "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Lagos",
      "O": "Acellware",
      "OU": "Devops kubernetes",
      "ST": "Lagos"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca/ca.pem \
  -ca-key=ca/ca-key.pem \
  -config=ca/ca-config.json \
  -profile=kubernetes \
  master/master-kubernetes-csr.json | cfssljson -bare master/master-kubernetes

echo "\033[32m Master Node keys generated!\033[0m"

echo "\033[33m Generating K8 Scheduler keys...\033[0m"
# Generate key for the scheduler
cat > scheduler/kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Lagos",
      "O": "Acellware",
      "OU": "Devops kubernetes",
      "ST": "Lagos"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca/ca.pem \
  -ca-key=ca/ca-key.pem \
  -config=ca/ca-config.json \
  -profile=kubernetes \
  scheduler/kube-scheduler-csr.json | cfssljson -bare scheduler/kube-scheduler

echo "\033[32m K8 Scheduler keys generated!\033[0m"


echo "\033[33m Generating K8 Kube-proxy keys...\033[0m"
# Generate key for kube-proxy
cat > kubeproxy/kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Lagos",
      "O": "Acellware",
      "OU": "Devops kubernetes",
      "ST": "Lagos"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca/ca.pem \
  -ca-key=ca/ca-key.pem \
  -config=ca/ca-config.json \
  -profile=kubernetes \
  kubeproxy/kube-proxy-csr.json | cfssljson -bare kubeproxy/kube-proxy

echo "\033[32m K8 Kube-proxy generated!\033[0m"


echo "\033[33m Generating K8 Controller keys...\033[0m"
# Generate key for controller
cat > controller/kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Lagos",
      "O": "Acellware",
      "OU": "Devops kubernetes",
      "ST": "Lagos"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca/ca.pem \
  -ca-key=ca/ca-key.pem \
  -config=ca/ca-config.json \
  -profile=kubernetes \
  controller/kube-controller-manager-csr.json | cfssljson -bare controller/kube-controller-manager

echo "\033[32m K8 controller generated!\033[0m"


echo "\033[33m Generating K8 Admin User keys...\033[0m"
# Generate key for admin
cat > admin/admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Lagos",
      "O": "Acellware",
      "OU": "Devops kubernetes",
      "ST": "Lagos"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca/ca.pem \
  -ca-key=ca/ca-key.pem \
  -config=ca/ca-config.json \
  -profile=kubernetes \
  admin/admin-csr.json | cfssljson -bare admin/admin

echo "\033[32m K8 admin user keys generated!\033[0m"


echo "\033[33m Generating K8 service account keys...\033[0m"
cat > sa/service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NG",
      "L": "Lagos",
      "O": "Acellware",
      "OU": "Devops kubernetes",
      "ST": "Lagos"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca/ca.pem \
  -ca-key=ca/ca-key.pem \
  -config=ca/ca-config.json \
  -profile=kubernetes \
  sa/service-account-csr.json | cfssljson -bare sa/service-account
echo "\033[32m K8 service account keys generated!\033[0m"


echo "\033[33m Generating K8 Kubelets keys...\033[0m"
# Generate key for kubelets
for i in 0 1 2; do
  instance="${NAME}-Cluster-Worker-${i}"
  instance_hostname="ip-10-0-0-2${i}"
  echo $instance
  echo $instance_hostname
  cat > kubelets/${instance}-csr.json << EOF
  {
    "CN": "system:node:${instance_hostname}",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "NG",
        "L": "Lagos",
        "O": "Acellware",
        "OU": "Devops kubernetes",
        "ST": "Lagos"
      }
    ]
  }
EOF

  external_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')

  internal_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${instance}" \
    --output text --query 'Reservations[].Instances[].PrivateIpAddress')

  cfssl gencert \
    -ca=ca/ca.pem \
    -ca-key=ca/ca-key.pem \
    -config=ca/ca-config.json \
    -hostname=${instance_hostname},${external_ip},${internal_ip} \
    -profile=kubernetes \
    kubelets/${NAME}-Cluster-Worker-${i}-csr.json | cfssljson -bare kubelets/${NAME}-Cluster-Worker-${i}
done

echo "\033[32m K8 kubelets generated!\033[0m"

cd $PROJECT_DIR
