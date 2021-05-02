#!/usr/bin/env bash

## source environmient variables for later use
source /home/ubuntu/deployments/secrets/prod-secrets.sh

BACKUPS_DIR=/home/ubuntu/backups

declare -a databases=(decide_production sorting-hat_production salamandra_prod)

## Change directory to backups dir
cd $BACKUPS_DIR

for database in ${databases[@]}; do
    # Backup name with db name + timestamp
    backup_name=$database-`date +%Y-%m-%d"_"%H_%M_%S`

    # Docker execution of postgres backup
    docker exec -t \
    compose_db_1 pg_dump -c -U decide_prod -d $database > $backup_name.sql
    
    # Compresion of db backup  
    tar -czvf $BACKUPS_DIR/$backup_name.tar.gz $backup_name.sql
done

## Remove raw SQL backups
rm -v ./*.sql

## Configure file backup with rclone
rclone copy --immutable /home/ubuntu/salamandra/private_files tecnologia_edm:salamandra/private_files
rclone copy --immutable $BACKUPS_DIR tecnologia_edm:databases

## Cleanup after backups
rm -v ./*.tar.gz

## Return to previous directory
cd -

## Notify Slack bot that backup was completed
curl -X POST -H 'Content-type: application/json' --data '{"text":"Backups uploaded!"}' \
$BACKUP_SLACK_WEBHOOK_URL
