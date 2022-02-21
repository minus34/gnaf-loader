#!/usr/bin/env bash


# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

cd ${SCRIPT_DIR}/../docker
docker build --squash --tag minus34/gnafloader:latest --tag minus34/gnafloader:202202 --no-cache  --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202202" .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA2020 docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

docker build --squash --tag minus34/gnafloader:latest-gda2020 --tag minus34/gnafloader:202202-gda2020 --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202202-gda2020" .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push images to Docker Hub"
echo "---------------------------------------------------------------------------------------------------------------------"

docker push --all-tags minus34/gnafloader

echo "---------------------------------------------------------------------------------------------------------------------"
echo "clean up Docker locally - warning: this could accidentally destroy other Docker images"
echo "---------------------------------------------------------------------------------------------------------------------"

echo 'y' | docker system prune
