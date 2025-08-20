#!/usr/bin/env bash

# need a Python 3.10+ environment with GDAL 3.6.0 and PyArrow
conda deactivate
conda activate geo

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OUTPUT_FOLDER="/Users/$(whoami)/tmp/gdal-testing"
mkdir -p "${OUTPUT_FOLDER}"
cd "${OUTPUT_FOLDER}"


# convert Postgres table to CSV with CSVT field types file
input_schema="gnaf_202508"
input_table="address_principals"

echo "Exporting ${input_schema}.${input_table}"

ogr2ogr \
  -f CSV \
  "${OUTPUT_FOLDER}/${input_table}.csv" \
  PG:"host='localhost' dbname='geo' user='postgres' password='password' port='5432'" \
  "${input_schema}.${input_table}(geom)" \
  -lco CREATE_CSVT=YES
