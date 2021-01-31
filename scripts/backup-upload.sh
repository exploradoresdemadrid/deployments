#!/usr/bin/env bash

DECIDE_PROD_NAME=decide_production_`date +%Y-%m-%d"_"%H_%M_%S`
SORTING_HAT_PRODUCTION=sorting-hat_production_`date +%Y-%m-%d"_"%H_%M_%S`

docker exec -t compose_db_1 pg_dumpall -c -U decide_prod -l decide_production \
> ~/backups/$DECIDE_PROD_NAME.sql

tar -czvf ~/backups/$DECIDE_PROD_NAME.tar.gz ~/backups/$DECIDE_PROD_NAME.sql

docker exec -t compose_db_1 pg_dumpall -c -U hat_production -l decide_production \
> ~/backups/$SORTING_HAT_PRODUCTION.sql

tar -czvf ~/backups/$SORTING_HAT_PRODUCTION.tar.gz ~/backups/$SORTING_HAT_PRODUCTION.sql


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
-F "file=@/home/ubuntu/backups/$DECIDE_PROD_NAME.tar.gz;type=application/gzip" \
"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"


curl \
-X POST -L \
-H "Authorization: Bearer $GCLOUD_ACCESS_TOKEN" \
-F "metadata={name :'$SORTING_HAT_PRODUCTION.tar.gz', parents :['$GCLOUD_FOLDER_ID']};type=application/json;charset=UTF-8" \
-F "file=@/home/ubuntu/backups/$SORTING_HAT_PRODUCTION.tar.gz;type=application/gzip" \
"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"


## Notify Slack bot that backup was completed
curl -X POST -H 'Content-type: application/json' --data '{"text":"Backups uploaded!"}' \
$BACKUP_SLACK_WEBHOOK_URL