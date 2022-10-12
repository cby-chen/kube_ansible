#!/bin/bash

# 查看版本地址：
# 
# https://github.com/containernetworking/plugins/releases/
# https://github.com/containerd/containerd/releases/
# https://github.com/kubernetes-sigs/cri-tools/releases/
# https://github.com/Mirantis/cri-dockerd/releases/
# https://github.com/etcd-io/etcd/releases/
# https://github.com/cloudflare/cfssl/releases/
# https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG

# 指定版本 kubernetes 只能选择 v1.25.x

kubernetes_server='v1.25.2'
etcd='v3.5.4'
cni_plugins='v1.1.1'
cri_containerd_cni='1.6.8'
crictl='v1.24.2'
cri_dockerd='0.2.5'
cfssl='1.6.2'
cfssljson='1.6.2'


if [ ! -f "cni-plugins-linux-amd64-${cni_plugins}.tgz" ];then
wget https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/${cni_plugins}/cni-plugins-linux-amd64-${cni_plugins}.tgz
else
echo "文件存在"
fi

if [ ! -f "cri-containerd-cni-${cri_containerd_cni}-linux-amd64.tar.gz" ];then
wget https://ghproxy.com/https://github.com/containerd/containerd/releases/download/v${cri_containerd_cni}/cri-containerd-cni-${cri_containerd_cni}-linux-amd64.tar.gz
else
echo "文件存在"
fi

if [ ! -f "crictl-${crictl}-linux-amd64.tar.gz" ];then
wget https://ghproxy.com/https://github.com/kubernetes-sigs/cri-tools/releases/download/${crictl}/crictl-${crictl}-linux-amd64.tar.gz
else
echo "文件存在"
fi

if [ ! -f "cri-dockerd-${cri_dockerd}.amd64.tgz" ];then
wget https://ghproxy.com/https://github.com/Mirantis/cri-dockerd/releases/download/v${cri_dockerd}/cri-dockerd-${cri_dockerd}.amd64.tgz
else
echo "文件存在"
fi

if [ ! -f "kubernetes-server-linux-amd64.tar.gz" ];then
wget https://dl.k8s.io/${kubernetes_server}/kubernetes-server-linux-amd64.tar.gz
else
echo "文件存在"
fi

if [ ! -f "etcd-${etcd}-linux-amd64.tar.gz" ];then
wget https://ghproxy.com/https://github.com/etcd-io/etcd/releases/download/${etcd}/etcd-${etcd}-linux-amd64.tar.gz
else
echo "文件存在"
fi

if [ ! -f "ccfssl" ];then
wget https://ghproxy.com/https://github.com/cloudflare/cfssl/releases/download/v${cfssl}/cfssl_${cfssl}_linux_amd64 -O cfssl
else
echo "文件存在"
fi

if [ ! -f "cfssljson" ];then
wget https://ghproxy.com/https://github.com/cloudflare/cfssl/releases/download/v${cfssljson}/cfssljson_${cfssljson}_linux_amd64 -O cfssljson
else
echo "文件存在"
fi

if [ ! -f "helm-canary-linux-amd64.tar.gz" ];then
wget https://get.helm.sh/helm-canary-linux-amd64.tar.gz
else
echo "文件存在"
fi
