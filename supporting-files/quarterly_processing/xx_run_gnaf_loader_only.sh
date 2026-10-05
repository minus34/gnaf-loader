#!/usr/bin/env bash

# need a Python 3.6+ environment with Psycopg (run 01_setup_conda_env.sh to create Conda environment)
conda deactivate
conda activate geo

# ---------------------------------------------------------------------------------------------------------------------
# edit these to taste - NOTE: you can't use "~" for your home folder, Postgres doesn't like it
# ---------------------------------------------------------------------------------------------------------------------

AWS_PROFILE="minus34"
OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202608"
OUTPUT_FOLDER_2020="/Users/$(whoami)/tmp/geoscape_202608_gda2020"
GNAF_PATH="/Users/$(whoami)/Downloads/g-naf_aug26_allstates_gda94_psv_110"
BDYS_PATH="/Users/$(whoami)/Downloads/aug26_adminbounds_gda_94_shp"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "Run gnaf-loader and locality boundary clean"
echo "---------------------------------------------------------------------------------------------------------------------"

python3 "/Users/$(whoami)/git/minus34/gnaf-loader/load-gnaf.py" --pgport=5432 --pgdb=geo --max-processes=6 --gnaf-tables-path="${GNAF_PATH}" --admin-bdys-path="${BDYS_PATH}" \
--gnaf-schema="gnaf_202608_test" --admin-schema="admin_bdys_202608_test" --previous-gnaf-schema="gnaf_202608" --previous-admin-schema="admin_bdys_202608"
