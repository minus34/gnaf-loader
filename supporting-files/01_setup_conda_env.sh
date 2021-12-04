#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------------------

PYTHON_VERSION="3.9"

# --------------------------------------------------------------------------------------------------------------------

echo "-------------------------------------------------------------------------"
echo "Creating new Conda Environment 'geo'"
echo "-------------------------------------------------------------------------"

# update Conda platform
conda update -y conda

# WARNING - removes existing environment
conda env remove --name geo

# Create Conda environment
conda create -y -n geo python=${PYTHON_VERSION}

# activate and setup env
conda activate geo
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict

# reactivate for env vars to take effect
conda activate geo

# install packages for sedona only
conda install -y -c conda-forge gdal pygeos geopandas psycopg2 geoalchemy2 rasterio
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
