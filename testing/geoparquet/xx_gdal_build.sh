#!/usr/bin/env bash

# build script for GDAL (with Parquet supported) on MacOS

INSTALL_DIR="/Users/$(whoami)/gdal"

echo "-------------------------------------------------------------------------"
echo "Installing CMake and Apache-Arrow"
echo "-------------------------------------------------------------------------"

# get Homebrew packages
brew update
brew install cmake
brew install apache-arrow

echo "-------------------------------------------------------------------------"
echo "Downloading GDAL source code"
echo "-------------------------------------------------------------------------"

cd ${INSTALL_DIR}

curl -O https://github.com/OSGeo/gdal/releases/download/v3.5.0/gdal-3.5.0.tar.gz
tar xzf gdal-3.5.0.tar.gz
rm gdal-3.5.0.tar.gz

echo "-------------------------------------------------------------------------"
echo "Building GDAL with Parquet supported"
echo "-------------------------------------------------------------------------"

mkdir build
cd build

cmake -DCMAKE_PREFIX_PATH=/usr/local/Cellar/apache-arrow/8.0.0_1/lib  ..
cmake --build .
cmake --build . --target install

#/usr/local/Cellar/apache-arrow/8.0.0_1/lib/cmake/arrow

