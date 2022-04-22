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

#echo "install redis insight ..."
## https://hub.docker.com/r/redislabs/redisinsight/tags
#firewall-offline-cmd  --zone=public --add-port=8001/tcp
#systemctl restart firewalld
#mkdir -p /home/opc/redisinsight/db
#chown -R 1001 /home/opc/redisinsight/db

#docker run -d --name redis-insight --cap-add ipc_lock --network=host --restart=unless-stopped -v /home/opc/redisinsight/db:/db redislabs/redisinsight:vulnerability-fix-apr-22
## docker run -d --name redis-insight  --cap-add ipc_lock --restart=always -v /home/opc/redisinsight/db:/db -p 8001:8001 redislabs/redisinsight:latest

#echo "install redis insight v2..."
#firewall-offline-cmd  --zone=public --add-port=5000/tcp
#systemctl restart firewalld
#mkdir -p /home/opc/redisinsight-v2/db
#docker run -d --name redis-insight-v2 --cap-add ipc_lock --network=host --restart=unless-stopped -v /home/opc/redisinsight-v2/db:/root/.redisinsight-v2 atjapan2015/redisinsight:2.0.5

#echo "install kubectl"
#curl -LO https://dl.k8s.io/release/v1.22.7/bin/linux/amd64/kubectl
#install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#echo "install rancher"
#firewall-offline-cmd  --zone=public --add-port=443/tcp
#systemctl restart firewalld
#mkdir -p /home/opc/rancher/main
#mkdir -p /home/opc/rancher/data
#mkdir -p /home/opc/rancher/auditlog
#docker run --privileged -d --name=rancher --network=host --restart=unless-stopped -v /home/opc/rancher/main:/var/lib/rancher -v /home/opc/rancher/data:/var/lib/rancher-data -v /home/opc/rancher/auditlog:/var/log/auditlog -e AUDIT_LEVEL=1 -e CATTLE_BOOTSTRAP_PASSWORD=${global_password} rancher/rancher:v2.6.4
## docker run --privileged -d --name=rancher --network=host --restart=unless-stopped -p 80:80 -p 443:443 -v /home/opc/rancher/main:/var/lib/rancher -v /home/opc/rancher/data:/var/lib/rancher-data -v /home/opc/rancher/auditlog:/var/log/auditlog -e AUDIT_LEVEL=1 -e CATTLE_BOOTSTRAP_PASSWORD=${global_password} rancher/rancher:stable

echo "install prometheus"
firewall-offline-cmd --zone=public --add-port=9090/tcp
systemctl restart firewalld
mkdir -p /home/opc/prometheus/data
mkdir -p /home/opc/prometheus/data/sd_configs/redis
cat << EOF > /home/opc/prometheus/data/prometheus.yml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).
  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: "prometheus-stack-monitor"

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]

# scrape Redis
  - job_name: redis
    scrape_interval: 30s
    scrape_timeout: 30s
    metrics_path: /metrics
    scheme: http
    tls_config:
      insecure_skip_verify: true
    file_sd_configs:
    - files:
      - 'sd_configs/redis/*.json'
EOF

chown -R 65534 /home/opc/prometheus/data
chown -R 65534 /home/opc/prometheus/data/sd_configs/redis
docker run -d --name=prometheus --network=host --restart=unless-stopped -v /home/opc/prometheus/data/prometheus.yml:/etc/prometheus/prometheus.yml -v /home/opc/prometheus/data/sd_configs/redis:/etc/prometheus/sd_configs/redis prom/prometheus:v2.34.0
# docker run -d --name=prometheus --restart=always -p 9090:9090 prom/prometheus:latest

echo "install prometheus"
firewall-offline-cmd --zone=public --add-port=9091/tcp
systemctl restart firewalld
docker run -d --name=redis-prometheus --network=host --restart=unless-stopped -v /home/opc/prometheus/data/sd_configs/redis:/u01/data/sd_configs/redis -p 9091:9091 atjapan2015/redis-prometheus:latest

# https://github.com/cloudalchemy/ansible-grafana ToDo
echo "install grafana"
firewall-offline-cmd --zone=public --add-port=3000/tcp
systemctl restart firewalld
# https://grafana.com/docs/grafana/latest/administration/configure-docker/
mkdir -p /home/opc/grafana/data
chown -R 472 /home/opc/grafana/data
docker run -d --name=grafana --network=host --restart=unless-stopped -e "GF_SECURITY_ADMIN_PASSWORD=${global_password}" -e "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel,redis-app" -v /home/opc/grafana/data:/var/lib/grafana grafana/grafana:8.4.5
# docker run -d --name=grafana --restart=always -e "GF_SECURITY_ADMIN_PASSWORD=${global_password}" -e "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel,redis-app" -p 3000:3000 grafana/grafana:latest

sleep 15
curl -d '{"name":"Prometheus","type":"prometheus","url":"http://127.0.0.1:9090","access":"proxy","basicAuth":false}' -H "Content-Type: application/json" -X POST http://admin:${global_password}@127.0.0.1:3000/api/datasources