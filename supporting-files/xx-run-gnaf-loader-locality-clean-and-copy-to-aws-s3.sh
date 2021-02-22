#!/usr/bin/env bash

# set these to taste - NOTE: you can't use "~" for your home folder
output_folder="/Users/s57405/tmp"
gnaf_path="/Users/s57405/Downloads/nov20_gnaf_pipeseparatedvalue/G-NAF"
bdys_path="/Users/s57405/Downloads/feb21_adminbounds_esrishapefileordbffile/Administrative Boundaries"

# run gnaf-loader
python3 /Users/s57405/git/minus34/gnaf-loader/load-gnaf.py --pgdb=geo --max-processes=4 --gnaf-tables-path="${gnaf_path}" --admin-bdys-path="${bdys_path}"

# run locality clean
python3 /Users/s57405/git/iag_geo/psma-admin-bdys/locality-clean.py --output-path=${output_folder}

# dump postgres schemas to a local folder
/Applications/Postgres.app/Contents/Versions/12/bin/pg_dump -Fc -d geo -n gnaf_202102 -p 5432 -U postgres -f "${output_folder}/gnaf-202102.dmp" --no-owner
echo "GNAF schema exported to dump file"
/Applications/Postgres.app/Contents/Versions/12/bin/pg_dump -Fc -d geo -n admin_bdys_202102 -p 5432 -U postgres -f "${output_folder}/admin-bdys-202102.dmp" --no-owner
echo "Admin Bdys schema exported to dump file"

# OPTIONAL - copy files to AWS S3 and allow public read access (requires AWSCLI installed and your AWS credentials setup)
aws_profile="default"

cd "${output_folder}" || exit

for f in *-202102.dmp;
  do
    aws --profile=${aws_profile} s3 cp --storage-class REDUCED_REDUNDANCY "./${f}" s3://minus34.com/opendata/psma-202102/${f};
    aws --profile=${aws_profile} s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/psma-202102/${f}
    echo "${f} uploaded to AWS S3"
  done

# OPTIONAL - create parquet version of GNAF and Admin Bdys and upload to AWS S3
. ../spark/01_setup_pyspark_3.sh
python ../spark/02_export_gnaf_and_admin_bdys_to_s3.py
