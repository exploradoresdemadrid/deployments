#!/usr/bin/env bash

cd ..
source secrets/prod-secrets.sh

docker-compose -f compose/docker-compose-2.yml pull && docker-compose -f compose/docker-compose-2.yml up -d

docker image prune -af
