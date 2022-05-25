#!/usr/bin/env bash

# need a Python 3.9+ environment with Psycopg2 and PyArrow
conda deactivate
conda activate geo

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202205"

python ${SCRIPT_DIR}/export_gnaf_and_admin_bdys_to_geoparquet.py --admin-schema="admin_bdys_202205" --gnaf-schema="gnaf_202205" --output-path="${OUTPUT_FOLDER}/geoparquet"
