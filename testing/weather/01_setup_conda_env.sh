#!/usr/bin/env bash

SECONDS=0*

echo "-------------------------------------------------------------------------"
echo " Start time : $(date)"

# --------------------------------------------------------------------------------------------------------------------
# Script creates a new Conda environment with AWS, Psycopg, Pandas and BeautifulSoup
# --------------------------------------------------------------------------------------------------------------------

PYTHON_VERSION="3.9"
SPARK_VERSION="3.0.2"

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
echo "y" | conda install -c conda-forge pyspark=${SPARK_VERSION} pyspark-stubs psycopg2 dask geopandas pygeos geoalchemy2 jupyter lux-api pyarrow matplotlib scipy bs4 requests boto3 awscli

# setup lux widget (for automated viz) for Jupyter notebooks
jupyter nbextension install --py luxwidget
jupyter nbextension enable --py luxwidget

# install Apache Sedona
pip install apache-sedona

# experimental - can't load WKT geoms
#pip install git+git://github.com/geopandas/dask-geopandas.git

#scipy descartes

# install pypi packages
#pip install geovoronoi[plotting]


echo "----------------------------------------------------------------------------------------------------------------"

cd ${HOME} || exit

duration=$SECONDS

echo " End time : $(date)"
echo " it took $((duration / 60)) mins"
echo "----------------------------------------------------------------------------------------------------------------"
