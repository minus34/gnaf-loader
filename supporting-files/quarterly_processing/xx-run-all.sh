#!/usr/bin/env bash

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR} || exit

#. 01_setup_conda_env.sh

. 02-run-gnaf-loader-locality-clean-and-copy-to-aws-s3.sh

. 03-run-gnaf-loader-locality-clean-and-copy-to-aws-s3-gda2020.sh

. 04-create-podman-images.sh
