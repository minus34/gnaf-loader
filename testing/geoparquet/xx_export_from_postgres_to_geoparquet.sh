#!/usr/bin/env bash

# - prereqs - add Docker container IP rnage to both Postyres conf and HBA file to allow access to localhost database

## need a Python 3.9+ environment with GDAL 3.6.0 and PyArrow
#conda deactivate
#conda activate geo

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OUTPUT_FOLDER="/Users/$(whoami)/tmp/gdal-testing"
mkdir -p "${OUTPUT_FOLDER}"
cd "${OUTPUT_FOLDER}"


# get list of tables to export
rm tables.txt

for input_schema in "admin_bdys_202208" "gnaf_202208"
do
  QUERY="SELECT concat(table_schema, '.', table_name)
         FROM information_schema.tables
         WHERE table_schema='${input_schema}'
           AND table_type='BASE TABLE'
           AND table_name <> 'qa'
           AND table_name NOT LIKE '%_2011_%'
           AND table_name NOT LIKE '%_analysis%'
           AND table_name NOT LIKE '%_display%';"

  psql -d geo -p 5432 -U postgres -t -A -c "${QUERY}" >> tables.txt
done


# convert Postgres tables to GeoParquet
while read p; do
  # split schema and table name
  arrIN=(${p//./ })
  input_schema=${arrIN[0]}
  input_table=${arrIN[1]}

  echo "Exporting ${input_table}"

  docker run --rm -it -v $(pwd):/data osgeo/gdal:ubuntu-full-3.6.0 \
    ogr2ogr \
    "/data/${input_table}.parquet" \
    PG:"host='host.docker.internal' dbname='geo' user='postgres' password='password' port='5432'" \
    "${input_schema}.${input_table}(geom)" \
    -lco COMPRESSION=BROTLI \
    -lco GEOMETRY_ENCODING=GEOARROW \
    -lco POLYGON_ORIENTATION=COUNTERCLOCKWISE \
    -lco ROW_GROUP_SIZE=9999999

done < tables.txt
