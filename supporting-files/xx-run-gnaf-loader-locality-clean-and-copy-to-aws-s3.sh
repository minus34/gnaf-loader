#!/usr/bin/env bash

# set these to taste - NOTE: you can't use "~" for your home folder
output_folder="/Users/hugh.saalmans/tmp"
gnaf_path="/Users/hugh.saalmans/Downloads/NOV19_GNAF_PipeSeparatedValue"
bdys_path="/Users/hugh.saalmans/Downloads/NOV19_AdminBounds_ESRIShapefileorDBFfile"

# run gnaf-loader
python3 /Users/hugh.saalmans/git/minus34/gnaf-loader/load-gnaf.py --pgdb=geo --raw-fk --max-processes=4 --gnaf-tables-path=${gnaf_path} --admin-bdys-path=${bdys_path}

# run locality clean
python3 /Users/hugh.saalmans/git/iag_geo/psma-admin-bdys/locality-clean.py --output-path=${output_folder}

# dump postgres schemas to a local folder
/Applications/Postgres.app/Contents/Versions/11/bin/pg_dump -Fc -d geo -n gnaf_202002 -p 5432 -U postgres -f ${output_folder}/gnaf-202002.dmp --no-owner
echo "GNAF schema exported to dump file"
/Applications/Postgres.app/Contents/Versions/11/bin/pg_dump -Fc -d geo -n admin_bdys_202002 -p 5432 -U postgres -f ${output_folder}/admin-bdys-202002.dmp --no-owner
echo "Admin Bdys schema exported to dump file"

# OPTIONAL - copy files to AWS S3 and allow public read access (requires AWSCLI installed and your AWS credentials setup)
aws_profile="default"

cd ${output_folder}

for f in *-202002.dmp;
  do
    aws --profile=${aws_profile} s3 cp --storage-class REDUCED_REDUNDANCY ./${f} s3://minus34.com/opendata/psma-202002/${f};
    aws --profile=${aws_profile} s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/psma-202002/${f}
    echo "${f} uploaded to AWS S3"
  done
