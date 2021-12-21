#!/usr/bin/env bash

# need a Python 3.6+ environment with Psycopg2 (run 01_setup_conda_env.sh to create Conda environment)
conda activate geo

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader docker image and push to Docker Hub"
echo "---------------------------------------------------------------------------------------------------------------------"

cd ${SCRIPT_DIR}/../docker
docker build --squash --tag minus34/gnafloader:latest --tag minus34/gnafloader:202111 --no-cache  --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202111" .
docker push --all-tags minus34/gnafloader

echo "---------------------------------------------------------------------------------------------------------------------"
echo "build gnaf-loader GDA2020 docker image and push to Docker Hub"
echo "---------------------------------------------------------------------------------------------------------------------"

cd ${SCRIPT_DIR}/../docker
docker build --squash --tag minus34/gnafloader:latest-gda2020 --tag minus34/gnafloader:202111-gda2020 --no-cache --build-arg BASE_URL="https://minus34.com/opendata/geoscape-202111-gda2020" .
docker push --all-tags minus34/gnafloader
