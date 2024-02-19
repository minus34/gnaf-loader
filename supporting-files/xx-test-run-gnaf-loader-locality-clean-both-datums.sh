#!/usr/bin/env bash

# need a Python 3.6+ environment with Psycopg (run 01_setup_conda_env.sh to create Conda environment)
conda activate geo

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# ---------------------------------------------------------------------------------------------------------------------
# edit these to taste - NOTE: you can't use "~" for your home folder, Postgres doesn't like it
# ---------------------------------------------------------------------------------------------------------------------

AWS_PROFILE="minus34"
OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202402"
GNAF_PATH="/Users/$(whoami)/Downloads/g-naf_feb22_allstates_gda94_psv_105"
BDYS_PATH="/Users/$(whoami)/Downloads/FEB22_AdminBounds_GDA94_SHP"
GNAF_2020_PATH="/Users/$(whoami)/Downloads/g-naf_feb22_allstates_gda2020_psv_105"
BDYS_2020_PATH="/Users/$(whoami)/Downloads/FEB22_AdminBounds_GDA2020_SHP"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "Run gnaf-loader and locality boundary clean"
echo "---------------------------------------------------------------------------------------------------------------------"

python3 /Users/$(whoami)/git/minus34/gnaf-loader/load-gnaf.py --pgport=5432 --pgdb=geo --max-processes=6 --gnaf-tables-path="${GNAF_PATH}" --admin-bdys-path="${BDYS_PATH}" --gnaf-schema gnaf_202402 --admin-schema admin_bdys_202402 --previous-gnaf-schema gnaf_202311 --previous-admin-schema admin_bdys_202311
python3 /Users/$(whoami)/git/iag_geo/psma-admin-bdys/locality-clean.py --pgport=5432 --pgdb=geo --max-processes=6 --output-path=${OUTPUT_FOLDER} --admin-schema admin_bdys_202402

echo "---------------------------------------------------------------------------------------------------------------------"
echo "Run gnaf-loader and locality boundary clean - GDA2020"
echo "---------------------------------------------------------------------------------------------------------------------"

python3 /Users/$(whoami)/git/minus34/gnaf-loader/load-gnaf.py --pgport=5432 --pgdb=geo --max-processes=6 --gnaf-tables-path="${GNAF_2020_PATH}" --admin-bdys-path="${BDYS_2020_PATH}" --srid=7844 --gnaf-schema gnaf_202402_gda2020 --admin-schema admin_bdys_202402_gda2020 --previous-gnaf-schema gnaf_202402 --previous-admin-schema admin_bdys_202402
python3 /Users/$(whoami)/git/iag_geo/psma-admin-bdys/locality-clean.py --pgport=5432 --pgdb=geo --max-processes=6 --output-path=${OUTPUT_FOLDER} --admin-schema admin_bdys_202402_gda2020
