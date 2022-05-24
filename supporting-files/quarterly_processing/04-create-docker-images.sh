#!/usr/bin/env bash

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

cd ${SCRIPT_DIR}/../../docker

docker build --tag minus34/gnafloader:latest --tag minus34/gnafloader:202205 --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202205" .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA2020 docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

docker build --tag minus34/gnafloader:latest-gda2020 --tag minus34/gnafloader:202205-gda2020 --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202205-gda2020" .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push both images (with 4 tags) to Docker Hub"
echo "---------------------------------------------------------------------------------------------------------------------"

docker push minus34/gnafloader --all-tags

#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "clean up Docker locally - warning: this could accidentally destroy other Docker images"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
#echo 'y' | docker system prune
