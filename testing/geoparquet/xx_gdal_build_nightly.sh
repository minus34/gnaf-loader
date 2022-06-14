#!/usr/bin/env bash

# build script for GDAL (with Parquet supported) on MacOS
# requires Homebrew: https://brew.sh/

# TODO: edit these
PYTHON_VERSION="3.10"
INSTALL_DIR="/Users/$(whoami)/git/osgeo"
LOG_DIR="/Users/$(whoami)/git/minus34/gnaf-loader/testing/geoparquet"

echo "-------------------------------------------------------------------------"
echo "Installing CMake and prerequisites"
echo "-------------------------------------------------------------------------"

## get Homebrew packages
#brew update
#brew install openssl cmake apache-arrow protobuf sqlite proj tiledb-inc/stable/tiledb

# WARNING - removes existing environment
conda deactivate
conda env remove --name gdal

# update Conda platform & install Mamba (much faster package installer)
conda update -n base conda
conda install -y -c conda-forge mamba -n base

# Create Conda environment
conda create -y -n gdal python=${PYTHON_VERSION}

# activate and setup env
conda activate gdal
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict

# reactivate for env vars to take effect
conda activate gdal

mamba install --yes --quiet curl libiconv icu git swig numpy pytest zlib clcache
#mamba install --yes --quiet -c conda-forge compilers
mamba install --yes --quiet -c conda-forge \
    cmake proj geos protobuf arrow-cpp hdf4 hdf5 \
    libnetcdf openjpeg poppler libtiff libpng xerces-c expat libxml2 kealib json-c \
    cfitsio freexl geotiff jpeg libpq libspatialite libwebp-base pcre postgresql \
    sqlite tiledb zstd charls cryptopp cgal librttopo libkml openssl xz

echo "-------------------------------------------------------------------------"
echo "Downloading GDAL source code"
echo "-------------------------------------------------------------------------"

cd ${HOME}

# WARNING: delete existing source code & build directory
rm -rf "${INSTALL_DIR}/gdal"

# get GitHub repo
mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"
git clone https://github.com/OSGeo/gdal.git

mkdir -p "${INSTALL_DIR}/gdal/build"

echo "-------------------------------------------------------------------------"
echo "Building GDAL with Parquet support"
echo "-------------------------------------------------------------------------"

cd "${INSTALL_DIR}/gdal/build"

# TODO: need to edit package version numbers in future
#cmake -DCMAKE_PREFIX_PATH="/usr/local/Cellar/apache-arrow/8.0.0_1/lib;/usr/local/Cellar/protobuf/3.19.4;/usr/local/Cellar/openssl@3/3.0.3;/usr/local/Cellar/sqlite/3.38.5;/usr/local/Cellar/tiledb/2.5.0" \
#      -DPROJ_INCLUDE_DIR="/usr/local/Cellar/proj/9.0.0_1/include" \
#      -DPython_ROOT=""
#      .. | tee ${LOG_DIR}/xx_gdal_nightly_build_1.log
#cmake --build . | tee ${LOG_DIR}/xx_gdal_nightly_build_2.log
#cmake --build . --target install | tee ${LOG_DIR}/xx_gdal_nightly_build_3.log


cmake .. -DCMAKE_PREFIX_PATH:FILEPATH="%CONDA_PREFIX%" | tee ${LOG_DIR}/xx_gdal_nightly_build_1.log
cmake --build . | tee ${LOG_DIR}/xx_gdal_nightly_build_2.log
cmake --build . --target install | tee ${LOG_DIR}/xx_gdal_nightly_build_3.log
