#!/bin/bash

echo "config selinux ..."
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

echo "install tools"
yum install -y git tc jq telnet curl

echo "create authorized_keys ..."
cp /home/opc/.ssh/authorized_keys /home/opc/.ssh/authorized_keys.bak
echo "${ssh_public_key}" >> /home/opc/.ssh/authorized_keys
chown -R opc /home/opc/.ssh/authorized_keys

echo "install terraform ..."
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform
terraform version

echo "install docker ..."
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.5.11-3.1.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-20.10.9-3.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-cli-20.10.9-3.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-rootless-extras-20.10.9-3.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-scan-plugin-0.9.0-3.el7.x86_64.rpm
wget https://www.rpmfind.net/linux/centos/7.9.2009/extras/x86_64/Packages/container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
wget https://www.rpmfind.net/linux/centos/7.9.2009/extras/x86_64/Packages/fuse-overlayfs-0.7.2-6.el7_8.x86_64.rpm
wget https://www.rpmfind.net/linux/centos/7.9.2009/extras/x86_64/Packages/slirp4netns-0.4.3-4.el7_8.x86_64.rpm
wget http://mirror.centos.org/centos/7/extras/x86_64/Packages/fuse3-libs-3.6.1-4.el7.x86_64.rpm
yum localinstall -y *.rpm
systemctl enable --now docker
docker info
usermod -a -G docker opc

echo "install redis insight ..."
# https://hub.docker.com/r/redislabs/redisinsight/tags
firewall-cmd --add-port=8001/tcp --permanent
firewall-cmd --reload
mkdir -p /home/opc/redisinsight/db
chown -R 1001 /home/opc/redisinsight/db
# docker run -d --name redis-insight --restart=always -v /home/opc/redisinsight/db:/db -p 0.0.0.0:8001:8001 redislabs/redisinsight:1.11.1
docker run -d --name redis-insight --restart=always -v /home/opc/redisinsight/db:/db -p 0.0.0.0:8001:8001 redislabs/redisinsight:latest

