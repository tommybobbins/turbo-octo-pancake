#!/bin/bash 
dnf update -y
hostnamectl set-hostname ${hostname}

cat <<EOF | sudo tee /etc/yum.repos.d/influxdata.repo
[influxdata]
name = InfluxData Repository - Stable
baseurl = https://repos.influxdata.com/stable/\$basearch/main
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdata-archive_compat.key
EOF
sudo dnf install influxdb2-cli.x86_64 -y
influx config create \
  --config-name ${PREFIX} \
  --host-url ${INFLUXDB_ENDPOINT} \
  --org ${PROJECT} \
  --token your-api-token

# Set the production config as active
influx config set --config-name production
