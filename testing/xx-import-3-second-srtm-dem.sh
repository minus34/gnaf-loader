#!/usr/bin/env bash

# step 1 - make sure Postgres bin folder is in your system PATH

# step 2 - download DEM (~600mb) from:
https://ecat.ga.gov.au/geonetwork/srv/eng/catalog.search#/metadata/69888

# step 4 - unzip download

# step 4 - import into PostGIS with index
psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;"
raster2pgsql -c -I -F -s 4326 -t 128x128 \
/Users/$(whoami)/Downloads/3secSRTM_DEM/DEM_ESRI_GRID_16bit_Integer/dem3s_int/hdr.adf testing.srtm_3s_dem \
| psql -U postgres -d geo -h localhost -p 5432

# step 5 - add elevation to GNAF points - code here: ../postgres-scripts/xx-add-elevation-to-gnaf.sql
