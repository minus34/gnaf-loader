#!/usr/bin/env bash

conda activate sedona

# --------------------------------------------------------------------------------------------------------------------
# create the GNAF and admin bdy Geoparquet and Parquet (for non-spatial tables) files
# --------------------------------------------------------------------------------------------------------------------

#spark-submit /Users/$(whoami)/git/minus34/gnaf-loader/spark/xx_export_gnaf_and_admin_bdys_to_geoparquet.py

# --------------------------------------------------------------------------------------------------------------------
# run test query to boundary tag 12M GNAF addresses with Local Government Area IDs - takes 3-5 mins
# --------------------------------------------------------------------------------------------------------------------

spark-submit /Users/$(whoami)/git/minus34/gnaf-loader/spark/02_run_spatial_query_with_s3.py