
```bash
KUBERNETES_PUBLIC_ADDRESS=$(aws elbv2 describe-load-balancers \
--names MC-K8-NetworkLoadBalancer \
--output text --query 'LoadBalancers[].DNSName')
```

the server is the k8 api-server while the client are all components that communicate with this server


#### master
```bash
cat > master-kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
   "hosts": [
   "127.0.0.1",
   "10.0.1.20",
   "10.0.1.21",
   "10.0.1.22",
   "10.0.1.30",
   "10.0.1.31",
   "10.0.1.32",
   "ip-10-0-1-20",
   "ip-10-0-1-21",
   "ip-10-0-1-22",
   "ip-10-0-1-30",
   "ip-10-0-1-31",
   "ip-10-0-1-32",   
   "ip-10-0-1-20.us-east-1.mc.compute.internal",
   "ip-10-0-1-21.us-east-1.mc.compute.internal",
   "ip-10-0-1-22.us-east-1.mc.compute.internal",
   "ip-10-0-1-30.us-east-1.mc.compute.internal",
   "ip-10-0-1-31.us-east-1.mc.compute.internal",
   "ip-10-0-1-32.us-east-1.mc.compute.internal",   
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
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  master-kubernetes-csr.json | cfssljson -bare master-kubernetes
}
```
