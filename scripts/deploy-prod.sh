#!/usr/bin/env bash

cd ..
source secrets/prod-secrets.sh

docker-compose -f compose/docker-compose.yml pull && docker-compose -f compose/docker-compose.yml up -d && docker-restart compose_nginx_1

docker image prune -af
