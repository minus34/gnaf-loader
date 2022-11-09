#!/usr/bin/env bash

mkdir -p ~/tmp/gdal-testing
cd ~/tmp/gdal-testing

#wget https://usbuildingdata.blob.core.windows.net/usbuildings-v2/Utah.geojson.zip
curl https://usbuildingdata.blob.core.windows.net/usbuildings-v2/Utah.geojson.zip --output Utah.geojson.zip

docker run --rm -it -v $(pwd):/data osgeo/gdal:latest \
  ogr2ogr \
  /data/Utah.parquet \
  /vsizip//data/Utah.geojson.zip \
  -dialect SQLite \
  -sql "SELECT geometry FROM 'Utah.geojson'" \
  -lco COMPRESSION=BROTLI \
  -lco GEOMETRY_ENCODING=GEOARROW \
  -lco POLYGON_ORIENTATION=COUNTERCLOCKWISE \
  -lco ROW_GROUP_SIZE=9999999

#ogr2ogr \
#$(pwd)/Utah2.parquet \
#/vsizip/$(pwd)/Utah.geojson.zip \
#-dialect SQLite \
#-sql "SELECT geometry FROM 'Utah.geojson'" \
#-lco COMPRESSION=BROTLI \
#-lco GEOMETRY_ENCODING=GEOARROW \
#-lco POLYGON_ORIENTATION=COUNTERCLOCKWISE \
#-lco ROW_GROUP_SIZE=9999999
