#!/usr/bin/env bash

# need a Python 3.6+ environment with Psycopg (run 01_setup_conda_env.sh to create Conda environment)
conda deactivate
conda activate geo

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# ---------------------------------------------------------------------------------------------------------------------
# edit these to taste - NOTE: you can't use "~" for your home folder, Postgres doesn't like it
# ---------------------------------------------------------------------------------------------------------------------

AWS_PROFILE="minus34"
OUTPUT_FOLDER_2020="/Users/$(whoami)/tmp/geoscape_202505_gda2020"
GNAF_2020_PATH="/Users/$(whoami)/Downloads/g-naf_feb25_allstates_gda2020_psv_1018"
BDYS_2020_PATH="/Users/$(whoami)/Downloads/FEB25_AdminBounds_GDA_2020_SHP"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "Run gnaf-loader and locality boundary clean"
echo "---------------------------------------------------------------------------------------------------------------------"

python3 "/Users/$(whoami)/git/minus34/gnaf-loader/load-gnaf.py" --pgport=5432 --pgdb=geo --max-processes=6 --gnaf-tables-path="${GNAF_2020_PATH}" --admin-bdys-path="${BDYS_2020_PATH}" --srid=7844 --gnaf-schema gnaf_202505_gda2020 --admin-schema admin_bdys_202505_gda2020 --previous-gnaf-schema gnaf_202505 --previous-admin-schema admin_bdys_202505
python3 "/Users/$(whoami)/git/iag_geo/psma-admin-bdys/locality-clean.py" --pgport=5432 --pgdb=geo --max-processes=6 --output-path=${OUTPUT_FOLDER_2020} --admin-schema admin_bdys_202505_gda2020

# upload locality bdy files to S3
aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020} s3://minus34.com/opendata/geoscape-202505-gda2020 --exclude "*" --include "*.zip" --acl public-read

# done in GDA94 script (files not processed for GDA2020 data as the result is 99.99999.....% the same)
#echo "---------------------------------------------------------------------------------------------------------------------"
#echo "create concordance file"
#echo "---------------------------------------------------------------------------------------------------------------------"
#
## create concordance file and upload to S3
#mkdir -p "${OUTPUT_FOLDER_2020}"
#python3 /Users/$(whoami)/git/iag_geo/concord/create_concordance_file.py --pgdb=geo --admin-schema="admin_bdys_202505_gda2020" --gnaf-schema="gnaf_202505_gda2020" --output-path=${OUTPUT_FOLDER_2020}
#aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020} s3://minus34.com/opendata/geoscape-202505-gda2020 --exclude "*" --include "*.csv" --acl public-read

echo "---------------------------------------------------------------------------------------------------------------------"
echo "dump postgres schemas to a local folder"
echo "---------------------------------------------------------------------------------------------------------------------"

/Applications/Postgres.app/Contents/Versions/14/bin/pg_dump -Fc -d geo -n gnaf_202505_gda2020 -p 5432 -U postgres -f "${OUTPUT_FOLDER_2020}/gnaf-202505.dmp" --no-owner
echo "GNAF schema exported to dump file"
/Applications/Postgres.app/Contents/Versions/14/bin/pg_dump -Fc -d geo -n admin_bdys_202505_gda2020 -p 5432 -U postgres -f "${OUTPUT_FOLDER_2020}/admin-bdys-202505.dmp" --no-owner
echo "Admin Bdys schema exported to dump file"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "copy Postgres dump files to AWS S3 and allow public read access (requires AWSCLI installed & AWS credentials setup)"
echo "---------------------------------------------------------------------------------------------------------------------"

aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020} s3://minus34.com/opendata/geoscape-202505-gda2020 --exclude "*" --include "*.dmp" --acl public-read

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
#python ${SCRIPT_DIR}/../../spark/xx_export_gnaf_and_admin_bdys_to_geoparquet.py --admin-schema="admin_bdys_202505_gda2020" --gnaf-schema="gnaf_202505_gda2020" --output-path="${OUTPUT_FOLDER_2020}/geoparquet"
#
#aws --profile=${AWS_PROFILE} s3 rm s3://minus34.com/opendata/geoscape-202505-gda2020/geoparquet/ --recursive
#aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020}/geoparquet s3://minus34.com/opendata/geoscape-202505-gda2020/geoparquet --acl public-read
