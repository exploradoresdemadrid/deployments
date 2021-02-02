#!/usr/bin/env bash

## source environmient variables for later use
source /home/ubuntu/deployments/secrets/prod-secrets.sh

DECIDE_PROD_NAME=decide_production_`date +%Y-%m-%d"_"%H_%M_%S`
SORTING_HAT_PRODUCTION=sorting-hat_production_`date +%Y-%m-%d"_"%H_%M_%S`
BACKUPS_DIR=/home/ubuntu/backups

declare -a databases=(decide_production sorting-hat_production)

## Get new access token with refresh token
GCLOUD_ACCESS_TOKEN=""
GCLOUD_ACCESS_TOKEN=$(curl --silent -d \
client_id=$GCLOUD_CLIENT_ID \
-d client_secret=$GCLOUD_SECRET \
-d refresh_token=$GCLOUD_REFRESH_TOKEN \
-d grant_type=refresh_token \
https://accounts.google.com/o/oauth2/token | jq '.access_token')



for database in ${databases[@]}; do
    # Backup name with db name + timestamp
    backup_name=$database-`date +%Y-%m-%d"_"%H_%M_%S`

    # Docker execution of postgres backup
    docker exec -t \
    compose_db_1 pg_dump -c -U decide_prod -d $database > $BACKUPS_DIR/$backup_name.sql
    
    # Compresion of db backup  
    tar -czvf $BACKUPS_DIR/$backup_name.tar.gz $BACKUPS_DIR/$backup_name.sql
    
    # Upload of compressed backup to gdrive with token
    curl \
    -X POST -L \
    -H "Authorization: Bearer $GCLOUD_ACCESS_TOKEN" \
    -F "metadata={name :'$backup_name.tar.gz', parents :['$GCLOUD_FOLDER_ID']};type=application/json;charset=UTF-8" \
    -F "file=@$BACKUPS_DIR/$backup_name.tar.gz;type=application/gzip" \
    "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
done

## Cleanup after backups
rm -v $BACKUPS_DIR/*.tar.gz
rm -v $BACKUPS_DIR/*.sql

## Notify Slack bot that backup was completed
curl -X POST -H 'Content-type: application/json' --data '{"text":"Backups uploaded!"}' \
$BACKUP_SLACK_WEBHOOK_URL
