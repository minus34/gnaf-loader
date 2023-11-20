#!/usr/bin/env bash

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202311"
OUTPUT_FOLDER_2020="/Users/$(whoami)/tmp/geoscape_202311_gda2020"

cd ${SCRIPT_DIR}/../../docker

echo "---------------------------------------------------------------------------------------------------------------------"
echo "start Docker desktop and wait 90 seconds for startup"
echo "---------------------------------------------------------------------------------------------------------------------"

open -a Docker
sleep 90

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA94 docker image "
echo "---------------------------------------------------------------------------------------------------------------------"

# force platform to avoid Apple Silicon only images
cd ${OUTPUT_FOLDER}
docker build --platform linux/amd64 --no-cache --tag docker.io/minus34/gnafloader:latest --tag docker.io/minus34/gnafloader:202311 \
  -f /Users/$(whoami)/git/minus34/gnaf-loader/docker/Dockerfile .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push image (with 2 tags) to Docker Hub"
echo "---------------------------------------------------------------------------------------------------------------------"

docker push minus34/gnafloader --all-tags

echo "---------------------------------------------------------------------------------------------------------------------"
echo "clean up Docker locally - warning: this could accidentally destroy other Docker images"
echo "---------------------------------------------------------------------------------------------------------------------"

# required or Docker VM will run out of space
echo 'y' | docker system prune

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA2020 docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

cd ${OUTPUT_FOLDER_2020}
docker build --platform linux/amd64 --no-cache --tag docker.io/minus34/gnafloader:latest-gda2020 --tag docker.io/minus34/gnafloader:202311-gda2020 \
  -f /Users/$(whoami)/git/minus34/gnaf-loader/docker/Dockerfile .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push images (with 2 new tags) to Docker Hub"
echo "---------------------------------------------------------------------------------------------------------------------"

docker push minus34/gnafloader --all-tags

echo "---------------------------------------------------------------------------------------------------------------------"
echo "clean up Docker locally - warning: this could accidentally destroy other Docker images"
echo "---------------------------------------------------------------------------------------------------------------------"

# required or Docker VM will run out of space
echo 'y' | docker system prune
