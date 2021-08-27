#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------------------

PYTHON_VERSION="3.9"

# --------------------------------------------------------------------------------------------------------------------

echo "-------------------------------------------------------------------------"
echo "Creating new Conda Environment 'datashader'"
echo "-------------------------------------------------------------------------"

# update Conda platform
echo "y" | conda update conda

# WARNING - removes existing environment
conda env remove --name datashader

# Create Conda environment
echo "y" | conda create -n datashader python=${PYTHON_VERSION}

# activate and setup env
conda activate datashader
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict

# reactivate for env vars to take effect
conda activate datashader

# install packages
echo "y" | conda install -c conda-forge dask datashader pyarrow psycopg2 geoalchemy2 jupyter
#echo "y" | conda install -c conda-forge geopandas dask pygeos datashader pyarrow psycopg2 geoalchemy2 jupyter
#pip install git+git://github.com/geopandas/dask-geopandas.git

# --------------------------
# extra bits
# --------------------------

## activate env
#conda activate datashader

## shut down env
#conda deactivate

## delete env permanently
#conda env remove --name datashader
