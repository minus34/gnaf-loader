#!/usr/bin/env bash

# NOTE: requires GDAL to be installed

# set this to taste - NOTE: you can't use "~" for your home folder
output_folder="/Users/$(whoami)/tmp"

# full addresses
ogr2ogr -f FlatGeobuf ${output_folder}/address-principals-202205.fgb \
PG:"host=localhost dbname=geo user=postgres password=password port=5432" "gnaf_202205.address_principals(geom)"

# just GNAF PIDs and point geometries
ogr2ogr -f FlatGeobuf ${output_folder}/address-principals-lite-202102.fgb \
PG:"host=localhost dbname=geo user=postgres password=password port=5432" -sql "select gnaf_pid, ST_Transform(geom, 4326) as geom from gnaf_202102.address_principals"

# display locality boundaries
ogr2ogr -f FlatGeobuf ${output_folder}/address-principals-202205.fgb \
PG:"host=localhost dbname=geo user=postgres password=password port=5432" "admin_bdys_202205.locality_bdys_display(geom)"

# OPTIONAL - copy files to AWS S3 and allow public read access (requires AWSCLI installed and your AWS credentials setup)
cd ${output_folder}

for f in *-202205.fgb;
  do
    aws --profile=default s3 cp --storage-class REDUCED_REDUNDANCY ./${f} s3://minus34.com/opendata/geoscape-202205/flatgeobuf/${f};
    aws --profile=default s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/geoscape-202205/flatgeobuf/${f}
    echo "${f} uploaded to AWS S3"
  done
