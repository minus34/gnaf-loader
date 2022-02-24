#!/usr/bin/env bash

AWS_PROFILE="default"
OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202202"
OUTPUT_FOLDER_2020="/Users/$(whoami)/tmp/geoscape_202202_gda2020"


aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER} s3://minus34.com/opendata/geoscape-202202 --exclude "*" --include "*.dmp" --acl public-read

aws --profile=${AWS_PROFILE} s3 sync ${OUTPUT_FOLDER_2020} s3://minus34.com/opendata/geoscape-202202-gda2020 --exclude "*" --include "*.dmp" --acl public-read
