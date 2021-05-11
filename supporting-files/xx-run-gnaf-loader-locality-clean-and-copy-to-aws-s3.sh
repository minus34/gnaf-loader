#!/usr/bin/env bash

# ---------------------------------------------------------------------------------------------------------------------
# edit these to taste - NOTE: you can't use "~" for your home folder, Postgres doesn't like it
# ---------------------------------------------------------------------------------------------------------------------

output_folder="/Users/$(whoami)/tmp"
gnaf_path="/Users/$(whoami)/Downloads/FEB21_GNAF_PipeSeparatedValue_20210522101749/G-NAF"
bdys_path="/Users/$(whoami)/Downloads/FEB21_AdminBounds_ESRIShapefileorDBFfile/Administrative Boundaries"

# ---------------------------------------------------------------------------------------------------------------------

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# ---------------------------------------------------------------------------------------------------------------------
# Run gnaf-loader and locality boundary clean
# ---------------------------------------------------------------------------------------------------------------------

python3 /Users/$(whoami)/git/minus34/gnaf-loader/load-gnaf.py --pgport=5432 --pgdb=geo --max-processes=4 --gnaf-tables-path="${gnaf_path}" --admin-bdys-path="${bdys_path}"
python3 /Users/$(whoami)/git/iag_geo/psma-admin-bdys/locality-clean.py --pgport=5432 --pgdb=geo --max-processes=4 --output-path=${output_folder}

# ---------------------------------------------------------------------------------------------------------------------
# dump postgres schemas to a local folder
# ---------------------------------------------------------------------------------------------------------------------

/Applications/Postgres.app/Contents/Versions/12/bin/pg_dump -Fc -d geo -n gnaf_202105 -p 5432 -U postgres -f "${output_folder}/gnaf-202105.dmp" --no-owner
echo "GNAF schema exported to dump file"
/Applications/Postgres.app/Contents/Versions/12/bin/pg_dump -Fc -d geo -n admin_bdys_202105 -p 5432 -U postgres -f "${output_folder}/admin-bdys-202105.dmp" --no-owner
echo "Admin Bdys schema exported to dump file"

# ---------------------------------------------------------------------------------------------------------------------
# copy Postgres dump files to AWS S3 and allow public read access (requires AWSCLI installed & AWS credentials setup)
# ---------------------------------------------------------------------------------------------------------------------

aws_profile="default"

cd "${output_folder}" || exit

for f in *-202105.dmp;
  do
    aws --profile=${aws_profile} s3 cp --storage-class REDUCED_REDUNDANCY "./${f}" s3://minus34.com/opendata/psma-202105/${f};
    aws --profile=${aws_profile} s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/psma-202105/${f}
    echo "${f} uploaded to AWS S3"
  done

# ---------------------------------------------------------------------------------------------------------------------
# create parquet versions of GNAF and Admin Bdys and upload to AWS S3
# ---------------------------------------------------------------------------------------------------------------------

. ${SCRIPT_DIR}/../spark/01_setup_pyspark_3.sh
python ${SCRIPT_DIR}/../spark/02_export_gnaf_and_admin_bdys_to_s3.py
