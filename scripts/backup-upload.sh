#!/usr/bin/env bash


FILENAME=testfile.tar.gz
FILEPATH=/home/ubuntu/










## Get new access token with refresh token
GDRIVE_ACCESS_TOKEN=""
GDRIVE_ACCESS_TOKEN=$(curl --silent -d \
client_id=$GCLOUD_CLIENT_ID \
-d client_secret=$GCLOUD_SECRET \
-d refresh_token=$GCLOUD_REFRESH_TOKEN \
-d grant_type=refresh_token \
https://accounts.google.com/o/oauth2/token | jq '.access_token')


# Upload file to folder
curl \
-X POST -L \
-H "Authorization: Bearer $GCLOUD_ACCESS_TOKEN" \
-F "metadata={name :'$FILENAME', parents :['$GCLOUD_FOLDER_ID']};type=application/json;charset=UTF-8" \
-F "file=@$FILEPATH/$FILENAME;type=application/gzip" \
"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"

