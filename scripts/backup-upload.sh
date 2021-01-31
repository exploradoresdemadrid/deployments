#!/usr/bin/env bash

## source environmient variables
source /home/ubuntu/deployments/secrets/prod-secrets.sh

DECIDE_PROD_NAME=decide_production_`date +%Y-%m-%d"_"%H_%M_%S`
SORTING_HAT_PRODUCTION=sorting-hat_production_`date +%Y-%m-%d"_"%H_%M_%S`
BACKUPS_DIR=/home/ubuntu/backups

docker exec -t compose_db_1 pg_dumpall -c -U decide_prod -l decide_production \
> $BACKUPS_DIR/$DECIDE_PROD_NAME.sql

tar -czvf $BACKUPS_DIR/$DECIDE_PROD_NAME.tar.gz $BACKUPS_DIR/$DECIDE_PROD_NAME.sql

docker exec -t compose_db_1 pg_dumpall -c -U hat_production -l decide_production \
> $BACKUPS_DIR/$SORTING_HAT_PRODUCTION.sql

tar -czvf $BACKUPS_DIR/$SORTING_HAT_PRODUCTION.tar.gz $BACKUPS_DIR/$SORTING_HAT_PRODUCTION.sql

## Get new access token with refresh token
GCLOUD_ACCESS_TOKEN=""
GCLOUD_ACCESS_TOKEN=$(curl --silent -d \
client_id=$GCLOUD_CLIENT_ID \
-d client_secret=$GCLOUD_SECRET \
-d refresh_token=$GCLOUD_REFRESH_TOKEN \
-d grant_type=refresh_token \
https://accounts.google.com/o/oauth2/token | jq '.access_token')


# Upload file to folder
curl \
-X POST -L \
-H "Authorization: Bearer $GCLOUD_ACCESS_TOKEN" \
-F "metadata={name :'$DECIDE_PROD_NAME.tar.gz', parents :['$GCLOUD_FOLDER_ID']};type=application/json;charset=UTF-8" \
-F "file=@$BACKUPS_DIR/$DECIDE_PROD_NAME.tar.gz;type=application/gzip" \
"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"


curl \
-X POST -L \
-H "Authorization: Bearer $GCLOUD_ACCESS_TOKEN" \
-F "metadata={name :'$SORTING_HAT_PRODUCTION.tar.gz', parents :['$GCLOUD_FOLDER_ID']};type=application/json;charset=UTF-8" \
-F "file=@$BACKUPS_DIR/$SORTING_HAT_PRODUCTION.tar.gz;type=application/gzip" \
"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"


## Cleanup after backups
rm -v $BACKUPS_DIR/*.tar.gz
rm -v $BACKUPS_DIR/*.sql

## Notify Slack bot that backup was completed
curl -X POST -H 'Content-type: application/json' --data '{"text":"Backups uploaded!"}' \
$BACKUP_SLACK_WEBHOOK_URL
