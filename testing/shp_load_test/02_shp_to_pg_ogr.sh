#!/usr/bin/env bash

# set environment to enable OGR (part of GDAL)
conda activate geo

echo "----------------------------------------------------------------------------------------------------------------"
echo " Start Shapefile to Postgres - OGR test"
echo " Start time : $(date)"
echo "----------------------------------------------------------------------------------------------------------------"

SECONDS=0*

# create an array of state names
declare -a STATES=("ACT" "NSW" "NT" "OT" "QLD" "SA" "TAS" "VIC" "WA")

for i in $(seq 1 5);
do
  echo " ROUND ${i} OF 5"

  for STATE in "${STATES[@]}"
  do
    SHP_PATH="/Users/s57405/Downloads/AUG21_Admin_Boundaries_ESRIShapefileorDBFfile/Localities_AUG21_GDA94_SHP/Localities/Localities AUGUST 2021/Standard/${STATE}_localities.shp"

    if [[ ${STATE} == "ACT" ]]
    then
      echo -n "  - importing ${STATE}"
      ogr2ogr -f "PostgreSQL" -overwrite -nln testing.locality PG:"host=localhost port=5432 dbname=geo user=postgres password=password" "${SHP_PATH}"
    else
      echo -n ", ${STATE}"
      ogr2ogr -f "PostgreSQL" -append -update -nln testing.locality PG:"host=localhost port=5432 dbname=geo user=postgres password=password" "${SHP_PATH}"
    fi
  done

  echo ""
done

duration=$SECONDS

echo "-------------------------------------------------------------------------"
echo " End time : $(date)"
echo " Test took ${duration} seconds"
echo "----------------------------------------------------------------------------------------------------------------"
