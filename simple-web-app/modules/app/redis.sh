#!/usr/bin/env bash
set -euo pipefail
sudo apt update
sudo apt install -y redis-server redis redis-tools
prv_ip=`ip -br a  | grep '192.168' | grep -oP '(\d{1,3}\.){3}\d{1,3}'`
sudo sed -E -i "s/^(bind.*)/\1 $prv_ip/" /etc/redis/redis.conf
sudo systemctl restart redis
