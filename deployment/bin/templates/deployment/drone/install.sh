#!/bin/bash
set -u

VERSION=$1

if [[ ${VERSION} = "master" ]]; then
  VERSION='latest'
fi

NAME={{ .ProjectConfig.BuildName }}

IMAGE_NAME=fspub/${NAME}:${VERSION}
CONTAINER_NAME=${NAME}-${VERSION}

docker rm -vf ${CONTAINER_NAME}
docker rmi ${IMAGE_NAME}

docker pull ${IMAGE_NAME}

docker run --restart=always \
    -d --name ${CONTAINER_NAME} \
    -p 10070:10070 \
    --link mysql5:db \
    -e CONFIG_FILE_PATH=/app/bin/config/config.json \
    -v /home/yf-gogs/drone/{{ .ProjectConfig.PackageName }}/config/:/app/bin/config/ \
    -v /etc/localtime:/etc/localtime \
    ${IMAGE_NAME}