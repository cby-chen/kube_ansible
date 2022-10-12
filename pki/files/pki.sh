#!/bin/bash

export k8s_master01="10.0.0.110"
export k8s_master02="10.0.0.111"
export k8s_master03="10.0.0.112"
export lb_vip="10.0.0.66"

echo "生成etcd证书"
cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare /etc/etcd/ssl/etcd-ca
cfssl gencert -ca=/etc/etcd/ssl/etcd-ca.pem -ca-key=/etc/etcd/ssl/etcd-ca-key.pem -config=ca-config.json -hostname=127.0.0.1,k8s-master01,k8s-master02,k8s-master03,$k8s_master01,$k8s_master02,$k8s_master03  -profile=kubernetes etcd-csr.json | cfssljson -bare /etc/etcd/ssl/etcd

echo "生成k8s证书"
mkdir -p /etc/kubernetes/pki/
cfssl gencert -initca ca-csr.json | cfssljson -bare /etc/kubernetes/pki/ca
cfssl gencert -ca=/etc/kubernetes/pki/ca.pem -ca-key=/etc/kubernetes/pki/ca-key.pem -config=ca-config.json -hostname=10.96.0.1,$lb_vip,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,$domain,$k8s_master01,$k8s_master02,$k8s_master03 -profile=kubernetes   apiserver-csr.json | cfssljson -bare /etc/kubernetes/pki/apiserver

echo "生成k8s-apiserver证书"
cfssl gencert   -initca front-proxy-ca-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-ca 
cfssl gencert   -ca=/etc/kubernetes/pki/front-proxy-ca.pem   -ca-key=/etc/kubernetes/pki/front-proxy-ca-key.pem   -config=ca-config.json   -profile=kubernetes   front-proxy-client-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-client

echo "生成controller-manage证书"
cfssl gencert -ca=/etc/kubernetes/pki/ca.pem -ca-key=/etc/kubernetes/pki/ca-key.pem -config=ca-config.json -profile=kubernetes manager-csr.json | cfssljson -bare /etc/kubernetes/pki/controller-manager
kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/pki/ca.pem --embed-certs=true --server=https://$lb_vip:8443 --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig
kubectl config set-context system:kube-controller-manager@kubernetes --cluster=kubernetes --user=system:kube-controller-manager --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig
kubectl config set-credentials system:kube-controller-manager --client-certificate=/etc/kubernetes/pki/controller-manager.pem --client-key=/etc/kubernetes/pki/controller-manager-key.pem --embed-certs=true --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig
kubectl config use-context system:kube-controller-manager@kubernetes --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig
cfssl gencert -ca=/etc/kubernetes/pki/ca.pem -ca-key=/etc/kubernetes/pki/ca-key.pem -config=ca-config.json -profile=kubernetes scheduler-csr.json | cfssljson -bare /etc/kubernetes/pki/scheduler
kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/pki/ca.pem --embed-certs=true --server=https://$lb_vip:8443 --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
kubectl config set-credentials system:kube-scheduler --client-certificate=/etc/kubernetes/pki/scheduler.pem --client-key=/etc/kubernetes/pki/scheduler-key.pem --embed-certs=true --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
kubectl config set-context system:kube-scheduler@kubernetes --cluster=kubernetes --user=system:kube-scheduler --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
kubectl config use-context system:kube-scheduler@kubernetes --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
cfssl gencert -ca=/etc/kubernetes/pki/ca.pem -ca-key=/etc/kubernetes/pki/ca-key.pem  -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare /etc/kubernetes/pki/admin
kubectl config set-cluster kubernetes     --certificate-authority=/etc/kubernetes/pki/ca.pem     --embed-certs=true     --server=https://$lb_vip:8443     --kubeconfig=/etc/kubernetes/admin.kubeconfig
kubectl config set-credentials kubernetes-admin     --client-certificate=/etc/kubernetes/pki/admin.pem     --client-key=/etc/kubernetes/pki/admin-key.pem     --embed-certs=true     --kubeconfig=/etc/kubernetes/admin.kubeconfig
kubectl config set-context kubernetes-admin@kubernetes     --cluster=kubernetes     --user=kubernetes-admin     --kubeconfig=/etc/kubernetes/admin.kubeconfig
kubectl config use-context kubernetes-admin@kubernetes     --kubeconfig=/etc/kubernetes/admin.kubeconfig
cfssl gencert -ca=/etc/kubernetes/pki/ca.pem  -ca-key=/etc/kubernetes/pki/ca-key.pem  -config=ca-config.json  -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare /etc/kubernetes/pki/kube-proxy
kubectl config set-cluster kubernetes      --certificate-authority=/etc/kubernetes/pki/ca.pem     --embed-certs=true      --server=https://$lb_vip:8443      --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
kubectl config set-credentials kube-proxy    --client-certificate=/etc/kubernetes/pki/kube-proxy.pem      --client-key=/etc/kubernetes/pki/kube-proxy-key.pem     --embed-certs=true     --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
kubectl config set-context kube-proxy@kubernetes    --cluster=kubernetes     --user=kube-proxy    --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
kubectl config use-context kube-proxy@kubernetes  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

echo "创建ServiceAccount Key"
openssl genrsa -out /etc/kubernetes/pki/sa.key 2048
openssl rsa -in /etc/kubernetes/pki/sa.key -pubout -out /etc/kubernetes/pki/sa.pub


kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/pki/ca.pem --embed-certs=true --server=https://$lb_vip:8443 --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
kubectl config set-credentials tls-bootstrap-token-user --token=c8ad9c.2e4d610cf3e7426e --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
kubectl config set-context tls-bootstrap-token-user@kubernetes --cluster=kubernetes --user=tls-bootstrap-token-user --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
kubectl config use-context tls-bootstrap-token-user@kubernetes --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

# token的位置在bootstrap.secret.yaml，如果修改的话到这个文件修改
mkdir -p /root/.kube ; cp /etc/kubernetes/admin.kubeconfig /root/.kube/config
