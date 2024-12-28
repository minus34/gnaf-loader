#!/usr/bin/env bash

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202411"
OUTPUT_FOLDER_2020="/Users/$(whoami)/tmp/geoscape_202411_gda2020"

DOCKER_FOLDER=${SCRIPT_DIR}/../../docker

echo "---------------------------------------------------------------------------------------------------------------------"
echo "copy postgres dump files to Dockerfile folder"
echo "---------------------------------------------------------------------------------------------------------------------"

cp ${OUTPUT_FOLDER}/*.dmp ${DOCKER_FOLDER}/

echo "---------------------------------------------------------------------------------------------------------------------"
echo "start podman"
echo "---------------------------------------------------------------------------------------------------------------------"

# default folder /var/tmp/ is too small
export TMPDIR=/Users/$(whoami)/tmp/podman/

podman machine stop
echo 'y' | podman system prune --all
echo 'y' | podman machine rm
podman machine init --cpus 10 --memory 16384 --disk-size=128  # memory in Mb, disk size in Gb
podman machine start
podman login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} docker.io/minus34

# go to Dockerfile directory
cd ${DOCKER_FOLDER}

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA94 docker image"
echo "---------------------------------------------------------------------------------------------------------------------"

# build images
podman build --platform linux/amd64,linux/arm64 --tag localhost/fred .

podman manifest create minus34/gnafloader_test:latest localhost/fred
podman manifest push minus34/gnafloader_test:latest

docker manifest create minus34/gnafloader_test:202411 localhost/fred
docker manifest push minus34/gnafloader_test:202411

#podman build --platform linux/amd64,linux/arm64 --tag docker.io/minus34/gnafloader_test:latest --tag docker.io/minus34/gnafloader_test:202411 .
#
#podman manifest create minus34/gnafloader_test
#podman manifest add minus34/gnafloader_test docker.io/minus34/gnafloader_test:latest
#podman manifest add minus34/gnafloader_test docker.io/minus34/gnafloader_test:202411
#podman manifest push minus34/gnafloader_test




#podman build --no-cache --platform linux/arm64,linux/amd64 --tag minus34/gnafloader_test:latest --tag minus34/gnafloader_test:202411 .
#podman image push localhost/minus34/gnafloader_test docker://docker.io/minus34/gnafloader_test

# delete postgres dmp files
rm ${DOCKER_FOLDER}/*.dmp

#podman machine stop
#echo 'y' | podman system prune --all
#echo 'y' | podman machine rm
#podman machine init --cpus 10 --memory 16384 --disk-size=128  # memory in Mb, disk size in Gb
#podman machine start
#podman login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} docker.io/minus34/gnafloader_test
#
#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "copy GDA2020 postgres dump files to Dockerfile folder"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
#cp ${OUTPUT_FOLDER_2020}/*.dmp ${DOCKER_FOLDER}/
#
#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "build gnaf-loader GDA2020 docker image"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
#podman build --no-cache --platform linux/arm64,linux/amd64 --tag minus34/gnafloader_test:latest-gda2020 --tag minus34/gnafloader_test:202411-gda2020 .
#podman image push localhost/minus34/gnafloader_test docker://docker.io/minus34/gnafloader_test
#
## delete postgres dmp files
#rm ${DOCKER_FOLDER}/*.dmp
#
#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "clean up podman locally - warning: this could accidentally destroy other images"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
## required or podman VM could run out of space
#echo 'y' | podman system prune --all
#podman machine stop
#echo 'y' | podman machine rm
