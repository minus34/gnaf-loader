#!/usr/bin/env bash

# need a Python 3.7+ environment with Psycopg2
conda activate minus34

# ---------------------------------------------------------------------------------------------------------------------
# edit these to taste - NOTE: you can't use "~" for your home folder, Postgres doesn't like it
# ---------------------------------------------------------------------------------------------------------------------

AWS_PROFILE="default"
OUTPUT_FOLDER="/Users/$(whoami)/tmp"
GNAF_PATH="/Users/$(whoami)/Downloads/G-NAF_MAY21_AUSTRALIA_GDA94"
BDYS_PATH="/Users/$(whoami)/Downloads/MAY21 AdminBounds ESRIShapefileorDBFfile"

# ---------------------------------------------------------------------------------------------------------------------

# get the directory this script is running from
GNAF_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# ---------------------------------------------------------------------------------------------------------------------
# Run gnaf-loader and locality boundary clean
# ---------------------------------------------------------------------------------------------------------------------

python3 /Users/$(whoami)/git/minus34/gnaf-loader/load-gnaf.py --pgport=5432 --pgdb=geo --max-processes=6 --gnaf-tables-path="${GNAF_PATH}" --admin-bdys-path="${BDYS_PATH}"
python3 /Users/$(whoami)/git/iag_geo/psma-admin-bdys/locality-clean.py --pgport=5432 --pgdb=geo --max-processes=6 --output-path=${OUTPUT_FOLDER}

# ---------------------------------------------------------------------------------------------------------------------
# dump postgres schemas to a local folder
# ---------------------------------------------------------------------------------------------------------------------

/Applications/Postgres.app/Contents/Versions/12/bin/pg_dump -Fc -d geo -n gnaf_202105 -p 5432 -U postgres -f "${OUTPUT_FOLDER}/gnaf-202105.dmp" --no-owner
echo "GNAF schema exported to dump file"
/Applications/Postgres.app/Contents/Versions/12/bin/pg_dump -Fc -d geo -n admin_bdys_202105 -p 5432 -U postgres -f "${OUTPUT_FOLDER}/admin-bdys-202105.dmp" --no-owner
echo "Admin Bdys schema exported to dump file"

# ---------------------------------------------------------------------------------------------------------------------
# copy Postgres dump files to AWS S3 and allow public read access (requires AWSCLI installed & AWS credentials setup)
# ---------------------------------------------------------------------------------------------------------------------

#cd "${OUTPUT_FOLDER}" || exit

aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER} s3://minus34.com/opendata/geoscape-202105 --exclude "*" --include "*.dmp" --acl public-read
echo "dump files uploaded to AWS S3"

#for f in *-202105.dmp;
#  do
#    aws --profile=${AWS_PROFILE} s3 cp --storage-class REDUCED_REDUNDANCY "./${f}" s3://minus34.com/opendata/geoscape-202105/${f};
#    aws --profile=${AWS_PROFILE} s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/geoscape-202105/${f}
#    echo "${f} uploaded to AWS S3"
#  done

## ---------------------------------------------------------------------------------------------------------------------
## build gnafloader docker image
## ---------------------------------------------------------------------------------------------------------------------
#
#cd /Users/$(whoami)/git/minus34/gnaf-loader/docker
#docker build --tag minus34/gnafloader:latest --tag minus34/gnafloader:202105 .

# ---------------------------------------------------------------------------------------------------------------------
# create parquet versions of GNAF and Admin Bdys and upload to AWS S3
# ---------------------------------------------------------------------------------------------------------------------

# first - activate or create Conda environment with Apache Spark + Sedona
#. /Users/$(whoami)/git/iag_geo/spark_testing/apache_sedona/01_setup_sedona.sh
conda activate sedona

python ${GNAF_SCRIPT_DIR}/../spark/02_export_gnaf_and_admin_bdys_to_s3.py

aws --profile=${AWS_PROFILE} s3 sync ${GNAF_SCRIPT_DIR}/../spark/data s3://minus34.com/opendata/geoscape-202105/parquet --acl public-read
