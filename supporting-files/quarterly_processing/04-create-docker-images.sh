#!/usr/bin/env bash

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}/../../docker

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA94 docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

docker build --tag minus34/gnafloader:latest --tag minus34/gnafloader:202302 --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202302" .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA2020 docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

docker build --tag minus34/gnafloader:latest-gda2020 --tag minus34/gnafloader:202302-gda2020 --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202302-gda2020" .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push both images (with 4 tags) to Docker Hub"
echo "---------------------------------------------------------------------------------------------------------------------"

docker push minus34/gnafloader --all-tags

#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "clean up Docker locally - warning: this could accidentally destroy other Docker images"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
#echo 'y' | docker system prune
