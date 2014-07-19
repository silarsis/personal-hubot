#!/bin/bash
#
# Script to provision from wercker, building on orchard
#
# Needs/supports the following environment variables:
# HUBOT_SLACK_TEAM
# HUBOT_SLACK_TOKEN
# HUBOT_SLACK_BOTNAME

SRC="."
ORCHARD_BIN="./orchard"
ORCHARD_CMD="${ORCHARD_BIN}"
DOCKER_CMD="${ORCHARD_CMD} docker"
IMAGE_NAME="hubot"
RUN_FLAGS="-d -t"
VOLUME_FLAG=""
BUILD=0
RESTART=0

while getopts ":br" opt; do
  case $opt in
    b)
      BUILD=1
      ;;
    r)
      RESTART=1
      ;;
  esac
done

set -e
set -x

[ -e ./orchard ] || {
  curl -L -o ${ORCHARD_BIN} https://github.com/orchardup/go-orchard/releases/download/2.0.7/linux
  chmod +x ${ORCHARD_BIN}
  ${ORCHARD_CMD} hosts create
}

[ ${BUILD} -eq 1 ] && {
  time ${DOCKER_CMD} build --rm -t ${IMAGE_NAME} ${SRC}
}

set +x

[ ${RESTART} -eq 1 ] && {
  ${DOCKER_CMD} kill ${IMAGE_NAME} || echo "could not kill ${IMAGE_NAME}"
  ${DOCKER_CMD} rm ${IMAGE_NAME} || echo "could not remove ${IMAGE_NAME} container"
  echo "${DOCKER_CMD} run ${RUN_FLAGS} <environment> --name ${IMAGE_NAME} ${IMAGE_NAME} /usr/local/bin/start.sh"
  ${DOCKER_CMD} run ${RUN_FLAGS} ${VOLUME_FLAG} \
    -p 8080:80
    -e SLACK_API_URL=${SLACK_API_URL} \
    -e LOGENTRIES_TOKEN=${LOGENTRIES_TOKEN} \
    -e HUBOT_SLACK_TOKEN=${HUBOT_SLACK_TOKEN} \
    -e HUBOT_SLACK_TEAM=${HUBOT_SLACK_TEAM} \
    -e HUBOT_SLACK_BOTNAME=${HUBOT_SLACK_BOTNAME} \
    --name ${IMAGE_NAME} \
    ${IMAGE_NAME} /usr/local/bin/start.sh
}
exit 0
