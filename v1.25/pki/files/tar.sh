#!/bin/bash
tar -xf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy} && tar -xf etcd*.tar.gz && mv etcd-*/etcd /usr/local/bin/ && mv etcd-*/etcdctl /usr/local/bin/ && chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson && mkdir /etc/etcd/ssl -p && mkdir -p /etc/kubernetes/pki
