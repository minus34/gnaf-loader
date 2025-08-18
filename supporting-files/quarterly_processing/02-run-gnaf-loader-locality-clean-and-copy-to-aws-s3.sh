#!/usr/bin/env bash

# need a Python 3.6+ environment with Psycopg (run 01_setup_conda_env.sh to create Conda environment)
conda deactivate
conda activate geo

# ---------------------------------------------------------------------------------------------------------------------
# edit these to taste - NOTE: you can't use "~" for your home folder, Postgres doesn't like it
# ---------------------------------------------------------------------------------------------------------------------

AWS_PROFILE="minus34"
OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202508"
OUTPUT_FOLDER_2020="/Users/$(whoami)/tmp/geoscape_202508_gda2020"
GNAF_PATH="/Users/$(whoami)/Downloads/g-naf_aug25_allstates_gda94_psv_1020"
BDYS_PATH="/Users/$(whoami)/Downloads/AUG25_AdminBounds_GDA_94_SHP"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "Run gnaf-loader and locality boundary clean"
echo "---------------------------------------------------------------------------------------------------------------------"

python3 "/Users/$(whoami)/git/minus34/gnaf-loader/load-gnaf.py" --pgport=5432 --pgdb=geo --max-processes=6 --gnaf-tables-path="${GNAF_PATH}" --admin-bdys-path="${BDYS_PATH}"
python3 "/Users/$(whoami)/git/iag_geo/psma-admin-bdys/locality-clean.py" --pgport=5432 --pgdb=geo --max-processes=6 --output-path=${OUTPUT_FOLDER}

# upload locality bdy files to S3
aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER} s3://minus34.com/opendata/geoscape-202508 --exclude "*" --include "*.zip" --acl public-read

echo "---------------------------------------------------------------------------------------------------------------------"
echo "create concordance file"
echo "---------------------------------------------------------------------------------------------------------------------"

# create concordance file and upload to S3

mkdir -p "${OUTPUT_FOLDER}"
python3 "/Users/$(whoami)/git/iag_geo/concord/create_concordance_file.py" --pgdb=geo --output-path=${OUTPUT_FOLDER}
aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER} s3://minus34.com/opendata/geoscape-202508 --exclude "*" --include "*.csv" --acl public-read

# copy concordance score file to GitHub repo local files
cp "${OUTPUT_FOLDER}/boundary_concordance_score.csv" "/Users/$(whoami)/git/iag_geo/concord/data/"

# copy files to GDA2020 local and S3 folders (files not processed for GDA2020 data as the result is 99.99999.....% the same)
mkdir -p "${OUTPUT_FOLDER_2020}"
cp ${OUTPUT_FOLDER}/boundary_concordance.csv ${OUTPUT_FOLDER_2020}/boundary_concordance.csv
cp ${OUTPUT_FOLDER}/boundary_concordance_score.csv ${OUTPUT_FOLDER_2020}/boundary_concordance_score.csv
aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020} s3://minus34.com/opendata/geoscape-202508-gda2020 --exclude "*" --include "*.csv" --acl public-read

echo "---------------------------------------------------------------------------------------------------------------------"
echo "dump postgres schemas to a local folder"
echo "---------------------------------------------------------------------------------------------------------------------"

/Applications/Postgres.app/Contents/Versions/14/bin/pg_dump -Fc -d geo -n gnaf_202508 -p 5432 -U postgres -f "${OUTPUT_FOLDER}/gnaf-202508.dmp" --no-owner
echo "GNAF schema exported to dump file"
/Applications/Postgres.app/Contents/Versions/14/bin/pg_dump -Fc -d geo -n admin_bdys_202508 -p 5432 -U postgres -f "${OUTPUT_FOLDER}/admin-bdys-202508.dmp" --no-owner
echo "Admin Bdys schema exported to dump file"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "copy Postgres dump files to AWS S3 and allow public read access (requires AWSCLI installed & AWS credentials setup)"
echo "---------------------------------------------------------------------------------------------------------------------"

aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER} s3://minus34.com/opendata/geoscape-202508 --exclude "*" --include "*.dmp" --acl public-read
