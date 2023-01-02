
```bash
KUBERNETES_PUBLIC_ADDRESS=$(aws elbv2 describe-load-balancers \
--names MC-K8-NetworkLoadBalancer \
--output text --query 'LoadBalancers[].DNSName')
```

the server is the k8 api-server while the client are all components that communicate with this server


#### master
```bash
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
```
