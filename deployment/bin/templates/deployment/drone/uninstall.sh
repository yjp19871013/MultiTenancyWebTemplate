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