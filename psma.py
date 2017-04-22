import multiprocessing
import math
import os
import subprocess
import psycopg2


# takes a list of sql queries or command lines and runs them using multiprocessing
def multiprocess_list(mp_type, work_list, settings, logger):
    pool = multiprocessing.Pool(processes=settings['max_concurrent_processes'])

    num_jobs = len(work_list)

    if mp_type == "sql":
        results = pool.imap_unordered(run_sql_multiprocessing, [[w, settings] for w in work_list])
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


def run_sql_multiprocessing(args):
    the_sql = args[0]
    settings = args[1]
    pg_conn = psycopg2.connect(settings['pg_connect_string'])
    pg_conn.autocommit = True
    pg_cur = pg_conn.cursor()

    # set raw gnaf database schema (it's needed for the primary and foreign key creation)
    if settings['raw_gnaf_schema'] != "public":
        pg_cur.execute("SET search_path = {0}, public, pg_catalog".format(settings['raw_gnaf_schema'],))

    try:
        pg_cur.execute(the_sql)
        result = "SUCCESS"
    except Exception as ex:
        result = "SQL FAILED! : {0} : {1}".format(the_sql, ex)

    pg_cur.close()
    pg_conn.close()

    return result


def run_command_line(cmd):
    # run the command line without any output (it'll still tell you if it fails miserably)
    try:
        fnull = open(os.devnull, "w")
        subprocess.call(cmd, shell=True, stdout=fnull, stderr=subprocess.STDOUT)
        result = "SUCCESS"
    except Exception as ex:
        result = "COMMAND FAILED! : {0} : {1}".format(cmd, ex)

    return result


def open_sql_file(file_name, settings):
    sql = open(os.path.join(settings['sql_dir'], file_name), "r").read()
    return prep_sql(sql, settings)


# change schema names in an array of SQL script if schemas not the default
def prep_sql_list(sql_list, settings):
    output_list = []
    for sql in sql_list:
        output_list.append(prep_sql(sql, settings))
    return output_list


# set schema names in the SQL script
def prep_sql(sql, settings):

    if settings['raw_gnaf_schema'] is not None:
        sql = sql.replace(" raw_gnaf.", " {0}.".format(settings['raw_gnaf_schema'], ))
    if settings['raw_admin_bdys_schema'] is not None:
        sql = sql.replace(" raw_admin_bdys.", " {0}.".format(settings['raw_admin_bdys_schema'], ))
    if settings['gnaf_schema'] is not None:
        sql = sql.replace(" gnaf.", " {0}.".format(settings['gnaf_schema'], ))
    if settings['admin_bdys_schema'] is not None:
        sql = sql.replace(" admin_bdys.", " {0}.".format(settings['admin_bdys_schema'], ))

    if settings['pg_user'] != "postgres":
        # alter create table script to run with correct Postgres user name
        sql = sql.replace(" postgres;", " {0};".format(settings['pg_user'], ))

    return sql


def split_sql_into_list(pg_cur, the_sql, table_schema, table_name, table_alias, table_gid, settings, logger):
    # get min max gid values from the table to split
    min_max_sql = "SELECT MIN({2}) AS min, MAX({2}) AS max FROM {0}.{1}".format(table_schema, table_name, table_gid)

    pg_cur.execute(min_max_sql)

    try:
        result = pg_cur.fetchone()

        min_pkey = int(result[0])
        max_pkey = int(result[1])
        diff = max_pkey - min_pkey

        # Number of records in each query
        rows_per_request = int(math.floor(float(diff) / float(settings['max_concurrent_processes']))) + 1

        # If less records than processes or rows per request,
        # reduce both to allow for a minimum of 15 records each process
        if float(diff) / float(settings['max_concurrent_processes']) < 10.0:
            rows_per_request = 10
            processes = int(math.floor(float(diff) / 10.0)) + 1
            logger.info("\t\t- running {0} processes (adjusted due to low row count in table to split)"
                        .format(processes))
        else:
            processes = settings['max_concurrent_processes']

        # create list of sql statements to run with multiprocessing
        sql_list = []
        start_pkey = min_pkey - 1

        for i in range(0, processes):
            end_pkey = start_pkey + rows_per_request

            where_clause = " WHERE {0}.{3} > {1} AND {0}.{3} <= {2}"\
                .format(table_alias, start_pkey, end_pkey, table_gid)

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

        # logger.info('\n'.join(sql_list))

        return sql_list
    except Exception as ex:
        logger.fatal("Looks like the table in this query is empty: {0}\n{1}".format(min_max_sql, ex))
        return None


# get latest PSMA release version as YYYYMM, as of the date provided
def get_psma_version(date):
    month = date.month
    year = date.year

    if month == 1:
        return str(year - 1) + '11'
    elif 2 <= month < 5:
        return str(year) + '02'
    elif 5 <= month < 8:
        return str(year) + '05'
    elif 8 <= month < 11:
        return str(year) + '08'
    else:
        return str(year) + '11'


def check_postgis_version(pg_cur, settings, logger):
    # get Postgres, PostGIS & GEOS versions
    pg_cur.execute("SELECT version()")
    pg_version = pg_cur.fetchone()[0].replace("PostgreSQL ", "").split(",")[0]
    pg_cur.execute("SELECT PostGIS_full_version()")
    lib_strings = pg_cur.fetchone()[0].replace("\"", "").split(" ")
    postgis_version = "UNKNOWN"
    postgis_version_num = 0.0
    geos_version = "UNKNOWN"
    geos_version_num = 0.0
    settings['st_subdivide_supported'] = False
    for lib_string in lib_strings:
        if lib_string[:8] == "POSTGIS=":
            postgis_version = lib_string.replace("POSTGIS=", "")
            postgis_version_num = float(postgis_version[:3])
        if lib_string[:5] == "GEOS=":
            geos_version = lib_string.replace("GEOS=", "")
            geos_version_num = float(geos_version[:3])
    if postgis_version_num >= 2.2 and geos_version_num >= 3.5:
        settings['st_subdivide_supported'] = True
    logger.info("")
    logger.info("Running on Postgres {0} and PostGIS {1} (with GEOS {2})"
                .format(pg_version, postgis_version, geos_version))


def multiprocess_shapefile_load(work_list, settings, logger):
    pool = multiprocessing.Pool(processes=settings['max_concurrent_processes'])

    num_jobs = len(work_list)

    results = pool.imap_unordered(intermediate_shapefile_load_step, [[w, settings] for w in work_list])

    pool.close()
    pool.join()

    result_list = list(results)
    num_results = len(result_list)

    if num_jobs > num_results:
        logger.warning("\t- A MULTIPROCESSING PROCESS FAILED WITHOUT AN ERROR\nACTION: Check the record counts")

    for result in result_list:
        if result != "SUCCESS":
            logger.info(result)


def intermediate_shapefile_load_step(args):
    work_dict = args[0]
    settings = args[1]
    # logger = args[2]

    file_path = work_dict['file_path']
    pg_table = work_dict['pg_table']
    pg_schema = work_dict['pg_schema']
    delete_table = work_dict['delete_table']
    spatial = work_dict['spatial']

    pg_conn = psycopg2.connect(settings['pg_connect_string'])
    pg_conn.autocommit = True
    pg_cur = pg_conn.cursor()

    result = import_shapefile_to_postgres(pg_cur, file_path, pg_table, pg_schema, delete_table, spatial)

    return result


# imports a Shapefile into Postgres in 2 steps: SHP > SQL; SQL > Postgres
# overcomes issues trying to use psql with PGPASSWORD set at runtime
def import_shapefile_to_postgres(pg_cur, file_path, pg_table, pg_schema, delete_table, spatial):

    # delete target table or append to it?
    if delete_table:
        delete_append_flag = "-d"
    else:
        delete_append_flag = "-a"

    # assign coordinate system if spatial, otherwise flag as non-spatial
    if spatial:
        spatial_or_dbf_flags = "-s 4283 -I"
    else:
        spatial_or_dbf_flags = "-G -n"

    # build shp2pgsql command line
    shp2pgsql_cmd = "shp2pgsql {0} {1} -i \"{2}\" {3}.{4}"\
        .format(delete_append_flag, spatial_or_dbf_flags, file_path, pg_schema, pg_table)
    # print(shp2pgsql_cmd)

    # convert the Shapefile to SQL statements
    try:
        process = subprocess.Popen(shp2pgsql_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        sqlobj, err = process.communicate()
    except:
        return "Importing {0} - Couldn't convert Shapefile to SQL".format(file_path)

    # prep Shapefile SQL
    sql = sqlobj.decode("utf-8")  # this is required for Python 3
    sql = sql.replace("Shapefile type: ", "-- Shapefile type: ")
    sql = sql.replace("Postgis type: ", "-- Postgis type: ")
    sql = sql.replace("SELECT DropGeometryColumn", "-- SELECT DropGeometryColumn")

    # bug in shp2pgsql? - an append command will still create a spatial index if requested - disable it
    if not delete_table or not spatial:
        sql = sql.replace("CREATE INDEX ", "-- CREATE INDEX ")

    # this is required due to differing approaches by different versions of PostGIS
    sql = sql.replace("DROP TABLE ", "DROP TABLE IF EXISTS ")
    sql = sql.replace("DROP TABLE IF EXISTS IF EXISTS ", "DROP TABLE IF EXISTS ")

    # import data to Postgres
    try:
        pg_cur.execute(sql)
    except:
        # if import fails for some reason - output sql to file for debugging
        target = open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'test.sql'), "w")
        target.write(sql)

        return "\tImporting {0} - Couldn't run Shapefile SQL\nshp2pgsql result was: {1} ".format(file_path, err)

    # Cluster table on spatial index for performance
    if delete_table and spatial:
        sql = "ALTER TABLE {0}.{1} CLUSTER ON {1}_geom_idx".format(pg_schema, pg_table)

        try:
            pg_cur.execute(sql)
        except:
            return "\tImporting {0} - Couldn't cluster on spatial index".format(pg_table)

    return "SUCCESS"