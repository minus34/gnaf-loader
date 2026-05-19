#!/usr/bin/env bash

# get the directory this script is running from
THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# first - activate or create Conda environment with Apache Spark + Sedona
. "/Users/$(whoami)/git/iag_geo/spark_testing/apache_sedona/01_setup_sedona.sh"

## need a Python 3.12+ environment with Psycopg (run 01_setup_conda_env.sh to create Conda environment)
#conda deactivate
#conda activate sedona

AWS_PROFILE="minus34"
OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202605"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "create geoparquet versions of GNAF and Admin Bdys and upload to AWS S3"
echo "---------------------------------------------------------------------------------------------------------------------"

# delete all existing files
rm -rf "${OUTPUT_FOLDER}/geoparquet"

python "${THIS_SCRIPT_DIR}/../../spark/xx_export_gnaf_and_admin_bdys_to_geoparquet.py" --admin-schema="admin_bdys_202605" --gnaf-schema="gnaf_202605" --output-path="${OUTPUT_FOLDER}/geoparquet"

aws --profile=${AWS_PROFILE} s3 rm s3://minus34.com/opendata/geoscape-202605/geoparquet/ --recursive
aws --profile=${AWS_PROFILE} s3 sync "${OUTPUT_FOLDER}/geoparquet" "s3://minus34.com/opendata/geoscape-202605/geoparquet" --acl public-read


# disabled as currently only exporting the GDA94 version in WGS84 coordinates
#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "create geoparquet versions of GNAF and Admin Bdys and upload to AWS S3"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
## first - activate or create Conda environment with Apache Spark + Sedona
##. /Users/$(whoami)/git/iag_geo/spark_testing/apache_sedona/01_setup_sedona.sh
#
#conda activate sedona
#
## delete all existing files
#rm -rf ${OUTPUT_FOLDER}/geoparquet
#
#python ${THIS_SCRIPT_DIR}/../../spark/xx_export_gnaf_and_admin_bdys_to_geoparquet.py --admin-schema="admin_bdys_202605_gda2020" --gnaf-schema="gnaf_202605_gda2020" --output-path="${OUTPUT_FOLDER_2020}/geoparquet"
#
#aws --profile=${AWS_PROFILE} s3 rm s3://minus34.com/opendata/geoscape-202605-gda2020/geoparquet/ --recursive
#aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020}/geoparquet s3://minus34.com/opendata/geoscape-202605-gda2020/geoparquet --acl public-read
