#!/usr/bin/env bash

cd ..
source secrets/prod-secrets.sh

# Download docker images
docker-compose -f compose/docker-compose.yml pull

# Stop local DNS server
sudo systemctl stop systemd-resolved

# Start docker images (including DNS server)
docker-compose -f compose/docker-compose.yml up -d

docker image prune -af
