
# import io
import logging
import math
import multiprocessing
import os
import subprocess

# import platform
import psycopg
from psycopg import sql

import settings

# import sys


# takes a list of sql queries or command lines and runs them using multiprocessing
def multiprocess_list(mp_type: str, work_list: list[str], logger: logging.Logger) -> None:
    pool = multiprocessing.Pool(processes=settings.max_processes)

    num_jobs = len(work_list)

    if mp_type == "sql":
        results = pool.imap_unordered(run_sql_multiprocessing, work_list)
    else:
        results = pool.imap_unordered(run_command_line, work_list)

    pool.close()
    pool.join()

    result_list = list(results)
    num_results = len(result_list)

    if num_jobs > num_results:
        logger.warning("\t- A MULTIPROCESSING PROCESS FAILED WITHOUT AN ERROR\nACTION: Check the record counts")

    for result in result_list:
        if result != "SUCCESS":
            logger.info(result)


def run_sql_multiprocessing(the_sql: str):
    pg_conn = psycopg.connect(settings.pg_connect_string)
    pg_conn.autocommit = True
    pg_cur = pg_conn.cursor()

    # set raw gnaf database schema (it's needed for the primary and foreign key creation)
    if settings.raw_gnaf_schema != "public":
        pg_cur.execute(sql.SQL("SET search_path = {}, public, pg_catalog").format(sql.Identifier(settings.raw_gnaf_schema)))

    try:
        pg_cur.execute(the_sql) # type: ignore
        result = "SUCCESS"
    except psycopg.Error as ex:
        result = f"SQL FAILED! : {the_sql} : {ex}"

    pg_cur.close()
    pg_conn.close()

    return result


def run_command_line(cmd: str) -> str:
    # run the command line without any output (it'll still tell you if it fails miserably)
    with open(os.devnull, "w") as f_null:
        returncode = subprocess.call(cmd, shell=True, stdout=f_null, stderr=subprocess.STDOUT)
        if returncode != 0:
            result = f"COMMAND FAILED! : {cmd} : exit code {returncode}"
        else:
            result = "SUCCESS"

    return result


def open_sql_file(file_name: str) -> str:
    with open(os.path.join(settings.sql_dir, file_name), "r") as f:
        sql_string = f.read()
        
    return prep_sql(sql_string)


# change schema names in an array of SQL script if schemas not the default
def prep_sql_list(sql_list: list[str]) -> list[str]:
    output_list = list[str]()
    for sql_string in sql_list:
        output_list.append(prep_sql(sql_string))
    return output_list


# set schema names in the SQL script
def prep_sql(sql: str) -> str:
    if settings.raw_gnaf_schema:
        sql = sql.replace(" raw_gnaf.", f" {settings.raw_gnaf_schema}.")
    if settings.raw_admin_bdys_schema:
        sql = sql.replace(" raw_admin_bdys.", f" {settings.raw_admin_bdys_schema}.")
    if settings.gnaf_schema:
        sql = sql.replace(" gnaf.", f" {settings.gnaf_schema}.")
    if settings.admin_bdys_schema:
        sql = sql.replace(" admin_bdys.", f" {settings.admin_bdys_schema}.")

    if settings.pg_user != "postgres":
        # alter create table script to run with correct Postgres username
        sql = sql.replace(" postgres;", f" {settings.pg_user};")

    return sql


def split_sql_into_list(pg_cur: psycopg.Cursor, the_sql: str, table_schema: str, table_name: str, table_alias: str, table_gid: str, logger: logging.Logger) -> list[str]:
    # get min max gid values from the table to split
    min_max_sql = "SELECT MIN(%s) AS min, MAX(%s) AS max FROM %s.%s"
    pg_cur.execute(min_max_sql, (table_gid, table_gid, table_schema, table_name))

    try:
        result = pg_cur.fetchone()

        min_pkey = int(result[0]) # type: ignore
        max_pkey = int(result[1]) # type: ignore
        diff = max_pkey - min_pkey

        # Number of records in each query
        rows_per_request = math.floor(float(diff) / float(settings.max_processes)) + 1

        # If less records than processes or rows per request,
        # reduce both to allow for a minimum of 15 records each process
        if float(diff) / float(settings.max_processes) < 10.0:
            rows_per_request = 10
            processes = math.floor(float(diff) / 10.0) + 1
            logger.info(f"\t\t- running {processes} processes (adjusted due to low row count in table to split)")
        else:
            processes = settings.max_processes

        # create list of sql statements to run with multiprocessing
        sql_list = list[str]()
        start_pkey = min_pkey - 1

        for _ in range(processes):
            end_pkey = start_pkey + rows_per_request

            where_clause = \
                f" WHERE {table_alias}.{table_gid} > {start_pkey} AND {table_alias}.{table_gid} <= {end_pkey}"

            if "WHERE " in the_sql:
                mp_sql = the_sql.replace(" WHERE ", where_clause + " AND ")
            elif "GROUP BY " in the_sql:
                mp_sql = the_sql.replace("GROUP BY ", where_clause + " GROUP BY ")
            elif "ORDER BY " in the_sql:
                mp_sql = the_sql.replace("ORDER BY ", where_clause + " ORDER BY ")
            else:
                if ";" in the_sql:
                    mp_sql = the_sql.replace(";", where_clause + ";")
                else:
                    mp_sql = the_sql + where_clause
                    logger.warning("\t\t- NOTICE: no ; found at the end of the SQL statement")

            sql_list.append(mp_sql)
            start_pkey = end_pkey

        # logger.info("\n".join(sql_list))

        return sql_list
    except Exception as ex:  # noqa: BLE001
        logger.fatal(f"Looks like the table in this query is empty: {min_max_sql}\n{ex}")
        return list[str]()


def multiprocess_shapefile_load(work_list: list[dict[str, str]], logger: logging.Logger):
    pool = multiprocessing.Pool(processes=settings.max_processes)

    num_jobs = len(work_list)

    results = pool.imap_unordered(intermediate_shapefile_load_step, work_list)

    pool.close()
    pool.join()

    result_list = list(results)
    num_results = len(result_list)

    if num_jobs > num_results:
        logger.warning("\t- A MULTIPROCESSING PROCESS FAILED WITHOUT AN ERROR\nACTION: Check the record counts")

    for result in result_list:
        if result != "SUCCESS":
            logger.info(result)


def intermediate_shapefile_load_step(work_dict: dict[str, str]) -> str:
    file_path = work_dict["file_path"]
    pg_table = work_dict["pg_table"]
    pg_schema = work_dict["pg_schema"]
    delete_table = bool(work_dict["delete_table"])
    spatial = bool(work_dict["spatial"])

    result = import_shapefile_to_postgres(file_path, pg_table, pg_schema, delete_table, spatial)

    return result


# imports a Shapefile into Postgres in 2 steps: SHP > SQL; SQL > Postgres
# overcomes issues trying to use psql with PGPASSWORD set at runtime
def import_shapefile_to_postgres(file_path: str, pg_table: str, pg_schema: str, delete_table: bool, spatial: bool) -> str:
    # delete target table or append to it?
    if delete_table:
        # add delete and spatial index flag
        delete_append_flag = "-d -I"
    else:
        delete_append_flag = "-a"

    # assign coordinate system if spatial, otherwise flag as non-spatial
    if spatial:
        spatial_or_dbf_flags = f"-s {settings.srid}"
    else:
        spatial_or_dbf_flags = "-G -n"

    # build shp2pgsql command line (note: forces 2D as some files erroneously have Z values in their geometries)
    shp2pgsql_cmd = f"shp2pgsql -t 2D {delete_append_flag} {spatial_or_dbf_flags}" \
                    f" -i \"{file_path}\" {pg_schema}.{pg_table}"
    # print(shp2pgsql_cmd)

    # convert the Shapefile to SQL statements
    try:
        process = subprocess.Popen(shp2pgsql_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        sqlobj, err = process.communicate()
    except Exception as ex:  # noqa: BLE001
        process.kill() # type: ignore
        return f"Importing {file_path} - Couldn't convert Shapefile to SQL : {ex}"

    # check shp2pgsql exit code — a non-zero return means the conversion failed
    if process.returncode != 0:
        err_msg = err.decode("utf-8").strip() if err else "unknown error"
        return f"Importing {file_path} - shp2pgsql failed (exit code {process.returncode}): {err_msg}"

    # prep Shapefile SQL
    sql = sqlobj.decode("utf-8")  # this is required for Python 3
    sql = sql.replace("Shapefile type: ", "-- Shapefile type: ")
    sql = sql.replace("Postgis type: ", "-- Postgis type: ")
    sql = sql.replace("SELECT DropGeometryColumn", "-- SELECT DropGeometryColumn")

    # # bug in shp2pgsql? - an append command will still create a spatial index if requested - disable it
    # if not delete_table or not spatial:
    #     sql = sql.replace("CREATE INDEX ", "-- CREATE INDEX ")

    # this is required due to differing approaches by different versions of PostGIS
    sql = sql.replace("DROP TABLE ", "DROP TABLE IF EXISTS ")
    sql = sql.replace("DROP TABLE IF EXISTS IF EXISTS ", "DROP TABLE IF EXISTS ")

    # guard against empty SQL — shp2pgsql may exit 0 but produce no output
    if len(sql.strip()) == 0:
        return f"Importing {file_path} - shp2pgsql produced empty SQL output"

    # import data to Postgres
    pg_conn = psycopg.connect(settings.pg_connect_string)
    pg_conn.autocommit = True
    pg_cur = pg_conn.cursor()

    try:
        pg_cur.execute(sql) # type: ignore
    except psycopg.Error as ex:
        # if import fails for some reason - output sql to file for debugging
        file_name = os.path.basename(file_path)

        with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), f"error_debug_{file_name}.sql"), "w") as target:
            target.write(sql)

        pg_cur.close()
        pg_conn.close()

        return f"\tImporting {file_name} - Couldn't run Shapefile SQL\nshp2pgsql result was: {ex} "

    # Cluster table on spatial index for performance
    if delete_table and spatial:
        sql = f"ALTER TABLE {pg_schema}.{pg_table} CLUSTER ON {pg_table}_geom_idx"

        try:
            pg_cur.execute(sql) # type: ignore
        except psycopg.Error as ex:
            pg_cur.close()
            pg_conn.close()
            return f"\tImporting {pg_table} - Couldn't cluster on spatial index : {ex}"

    pg_cur.close()
    pg_conn.close()

    return "SUCCESS"
