# ---------------------------------------------------------------------------------------------------------------------
#
# script to import each GNAF & administrative boundary table from Postgres & export as GZIPped Parquet files
#
# PROCESS
#
# 1. get list of tables from Postgres
# 2. for each table:
#     a. import into Dask GeoPandas dataframe
#     b. export as gzip geoparquet files to local disk using pyarrow
#
# ---------------------------------------------------------------------------------------------------------------------

import argparse
import geopandas
import dask_geopandas
import json
import logging
import math
import os
import psycopg
import pyarrow as pa
import pyarrow.parquet as pq
import pyproj
import sqlalchemy
import sys

# from boto3.s3.transfer import TransferConfig  # S3 transfer disabled as AWS CLI sync is much faster
from datetime import datetime
from multiprocessing import cpu_count
from pathlib import Path

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

# # create Postgres JDBC url
# jdbc_url = "jdbc:postgresql://{HOST}:{PORT}/{DB}".format(**pg_settings)

# get connect string for psycopg
pg_connect_string = "dbname={DB} host={HOST} port={PORT} user={USER} password={PASS}".format(**pg_settings)

# get connect string for sqlalchemy
sql_alchemy_engine_string = "postgresql+psycopg://{USER}:{PASS}@{HOST}:{PORT}/{DB}".format(**pg_settings)

# Set PyGEOS to True to speed up GeoPandas
geopandas.options.use_pygeos = True

# get runtime arguments
parser = argparse.ArgumentParser(description="Converts Postgres/PostGIS tables to Geoparquet files.")

parser.add_argument("--gnaf-schema", help="Input schema name for GNAF tables.")
parser.add_argument("--admin-schema", help="Input schema name for admin boundary tables.")
parser.add_argument("--output-path", help="Output path for Geoparquet files.")


def main():
    start_time = datetime.now()

    # get settings
    args = parser.parse_args()
    output_path = args.output_path
    schema_names = [args.gnaf_schema, args.admin_schema]

    # create output path (if required)
    Path(output_path).mkdir(parents=True, exist_ok=True)

    # create sqlalchemy database engine
    sql_engine = sqlalchemy.create_engine(sql_alchemy_engine_string, isolation_level="AUTOCOMMIT")

    # get list of tables to export to S3
    pg_conn = psycopg.connect(pg_connect_string)
    pg_cur = pg_conn.cursor()

    # --------------------------------------------------------------
    # import each table from each schema in Postgres &
    # export to GZIPped Parquet files in AWS S3
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

        logger.info("\t - {} schema : {} tables to export : {}"
                    .format(schema_name, len(tables), datetime.now() - start_time))

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
                    if geom_srid != 4326:
                        geom_sql = ",ST_Subdivide((ST_Dump(ST_Buffer(ST_Transform(geom, 4326), 0.0))).geom, 256) " \
                                   "as geometry"
                    else:
                        geom_sql = ",ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 256) as geometry"
                else:
                    if geom_srid != 4326:
                        geom_sql = ",ST_Transform(geom, 4326) as geometry"

                    else:
                        geom_sql = ",geom as geometry"

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

            import_query = str(pg_cur.fetchone()[0])  # str is just there for intellisense in Pycharm

            # TESTING - only run for geom tables - ignore non-geom tables while testing
            if geom_field is not None:
                # import into Dask GeoPandas
                df = import_table(sql_engine, import_query)
                # num_rows = df.shape[0]
                # logger.info(f"\t\t {i}. imported {num_rows} from {table_name} : {datetime.now() - start_time}")
                # start_time = datetime.now()
    
                # export
                export_to_geoparquet(df, geom_type, table_name, output_path)
    
                logger.info(f"\t\t {i}. exported {table_name} : {datetime.now() - start_time}")
                # else:
                #     logger.warning("\t\t {}. {} has no records! : {}".format(i, table_name, datetime.now() - start_time))

            i += 1

    # cleanup
    pg_cur.close()
    pg_conn.close()


# load bdy table from Postgres and create a geospatial dataframe from it
def import_table(sql_engine, sql):

    # debugging
    # sql = "select gnaf_pid, geom as geometry from gnaf_202308.address_principals"
    # sql += " LIMIT 1000000"
    # dtype_dict = {"locality_name": "category", "postcode": "category", "state": "category"}
    # print(sql)

    df = geopandas.read_postgis(sql, sql_engine, geom_col='geometry')
    # df = dask_geopandas.from_geopandas(df, npartitions=8)

    # print(df.info(memory_usage="deep"))

    # <class 'geopandas.geodataframe.GeoDataFrame'>
    # RangeIndex: 2000000 entries, 0 to 1999999
    # Data columns (total 29 columns):
    # #   Column               Dtype
    # ---  ------               -----
    # 0   gid                  int64
    # 1   gnaf_pid             object
    # 2   street_locality_pid  object
    # 3   locality_pid         object
    # 4   alias_principal      object
    # 5   primary_secondary    object
    # 6   building_name        object
    # 7   lot_number           object
    # 8   flat_number          object
    # 9   level_number         object
    # 10  number_first         object
    # 11  number_last          object
    # 12  street_name          object
    # 13  street_type          object
    # 14  street_suffix        object
    # 15  address              object
    # 16  locality_name        object
    # 17  postcode             object
    # 18  state                object
    # 19  locality_postcode    object
    # 20  confidence           int64
    # 21  legal_parcel_id      object
    # 22  mb_2016_code         int64
    # 23  mb_2021_code         int64
    # 24  latitude             float64
    # 25  longitude            float64
    # 26  geocode_type         object
    # 27  reliability          int64
    # 28  geometry             geometry
    # dtypes: float64(2), geometry(1), int64(5), object(21)
    # memory usage: 2.2 GB
    # None

    return df


# export a dataframe to gz parquet files
def export_to_geoparquet(df, geom_type, name, output_path):

    table = pa.Table.from_pandas(df.to_wkb())

    # add metadata & schema
    metadata = {
        "version": "0.4.0",
        "primary_column": "geometry",
        "columns": {
            "geometry": {
                "encoding": "WKB",
                "geometry_type": [geom_type.capitalize()],
                "crs": json.loads(df.crs.to_json()),
                "edges": "planar",
                "bbox": [round(x, 4) for x in df.total_bounds],
            },
        },
    }

    schema = (
        table.schema
            .with_metadata({"geo": json.dumps(metadata)})
    )
    table = table.cast(schema)

    # export to geoparquet
    pq.write_table(table, os.path.join(output_path, f"{name}.parquet"), compression="snappy")

    # df.write.option("compression", "gzip") \
    #     .mode("overwrite") \
    #     .parquet(os.path.join(output_path, name))


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
#                 logger.warning("\t\t\t - {} copy to S3 problem : {}".format(name, response))


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

    task_name = "Geoscape Admin Boundary Export to S3"

    logger.info("{} started".format(task_name))
    logger.info("Running on Python {}".format(sys.version.replace("\n", " ")))

    main()

    time_taken = datetime.now() - full_start_time
    logger.info("{} finished : {}".format(task_name, time_taken))
    print()
