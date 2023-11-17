#!/usr/bin/env bash

SECONDS=0*

echo "-------------------------------------------------------------------------"
echo "Start time : $(date)"

# --------------------------------------------------------------------------------------------------------------------
# Script installs Apache Sedona & Apache Spark locally on a Mac, self-contained in a Conda environment
# --------------------------------------------------------------------------------------------------------------------
#
# Author: Hugh Saalmans, IAG Strategy & Innovation
# Date: 2020-09-25
#
# WARNINGS:
#   - Removes existing 'sedona' Conda environment
#
# PRE_REQUISITES:
#   1. Java 11 OpenJDK is installed using Homebrew: brew install openjdk@11
#   2. JAVA_HOME is set as an environment variable: export JAVA_HOME=/opt/homebrew/opt/openjdk@11 (if installed via brew)
#   3. Miniconda is installed in the default directory ($HOME/opt/miniconda3). Get the installer here:
#        - Intel: https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.pkg
#        - M1/M2: https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.pkg
#
# ISSUES:
#   1. Conda environment variables aren't accessible in IntelliJ/Pycharm due to a missing feature
#        - Sedona Python scripts will fail in IntelliJ/Pycharm as Spark env vars aren't set (e.g. $SPARK_HOME)
#
# --------------------------------------------------------------------------------------------------------------------
#
# SETUP:
#   - edit these if it's now the future and versions have changed
#

ENV_NAME=sedona

PYTHON_VERSION="3.11"
SPARK_VERSION="3.4.1"  # uncomment to install specific version of Spark
SPARK_MINOR_VERSION="3.4"  # required to get the correct Sedona Spark shaded JAR (must match latest version here: https://repo1.maven.org/maven2/org/apache/sedona/)
SEDONA_VERSION="1.5.0"
SCALA_VERSION="2.12"  # leave at 2.12 until PySpark in Pypi moves to 2.13
#TEMP_WRAPPER_VERSION="1.5.0"  # required when GeoTools Wrapper points to an old version of Sedona
GEOTOOLS_VERSION="28.2"
POSTGRES_JDBC_VERSION="42.6.0"

# --------------------------------------------------------------------------------------------------------------------

# get the directory this script is running from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# this assumes miniconda is installed in the default directory on linux/MacOS
SPARK_HOME_DIR="${HOME}/miniconda3/envs/${ENV_NAME}/lib/python${PYTHON_VERSION}/site-packages/pyspark"

cd ${HOME}

echo "-------------------------------------------------------------------------"
echo "Creating new Conda Environment '${ENV_NAME}'"
echo "-------------------------------------------------------------------------"

# deactivate current environment and start base env (in case you just deactivated it) - lazy method
conda deactivate
conda activate base

# WARNING - removes existing environment
conda env remove --name ${ENV_NAME}

# update Conda base environment
conda update -y conda

# Create Conda environment
conda create -y -n ${ENV_NAME} python=${PYTHON_VERSION}

# add environment variables for Pyspark
conda env config vars set SPARK_HOME="${SPARK_HOME_DIR}"
conda env config vars set SPARK_LOCAL_IP="127.0.0.1"
conda env config vars set SPARK_LOCAL_DIRS="${HOME}/tmp/spark"
conda env config vars set PYTHONPATH="${HOME}/miniconda3/envs/${ENV_NAME}/bin/python${PYTHON_VERSION}"
conda env config vars set PYSPARK_PYTHON="${PYTHONPATH}"
conda env config vars set PYSPARK_DRIVER_PYTHON="${HOME}/miniconda3/envs/${ENV_NAME}/bin/ipython3"
conda env config vars set PYLIB="${SPARK_HOME_DIR}/python/lib"

# reactivate for env vars to take effect
conda activate ${ENV_NAME}

## install Mamba (faster package installer)
#conda install -y -c conda-forge mamba

# install supporting & useful packages
conda install -y -c conda-forge psycopg sqlalchemy geoalchemy2 geopandas pyarrow jupyter matplotlib

# OPTIONAL - AWS Packages
conda install -y -c conda-forge boto3 s3fs

echo "-------------------------------------------------------------------------"
echo "Install Pyspark with Apache Sedona"
echo "-------------------------------------------------------------------------"

if [ -z ${SPARK_VERSION+x} ];
  then
     # includes full Apache Spark install -- latest version of Sedona and latest supported version of Spark
     pip install apache-sedona[spark] pydeck keplergl;
  else
    # install specific version of Spark with the latest Sedona
    pip install pyspark==${SPARK_VERSION} apache-sedona pydeck keplergl;
fi

# create folder for Spark temp files
mkdir -p ${HOME}/tmp/spark

echo "-------------------------------------------------------------------------"
echo "Downloading additional JAR files"
echo "-------------------------------------------------------------------------"

cd ${SPARK_HOME_DIR}/jars

# add Apache Sedona Python shaded JAR and GeoTools
curl -O https://repo1.maven.org/maven2/org/apache/sedona/sedona-spark-shaded-${SPARK_MINOR_VERSION}_${SCALA_VERSION}/${SEDONA_VERSION}/sedona-spark-shaded-${SPARK_MINOR_VERSION}_${SCALA_VERSION}-${SEDONA_VERSION}.jar
curl -O https://repo1.maven.org/maven2/org/datasyslab/geotools-wrapper/${SEDONA_VERSION}-${GEOTOOLS_VERSION}/geotools-wrapper-${SEDONA_VERSION}-${GEOTOOLS_VERSION}.jar

## required when GeoTools Wrapper points to an old version of Sedona
#curl -O https://repo1.maven.org/maven2/org/datasyslab/geotools-wrapper/${TEMP_WRAPPER_VERSION}-${GEOTOOLS_VERSION}/geotools-wrapper-${TEMP_WRAPPER_VERSION}-${GEOTOOLS_VERSION}.jar

## missing additional logging JAR - doesn't fix logging warning on Spark startup
#curl -O https://repo1.maven.org/maven2/org/slf4j/slf4j-simple/2.0.9/slf4j-simple-2.0.9.jar

# add Postgres JDBC driver to Spark (optional - included for running xx_prep_abs_boundaries.py)
curl -O https://jdbc.postgresql.org/download/postgresql-${POSTGRES_JDBC_VERSION}.jar

# get hadoop & aws-java-sdk JAR files (optional - required for accessing AWS S3) -- versions may need updating
curl -O https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar  # has to be the version used to compile the Hadoop JARs below (check with Maven)
curl -O https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar  # must match Spark's current supported version (see Spark JARs folder)
curl -O https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.4/hadoop-common-3.3.4.jar  # must match Spark's current supported version (see Spark JARs folder)
curl -O https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client/3.3.4/hadoop-client-3.3.4.jar  # must match Spark's current supported version (see Spark JARs folder)

# get Google Storage connector shaded JAR (optional - required for accessing GCP Storage) -- versions may need updating
#curl -O https://search.maven.org/remotecontent?filepath=com/google/cloud/bigdataoss/gcs-connector/hadoop3-2.2.0/gcs-connector-hadoop3-2.2.0-shaded.jar

## Snowflake JDBC driver
#curl -O https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.14.2/snowflake-jdbc-3.14.2.jar

## copy Greenplum JDBC driver (must be downloaded manually after logging into VMWare site)
#cp ${HOME}/Downloads/greenplum-connector-apache-spark-scala_2.13-2.1.0/greenplum-connector-apache-spark-scala_2.13-2.1.0.jar .

echo "-------------------------------------------------------------------------"
echo "Verify Apache Spark and Sedona versions"
echo "-------------------------------------------------------------------------"

# bug in current miniconda? - requires env reactivation now
conda deactivate
conda activate ${ENV_NAME}

${SPARK_HOME_DIR}/bin/spark-submit --version

echo "---------------------------------------"
pip list | grep "spark"
echo "---------------------------------------"
pip list | grep "sedona"
echo "---------------------------------------"
echo ""

echo "-------------------------------------------------------------------------"
echo "Run test Sedona script to prove everything is working"
echo "-------------------------------------------------------------------------"

python ${SCRIPT_DIR}/02_run_spatial_query.py

echo "----------------------------------------------------------------------------------------------------------------"

# clear cache (builds over time)
echo "Conda Cleanup"
conda clean -y --all

echo "----------------------------------------------------------------------------------------------------------------"

cd ${SCRIPT_DIR}

duration=$SECONDS

echo "End time : $(date)"
echo "  - it took $((duration / 60)) mins"
echo "----------------------------------------------------------------------------------------------------------------"
