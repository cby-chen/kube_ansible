#!/bin/bash
export lb1="192.168.1.31"
export lb2="192.168.1.32"
export lb3="192.168.1.33"
export vip="192.168.1.30"
export eth="ens18"
export lb="192.168.1.31 192.168.1.32 192.168.1.33"


for HOST in $lb;do
{
    echo "配置主机$HOST 配置文件"
    ssh root@"$HOST" "cat > /etc/haproxy/haproxy.cfg << EOF 
global
 maxconn 2000
 ulimit-n 16384
 log 127.0.0.1 local0 err
 stats timeout 30s
defaults
 log global
 mode http
 option httplog
 timeout connect 5000
 timeout client 50000
 timeout server 50000
 timeout http-request 15s
 timeout http-keep-alive 15s
frontend monitor-in
 bind *:33305
 mode http
 option httplog
 monitor-uri /monitor
frontend k8s-master
 bind 0.0.0.0:8443
 bind 127.0.0.1:8443
 mode tcp
 option tcplog
 tcp-request inspect-delay 5s
 default_backend k8s-master
backend k8s-master
 mode tcp
 option tcplog
 option tcp-check
 balance roundrobin
 default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
 server  master01  $lb1:6443 check
 server  master02  $lb2:6443 check
 server  master03  $lb3:6443 check
EOF"

} 
done


for HOST in $lb1;do
{

    echo "配置主机$HOST 配置文件"
    ssh root@"$HOST" "cat > /etc/keepalived/keepalived.conf << EOF 
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script chk_apiserver {
    script \"/etc/keepalived/check_apiserver.sh\"
    interval 5 
    weight -5
    fall 2
    rise 1
}
vrrp_instance VI_1 {
    state MASTER
    interface $eth
    mcast_src_ip $lb1
    virtual_router_id 51
    priority 100
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        $vip
    }
    track_script {
      chk_apiserver 
} }
EOF"

} 
done



for HOST in $lb2;do
{

    echo "配置主机$HOST 配置文件"
    ssh root@"$HOST" "cat > /etc/keepalived/keepalived.conf << EOF 
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script chk_apiserver {
    script \"/etc/keepalived/check_apiserver.sh\"
    interval 5 
    weight -5
    fall 2
    rise 1
}
vrrp_instance VI_1 {
    state BACKUP
    interface $eth
    mcast_src_ip $lb2
    virtual_router_id 51
    priority 80
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        $vip
    }
    track_script {
      chk_apiserver 
} }
EOF"

} 
done


for HOST in $lb3;do
{

    echo "配置主机$HOST 配置文件"
    ssh root@"$HOST" "cat > /etc/keepalived/keepalived.conf << EOF 
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script chk_apiserver {
    script \"/etc/keepalived/check_apiserver.sh\"
    interval 5 
    weight -5
    fall 2
    rise 1
}
vrrp_instance VI_1 {
    state BACKUP
    interface $eth
    mcast_src_ip $lb3
    virtual_router_id 51
    priority 60
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        $vip
    }
    track_script {
      chk_apiserver 
} }
EOF"

} 
done
