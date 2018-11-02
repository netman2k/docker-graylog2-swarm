#!/bin/bash
#
# This can upload contentpack content
#
# Please refer to this page
# - http://docs.graylog.org/en/2.4/pages/configuration/index_model.html
#
# Author: DaeHyung Lee<daehyung@gmail.com>
#
[ $# -eq 0 ] && { echo "Usage $0 <File to upload>"; exit 1; }
FILE=$1

[ -z $GRAYLOG_HOST ] && GRAYLOG_HOST="http://localhost:9000"
[ -z $GRAYLOG_USER ] && GRAYLOG_USER="admin"
[ -z $GRAYLOG_PASSWORD ] && GRAYLOG_PASSWORD="admin" 

# requirement check
which jq > /dev/null
[ $? -eq 1 ] && { echo "You need to install jq first to use this script" 1>&2; exit 1; }

# Request updating
result=$(curl -s -u ${GRAYLOG_USER}:${GRAYLOG_PASSWORD} -X POST -H 'Content-Type: application/json' $GRAYLOG_HOST/api/system/bundles -d @${FILE})

# Print result
echo $result | jq .
