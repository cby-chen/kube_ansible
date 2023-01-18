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
# https://github.com/opencontainers/runc/releases/
# https://download.docker.com/linux/static/stable/x86_64/
# https://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el7/x86_64/RPMS/

# 指定版本 kubernetes 只能选择 v1.26.x

kubernetes_server='v1.26.0'
etcd='v3.5.6'
cni_plugins='v1.1.1'
cri_containerd_cni='1.6.15'
crictl='v1.26.0'
cri_dockerd='0.3.0'
cfssl='1.6.3'
cfssljson='1.6.3'
docker_v='20.10.22'
runc='1.1.4'
kernel='5.4.224'

if [ ! -f "kernel-lt-5.4.224-1.el7.elrepo.x86_64.rpm" ];then
wget http://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el7/x86_64/RPMS/kernel-lt-${kernel}-1.el7.elrepo.x86_64.rpm
else
echo "文件存在"
fi


if [ ! -f "runc.amd64" ];then
wget https://ghproxy.com/https://github.com/opencontainers/runc/releases/download/v${runc}/runc.amd64
else
echo "文件存在"
fi

if [ ! -f "docker-${docker_v}.tgz" ];then
wget https://download.docker.com/linux/static/stable/x86_64/docker-${docker_v}.tgz 
else
echo "文件存在"
fi


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

if [ ! -f "cfssl" ];then
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
