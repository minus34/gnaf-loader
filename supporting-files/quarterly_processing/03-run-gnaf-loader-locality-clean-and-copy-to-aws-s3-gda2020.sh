#!/usr/bin/env bash

# need a Python 3.6+ environment with Psycopg2 (run 01_setup_conda_env.sh to create Conda environment)
conda deactivate
conda activate geo

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# ---------------------------------------------------------------------------------------------------------------------
# edit these to taste - NOTE: you can't use "~" for your home folder, Postgres doesn't like it
# ---------------------------------------------------------------------------------------------------------------------

AWS_PROFILE="minus34"
OUTPUT_FOLDER_2020="/Users/$(whoami)/tmp/geoscape_202208_gda2020"
GNAF_2020_PATH="/Users/$(whoami)/Downloads/g-naf_aug22_allstates_gda2020_psv_108"
BDYS_2020_PATH="/Users/$(whoami)/Downloads/AUG22_AdminBounds_GDA_2020_SHP"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "Run gnaf-loader and locality boundary clean"
echo "---------------------------------------------------------------------------------------------------------------------"

python3 /Users/$(whoami)/git/minus34/gnaf-loader/load-gnaf.py --pgport=5432 --pgdb=geo --max-processes=6 --gnaf-tables-path="${GNAF_2020_PATH}" --admin-bdys-path="${BDYS_2020_PATH}" --srid=7844 --gnaf-schema gnaf_202208_gda2020 --admin-schema admin_bdys_202208_gda2020 --previous-gnaf-schema gnaf_202208 --previous-admin-schema admin_bdys_202208
python3 /Users/$(whoami)/git/iag_geo/psma-admin-bdys/locality-clean.py --pgport=5432 --pgdb=geo --max-processes=6 --output-path=${OUTPUT_FOLDER_2020} --admin-schema admin_bdys_202208_gda2020

echo "---------------------------------------------------------------------------------------------------------------------"
echo "create concordance file"
echo "---------------------------------------------------------------------------------------------------------------------"

# create concordance file and upload to S3
mkdir -p "${OUTPUT_FOLDER_2020}"
python3 /Users/$(whoami)/git/iag_geo/concord/create_concordance_file.py --pgdb=geo --admin-schema="admin_bdys_202208_gda2020" --gnaf-schema="gnaf_202208_gda2020" --output-path=${OUTPUT_FOLDER_2020}
aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020} s3://minus34.com/opendata/geoscape-202208-gda2020 --exclude "*" --include "*.csv" --acl public-read

echo "---------------------------------------------------------------------------------------------------------------------"
echo "dump postgres schemas to a local folder"
echo "---------------------------------------------------------------------------------------------------------------------"

/Applications/Postgres.app/Contents/Versions/13/bin/pg_dump -Fc -d geo -n gnaf_202208_gda2020 -p 5432 -U postgres -f "${OUTPUT_FOLDER_2020}/gnaf-202208.dmp" --no-owner
echo "GNAF schema exported to dump file"
/Applications/Postgres.app/Contents/Versions/13/bin/pg_dump -Fc -d geo -n admin_bdys_202208_gda2020 -p 5432 -U postgres -f "${OUTPUT_FOLDER_2020}/admin-bdys-202208.dmp" --no-owner
echo "Admin Bdys schema exported to dump file"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "copy Postgres dump files to AWS S3 and allow public read access (requires AWSCLI installed & AWS credentials setup)"
echo "---------------------------------------------------------------------------------------------------------------------"

aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020} s3://minus34.com/opendata/geoscape-202208-gda2020 --exclude "*" --include "*.dmp" --acl public-read

echo "---------------------------------------------------------------------------------------------------------------------"
echo "create parquet versions of GNAF and Admin Bdys and upload to AWS S3"
echo "---------------------------------------------------------------------------------------------------------------------"

# first - activate or create Conda environment with Apache Spark + Sedona
#. /Users/$(whoami)/git/iag_geo/spark_testing/apache_sedona/01_setup_sedona.sh

conda activate sedona

python ${SCRIPT_DIR}/../../spark/02_export_gnaf_and_admin_bdys_to_s3.py --admin-schema="admin_bdys_202208_gda2020" --gnaf-schema="gnaf_202208_gda2020" --output-path="${OUTPUT_FOLDER_2020}/parquet"

aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020}/parquet s3://minus34.com/opendata/geoscape-202208-gda2020/parquet --acl public-read
