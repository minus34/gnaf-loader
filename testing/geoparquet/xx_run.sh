#!/usr/bin/env bash

## need a Python 3.9+ environment with Psycopg2 and PyArrow
#conda deactivate
#conda activate gdal

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OUTPUT_FOLDER="/Users/$(whoami)/tmp/geoscape_202205"

INPUT_SCHEMA="gnaf_202205"

## get list of tables
#QUERY="SELECT table_name
#       FROM information_schema.tables
#       WHERE table_schema='${INPUT_SCHEMA}'
#         AND table_type='BASE TABLE'
#         AND table_name <> 'qa'
#         AND table_name NOT LIKE '%_2011_%'
#         AND table_name NOT LIKE '%_analysis%'
#         AND table_name NOT LIKE '%_display%'"
#
#psql -d geo -p 5432 -U postgres -c "${QUERY};"

#                table_name
#------------------------------------------
# address_principals
# localities
# address_aliases
# streets
# street_aliases
# locality_aliases
# address_secondary_lookup
# address_alias_lookup
# locality_neighbour_lookup
# address_principal_admin_boundaries
# address_alias_admin_boundaries
# qa_comparison
# address_principal_census_2016_boundaries
# address_principal_census_2021_boundaries
# boundary_concordance
# boundary_concordance_score
#(16 rows)

INPUT_TABLE="address_principals"

/usr/local/bin/ogr2ogr -f Parquet "${OUTPUT_FOLDER}/geoparquet/${INPUT_TABLE}.parquet" \
    PG:"host=localhost dbname=geo user=postgres password=password port=5432" \
    "${INPUT_SCHEMA}.${INPUT_TABLE}(geom)"

#ogr2ogr -f "PostgreSQL" -overwrite -nlt ${GEOM_TYPE} -nln "${INPUT_SCHEMA}.${INPUT_TABLE}" PG:"host=localhost port=5432 dbname=geo user=postgres password=password" "${OUTPUT_FOLDER}/geoparquet/${INPUT_TABLE}.parquet"



#ogr2ogr -f "PostgreSQL" -overwrite -nlt MULTIPOLYGON -nln "${INPUT_SCHEMA}.address_principals" PG:"host=localhost port=5432 dbname=geo user=postgres password=password" "${OUTPUT_FOLDER}/geoparquet"







#python ${SCRIPT_DIR}/export_gnaf_and_admin_bdys_to_geoparquet.py --admin-schema="admin_bdys_202205" --gnaf-schema="gnaf_202205" --output-path="${OUTPUT_FOLDER}/geoparquet"





