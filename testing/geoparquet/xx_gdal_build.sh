#!/usr/bin/env bash

# build script for GDAL (with Parquet supported) on MacOS
# activate Conda so that the latest Python with the same version of GDAL is used (seriously cheating here)
conda deactivate
#conda activate gdal

BUILD_DIR="/Users/$(whoami)/gdal-3.5.0/build"

echo "-------------------------------------------------------------------------"
echo "Installing CMake and prerequisites"
echo "-------------------------------------------------------------------------"

## get Homebrew packages
#brew update
#brew install openssl cmake apache-arrow protobuf sqlite

echo "-------------------------------------------------------------------------"
echo "Downloading GDAL source code"
echo "-------------------------------------------------------------------------"

#mkdir -p ${INSTALL_DIR}
cd ${HOME}

# WARNING: delete existing source code & build directory
rm -rf ../${BUILD_DIR}

curl -O -L https://github.com/OSGeo/gdal/releases/download/v3.5.0/gdal-3.5.0.tar.gz
tar -xzf gdal-3.5.0.tar.gz
rm gdal-3.5.0.tar.gz

echo "-------------------------------------------------------------------------"
echo "Building GDAL with Parquet supported"
echo "-------------------------------------------------------------------------"

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
#cd ..

cmake -DCMAKE_PREFIX_PATH="/usr/local/Cellar/apache-arrow/8.0.0_1/lib;/usr/local/Cellar/protobuf/3.19.4;/usr/local/Cellar/openssl@1.1/1.1.1o;/usr/local/Cellar/sqlite/3.38.5" \
      -DGDAL_USE_OPENCL=ON \
      -DGDAL_USE_GEOTIFF_INTERNAL=ON \
      -DCMAKE_BUILD_TYPE=Release \
      .. | tee /Users/s57405/git/minus34/gnaf-loader/testing/geoparquet/xx_gdal_build_1.log
cmake --build . | tee /Users/s57405/git/minus34/gnaf-loader/testing/geoparquet/xx_gdal_build_2.log
cmake --build . --target install | tee /Users/s57405/git/minus34/gnaf-loader/testing/geoparquet/xx_gdal_build_3.log

#/usr/local/Cellar/apache-arrow/8.0.0_1/lib/cmake/arrow


#cmake -S . -B build -DCMAKE_PREFIX_PATH:FILEPATH="${CONDA_PREFIX}" \
#                    | tee /Users/s57405/git/minus34/gnaf-loader/testing/geoparquet/xx_gdal_build_ver2_1.log
#cmake --build build --config Release -j 8 | tee /Users/s57405/git/minus34/gnaf-loader/testing/geoparquet/xx_gdal_build_ver2_2.log


#cmake -DCMAKE_PREFIX_PATH:FILEPATH="${CONDA_PREFIX}" \
#      .. | tee /Users/s57405/git/minus34/gnaf-loader/testing/geoparquet/xx_gdal_build_1.log
#cmake --build . | tee /Users/s57405/git/minus34/gnaf-loader/testing/geoparquet/xx_gdal_build_2.log
#cmake --build . --target install | tee /Users/s57405/git/minus34/gnaf-loader/testing/geoparquet/xx_gdal_build_3.log


#                    -DCMAKE_C_COMPILER_LAUNCHER=clcache \
#                    -DCMAKE_CXX_COMPILER_LAUNCHER=clcache \
