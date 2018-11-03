#!/bin/bash
# Service Graylog up script
declare -r DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare -r GRAYLOG_SERVICE_DOMAIN_NAME="graylog.toastmaker.net"

# Declare environment variables
source ${DIR}/env/common

# Load common functions
source ${DIR}/functions 

function create_service(){
  # Master existance checking
  local id=$(docker service ls -f 'name=graylog2-master' -q)
  if [ ! "x${id}" = "x" ];then 
    docker service create --name graylog2-slave \
      --config "source=${CONFIG_NAME},target=/docker-entrypoint.sh,mode=0755" \
      --config "source=${CONFIG_NAME2},target=/usr/share/graylog/plugin/metrics-reporter-prometheus-1.5.0.jar,mode=0664" \
      --env "TZ=Asia/Seoul" \
      --env "GRAYLOG_ROOT_TIMEZONE=Asia/Seoul" \
      --env "GRAYLOG_IS_MASTER=false" \
      --env "GRAYLOG_WEB_ENABLE=false " \
      --env "GRAYLOG_PASSWORD_SECRET=${GRAYLOG_PASSWORD_SECRET}" \
      --env "GRAYLOG_ROOT_PASSWORD_SHA2=${GRAYLOG_ROOT_PASSWORD_SHA2}" \
      --env "GRAYLOG_ELASTICSEARCH_HOSTS=${ELASTICSEARCH_URL}" \
      --env "GRAYLOG_MONGODB_URI=${MONGODB_URI}" \
      --env "MAXMIND_DOWNLOAD_URI=${MAXMIND_DOWNLOAD_URL}" \
      --env "GRAYLOG_WEB_ENDPOINT_URI=http://${GRAYLOG_SERVICE_DOMAIN_NAME}/api" \
      --hostname "{{.Node.Hostname}}" \
      --network $NETWORK_NAME_GRAYLOG \
      --network $NETWORK_NAME_ELASTICSEARCH \
      --network $NETWORK_NAME_MONGO \
      --network $NETWORK_NAME_PROXY \
      --network $NETWORK_NAME_KAFKA \
      --network $NETWORK_NAME_ZOOKEEPER \
      --network $NETWORK_NAME_MONITOR \
      --reserve-cpu 0.5 \
      --reserve-memory 2G --limit-memory 3G \
      $IMAGE
  fi
}

create_service
