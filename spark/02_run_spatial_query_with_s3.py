
# script to load boundary & point data into Spark and run a spatial (point in polygon) query with the data

import boto3
import logging
import os
import sys

from datetime import datetime
from multiprocessing import cpu_count

from pyspark.sql import functions as f
from sedona.spark import *

#######################################################################################################################
# Set your AWS profile name here
#######################################################################################################################

aws_profile = "minus34"

#######################################################################################################################

s3_path = "s3a://minus34.com/opendata/geoscape-202311/geoparquet/"

# number of CPUs to use in processing (defaults to number of local CPUs)
num_processors = cpu_count()


def main():
    start_time = datetime.now()

    # get AWS credentials
    session = boto3.Session(profile_name=aws_profile)
    credentials = session.get_credentials()

    # if using a token
    # aws_token = credentials.token

    frozen_credentials = credentials.get_frozen_credentials()
    aws_access_key = frozen_credentials.access_key
    aws_secret_key = frozen_credentials.secret_key

    # create spark session object
    config = (SedonaContext
              .builder()
              .master("local[*]")
              .appName("Sedona Test")
              .config("spark.sql.session.timeZone", "UTC")
              .config("spark.sql.debug.maxToStringFields", 100)
              .config("spark.sql.adaptive.enabled", "true")
              .config("spark.serializer", KryoSerializer.getName)
              .config("spark.kryo.registrator", SedonaKryoRegistrator.getName)
              .config("spark.executor.cores", 1)
              .config("spark.cores.max", num_processors)
              .config("spark.driver.memory", "16g")
              .config("spark.driver.maxResultSize", "4g")
              .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
              .config("spark.hadoop.fs.s3a.aws.credentials.provider",
                      "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider")
              .config("spark.hadoop.fs.s3a.path.style.access", "true")
              .config("spark.hadoop.fs.s3a.endpoint", "s3.ap-southeast-2.amazonaws.com")
              .config("spark.hadoop.fs.s3a.access.key", aws_access_key)
              .config("spark.hadoop.fs.s3a.secret.key", aws_secret_key)
              .config("spark.hadoop.fs.s3a.aws.credentials.provider",
                      "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider")  # DO NOT use this if using a token
              # .config("spark.hadoop.fs.s3a.session.token", aws_token)  # use this if using a token
              # .config("spark.hadoop.fs.s3a.aws.credentials.provider",
              #         "org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider")  # use this if using a token
              .getOrCreate()
              )

    # Add Sedona functions and types to Spark
    spark = SedonaContext.create(config)

    logger.info("\t - PySpark {} session initiated: {}".format(spark.sparkContext.version, datetime.now() - start_time))
    start_time = datetime.now()

    # load boundaries (geometries are Well Known Text strings)
    bdy_df = spark.read.format("geoparquet").load(os.path.join(s3_path, "local_government_areas"))
    bdy_df = bdy_df.repartition(512, "state")
    # bdy_df.printSchema()
    # bdy_df.show(5)
    print(f"Boundary dataframe has {bdy_df.count()} rows")

    # create view to enable SQL queries
    bdy_df.createOrReplaceTempView("bdy")
    # # create view to enable SQL queries, filtered by state (slows query down!)
    # bdy_df.filter(bdy_df.state == "VIC").createOrReplaceTempView("bdy")

    logger.info(f"\t - Created boundary dataframe : {bdy_df.count():,} rows: {datetime.now() - start_time}")
    start_time = datetime.now()

    # load points (spatial data is lat/long fields)
    point_df = spark.read.format("geoparquet").load(os.path.join(s3_path, "address_principals"))
    point_df = point_df.repartition(512, "state")
    # point_df.printSchema()
    # point_df.show(5)
    print(f"Point dataframe has {point_df.count()} rows")

    # create view to enable SQL queries
    point_df.createOrReplaceTempView("pnt")

    logger.info(f"\t - Created point dataframe : {point_df.count():,} rows : {datetime.now() - start_time}")
    start_time = datetime.now()

    # run spatial join to boundary tag the points
    # notes:
    #   - spatial partitions and indexes for join will be created automatically
    #   - it's an inner join so point records will be lost when they are outside the boundaries
    sql = """SELECT pnt.gnaf_pid,
                    bdy.name as lga_name,
                    bdy.state,
                    pnt.geom
             FROM pnt
             INNER JOIN bdy ON ST_Intersects(pnt.geom, bdy.geom)"""
    join_df = spark.sql(sql)
    # join_df.explain()

    # # output join DataFrame
    # join_df.write.mode("overwrite") \
    #        .format("geoparquet") \
    #        .save(os.path.join(output_path))

    num_joined_points = join_df.count()

    # join_df.printSchema()
    join_df.orderBy(f.rand()).show(5, False)

    logger.info("\t - {:,} points were boundary tagged: {}"
                .format(num_joined_points, datetime.now() - start_time))

    # cleanup
    spark.stop()


if __name__ == "__main__":
    full_start_time = datetime.now()

    # setup logging
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # set Spark logging levels
    logging.getLogger("pyspark").setLevel(logging.ERROR)
    logging.getLogger("py4j").setLevel(logging.ERROR)

    # set logger
    log_file = os.path.abspath(__file__).replace(".py", ".log")
    logging.basicConfig(filename=log_file, level=logging.DEBUG, format="%(asctime)s %(message)s",
                        datefmt="%m/%d/%Y %I:%M:%S %p")

    # setup logger to write to screen as well as writing to log file
    # define a Handler which writes INFO messages or higher to the sys.stderr
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    # set a format which is simpler for console use
    formatter = logging.Formatter("%(name)-12s: %(levelname)-8s %(message)s")
    # tell the handler to use this format
    console.setFormatter(formatter)
    # add the handler to the root logger
    logging.getLogger("").addHandler(console)

    task_name = "Geoparquet Testiong"

    logger.info("{} started".format(task_name))
    logger.info("Running on Python {}".format(sys.version.replace("\n", " ")))

    main()

    time_taken = datetime.now() - full_start_time
    logger.info("{} finished : {}".format(task_name, time_taken))
    print()