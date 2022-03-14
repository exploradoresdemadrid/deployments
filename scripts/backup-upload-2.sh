#!/usr/bin/env bash

## source environmient variables for later use
source /home/ubuntu/deployments/secrets/prod-secrets.sh

BACKUPS_DIR=/home/ubuntu/backups

declare -a databases=(decide_production sorting-hat_production salamandra_prod)

## Change directory to backups dir
cd $BACKUPS_DIR

backup_name=web_edm-`date +%Y-%m-%d"_"%H_%M_%S`
docker exec server-2_db_1 /usr/bin/mysqldump -u $WORDPRESS_DB_USER --password=$WORDPRESS_DB_PASSWORD $WORDPRESS_DB_NAME > $backup_name.sql
tar -czvf $BACKUPS_DIR/$backup_name.tar.gz $backup_name.sql

## Remove raw SQL backups
rm -v ./*.sql

## Configure file backup with rclone
docker cp server-2_wordpress_1:/var/www/html /home/ubuntu/web_files_backup/
rclone copy --immutable /home/ubuntu/web_files_backup/ tecnologia_edm:web_edm/files
rclone copy --immutable $BACKUPS_DIR tecnologia_edm:databases

## Cleanup after backups
rm -v ./*.tar.gz

## Return to previous directory
cd -

## Notify Slack bot that backup was completed
curl -X POST -H 'Content-type: application/json' --data '{"text":"Backups server 2 uploaded!"}' \
$BACKUP_SLACK_WEBHOOK_URL
