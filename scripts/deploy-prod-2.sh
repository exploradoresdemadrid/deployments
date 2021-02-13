#!/usr/bin/env bash

cd ..
source secrets/prod-secrets.sh

docker-compose -f compose/server-2/docker-compose.yml pull && docker-compose -f compose/server-2/docker-compose.yml up -d

docker image prune -af
