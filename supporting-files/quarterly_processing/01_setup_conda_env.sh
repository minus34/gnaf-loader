#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------------------

PYTHON_VERSION="3.10"

# --------------------------------------------------------------------------------------------------------------------

echo "-------------------------------------------------------------------------"
echo "Creating new Conda Environment 'geo'"
echo "-------------------------------------------------------------------------"

# WARNING - removes existing environment
conda deactivate
conda env remove --name geo

# update Conda platform & install Mamba (much faster package installer)
conda update -y conda
conda update -y -n base conda
conda install -y mamba -n base -c conda-forge

# Create Conda environment
conda create -y -n geo python=${PYTHON_VERSION}

# activate and setup env
conda activate geo
conda env config vars set JAVA_HOME="/usr/local/opt/openjdk@11"
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict

# reactivate for env vars to take effect
conda activate geo

# install geospatial packages
mamba install -y -c conda-forge gdal pygeos pyarrow dask-geopandas openpyxl psycopg2 geoalchemy2 rasterio boto3
conda activate geo

# --------------------------
# extra bits
# --------------------------

## activate env
#conda activate geo

## shut down env
#conda deactivate

## delete env permanently
#conda env remove --name geo
