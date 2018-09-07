#!/bin/bash
# Service Graylog up script
declare -r DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

declare -r CONFIG_NAME="graylog-docker-entrypoint.sh"
declare -r NETWORK_NAME="graylog"
declare -r NETWORK_NAME_ELASTICSEARCH="elasticsearch"
declare -r NETWORK_NAME_MONGO="mongo"
declare -r NETWORK_NAME_PROXY="proxy"
declare -r IMAGE="graylog2/server:2.4.5-1"

# TODO - Extract MongoDB addresses via CLI or API
declare -r MONGODB_URI="mongodb://10.0.1.64:27017,10.0.1.63:27017,10.0.1.65:27017/graylog"
declare -r ELASTICSEARCH_URI="http://elasticsearch:9200"
declare -r MAXMIND_DOWNLOAD_URL="http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz"
declare -r GRAYLOG_PASSWORD_SECRET="HalWOabaZewE6O4YuHo63wvLP9cBqCmUDV9SMTQ8uTuiCtsl"
declare -r GRAYLOG_ROOT_PASSWORD_SHA2="8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918"
declare -r GRAYLOG_SERVICE_DOMAIN_NAME="graylog.toastmaker.net"

function create_network(){
  # Create an overlay network for graylog cluster
  local -r network=$(docker network ls -f "name=${NETWORK_NAME}" -q)
  if [ "x${network}" = "x" ];then 
    docker network create -d overlay --attachable "${NETWORK_NAME}"
    [ "$?" -eq "0" ] || { echo -e "\nUnable to create an overlay network, ${NETWORK_NAME}\n" 1>&2; cleanup ; exit 1; }
  fi
}

function cleanup(){
  local id=$(docker service ls -f 'name=graylog2-master' -q)
  if [ ! "x${id}" = "x" ];then 
    docker service rm graylog2-master &> /dev/null
  fi
  local network=$(docker network ls -f "name=${NETWORK_NAME}" -q)
  if [ ! "x${network}" = "x" ];then 
    docker network rm $NETWORK_NAME &> /dev/null
  fi
  local -r config=$(docker config ls -f "name=${CONFIG_NAME}" -q)
  if [ ! "x${config}" = "x" ];then 
    docker config rm ${CONFIG_NAME} &> /dev/null
  fi
}

function create_config(){
  # Create Configs
  local -r config=$(docker config ls -f "name=${CONFIG_NAME}" -q)
  
  # Delete first
  if [ ! "x${config}" = "x" ];then 
    docker config rm $config
    sleep 1
  fi
  docker config create $CONFIG_NAME $DIR/graylog2-docker-entrypoint.sh
  [ "$?" -eq "0" ] || { echo -e "\nUnable to create a config, ${CONFIG_NAME}\n" 1>&2; cleanup ; exit 1; }

}

function create_service(){
  local is_master=${1:-"false"}
  # Master existance checking
  local id=$(docker service ls -f 'name=graylog2-master' -q)
  if [ "x${id}" = "x" ];then 
    docker service create --name graylog2-master \
      --config "source=${CONFIG_NAME},target=/docker-entrypoint.sh,mode=0755" \
      --env "TZ=Asia/Seoul" \
      --env "GRAYLOG_ROOT_TIMEZONE=Asia/Seoul" \
      --env "GRAYLOG_IS_MASTER=${is_master}" \
      --env "GRAYLOG_PASSWORD_SECRET=${GRAYLOG_PASSWORD_SECRET}" \
      --env "GRAYLOG_ROOT_PASSWORD_SHA2=${GRAYLOG_ROOT_PASSWORD_SHA2}" \
      --env "GRAYLOG_ELASTICSEARCH_HOSTS=${ELASTICSEARCH_URL}" \
      --env "GRAYLOG_MONGODB_URI=${MONGODB_URI}" \
      --env "MAXMIND_DOWNLOAD_URI=${MAXMIND_DOWNLOAD_URI}" \
      --env "GRAYLOG_WEB_ENDPOINT_URI=http://${GRAYLOG_SERVICE_DOMAIN_NAME}/api" \
      --label "com.df.notify=true" \
      --label "com.df.servicePath=/,/api" \
      --label "com.df.port=9000" \
      --label "com.df.serviceDomain=${GRAYLOG_SERVICE_DOMAIN_NAME}" \
      --label "com.df.backendExtra=option httpchk HEAD /api/system/lbstatus" \
      --label "com.df.setReqHeader=X-Graylog-Server-URL http://${GRAYLOG_SERVICE_DOMAIN_NAME}/api" \
      --network $NETWORK_NAME \
      --network $NETWORK_NAME_ELASTICSEARCH \
      --network $NETWORK_NAME_MONGO \
      --network $NETWORK_NAME_PROXY \
      --publish "9000:9000" \
      --constraint "node.id==u8l893mdwu0c9o6w1gffl5gvj" \
      --reserve-cpu 0.5 \
      --reserve-memory 2G --limit-memory 3G \
      --hostname graylog \
      $IMAGE
  fi
}

function usage {
    cat <<- EOF
Usage: $PROGNAME [ -h -m ]

Optional arguments:
    -m | --master     Run Graylog master service 
    --clean           Clean up all service and related configurations
    -h                Help

General usage example:

  $ $PROGNAME -h 

EOF

    exit 0
}

function main(){

  # parse getopts options
  local tmp_getopts=`getopt -o h,m,d --long help,master,clean,dry-run -- "$@"`
  [ $? != 0 ] && usage
  eval set -- "$tmp_getopts"

  while true; do
      case "$1" in
          -h|--help)                    usage;;
          -m|--master)                  local graylog_node_type="master"; shift;;
          --clean)                      local clean="true";               shift;;
          --) shift; break;;
          *) usage;;
      esac
  done

  if [ "${clean}" = "true" ];then
    cleanup
  else
    create_network
    create_config
    create_service $graylog_node_type
  fi

}

main "$@"
