#!/usr/bin/env bash

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202411"
OUTPUT_FOLDER_2020="/Users/$(whoami)/tmp/geoscape_202411_gda2020"

cd ${SCRIPT_DIR}/../../docker

#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "start Docker desktop and wait 90 seconds for startup"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
#open -a Docker
#sleep 90

# required or Docker VM will run out of space
echo 'y' | docker builder prune --all
echo 'y' | docker system prune --all

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA94 docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

# 1. go to Dockerfile directory
cd ${OUTPUT_FOLDER}

# 2. launch buildx
docker buildx create --name gnafloader_test_builder --use
docker buildx inspect --bootstrap

# 3. build and push images
docker buildx build --platform linux/amd64,linux/arm64 --tag minus34/gnafloader_test:latest  --tag minus34/gnafloader_test:202411 -f /Users/$(whoami)/git/minus34/gnaf-loader/docker/Dockerfile . --load # --push

echo "---------------------------------------------------------------------------------------------------------------------"
echo "clean up Docker locally - warning: this could accidentally destroy other Docker images"
echo "---------------------------------------------------------------------------------------------------------------------"

## required or Docker VM will run out of space
#echo 'y' | docker builder prune --all
#echo 'y' | docker system prune --all
#
#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "build gnaf-loader GDA2020 docker image"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
## 1. go to Dockerfile directory
#cd ${OUTPUT_FOLDER_2020}
#
## 2. launch buildx
#docker buildx create --name gnafloader_test_gda2020_builder --use
#docker buildx inspect --bootstrap
#
## 3. build and push images
#docker buildx build --platform linux/amd64,linux/arm64 --tag minus34/gnafloader_test:latest-gda2020  --tag minus34/gnafloader_test:202411-gda2020 -f /Users/$(whoami)/git/minus34/gnaf-loader/docker/Dockerfile . --push
#
#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "clean up Docker locally - warning: this could accidentally destroy other Docker images"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
## required or Docker VM will run out of space
#echo 'y' | docker builder prune --all
#echo 'y' | docker system prune --all