#!/usr/bin/env bash

# set environment to enable OGR (part of GDAL)
conda activate geo

# Path of postgres executables
POSTGRES_PATH="/Applications/Postgres.app/Contents/Versions/13/bin"

# create an array of state names
declare -a STATES=("ACT" "NSW" "NT" "OT" "QLD" "SA" "TAS" "VIC" "WA")

# how many iterations of each test
TEST_COUNT=5


echo "----------------------------------------------------------------------------------------------------------------"
echo " Start Shapefile to Postgres - OGR test"
echo " Start time : $(date)"
echo "----------------------------------------------------------------------------------------------------------------"

SECONDS=0*

for i in $(seq 1 ${TEST_COUNT});
do
  echo " ROUND ${i} OF ${TEST_COUNT} - total time : ${SECONDS}s"

  for STATE in "${STATES[@]}"
  do
    SHP_PATH="/Users/$(whoami)/Downloads/AUG21_Admin_Boundaries_ESRIShapefileorDBFfile/Localities_AUG21_GDA94_SHP/Localities/Localities AUGUST 2021/Standard/${STATE}_localities.shp"

    if [[ ${STATE} == "ACT" ]]
    then
      echo -n "  - importing ${STATE}"
      ogr2ogr -f "PostgreSQL" -overwrite -nlt MULTIPOLYGON -nln "testing.locality_ogr_${i}" PG:"host=localhost port=5432 dbname=geo user=postgres password=password" "${SHP_PATH}"
    else
      echo -n ", ${STATE}"
      ogr2ogr -f "PostgreSQL" -append -update -nlt MULTIPOLYGON -nln "testing.locality_ogr_${i}" PG:"host=localhost port=5432 dbname=geo user=postgres password=password" "${SHP_PATH}"
    fi
  done

  echo ""
  echo "-------------------------------------------------------------------------"
done

DURATION=${SECONDS}

echo " End time : $(date)"
echo " OGR Test took ${DURATION}s"
echo "----------------------------------------------------------------------------------------------------------------"


echo "----------------------------------------------------------------------------------------------------------------"
echo " Start Shapefile to Postgres - SHP2PGSQL test"
echo " Start time : $(date)"
echo "----------------------------------------------------------------------------------------------------------------"

SECONDS=0*

for i in $(seq 1 ${TEST_COUNT});
do
  echo " ROUND ${i} OF ${TEST_COUNT} - total time : ${SECONDS}s"

  for STATE in "${STATES[@]}"
  do
    SHP_PATH="/Users/$(whoami)/Downloads/AUG21_Admin_Boundaries_ESRIShapefileorDBFfile/Localities_AUG21_GDA94_SHP/Localities/Localities AUGUST 2021/Standard/${STATE}_localities.shp"

    if [[ ${STATE} == "ACT" ]]
    then
      echo "  - importing ${STATE}"
      ${POSTGRES_PATH}/shp2pgsql -d -I -s 4283 -i "${SHP_PATH}" "testing.locality_shp2pgsql_${i}" | psql --quiet --host=localhost --port=5432 --dbname=geo --username=postgres > /dev/null
    else
      echo "  - importing ${STATE}"
      ${POSTGRES_PATH}/shp2pgsql -a -s 4283 -i "${SHP_PATH}" "testing.locality_shp2pgsql_${i}" | psql --quiet --host=localhost --port=5432 --dbname=geo --username=postgres > /dev/null
    fi
  done

  echo ""
  echo "-------------------------------------------------------------------------"
done

DURATION=${SECONDS}

echo " End time : $(date)"
echo " SHP2PGSQL Test took ${DURATION}s"
echo "----------------------------------------------------------------------------------------------------------------"

#    # delete target table or append to it?
#    if delete_table:
#        delete_append_flag = "-d"
#    else:
#        delete_append_flag = "-a"
#
#    # assign coordinate system if spatial, otherwise flag as non-spatial
#    if spatial:
#        spatial_or_dbf_flags = "-s 4283 -I"
#    else:
#        spatial_or_dbf_flags = "-G -n"
#
#    # build shp2pgsql command line
#    shp2pgsql_cmd = "shp2pgsql {0} {1} -i \"{2}\" {3}.{4}"\
#        .format(delete_append_flag, spatial_or_dbf_flags, file_path, pg_schema, pg_table)




