#!/usr/bin/env bash

# set environment to enable OGR (part of GDAL)
conda activate geo

echo "----------------------------------------------------------------------------------------------------------------"
echo " Start Shapefile to Postgres - OGR test"
echo " Start time : $(date)"
echo "----------------------------------------------------------------------------------------------------------------"

SECONDS=0*

STATE="ACT"
SHP_PATH="/Users/s57405/Downloads/AUG21_Admin_Boundaries_ESRIShapefileorDBFfile/Localities_AUG21_GDA94_SHP/Localities/Localities AUGUST 2021/Standard/${STATE}_localities.shp"

ogr2ogr -overwrite -f "PostgreSQL" -nln locality -lco SCHEMA=testing PG:"host=localhost port=5432 dbname=geo user=postgres password=password" "${SHP_PATH}"


duration=$SECONDS

echo "-------------------------------------------------------------------------"
echo " End time : $(date)"
echo " Test took ${duration} seconds"
echo "----------------------------------------------------------------------------------------------------------------"




#ogr2ogr -f PostgreSQL PG:dbname=destination_db   input_polygons.shp \
#        -nln destination_table  -update  -append  -t_srs "EPSG:4326" \
#        -sql "SELECT *, row_to_json(input_polygons) as attributes from input_polygons"