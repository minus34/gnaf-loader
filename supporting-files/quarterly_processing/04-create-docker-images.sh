#!/usr/bin/env bash

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}/../../docker

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA94 docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

podman build --tag docker.io/minus34/gnafloader:latest --tag minus34/gnafloader:202302 --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202302" .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push image (with 2 tags) to Docker Hub"
echo "---------------------------------------------------------------------------------------------------------------------"

# login (if needed)
#podman login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} docker.io

podman push docker.io/minus34/gnafloader/latest
podman push docker.io/minus34/gnafloader/202302

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA2020 docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

podman build --tag docker.io/minus34/gnafloader:latest-gda2020 --tag minus34/gnafloader:202302-gda2020 --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202302-gda2020" .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push image (with 2 tags) to Docker Hub"
echo "---------------------------------------------------------------------------------------------------------------------"

# login (if needed)
#podman login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} docker.io

podman push docker.io/minus34/gnafloader/latest-gda2020
podman push docker.io/minus34/gnafloader/202302-gda2020

#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "clean up Docker locally - warning: this could accidentally destroy other Docker images"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
#echo 'y' | docker system prune
