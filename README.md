### ansible 二进制安装 k8s

#### 执行此脚本需要在单独的机器执行，在集群之外的机器上执行，因为过程中需要重启集群

此脚本可以部署kubernetes 1.25.x 系列环境

Ubuntu 和 CentOS7 和 CentOS8 已支持

地址 ： [cby-chen/kube_ansible: 使用 ansible 安装 Kubernetes 高可用集群 (github.com)](https://github.com/cby-chen/kube_ansible)

https://github.com/cby-chen/kube_ansible

```shell
克隆仓库
git clone https://github.com/cby-chen/kube_ansible

在控制主机上进行配置免密
apt install -y sshpass
ssh-keygen -f /root/.ssh/id_rsa -P ''
export IP="192.168.1.130 192.168.1.131 192.168.1.132 192.168.1.128 192.168.1.129"
export SSHPASS=123123
for HOST in $IP;do
     sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done
```

#### 安装 ansibls

```shell
安装 ansibls
apt install ansible
```

#### 编辑主机hosts

```shell
编辑主机hosts
vim /etc/ansible/hosts 
cat /etc/ansible/hosts 
[kube_pki]
192.168.1.31

[etcd]
192.168.1.31 hostname=etcd-1
192.168.1.32 hostname=etcd-1
192.168.1.33 hostname=etcd-1

[kube_master]
192.168.1.31 hostname=k8s-master-1
192.168.1.32 hostname=k8s-master-2
192.168.1.33 hostname=k8s-master-3

[kube_node]
192.168.1.34 hostname=k8s-node-1
192.168.1.35 hostname=k8s-node-2

[chrony]
192.168.1.31
```

#### 编辑需要下载安装包版本

```shell
编辑需要下载安装包版本
vim files/download.sh
cat files/download.sh
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

# 指定版本 kubernetes 只能选择 v1.25.x

kubernetes_server='v1.25.2'
etcd='v3.5.4'
cni_plugins='v1.1.1'
cri_containerd_cni='1.6.8'
crictl='v1.24.2'
cri_dockerd='0.2.5'
cfssl='1.6.2'
cfssljson='1.6.2'
docker_v='20.10.9'
runc='1.1.4'
....

# 执行下载命令
cd files
bash download.sh


```

#### 编辑证书生成的环境变量

```shell
编辑证书生成的环境变量
vim pki/files/pki.sh
cat pki/files/pki.sh
#!/bin/bash
export k8s_master01="192.168.1.130"
export k8s_master02="192.168.1.132"
export k8s_master03="192.168.1.131"
export lb_vip="192.168.1.22"

略
```

#### 编辑lb环境变量

```shell
编辑lb环境变量
vim lb/files/lb.sh
cat lb/files/lb.sh
#!/bin/bash
export lb1="192.168.1.130"
export lb2="192.168.1.132"
export lb3="192.168.1.131"
export vip="192.168.1.22"
export eth="eth0"
export lb="192.168.1.130 192.168.1.132 192.168.1.131"

略
```

#### 执行部署程序

```shell
vim  main.yaml
# 在执行此playbook时，请先 cd files/ 执行 bash download.sh

# 基础环境初始化 
# hosts 写【etcd、kube master、kube node】所处的IP地址
# hosts 中的IP若在 /etc/ansible/hosts 中写过即此处无需再写
# vars 中环境变量需要根据实际情况写
#     all 写所有IP地址
#     passed 是所有的系统密码，此密码需要所有主机相同
- hosts: 
  - etcd
  - kube_master
  - kube_node
  remote_user: root
  vars:
    - all: 192.168.1.130 192.168.1.131 192.168.1.132 192.168.1.128 192.168.1.129
    - passwd: 123123
  roles:
    - role: local_init
    - role: chrony
      when: "groups['chrony']|length > 0" 
    - role: kernel
    - role: containerd
    - role: docker



# 创建证书初始化 
# hosts 写【kube master 01】所在的IP地址 【建议在 kube master 01 上执行】
# hosts 中的IP若在 /etc/ansible/hosts 中写过即此处无需再写
# vars 中环境变量需要根据实际情况写
#     all 写所有IP地址
#     etcd 写 etcd 的所有IP地址
#     Master 写所有 kube master 的IP地址
#     Work 写所有 kube node 的IP地址
# 
# 在执行之前请先修改 pki/files/pki.sh 中环境变量 ！！！！！
# 
- hosts: 
  - kube_pki
  remote_user: root
  roles:
    - role: pki
  vars:
    - all: 192.168.1.130 192.168.1.131 192.168.1.132 192.168.1.128 192.168.1.129
    - etcd: 192.168.1.130 192.168.1.131 192.168.1.132
    - Master: 192.168.1.130 192.168.1.131 192.168.1.132
    - Work: 192.168.1.128 192.168.1.129


# # 初始化etcd集群
# # hosts 写【etcd】所在的IP地址
# # hosts 中的IP若在 /etc/ansible/hosts 中写过即此处无需再写
- hosts: 
  - etcd
  remote_user: root
  roles:
    - role: etcd


# 初始化master集群
# hosts 写【kube_master】所在的IP地址
# hosts 中的IP若在 /etc/ansible/hosts 中写过即此处无需再写
# 
# 在执行之前请先修改 lb/files/lb.sh 中环境变量 ！！！！！
# 
- hosts: 
  - kube_master
  remote_user: root
  roles:
    - role: lb
    - role: kube_master
    - role: completion


# 初始化node集群
# hosts 写【kube_master kube_node】所在的IP地址
# hosts 中的IP若在 /etc/ansible/hosts 中写过即此处无需再写
- hosts: 
  - kube_master
  - kube_node
  remote_user: root
  roles:
    - role: kube_node


# 执行部署，hosts写master 随机一个IP即可 calico 和 cilium 二选一即可
- hosts: 
  - kube_pki
  remote_user: root
  roles:
    - role: calico
    # - role: cilium
    - role: coredns
    - role: dashboard
    - role: ingress
    - role: metrics-server

# 执行部署程序
ansible-playbook  main.yaml

```

#### 目录结构

```shell
root@cby:~/cby/roles# tree .
.
├── calico
│   ├── files
│   │   └── calico.yaml
│   └── tasks
│       └── main.yaml
├── chrony
│   ├── defaults
│   │   └── main.yml
│   ├── handlers
│   │   └── main.yaml
│   ├── tasks
│   │   └── main.yaml
│   └── templates
│       ├── client.conf.j2
│       └── server.conf.j2
├── cilium
│   ├── files
│   │   ├── connectivity-check.yaml
│   │   └── monitoring-example.yaml
│   └── tasks
│       └── main.yaml
├── completion
│   ├── files
│   │   └── source.sh
│   └── tasks
│       └── main.yaml
├── containerd
│   ├── files
│   │   ├── 99-kubernetes-cri.conf
│   │   ├── containerd.conf
│   │   ├── containerd.service
│   │   ├── crictl.yaml
│   │   └── hosts.toml
│   └── tasks
│       └── main.yaml
├── coredns
│   ├── files
│   │   └── coredns.yaml
│   └── tasks
│       └── main.yaml
├── dashboard
│   ├── files
│   │   ├── dashboard-user.yaml
│   │   └── dashboard.yaml
│   └── tasks
│       └── main.yaml
├── docker
│   ├── defaults
│   │   └── main.yaml
│   ├── files
│   │   ├── containerd.service
│   │   ├── cri-docker.service
│   │   ├── cri-docker.socket
│   │   ├── daemon.json
│   │   ├── docker.service
│   │   └── docker.socket
│   └── tasks
│       └── main.yaml
├── etcd
│   ├── defaults
│   │   └── main.yml
│   ├── files
│   │   └── etcd.service
│   ├── tasks
│   │   └── main.yaml
│   └── templates
│       └── etcd.config.yml.j2
├── files
│   ├── cfssl
│   ├── cfssljson
│   ├── cni-plugins-linux-amd64-v1.1.1.tgz
│   ├── cri-containerd-cni-1.6.8-linux-amd64.tar.gz
│   ├── crictl-v1.24.2-linux-amd64.tar.gz
│   ├── cri-dockerd-0.2.5.amd64.tgz
│   ├── docker-20.10.9.tgz
│   ├── download.sh
│   ├── etcd-v3.5.4-linux-amd64.tar.gz
│   ├── helm-canary-linux-amd64.tar.gz
│   ├── kernel-lt-5.4.224-1.el7.elrepo.x86_64.rpm
│   ├── kubernetes-server-linux-amd64.tar.gz
│   └── runc.amd64
├── ingress
│   ├── files
│   │   ├── backend.yaml
│   │   ├── deploy.yaml
│   │   └── ingress-demo-app.yaml
│   └── tasks
│       └── main.yaml
├── kernel
│   └── tasks
│       └── main.yaml
├── kube_master
│   ├── files
│   │   └── bootstrap.secret.yaml
│   ├── tasks
│   │   └── main.yaml
│   ├── templates
│   │   ├── kube-apiserver.service.j2
│   │   ├── kube-controller-manager.service.j2
│   │   └── kube-scheduler.service.j2
│   └── vars
│       └── main.yml
├── kube_node
│   ├── files
│   │   ├── kubelet-conf.yml
│   │   └── kube-proxy.yaml
│   ├── tasks
│   │   └── main.yaml
│   ├── templates
│   │   ├── kubelet.service.j2
│   │   └── kube-proxy.service.j2
│   └── vars
│       └── main.yml
├── lb
│   ├── files
│   │   ├── check_apiserver.sh
│   │   └── lb.sh
│   └── tasks
│       ├── lb.yaml
│       └── main.yaml
├── local_init
│   ├── defaults
│   │   └── main.yaml
│   ├── files
│   │   ├── calico.conf
│   │   ├── ipvs.conf
│   │   ├── kernel.conf
│   │   └── limits.conf
│   ├── handlers
│   │   └── main.yaml
│   └── tasks
│       ├── ipvs.yaml
│       ├── kernel.yaml
│       ├── libseccomp.yaml
│       ├── limits.yaml
│       ├── local.yaml
│       ├── main.yaml
│       ├── network.yaml
│       ├── repo.yaml
│       ├── sshpass.yaml
│       └── yum.yaml
├── main.yaml
├── metrics-server
│   ├── files
│   │   └── metrics-server.yaml
│   └── tasks
│       └── main.yaml
├── pki
│   ├── files
│   │   ├── admin-csr.json
│   │   ├── apiserver-csr.json
│   │   ├── ca-config.json
│   │   ├── ca-csr.json
│   │   ├── etcd-ca-csr.json
│   │   ├── etcd-csr.json
│   │   ├── front-proxy-ca-csr.json
│   │   ├── front-proxy-client-csr.json
│   │   ├── kubelet-csr.json
│   │   ├── kube-proxy-csr.json
│   │   ├── manager-csr.json
│   │   ├── pki.sh
│   │   ├── scheduler-csr.json
│   │   └── tar.sh
│   └── tasks
│       └── main.yaml
└── README.md

62 directories, 104 files
```

---

2022-11-26更新

· 适配 Ubuntu 和 CentOS7 和 CentOS8 环境

· 优化内核安装逻辑过程

· 优化docker安装过程

· 优化整体安装部署过程缩短时间

> **关于**
>
> https://www.oiox.cn/
>
> https://www.oiox.cn/index.php/start-page.html
>
> **CSDN、GitHub、知乎、开源中国、思否、掘金、简书、华为云、阿里云、腾讯云、哔哩哔哩、今日头条、新浪微博、个人博客**
>
> **全网可搜《小陈运维》**
>
> **文章主要发布于微信公众号**
