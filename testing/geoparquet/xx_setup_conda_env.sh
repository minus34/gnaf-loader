#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------------------

PYTHON_VERSION="3.10"

# --------------------------------------------------------------------------------------------------------------------

echo "-------------------------------------------------------------------------"
echo "Creating new Conda Environment 'gdal'"
echo "-------------------------------------------------------------------------"

# WARNING - removes existing environment
conda deactivate
conda env remove --name gdal

# update Conda platform & install Mamba (much faster package installer)
conda update -y conda
conda install -y -c conda-forge mamba -n base

# Create Conda environment
conda create -y -n gdal python=${PYTHON_VERSION}

# activate and setup env
conda activate gdal
conda env config vars set JAVA_HOME="/usr/local/opt/openjdk@11"
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict

# reactivate for env vars to take effect
conda activate gdal

# install packages for gdal only
mamba install -y -c conda-forge gdal psycopg pyarrow boto3 importlib_resources

## install packages for gdal build
#mamba install -y -c conda-forge curl libiconv icu swig numpy pytest zlib
##mamba install -y -c conda-forge compilers
#mamba install -y -c conda-forge cmake proj geos hdf4 hdf5 \
#                                libnetcdf openjpeg poppler libtiff libpng xerces-c expat libxml2 kealib json-c \
#                                cfitsio freexl geotiff jpeg libpq libspatialite libwebp-base pcre postgresql \
#                                sqlite tiledb zstd charls cryptopp cgal librttopo libkml openssl xz arrow-cpp gdal

conda activate gdal

echo "-------------------------------------------------------------------------"
echo "Download Geoparquet GitHub repo"
echo "-------------------------------------------------------------------------"

mkdir -p ${GIT_HOME}/osgeo
cd ${GIT_HOME}/osgeo
git clone https://github.com/opengeospatial/geoparquet.git

cd cd geoparquet/validator/python

# install geoparquet validator
pip install --no-binary geoparquet_validator .

# sample usage
#geoparquet_validator /Users/s57405/tmp/geoscape_202211/geoparquet/address_principals.parquet

# --------------------------
# extra bits
# --------------------------

## activate env
#conda activate gdal

## shut down env
#conda deactivate

## delete env permanently
#conda env remove --name gdal
