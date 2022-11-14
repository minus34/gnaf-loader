#!/usr/bin/env bash

# build script for GDAL (with Parquet supported) on MacOS - doesn't work
# requires Homebrew: https://brew.sh/

# TODO: edit these
GDAL_VERSION="3.6.0"
INSTALL_DIR="/Users/$(whoami)/gdal-${GDAL_VERSION}"
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

#mkdir -p ${INSTALL_DIR}
cd ${HOME}

# WARNING: delete existing source code & build directory
rm -rf ${INSTALL_DIR}

# NOTE: using insecure to allow for man-in-the-middle corporate proxies
curl -O -L --insecure https://github.com/OSGeo/gdal/releases/download/v${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz
tar -xzf gdal-${GDAL_VERSION}.tar.gz
rm gdal-${GDAL_VERSION}.tar.gz

echo "-------------------------------------------------------------------------"
echo "Building GDAL with Parquet support"
echo "-------------------------------------------------------------------------"

mkdir -p ${INSTALL_DIR}/build
cd ${INSTALL_DIR}/build

# TODO: need to edit package version numbers in future
cmake -DCMAKE_PREFIX_PATH="/usr/local/Cellar/apache-arrow/8.0.0_1/lib;/usr/local/Cellar/protobuf/3.19.4;/usr/local/Cellar/openssl@3/3.0.3;/usr/local/Cellar/sqlite/3.38.5" \
      .. | tee ${LOG_DIR}/xx_gdal_build_1.log
cmake --build . | tee ${LOG_DIR}/xx_gdal_build_2.log
cmake --build . --target install | tee ${LOG_DIR}/xx_gdal_build_3.log
