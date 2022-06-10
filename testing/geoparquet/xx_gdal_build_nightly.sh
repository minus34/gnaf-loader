#!/usr/bin/env bash

# build script for GDAL (with Parquet supported) on MacOS
# requires Homebrew: https://brew.sh/

# TODO: edit these
INSTALL_DIR="/Users/$(whoami)/git/osgeo/gdal"
LOG_DIR="/Users/$(whoami)/git/minus34/gnaf-loader/testing/geoparquet"

echo "-------------------------------------------------------------------------"
echo "Installing CMake and prerequisites"
echo "-------------------------------------------------------------------------"

# get Homebrew packages
brew update
brew install openssl cmake apache-arrow protobuf sqlite

echo "-------------------------------------------------------------------------"
echo "Downloading GDAL source code"
echo "-------------------------------------------------------------------------"

cd ${HOME}

# WARNING: delete existing source code & build directory
rm -rf ${INSTALL_DIR}

# get GitHub repo
mkdir -p ${INSTALL_DIR}/..
git clone https://github.com/OSGeo/gdal.git

mkdir -p ${INSTALL_DIR}/build

echo "-------------------------------------------------------------------------"
echo "Building GDAL with Parquet support"
echo "-------------------------------------------------------------------------"

cd ${INSTALL_DIR}/build

# TODO: need to edit package version numbers in future
cmake -DCMAKE_PREFIX_PATH="/usr/local/Cellar/apache-arrow/8.0.0_1/lib;/usr/local/Cellar/protobuf/3.19.4;/usr/local/Cellar/openssl@3/3.0.3;/usr/local/Cellar/sqlite/3.38.5" \
      .. | tee ${LOG_DIR}/xx_gdal_nightly_build_1.log
cmake --build . | tee ${LOG_DIR}/xx_gdal_nightly_build_2.log
cmake --build . --target install | tee ${LOG_DIR}/xx_gdal_nightly_build_3.log
