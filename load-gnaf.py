# *********************************************************************************************************************
# load-gnaf.py
# *********************************************************************************************************************
#
# A script for loading raw GNAF & PSMA Admin boundaries and creating flattened, complete, easy to use versions of them
#
# Author: Hugh Saalmans
# GitHub: minus34
# Twitter: @minus34
#
# Copyright:
#  - Code is licensed under an Apache License, version 2.0
#  - Data is copyright PSMA - SOON TO BE licensed under a Creative Commons (By Attribution) license

# Process:
#   1. Loads raw GNAF into Postgres from PSV files, using COPY
#   2. Loads raw PSMA Admin Boundaries from Shapefiles into Postgres using shp2pgsql (part of PostGIS)
#   3. Creates flattened and simplified GNAF tables containing all relevant data
#   4. Creates a ready to use Locality Boundaries table containing a number of fixes to overcome known data issues
#   5. Splits the locality boundary for Melbourne into 2, one for each of its postcodes (3000 & 3004)
#   6. Creates final principal & alias address tables containing fixes based on the above locality customisations
#   7. Creates an almost correct Postcode Boundary table from locality boundary aggregates with address based postcodes
#   8. Adds primary and foreign keys to confirm data integrity across the reference tables
#
# *********************************************************************************************************************

import multiprocessing
import math
import os
import subprocess
import platform
import psycopg2
import argparse

from datetime import datetime


def main():
    parser = argparse.ArgumentParser(
        description='A quick way to load the complete GNAF and PSMA Admin Boundaries into Postgres, '
                    'simplified and ready to use as reference data for geocoding, analysis and visualisation.')
    parser.add_argument(
        '--prevacuum', action='store_true', default=False, help='Forces database to be vacuumed after dropping tables.')
    parser.add_argument(
        '--raw-fk', action='store_true', default=False,
        help='Creates primary & foreign keys for the raw GNAF tables (adds time to data load)')
    parser.add_argument(
        '--raw-unlogged', action='store_true', default=False,
        help='Creates unlogged raw GNAF tables, speeding up the import. Only specify this option if you don\'t care '
             'about the raw data afterwards - they will be lost if the server crashes!')
    parser.add_argument(
        '--max-processes', type=int, default=6,
        help='Maximum number of parallel processes to use for the data load. (Set it to the number of cores on the '
             'Postgres server minus 2, limit to 12 if 16+ cores - there is minimal benefit beyond 12). Defaults to 6.')

    # PG Options
    parser.add_argument(
        '--pghost',
        help='Host name for Postgres server. Defaults to PGHOST environment variable if set, otherwise localhost.')
    parser.add_argument(
        '--pgport', type=int,
        help='Port number for Postgres server. Defaults to PGPORT environment variable if set, otherwise 5432.')
    parser.add_argument(
        '--pgdb',
        help='Database name for Postgres server. Defaults to PGDATABASE environment variable if set, '
             'otherwise psma_201602.')
    parser.add_argument(
        '--pguser',
        help='Username for Postgres server. Defaults to PGUSER environment variable if set, otherwise postgres.')
    parser.add_argument(
        '--pgpassword',
        help='Password for Postgres server. Defaults to PGPASSWORD environment variable if set, '
             'otherwise \'password\'.')

    # schema names for the raw gnaf, flattened reference and admin boundary tables
    parser.add_argument(
        '--raw-gnaf-schema', default='raw_gnaf',
        help='Schema name to store raw GNAF tables in. Defaults to \'raw_gnaf\'.')
    parser.add_argument(
        '--raw-admin-schema', default='raw_admin_bdys',
        help='Schema name to store raw admin boundary tables in. Defaults to \'raw_admin_bdys\'.')
    parser.add_argument(
        '--gnaf-schema', default='gnaf',
        help='Destination schema name to store final GNAF tables in. Defaults to \'gnaf\'.')
    parser.add_argument(
        '--admin-schema', default='admin_bdys',
        help='Destination schema name to store final admin boundary tables in. Defaults to \'admin_bdys\'.')

    # directories
    parser.add_argument(
        '--gnaf-tables-path', required=True,
        help='Path to source GNAF tables (*.psv files). This directory must be accessible by the Postgres server, '
             'and the local path to the directory for the server must be set via the local-server-dir argument if it differs '
             'from this path.')
    parser.add_argument(
        '--local-server-dir', help='Local path on server corresponding to gnaf-tables-path, if different to gnaf-tables-path.')
    parser.add_argument(
        '--admin-bdys-path', required=True, help='Local path to source admin boundary files.')

    # states to load
    parser.add_argument('--states', nargs='+', choices=["ACT", "NSW", "NT", "OT", "QLD", "SA", "TAS", "VIC", "WA"],
                        default=["ACT", "NSW", "NT", "OT", "QLD", "SA", "TAS", "VIC", "WA"],
                        help='List of states to load data for. Defaults to all states.')

    args = parser.parse_args()

    settings = dict()
    settings['vacuum_db'] = args.prevacuum
    settings['primary_foreign_keys'] = args.raw_fk
    settings['unlogged_tables'] = args.raw_unlogged
    settings['max_concurrent_processes'] = args.max_processes
    settings['states_to_load'] = args.states

    settings['raw_gnaf_schema'] = args.raw_gnaf_schema
    settings['raw_admin_bdys_schema'] = args.raw_admin_schema
    settings['gnaf_schema'] = args.gnaf_schema
    settings['admin_bdys_schema'] = args.admin_schema

    settings['gnaf_network_directory'] = args.gnaf_tables_path.replace("\\", "/")
    if args.local_server_dir:
        settings['gnaf_pg_server_local_directory'] = args.local_server_dir.replace("\\", "/")
    else:
        settings['gnaf_pg_server_local_directory'] = settings['gnaf_network_directory']
    settings['admin_bdys_local_directory'] = args.admin_bdys_path.replace("\\", "/")

    # create postgres connect string
    settings['pg_host'] = args.pghost or os.getenv("PGHOST", "localhost")
    settings['pg_port'] = args.pgport or os.getenv("PGPORT", 5432)
    settings['pg_db'] = args.pgdb or os.getenv("PGDATABASE", "psma_201602")
    settings['pg_user'] = args.pguser or os.getenv("PGUSER", "postgres")
    settings['pg_password'] = args.pgpassword or os.getenv("PGPASSWORD", "password")

    settings['pg_connect_string'] = "dbname='{0}' host='{1}' port='{2}' user='{3}' password='{4}'".format(
        settings['pg_db'], settings['pg_host'], settings['pg_port'], settings['pg_user'], settings['pg_password'])

    # set postgres script directory
    settings['sql_dir'] = os.path.join(os.path.dirname(os.path.realpath(__file__)), "postgres-scripts")

    full_start_time = datetime.now()

    # connect to Postgres
    try:
        pg_conn = psycopg2.connect(settings['pg_connect_string'])
    except psycopg2.Error:
        print "Unable to connect to database\nACTION: Check your Postgres parameters and/or database security"
        return False

    pg_conn.autocommit = True
    pg_cur = pg_conn.cursor()

    # add postgis to database (in the public schema) - run this in a try first time to confirm db user has privileges
    try:
        pg_cur.execute("SET search_path = public, pg_catalog; CREATE EXTENSION IF NOT EXISTS postgis")
    except psycopg2.Error:
        print "Unable to add PostGIS extension\nACTION: Check your Postgres user privileges or PostGIS install"
        return False

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

    print ""
    print "Running on Postgres {0} and PostGIS {1} (with GEOS {2})".format(pg_version, postgis_version, geos_version)

    # PART 1 - load gnaf from PSV files
    print ""
    start_time = datetime.now()
    print "Part 1 of 3 : Start raw GNAF load : {0}".format(start_time)
    drop_tables_and_vacuum_db(pg_cur, settings)
    create_raw_gnaf_tables(pg_cur, settings)
    populate_raw_gnaf(settings)
    index_raw_gnaf(settings)
    if settings['primary_foreign_keys']:
        create_primary_foreign_keys(settings)
    else:
        print "\t- Step 6 of 6 : primary & foreign keys NOT created"
    # set postgres search path back to the default
    pg_cur.execute("SET search_path = public, pg_catalog")
    print "Part 1 of 3 : Raw GNAF loaded! : {0}".format(datetime.now() - start_time)

    # PART 2 - load raw admin boundaries from Shapefiles
    print ""
    start_time = datetime.now()
    print "Part 2 of 3 : Start raw admin boundary load : {0}".format(start_time)
    load_raw_admin_boundaries(pg_cur, settings)
    prep_admin_bdys(pg_cur, settings)
    create_admin_bdys_for_analysis(pg_cur, settings)
    print "Part 2 of 3 : Raw admin boundaries loaded! : {0}".format(datetime.now() - start_time)

    # PART 3 - create flattened and standardised GNAF and Administrative Boundary reference tables
    print ""
    start_time = datetime.now()
    print "Part 3 of 3 : Start create reference tables : {0}".format(start_time)
    create_reference_tables(pg_cur, settings)
    print "Part 3 of 3 : Reference tables created! : {0}".format(datetime.now() - start_time)

    # # PART 4 - QA
    # print ""
    # start_time = datetime.now()
    # print "Part 4 of 3 : QA results : {0}".format(start_time)
    # create_reference_tables(pg_cur)
    # print "Part 4 of 3 : results QA'd : {0}".format(datetime.now() - start_time)

    pg_cur.close()
    pg_conn.close()

    print "Total time : : {0}".format(datetime.now() - full_start_time)


def drop_tables_and_vacuum_db(pg_cur, settings):
    # Step 1 of 6 : drop tables
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("01-01-drop-tables.sql", settings))
    print "\t- Step 1 of 6 : tables dropped : {0}".format(datetime.now() - start_time)

    # # Step 2 of 6 : vacuum database (if requested)
    # start_time = datetime.now()
    # if vacuum_db:
    #     pg_cur.execute("VACUUM")
    #     print "\t- Step 2 of 6 : database vacuumed : {0}".format(datetime.now() - start_time)
    # else:
    print "\t- Step 2 of 6 : database NOT vacuumed"


def create_raw_gnaf_tables(pg_cur, settings):
    # Step 3 of 6 : create tables
    start_time = datetime.now()

    # prep create table sql scripts (note: file doesn't contain any schema prefixes on table names)
    sql = open(os.path.join(settings['sql_dir'], "01-03-raw-gnaf-create-tables.sql"), "r").read()

    # create schema and set as search path
    if settings['raw_gnaf_schema'] != "public":
        pg_cur.execute("CREATE SCHEMA IF NOT EXISTS {0} AUTHORIZATION {1}"
                       .format(settings['raw_gnaf_schema'], settings['pg_user']))
        pg_cur.execute("SET search_path = {0}".format(settings['raw_gnaf_schema'],))

        # alter create table script to run on chosen schema
        sql = sql.replace("SET search_path = public", "SET search_path = {0}".format(settings['raw_gnaf_schema'],))

    # set tables to unlogged to speed up the load? (if requested)
    # -- they'll have to be rebuilt using this script again after a system crash --
    if settings['unlogged_tables']:
        sql = sql.replace("CREATE TABLE ", "CREATE UNLOGGED TABLE ")
        unlogged_string = "UNLOGGED "
    else:
        unlogged_string = ""

    if settings['pg_user'] != "postgres":
        # alter create table script to run with correct Postgres user name
        sql = sql.replace("postgres", settings['pg_user'])

    # create raw gnaf tables
    pg_cur.execute(sql)

    print "\t- Step 3 of 6 : {1}tables created : {0}".format(datetime.now() - start_time, unlogged_string)


# load raw gnaf authority & state tables using multiprocessing
def populate_raw_gnaf(settings):
    # Step 4 of 6 : load raw gnaf authority & state tables
    start_time = datetime.now()

    # authority code file list
    sql_list = get_raw_gnaf_files("authority_code", settings)

    # add state file lists
    for state in settings['states_to_load']:
        print "\t\t-Loading state {}".format( state )
        sql_list.extend(get_raw_gnaf_files(state, settings))

    # are there any files to load?
    if len(sql_list) == 0:
        print "No raw GNAF PSV files found\nACTION: Check your 'gnaf_network_directory' path"
        print "\t- Step 4 of 6 : table populate FAILED!"
    else:
        # load all PSV files using multiprocessing
        multiprocess_list("sql", sql_list, settings)
        print "\t- Step 4 of 6 : tables populated : {0}".format(datetime.now() - start_time)


def get_raw_gnaf_files(prefix, settings):
    sql_list = []
    prefix = prefix.lower()
    # get a dictionary of all files matching the filename prefix
    for root, dirs, files in os.walk(settings['gnaf_network_directory']):
        for file_name in files:
            if file_name.lower().startswith(prefix + "_"):
                if file_name.lower().endswith(".psv"):
                    file_path = os.path.join(root, file_name)\
                        .replace(settings['gnaf_network_directory'], settings['gnaf_pg_server_local_directory'])
                    table = file_name.lower().replace(prefix + "_", "", 1).replace("_psv.psv", "")

                    # if a non-Windows Postgres server OS - fix file path
                    if settings['gnaf_pg_server_local_directory'][0:1] == "/":
                        file_path = file_path.replace("\\", "/")
                        # print file_path

                    sql = "COPY {0}.{1} FROM '{2}' DELIMITER '|' CSV HEADER;"\
                        .format(settings['raw_gnaf_schema'], table, file_path)

                    sql_list.append(sql)

    return sql_list


# index raw gnaf using multiprocessing
def index_raw_gnaf(settings):
    # Step 5 of 6 : create indexes
    start_time = datetime.now()

    raw_sql_list = open_sql_file("01-05-raw-gnaf-create-indexes.sql", settings).split("\n")
    sql_list = []
    for sql in raw_sql_list:
        if sql[0:2] != "--" and sql[0:2] != "":
            sql_list.append(sql)

    multiprocess_list("sql", sql_list, settings)
    print "\t- Step 5 of 6 : indexes created: {0}".format(datetime.now() - start_time)


# create raw gnaf primary & foreign keys (for data integrity) using multiprocessing
def create_primary_foreign_keys(settings):
    start_time = datetime.now()

    key_sql = open(os.path.join(settings['sql_dir'], "01-06-raw-gnaf-create-primary-foreign-keys.sql"), "r").read()
    key_sql_list = key_sql.split("--")
    sql_list = []

    for sql in key_sql_list:
        sql = sql.strip()
        if sql[0:6] == "ALTER ":
            # add schema to tables names, in case raw gnaf schema not the default
            sql = sql.replace("ALTER TABLE ONLY ", "ALTER TABLE ONLY " + settings['raw_gnaf_schema'] + ".")
            sql_list.append(sql)

    # run queries in separate processes
    multiprocess_list("sql", sql_list, settings)

    print "\t- Step 6 of 6 : primary & foreign keys created : {0}".format(datetime.now() - start_time)


# loads the admin bdy shapefiles using the shp2pgsql command line tool (part of PostGIS), using multiprocessing
def load_raw_admin_boundaries(pg_cur, settings):
    start_time = datetime.now()

    # drop existing views
    pg_cur.execute(open_sql_file("02-01-drop-admin-bdy-views.sql", settings))

    # add locality class authority code table
    settings['states_to_load'].extend(["authority_code"])

    # create schema
    if settings['raw_admin_bdys_schema'] != "public":
        pg_cur.execute("CREATE SCHEMA IF NOT EXISTS {0} AUTHORIZATION {1}"
                       .format(settings['raw_admin_bdys_schema'], settings['pg_user']))

    # set psql connect string and password
    psql_str = "psql -U {0} -d {1} -h {2} -p {3}"\
        .format(settings['pg_user'], settings['pg_db'], settings['pg_host'], settings['pg_port'])

    password_str = ''
    if not os.getenv("PGPASSWORD"):
        if platform.system() == "Windows":
            password_str = "SET"
        else:
            password_str = "export"

        password_str += " PGPASSWORD={0}&&".format(settings['pg_password'])

    # get file list
    table_list = []
    cmd_list = []
    for state in settings['states_to_load']:
        state = state.lower()
        # get a dictionary of Shapefiles and DBFs matching the state
        for root, dirs, files in os.walk(settings['admin_bdys_local_directory']):
            for file_name in files:
                if file_name.lower().startswith(state + "_"):
                    if file_name.lower().endswith("_shp.dbf"):
                        # change file type for spatial files
                        if file_name.lower().endswith("_polygon_shp.dbf"):
                            spatial = True
                            bdy_file = os.path.join(root, file_name.replace(".dbf", ".shp"))
                        else:
                            spatial = False
                            bdy_file = os.path.join(root, file_name)

                        bdy_table = file_name.lower().replace(state + "_", "aus_", 1).replace("_shp.dbf", "")

                        # set command line parameters depending on whether this is the 1st state (for creating tables)
                        table_list_add = False

                        if bdy_table not in table_list:
                            table_list_add = True

                            if spatial:
                                params = "-d -D -s 4283 -i"
                            else:
                                params = "-d -D -G -n -i"
                        else:
                            if spatial:
                                params = "-a -D -s 4283 -i"
                            else:
                                params = "-a -D -G -n -i"

                        cmd = "{0}shp2pgsql {1} \"{2}\" {3}.{4} | {5}".format(
                            password_str, params, bdy_file, settings['raw_admin_bdys_schema'], bdy_table, psql_str)

                        # if locality file from Towns folder: don't add - it's a duplicate
                        if "town points" not in bdy_file.lower():
                            cmd_list.append(cmd)

                            if table_list_add:
                                table_list.append(bdy_table)
                        else:
                            if not bdy_file.lower().endswith("_locality_shp.dbf"):
                                cmd_list.append(cmd)

                                if table_list_add:
                                    table_list.append(bdy_table)

    # print '\n'.join(cmd_list)

    # are there any files to load?
    if len(cmd_list) == 0:
        print "No Admin Boundary files found\nACTION: Check your 'admin-bdys-path' argument"
    else:
        # load files in separate processes
        multiprocess_list("cmd", cmd_list, settings)
        print "\t- Step 1 of 3 : raw admin boundaries loaded : {0}".format(datetime.now() - start_time)


def prep_admin_bdys(pg_cur, settings):
    # Step 2 of 3 : create admin bdy tables read to be used
    start_time = datetime.now()

    if settings['admin_bdys_schema'] != "public":
        pg_cur.execute("CREATE SCHEMA IF NOT EXISTS {0} AUTHORIZATION {1}"
                       .format(settings['admin_bdys_schema'], settings['pg_user']))

    pg_cur.execute(open_sql_file("02-02-prep-admin-bdys-tables.sql", settings))

    # Special case - remove custom outback bdy if South Australia not requested
    if 'SA' not in settings['states_to_load']:
        pg_cur.execute(prep_sql("DELETE FROM admin_bdys.locality_bdys WHERE locality_pid = 'SA999999'", settings))
        pg_cur.execute(prep_sql("VACUUM ANALYZE admin_bdys.locality_bdys", settings))

    print "\t- Step 2 of 3 : admin boundaries prepped : {0}".format(datetime.now() - start_time)


def create_admin_bdys_for_analysis(pg_cur, settings):
    # Step 4 of 3 : create admin bdy tables optimised for spatial analysis
    start_time = datetime.now()

    if settings['st_subdivide_supported']:
        pg_cur.execute(open_sql_file("02-03-create-admin-bdy-analysis-tables.sql", settings))
        print "\t- Step 3 of 3 : admin boundaries for analysis created : {0}".format(datetime.now() - start_time)
    else:
        print "\t- Step 3 of 3 : admin boundaries for analysis NOT created - requires PostGIS 2.2+ with GEOS 3.5.0+"


# create gnaf reference tables by flattening raw gnaf address, streets & localities into a usable form
# also creates all supporting lookup tables and usable admin bdy tables
def create_reference_tables(pg_cur, settings):
    # set postgres search path back to the default
    pg_cur.execute("SET search_path = public, pg_catalog")

    # create schemas
    if settings['gnaf_schema'] != "public":
        pg_cur.execute("CREATE SCHEMA IF NOT EXISTS {0} AUTHORIZATION {1}"
                       .format(settings['gnaf_schema'], settings['pg_user']))

    # Step 1 of 14 : create reference tables
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-01-reference-create-tables.sql", settings))
    print "\t- Step  1 of 14 : create reference tables : {0}".format(datetime.now() - start_time)

    # Step 2 of 14 : populate localities
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-02-reference-populate-localities.sql", settings))
    print "\t- Step  2 of 14 : localities populated : {0}".format(datetime.now() - start_time)

    # Step 3 of 14 : populate locality aliases
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-03-reference-populate-locality-aliases.sql", settings))
    print "\t- Step  3 of 14 : locality aliases populated : {0}".format(datetime.now() - start_time)

    # Step 4 of 14 : populate locality neighbours
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-04-reference-populate-locality-neighbours.sql", settings))
    print "\t- Step  4 of 14 : locality neighbours populated : {0}".format(datetime.now() - start_time)

    # Step 5 of 14 : populate streets
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-05-reference-populate-streets.sql", settings))
    print "\t- Step  5 of 14 : streets populated : {0}".format(datetime.now() - start_time)

    # Step 6 of 14 : populate street aliases
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-06-reference-populate-street-aliases.sql", settings))
    print "\t- Step  6 of 14 : street aliases populated : {0}".format(datetime.now() - start_time)

    # Step 7 of 14 : populate addresses, using multiprocessing
    start_time = datetime.now()
    sql = open_sql_file("03-07-reference-populate-addresses-1.sql", settings)
    split_sql_into_list_and_process(pg_cur, sql, settings['gnaf_schema'], "streets", "str", "gid", settings)
    pg_cur.execute(prep_sql("ANALYZE gnaf.temp_addresses;", settings))
    print "\t- Step  7 of 14 : addresses populated : {0}".format(datetime.now() - start_time)

    # Step 8 of 14 : populate principal alias lookup
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-08-reference-populate-address-alias-lookup.sql", settings))
    print "\t- Step  8 of 14 : principal alias lookup populated : {0}".format(datetime.now() - start_time)

    # Step 9 of 14 : populate primary secondary lookup
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-09-reference-populate-address-secondary-lookup.sql", settings))
    pg_cur.execute(prep_sql("VACUUM ANALYSE gnaf.address_secondary_lookup", settings))
    print "\t- Step  9 of 14 : primary secondary lookup populated : {0}".format(datetime.now() - start_time)

    # Step 10 of 14 : split the Melbourne locality into its 2 postcodes (3000, 3004)
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-10-reference-split-melbourne.sql", settings))
    print "\t- Step 10 of 14 : Melbourne split : {0}".format(datetime.now() - start_time)

    # Step 11 of 14 : finalise localities assigned to streets and addresses
    start_time = datetime.now()
    pg_cur.execute(open_sql_file("03-11-reference-finalise-localities.sql", settings))
    print "\t- Step 11 of 14 : localities finalised : {0}".format(datetime.now() - start_time)

    # Step 12 of 14 : finalise addresses, using multiprocessing
    start_time = datetime.now()
    sql = open_sql_file("03-12-reference-populate-addresses-2.sql", settings)
    split_sql_into_list_and_process(pg_cur, sql, settings['gnaf_schema'], "localities", "loc", "gid", settings)
    # turf the temp address table
    pg_cur.execute(prep_sql("DROP TABLE IF EXISTS gnaf.temp_addresses", settings))
    print "\t- Step 12 of 14 : addresses finalised : {0}".format(datetime.now() - start_time)

    # Step 13 of 14 : create almost correct postcode boundaries by aggregating localities, using multiprocessing
    start_time = datetime.now()
    sql = open_sql_file("03-13-reference-derived-postcode-bdys.sql", settings)
    sql_list = []
    for state in settings['states_to_load']:
        state_sql = sql.replace("GROUP BY ", "WHERE state = '{0}' GROUP BY ".format(state))
        sql_list.append(state_sql)
    multiprocess_list("sql", sql_list, settings)

    # create analysis table?
    if settings['st_subdivide_supported']:
        pg_cur.execute(open_sql_file("03-13a-create-postcode-analysis-table.sql", settings))

    print "\t- Step 13 of 14 : postcode boundaries created : {0}".format(datetime.now() - start_time)

    # Step 14 of 14 : create indexes, primary and foreign keys, using multiprocessing
    start_time = datetime.now()
    raw_sql_list = open_sql_file("03-14-reference-create-indexes.sql", settings).split("\n")
    sql_list = []
    for sql in raw_sql_list:
        if sql[0:2] != "--" and sql[0:2] != "":
            sql_list.append(sql)
    multiprocess_list("sql", sql_list, settings)
    print "\t- Step 14 of 14 : create primary & foreign keys and indexes : {0}".format(datetime.now() - start_time)


# takes a list of sql queries or command lines and runs them using multiprocessing
def multiprocess_list(mp_type, work_list, settings):
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
        print "\t- A MULTIPROCESSING PROCESS FAILED WITHOUT AN ERROR\nACTION: Check the record counts"

    for result in result_list:
        if result != "SUCCESS":
            print result


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
    except psycopg2.Error, e:
        result = "SQL FAILED! : {0} : {1}".format(the_sql, e.message)

    pg_cur.close()
    pg_conn.close()

    return result


def run_command_line(cmd):
    # run the command line without any output (it'll still tell you if it fails)
    try:
        fnull = open(os.devnull, "w")
        subprocess.call(cmd, shell=True, stdout=fnull, stderr=subprocess.STDOUT)
        result = "SUCCESS"
    except Exception, e:
        result = "COMMAND FAILED! : {0} : {1}".format(cmd, e.message)

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


# change schema names in the SQL script if not the default
def prep_sql(sql, settings):
    if settings['raw_gnaf_schema'] != "raw_gnaf":
        sql = sql.replace(" raw_gnaf.", " {0}.".format(settings['raw_gnaf_schema'],))
    if settings['gnaf_schema'] != "gnaf":
        sql = sql.replace(" gnaf.", " {0}.".format(settings['gnaf_schema'],))
    if settings['raw_admin_bdys_schema'] != "raw_admin_bdys":
        sql = sql.replace(" raw_admin_bdys.", " {0}.".format(settings['raw_admin_bdys_schema'],))
    if settings['admin_bdys_schema'] != "admin_bdys":
        sql = sql.replace(" admin_bdys.", " {0}.".format(settings['admin_bdys_schema'],))
    return sql


def split_sql_into_list_and_process(pg_cur, the_sql, table_schema, table_name, table_alias, table_gid, settings):
    # get min max gid values from the table to split
    min_max_sql = "SELECT MIN({2}) AS min, MAX({2}) AS max FROM {0}.{1}".format(table_schema, table_name, table_gid)

    pg_cur.execute(min_max_sql)
    result = pg_cur.fetchone()

    min_pkey = int(result[0])
    max_pkey = int(result[1])
    diff = max_pkey - min_pkey

    # Number of records in each query
    rows_per_request = int(math.floor(float(diff) / float(settings['max_concurrent_processes']))) + 1

    # If less records than processes or rows per request, reduce both to allow for a minimum of 15 records each process
    if float(diff) / float(settings['max_concurrent_processes']) < 10.0:
        rows_per_request = 10
        processes = int(math.floor(float(diff) / 10.0)) + 1
        print "\t\t- running {0} processes (adjusted due to low row count in table to split)".format(processes)
    else:
        processes = settings['max_concurrent_processes']
        # print "\t\t- running {0} processes".format(processes)

    # create list of sql statements to run with multiprocessing
    sql_list = []
    start_pkey = min_pkey - 1

    for i in range(0, processes):
        end_pkey = start_pkey + rows_per_request

        where_clause = " WHERE {0}.{3} > {1} AND {0}.{3} <= {2}".format(table_alias, start_pkey, end_pkey, table_gid)

        if "WHERE " in the_sql:
            mp_sql = the_sql.replace(" WHERE ", where_clause + " AND ")
        elif "GROUP BY " in the_sql:
            mp_sql = the_sql.replace("GROUP BY ", where_clause + " GROUP BY ")
        elif "ORDER BY " in the_sql:
            mp_sql = the_sql.replace("ORDER BY ", where_clause + " ORDER BY ")
        else:
            mp_sql = the_sql.replace(";", where_clause + ";")

        sql_list.append(mp_sql)
        start_pkey = end_pkey

    # print '\n'.join(sql_list)
    multiprocess_list('sql', sql_list, settings)


if __name__ == '__main__':
    main()
