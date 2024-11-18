# ---------------------------------------------------------------------------------------------------------------------
#
# script to import each GNAF & admin boundary table from Postgres & export as GepParquet or Parquet files to AWS S3
#
# PROCESS
#
# 1. get list of tables from Postgres
# 2. for each table:
#     a. import into Spark dataframe
#     b. export as geoparquet/parquet files to local disk
#     c. copy files to S3
#
# note: direct export from Spark to S3 isn't used to avoid Hadoop install and config
#
# ---------------------------------------------------------------------------------------------------------------------

import argparse
# import boto3
import logging
import math
import os
import psycopg
import sys

# from boto3.s3.transfer import TransferConfig  # S3 transfer disabled as AWS CLI sync is much faster
from datetime import datetime
from multiprocessing import cpu_count
from pathlib import Path

# from pyspark.sql import functions as f
from sedona.spark import *

# setup logging - code is here to prevent conflict with logging.basicConfig() from one of the imports below
log_file = os.path.abspath(__file__).replace(".py", ".log")
logging.basicConfig(filename=log_file, level=logging.DEBUG, format="%(asctime)s %(message)s",
                    datefmt="%m/%d/%Y %I:%M:%S %p")

# set number of parallel processes (sets number of Spark executors and concurrent Postgres JDBC connections)
num_processors = cpu_count()


# set postgres connection parameters
def get_password(connection_name):
    # get credentials from local file
    passwords_file_path = os.path.join(os.environ["GIT_HOME"], "passwords.ini")

    if os.path.exists(passwords_file_path):
        passwords_file = open(passwords_file_path,'r').read().splitlines()
        passwords_file = [i for i in passwords_file if len(i) != 0]  # remove empty lines
        passwords_file = [i for i in passwords_file if i[0] != "#"]  # remove comment lines

        params = dict()
        for ini in passwords_file:
            params[ini.split()[0].rstrip().lstrip()] = ini.split(':=')[1].rstrip().lstrip()

        return dict(item.split("|") for item in params[connection_name].split(","))


pg_settings = get_password("localhost_super")

# create Postgres JDBC url
jdbc_url = "jdbc:postgresql://{HOST}:{PORT}/{DB}".format(**pg_settings)

# get connect string for psycopg
pg_connect_string = "dbname={DB} host={HOST} port={PORT} user={USER} password={PASS}".format(**pg_settings)

# # aws details
# s3_bucket = "minus34.com"
# s3_folder = "opendata/geoscape-202411/geoparquet"

# get runtime arguments
parser = argparse.ArgumentParser(description="Converts Postgres/PostGIS tables to Parquet files with WKT geometries.")

parser.add_argument("--gnaf-schema", help="Input schema name for GNAF tables.")
parser.add_argument("--admin-schema", help="Input schema name for admin boundary tables.")
parser.add_argument("--output-path", help="Output path for Parquet files.")


def main():
    start_time = datetime.now()

    # get settings
    args = parser.parse_args()
    output_path = args.output_path
    schema_names = [args.gnaf_schema, args.admin_schema]

    # create output path (if required)
    Path(output_path).mkdir(parents=True, exist_ok=True)

    # ----------------------------------------------------------
    # create Spark session and context
    # ----------------------------------------------------------

    # create spark session object
    config = (SedonaContext
              .builder()
              .master("local[*]")
              .appName("gnaf-loader export")
              .config("spark.sql.session.timeZone", "UTC")
              .config("spark.sql.debug.maxToStringFields", 100)
              .config("spark.sql.adaptive.enabled", "true")
              .config("spark.serializer", KryoSerializer.getName)
              .config("spark.kryo.registrator", SedonaKryoRegistrator.getName)
              .config("spark.executor.cores", 1)
              .config("spark.cores.max", num_processors)
              .config("spark.driver.memory", "24g")
              .config("spark.driver.maxResultSize", "2g")
              .getOrCreate()
              )

    # Add Sedona functions and types to Spark
    spark = SedonaContext.create(config)

    logger.info(f"\t - PySpark {spark.sparkContext.version} session initiated: {datetime.now() - start_time}")

    # get list of tables to export to S3
    pg_conn = psycopg.connect(pg_connect_string)
    pg_cur = pg_conn.cursor()

    # --------------------------------------------------------------
    # import each table from each schema in Postgres &
    # export to Parquet files in AWS S3
    # --------------------------------------------------------------

    for schema_name in schema_names:
        i = 1

        # get table list for schema
        sql = f"""SELECT table_name
                 FROM information_schema.tables
                 WHERE table_schema='{schema_name}'
                   AND table_type='BASE TABLE'
                   AND table_name <> 'qa'
                   AND table_name NOT LIKE '%_2011_%'
                   AND table_name NOT LIKE '%_analysis%'
                   AND table_name NOT LIKE '%_display%'"""
        pg_cur.execute(sql)

        tables = pg_cur.fetchall()

        logger.info(f"\t - {schema_name} schema : {len(tables)} tables to export : {datetime.now() - start_time}")

        for table in tables:
            start_time = datetime.now()

            table_name = table[0]

            # check what type of geometry field the table has and what it's coordinate system is
            sql = f"""SELECT f_geometry_column, type, srid FROM public.geometry_columns
                     WHERE f_table_schema = '{schema_name}'
                         AND f_table_name = '{table_name}'"""
            pg_cur.execute(sql)
            result = pg_cur.fetchone()

            if result is not None:
                geom_field = result[0]
                geom_type = result[1]
                geom_srid = result[2]
            else:
                geom_field = None
                geom_type = None
                geom_srid = None

            # build geom field sql
            # note: exported geom field will be WGS84 (EPSG:4326) Well Known Binaries (WKB)
            if geom_field is not None:
                if "POLYGON" in geom_type or "LINESTRING" in geom_type:
                    geom_sql = ",ST_AsText(ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 256)) as wkt_geom"
                else:
                    geom_sql = ",ST_AsText(geom) as wkt_geom"

                # transform geom to WGS84 if required
                if geom_srid != 4326:
                    geom_sql = geom_sql.replace("(geom", "(ST_Transform(geom, 4326)")

            else:
                geom_sql = ""

            # build query to select all columns and the WKB geom if exists
            sql = f"""SELECT 'SELECT ' || array_to_string(ARRAY(
                         SELECT column_name
                         FROM information_schema.columns
                         WHERE table_name = '{table_name}'
                             AND table_schema = '{schema_name}'
                             AND column_name NOT IN('geom')
                      ), ',') || '{geom_sql} ' ||
                            'FROM {schema_name}.{table_name}' AS sqlstmt"""
            pg_cur.execute(sql)
            query = str(pg_cur.fetchone()[0])  # str is just there for intellisense in Pycharm

            # get min and max gid values to enable parallel import from Postgres to Spark
            # add gid field based on row number if missing
            if "gid," in query:
                sql = f"SELECT min(gid), max(gid) FROM {schema_name}.{table_name}"
                pg_cur.execute(sql)
                gid_range = pg_cur.fetchone()
                min_gid = gid_range[0]
                max_gid = gid_range[1]
            else:
                # get row count as the max gid value
                sql = f"SELECT count(*) FROM {schema_name}.{table_name}"
                pg_cur.execute(sql)
                min_gid = 1
                max_gid = pg_cur.fetchone()[0]

                # add gid field to query
                query = query.replace("SELECT ", "SELECT row_number() OVER () AS gid,")

            # whether there's a geometry field determines how the table will be exported (as geoparquet or parquet)
            if geom_field is None:
                is_spatial = False
            else:
                is_spatial = True

            # check table has records
            if max_gid is not None and max_gid > min_gid:
                df = import_table(spark, query, min_gid, max_gid, 100000, is_spatial)
                # df.printSchema()

                export_to_parquet(df, table_name, output_path, is_spatial)
                # copy_to_s3(schema_name, table_name, output_path)

                df.unpersist()

                logger.info(f"\t\t {i}. exported {table_name} : {datetime.now() - start_time}")
            else:
                logger.warning(f"\t\t {i}. {table_name} has no records! : {datetime.now() - start_time}")

            i += 1

    # cleanup
    pg_cur.close()
    pg_conn.close()
    spark.stop()


# load bdy table from Postgres and create a geospatial dataframe from it
def import_table(spark, sql, min_gid, max_gid, partition_size, is_spatial):

    # get the number of partitions
    num_partitions = math.ceil(float(max_gid - min_gid) / float(partition_size))

    # load boundaries from Postgres in parallel
    raw_df = (spark.read.format("jdbc")
              .option("url", jdbc_url)
              .option("dbtable", "({}) as sqt".format(sql))
              .option("properties", pg_settings["USER"])
              .option("password", pg_settings["PASS"])
              .option("driver", "org.postgresql.Driver")
              .option("fetchSize", 1000)
              .option("partitionColumn", "gid")
              .option("lowerBound", min_gid)
              .option("upperBound", max_gid)
              .option("numPartitions", num_partitions)
              .load()
              )

    # create view for SparkSQL to use
    raw_df.createOrReplaceTempView("geo_table")

    # add geometry column and order by geohash for faster querying is table is spatial
    if is_spatial:
        df = spark.sql("""select *,
                                 ST_GeomFromWKT(wkt_geom) as geom 
                          from geo_table 
                          order by ST_GeoHash(ST_GeomFromWKT(wkt_geom), 5)""")
        return df.drop("wkt_geom")
    else:
        return raw_df


# export a dataframe to gz parquet files
def export_to_parquet(df, name, output_path, is_spatial):
    if is_spatial:
        df.write.mode("overwrite") \
            .format("geoparquet") \
            .save(os.path.join(output_path, name))
    else:
        df.write.option("compression", "snappy") \
            .mode("overwrite") \
            .parquet(os.path.join(output_path, name))


# def copy_to_s3(schema_name, name, output_path):
#
#     # set correct AWS user
#     boto3.setup_default_session(profile_name="minus34")
#
#     # delete existing files (each time you run this Spark creates new, random parquet file names)
#     s3 = boto3.resource('s3')
#     bucket = s3.Bucket(s3_bucket)
#     bucket.objects.filter(Prefix=os.path.join(s3_folder, schema_name, name)).delete()
#
#     s3_client = boto3.client('s3')
#     config = TransferConfig(multipart_threshold=1024 ** 2)  # 1MB
#
#     # upload one file at a time
#     for root, dirs, files in os.walk(os.path.join(output_path, name)):
#         for file in files:
#             response = s3_client\
#                 .upload_file(os.path.join(output_path, name, file), s3_bucket,
#                              os.path.join(s3_folder, schema_name, name, file),
#                              Config=config, ExtraArgs={'ACL': 'public-read'})
#
#             if response is not None:
#                 logger.warning(f"\t\t\t - {name} copy to S3 problem : {response}")


if __name__ == "__main__":
    full_start_time = datetime.now()

    # setup logging to file and the console (screen)
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # set Spark logging levels
    logging.getLogger("pyspark").setLevel(logging.ERROR)
    logging.getLogger("py4j").setLevel(logging.ERROR)

    # setup logger to write to screen as well as writing to log file
    # define a Handler which writes INFO messages or higher to the sys.stderr
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    # set a format which is simpler for console use
    formatter = logging.Formatter("%(name)-12s: %(levelname)-8s %(message)s")
    # tell the handler to use this format
    console.setFormatter(formatter)
    # add the handler to the root logger
    logging.getLogger().addHandler(console)

    task_name = "Geoscape GNAF & Admin Boundary Export to S3"

    logger.info(f"{task_name} started")
    logger.info("Running on Python {}".format(sys.version.replace("\n", " ")))

    main()

    time_taken = datetime.now() - full_start_time
    logger.info(f"{task_name} finished : {time_taken}")
    print()
