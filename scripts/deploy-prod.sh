#!/usr/bin/env bash

source ../secrets/prod-secrets.sh

docker-compose -f ../compose/docker-compose-prod.yml pull && docker-compose -f ../compose/docker-compose-prod.yml up -d
