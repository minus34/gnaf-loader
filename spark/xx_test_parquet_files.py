# ---------------------------------------------------------------------------------------------------------------------
#
# script to import each GNAF & administrative boundary table from Postgres & export as GZIPped Parquet files to AWS S3
#
# PROCESS
#
# 1. get list of tables from Postgres
# 2. for each table:
#     a. import into Spark dataframe
#     b. export as gzip parquet files to local disk
#     c. copy files to S3
#
# note: direct export from Spark to S3 isn't used to avoid Hadoop install and config
#
# ---------------------------------------------------------------------------------------------------------------------

# import boto3
import logging
import math
import os
import psycopg2
import sys

# from boto3.s3.transfer import TransferConfig
from datetime import datetime
from multiprocessing import cpu_count

from pyspark.sql import SparkSession, functions as f
from sedona.register import SedonaRegistrator
from sedona.utils import SedonaKryoRegistrator, KryoSerializer

# set number of parallel processes (sets number of Spark executors and concurrent Postgres JDBC connections)
num_processors = cpu_count()

# parqet dataset to check
input_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "data", "abs_2016_mb")


def main():
    start_time = datetime.now()

    # ----------------------------------------------------------
    # create Spark session and context
    # ----------------------------------------------------------

    spark = (SparkSession
             .builder
             .master("local[*]")
             .appName("gnaf-loader export")
             .config("spark.sql.session.timeZone", "UTC")
             .config("spark.sql.debug.maxToStringFields", 100)
             .config("spark.serializer", KryoSerializer.getName)
             .config("spark.kryo.registrator", SedonaKryoRegistrator.getName)
             .config("spark.jars.packages",
                     'org.apache.sedona:sedona-python-adapter-3.0_2.12:1.0.1-incubating,'
                     'org.datasyslab:geotools-wrapper:geotools-24.1')
             .config("spark.sql.adaptive.enabled", "true")
             .config("spark.executor.cores", 1)
             .config("spark.cores.max", num_processors)
             .config("spark.driver.memory", "8g")
             .config("spark.driver.maxResultSize", "1g")
             .getOrCreate()
             )

    # Add Sedona functions and types to Spark
    SedonaRegistrator.registerAll(spark)

    print("\t - PySpark {} session initiated: {}".format(spark.sparkContext.version, datetime.now() - start_time))
    start_time = datetime.now()

    # get row count
    df = spark.read.parquet(input_path)

    print("{} has {} rows : {}".format(input_path, df.count(), datetime.now() - start_time))


    spark.stop()


if __name__ == "__main__":
    full_start_time = datetime.now()

    main()

    time_taken = datetime.now() - full_start_time
    print("Finished : {}".format(time_taken))
    print()
