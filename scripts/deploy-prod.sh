#!/usr/bin/env bash

docker image prune -af

source ../secrets/prod-secrets.sh

docker-compose -f ../compose/docker-compose.yml pull && docker-compose -f ../compose/docker-compose.yml up -d
