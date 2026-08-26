#!/usr/bin/env bash

# get the directory this script is running from
MAIN_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# cd "${MAIN_SCRIPT_DIR}" || exit
# . 01_setup_conda_env.sh

cd "${MAIN_SCRIPT_DIR}" || exit
. 02-run-gnaf-loader-locality-clean-and-copy-to-aws-s3.sh
. 03-run-gnaf-loader-locality-clean-and-copy-to-aws-s3-gda2020.sh

cd "${MAIN_SCRIPT_DIR}" || exit
. 04-export-to-geoparquet.sh

cd "${MAIN_SCRIPT_DIR}" || exit
. 05-create-podman-images.sh

cd "${MAIN_SCRIPT_DIR}" || exit


# URLs
# https://github.com/minus34/gnaf-loader
# https://hub.docker.com/r/minus34/gnafloader
