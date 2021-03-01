#!/usr/bin/env bash

SECONDS=0*

echo "-------------------------------------------------------------------------"
echo " Start time : $(date)"

# --------------------------------------------------------------------------------------------------------------------
# Script creates a new Conda environment with AWS, Psycopg, Pandas and BeautifulSoup
# --------------------------------------------------------------------------------------------------------------------

PYTHON_VERSION="3.9"

# --------------------------------------------------------------------------------------------------------------------

echo "-------------------------------------------------------------------------"
echo "Creating new Conda Environment 'minus34'"
echo "-------------------------------------------------------------------------"

# stop the Conda environment currently running
conda deactivate

# WARNING - remove existing environment
conda env remove --name minus34

# update Conda platform
echo "y" | conda update conda

# Create Conda environment
echo "y" | conda create -n minus34 python=${PYTHON_VERSION}

# activate and setup env
conda activate minus34
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict

# reactivate for env vars to take effect
conda activate minus34

# install conda packages
echo "y" | conda install -c conda-forge psycopg2 geopandas matplotlib scipy descartes bs4 boto3 awscli requests

# install pypi packages
pip install geovoronoi[plotting]


echo "----------------------------------------------------------------------------------------------------------------"

cd ${HOME} || exit

duration=$SECONDS

echo " End time : $(date)"
echo " it took $((duration / 60)) mins"
echo "----------------------------------------------------------------------------------------------------------------"
