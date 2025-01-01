#!/usr/bin/env bash

#brew install podman

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202411"
OUTPUT_FOLDER_2020="/Users/$(whoami)/tmp/geoscape_202411_gda2020"

DOCKER_FOLDER=${SCRIPT_DIR}/../../docker

# default podman temp folder /var/tmp/ is too small
export TMPDIR=/Users/$(whoami)/tmp/podman/

echo "---------------------------------------------------------------------------------------------------------------------"
echo "copy GDA94 postgres dump files to Dockerfile folder"
echo "---------------------------------------------------------------------------------------------------------------------"

cp ${OUTPUT_FOLDER}/*.dmp ${DOCKER_FOLDER}/

echo "---------------------------------------------------------------------------------------------------------------------"
echo "initialise podman - warning: this could accidentally destroy other images"
echo "---------------------------------------------------------------------------------------------------------------------"

echo 'y' | podman system prune --all
podman machine stop
echo 'y' | podman machine rm
podman machine init --cpus 10 --memory 16384 --disk-size=256  # memory in Mb, disk size in Gb
podman machine start
podman login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} docker.io/minus34

# go to Dockerfile directory
cd ${DOCKER_FOLDER}

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA94 images : $(date)"
echo "---------------------------------------------------------------------------------------------------------------------"

# build images
podman manifest create localhost/gnafloader
podman build --quiet --squash --platform linux/amd64,linux/arm64/v8 --manifest localhost/gnafloader .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push 'latest' GDA94 images : $(date)"
echo "---------------------------------------------------------------------------------------------------------------------"

podman manifest push --compression-level 9 localhost/gnafloader docker://docker.io/minus34/gnafloader:latest

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push '202411' GDA94 images : $(date)"
echo "---------------------------------------------------------------------------------------------------------------------"

podman manifest push --compression-level 9 localhost/gnafloader docker://docker.io/minus34/gnafloader:202411

# delete postgres dmp files
rm ${DOCKER_FOLDER}/*.dmp

echo "---------------------------------------------------------------------------------------------------------------------"
echo "copy GDA2020 postgres dump files to Dockerfile folder"
echo "---------------------------------------------------------------------------------------------------------------------"

cp ${OUTPUT_FOLDER_2020}/*.dmp ${DOCKER_FOLDER}/

echo "---------------------------------------------------------------------------------------------------------------------"
echo "re-initialise podman - warning: this could accidentally destroy other images"
echo "---------------------------------------------------------------------------------------------------------------------"

echo 'y' | podman system prune --all
podman machine stop
echo 'y' | podman machine rm
podman machine init --cpus 10 --memory 16384 --disk-size=256  # memory in Mb, disk size in Gb
podman machine start
podman login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} docker.io/minus34

# go to Dockerfile directory
cd ${DOCKER_FOLDER}

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA2020 images : $(date)"
echo "---------------------------------------------------------------------------------------------------------------------"

# build images
podman manifest create localhost/gnafloader-gda2020
podman build --quiet --squash --platform linux/amd64,linux/arm64/v8 --manifest localhost/gnafloader-gda2020 .

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push 'latest' GDA2020 images : $(date)"
echo "---------------------------------------------------------------------------------------------------------------------"

podman manifest push --compression-level 9 localhost/gnafloader-gda2020 docker://docker.io/minus34/gnafloader:latest-gda2020

echo "---------------------------------------------------------------------------------------------------------------------"
echo "push '202411' GDA2020 images : $(date)"
echo "---------------------------------------------------------------------------------------------------------------------"

podman manifest push --compression-level 9 localhost/gnafloader-gda2020 docker://docker.io/minus34/gnafloader:202411-gda2020

# delete postgres dmp files
rm ${DOCKER_FOLDER}/*.dmp

echo "---------------------------------------------------------------------------------------------------------------------"
echo "clean up podman locally - warning: this could accidentally destroy other images"
echo "---------------------------------------------------------------------------------------------------------------------"

# clean up
echo 'y' | podman system prune --all
podman machine stop
echo 'y' | podman machine rm
