#!/usr/bin/env python

# *********************************************************************************************************************
# load-gnaf.py
# *********************************************************************************************************************
#
# A script for loading raw GNAF & Geoscape Admin boundaries and creating flattened, complete, easy to use versions
#
# Author: Hugh Saalmans
# GitHub: minus34
# Twitter: @minus34
#
# Copyright:
#  - Code is licensed under an Apache License, version 2.0
#  - Data is copyright Geoscape - licensed under a Creative Commons (By Attribution) license.
#    See http://data.gov.au for the correct attribution to use
#
# Process:
#   1. Loads raw GNAF into Postgres from PSV files, using COPY
#   2. Loads raw Geoscape Admin Boundaries from Shapefiles into Postgres using shp2pgsql (part of PostGIS)
#   3. Creates flattened and simplified GNAF tables containing all relevant data
#   4. Creates a ready to use Locality Boundaries table containing a number of fixes to overcome known data issues
#   5. Splits the locality boundary for Melbourne into 2, one for each of its postcodes (3000 & 3004)
#   6. Creates final principal & alias address tables containing fixes based on the above locality customisations
#   7. Creates an almost correct Postcode Boundary table from locality boundary aggregates with address based postcodes
#   8. Adds primary and foreign keys to confirm data integrity across the output tables
#
# *********************************************************************************************************************

import os
import psycopg2
import logging.config
import geoscape
import settings  # gets global vars

from datetime import datetime


def main():
    full_start_time = datetime.now()

    # log Python and OS versions
    logger.info(f"\t- running Python {settings.python_version} with Psycopg2 {settings.psycopg2_version}")
    logger.info(f"\t- on {settings.os_version}")

    # get Postgres connection & cursor
    pg_conn = psycopg2.connect(settings.pg_connect_string)
    pg_conn.autocommit = True
    pg_cur = pg_conn.cursor()

    # add postgis to database (in the public schema) - run this in a try to confirm db user has privileges
    try:
        pg_cur.execute("SET search_path = public, pg_catalog; CREATE EXTENSION IF NOT EXISTS postgis")
    except psycopg2.Error:
        logger.fatal("Unable to add PostGIS extension\nACTION: Check your Postgres user privileges or PostGIS install")
        return False

    # test if ST_Subdivide exists (only in PostGIS 2.2+). It's used to split boundaries for faster processing
    logger.info(f"\t- using Postgres {settings.pg_version} and PostGIS {settings.postgis_version} "
                f"(with GEOS {settings.geos_version})")

    # log the user's input parameters
    logger.info("")
    logger.info("Arguments")
    for arg in vars(settings.args):
        value = getattr(settings.args, arg)

        if value is not None:
            if arg != "pgpassword":
                logger.info(f"\t- {arg} : {value}")
            else:
                logger.info(f"\t- {arg} : ************")

    # START LOADING DATA

    # PART 1 - create new schemas
    logger.info("")
    start_time = datetime.now()
    logger.info(f"Part 1 of 6 : Create schemas : {start_time}")

    if settings.raw_gnaf_schema != "public":
        pg_cur.execute(f"CREATE SCHEMA IF NOT EXISTS {settings.raw_gnaf_schema} AUTHORIZATION {settings.pg_user}")
    if settings.raw_admin_bdys_schema != "public":
        pg_cur.execute(f"CREATE SCHEMA IF NOT EXISTS {settings.raw_admin_bdys_schema} AUTHORIZATION {settings.pg_user}")
    if settings.admin_bdys_schema != "public":
        pg_cur.execute(f"CREATE SCHEMA IF NOT EXISTS {settings.admin_bdys_schema} AUTHORIZATION {settings.pg_user}")
    if settings.gnaf_schema != "public":
        pg_cur.execute(f"CREATE SCHEMA IF NOT EXISTS {settings.gnaf_schema} AUTHORIZATION {settings.pg_user}")
    logger.info(f"Part 1 of 6 : Schemas created! : {datetime.now() - start_time}")

    # PART 2 - load gnaf from PSV files
    logger.info("")
    start_time = datetime.now()
    logger.info(f"Part 2 of 6 : Start raw GNAF load : {start_time}")
    drop_tables_and_vacuum_db(pg_cur)
    create_raw_gnaf_tables(pg_cur)
    populate_raw_gnaf(pg_cur)
    clean_authority_files(pg_cur, settings.raw_gnaf_schema, False)
    index_raw_gnaf(pg_cur)
    if settings.primary_foreign_keys:
        create_primary_foreign_keys()
    else:
        logger.info("\t- Step 6 of 7 : primary & foreign keys NOT created")
    analyse_raw_gnaf_tables(pg_cur)
    # set postgres search path back to the default
    pg_cur.execute("SET search_path = public, pg_catalog")
    logger.info(f"Part 2 of 6 : Raw GNAF loaded! : {datetime.now() - start_time}")

    # PART 3 - load raw admin boundaries from Shapefiles
    logger.info("")
    start_time = datetime.now()
    logger.info(f"Part 3 of 6 : Start raw admin boundary load : {start_time}")
    load_raw_admin_boundaries(pg_cur)
    clean_authority_files(pg_cur, settings.raw_admin_bdys_schema, True)
    prep_admin_bdys(pg_cur)
    create_admin_bdys_for_analysis()
    logger.info(f"Part 3 of 6 : Raw admin boundaries loaded! : {datetime.now() - start_time}")

    # PART 4 - create flattened and standardised GNAF and Administrative Boundary reference tables
    logger.info("")
    start_time = datetime.now()
    logger.info(f"Part 4 of 6 : Start create reference tables : {start_time}")
    create_reference_tables(pg_cur)
    logger.info(f"Part 4 of 6 : Reference tables created! : {datetime.now() - start_time}")

    # PART 5 - boundary tag GNAF addresses
    logger.info("")
    if settings.no_boundary_tag:
        logger.warning("Part 5 of 6 : Addresses NOT boundary tagged")
    else:
        start_time = datetime.now()
        logger.info(f"Part 5 of 6 : Start boundary tagging addresses : {start_time}")
        boundary_tag_gnaf(pg_cur)
        logger.info(f"Part 5 of 6 : Addresses boundary tagged : {datetime.now() - start_time}")

    # PART 6 - get record counts for QA
    logger.info("")
    start_time = datetime.now()
    logger.info(f"Part 6 of 6 : Start row counts : {start_time}")
    create_qa_tables(pg_cur)
    logger.info(f"Part 6 of 6 : Got row counts : {datetime.now() - start_time}")

    # close Postgres connection
    pg_cur.close()
    pg_conn.close()

    logger.info("")
    logger.info(f"Total time : {datetime.now() - full_start_time}")

    return True


def drop_tables_and_vacuum_db(pg_cur):
    # Step 1 of 7 : drop tables
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("01-01-drop-tables.sql"))
    logger.info(f"\t- Step 1 of 7 : tables dropped : {datetime.now() - start_time}")

    # Step 2 of 7 : vacuum database (if requested)
    start_time = datetime.now()
    if settings.vacuum_db:
        pg_cur.execute("VACUUM")
        logger.info(f"\t- Step 2 of 7 : database vacuumed : {datetime.now() - start_time}")
    else:
        logger.info("\t- Step 2 of 7 : database NOT vacuumed")


def create_raw_gnaf_tables(pg_cur):
    # Step 3 of 7 : create tables
    start_time = datetime.now()

    # prep create table sql scripts (note: file doesn't contain any schema prefixes on table names)
    sql = geoscape.open_sql_file("01-03-raw-gnaf-create-tables.sql")

    # set search path
    if settings.raw_gnaf_schema != "public":
        pg_cur.execute(f"SET search_path = {settings.raw_gnaf_schema}")

        # alter create table script to run on chosen schema
        sql = sql.replace("SET search_path = public", f"SET search_path = {settings.raw_gnaf_schema}")

    # set tables to unlogged to speed up the load? (if requested)
    # -- they'll have to be rebuilt using this script again after a system crash --
    if settings.unlogged_tables:
        sql = sql.replace("CREATE TABLE ", "CREATE UNLOGGED TABLE ")
        unlogged_string = "UNLOGGED "
    else:
        unlogged_string = ""

    # create raw gnaf tables
    pg_cur.execute(sql)

    logger.info(f"\t- Step 3 of 7 : {unlogged_string}tables created : {datetime.now() - start_time}")


# load raw gnaf authority & state tables using multiprocessing
def populate_raw_gnaf(pg_cur):
    # Step 4 of 7 : load raw gnaf authority & state tables
    start_time = datetime.now()

    # authority code file list
    sql_list = get_raw_gnaf_files("authority_code")

    # add state file lists
    for state in settings.states_to_load:
        logger.info(f"\t\t- Loading state {state}")
        sql_list.extend(get_raw_gnaf_files(state))

    # are there any files to load?
    if len(sql_list) == 0:
        logger.fatal("No raw GNAF PSV files found\nACTION: Check your 'gnaf_network_directory' path")
        logger.fatal("\t- Step 4 of 7 : table populate FAILED!")
    else:
        # load all PSV files using multiprocessing
        geoscape.multiprocess_list("sql", sql_list, logger)

        # fix missing geocodes (added due to missing data in 202111 release)
        sql = geoscape.open_sql_file("01-04-raw-gnaf-fix-missing-geocodes.sql")
        pg_cur.execute(sql)

        logger.info(f"\t- Step 4 of 7 : tables populated : {datetime.now() - start_time}")
        logger.info("\t\t- fixed missing geocodes")


def get_raw_gnaf_files(prefix):
    sql_list = []
    prefix = prefix.lower()
    # get a dictionary of all files matching the filename prefix
    for root, dirs, files in os.walk(settings.gnaf_network_directory):
        for file_name in files:
            if file_name.lower().startswith(prefix + "_"):
                if file_name.lower().endswith(".psv"):
                    file_path = os.path.join(root, file_name)\
                        .replace(settings.gnaf_network_directory, settings.gnaf_pg_server_local_directory)
                    table = file_name.lower().replace(prefix + "_", "", 1).replace("_psv", "").replace(".psv", "")

                    # if a non-Windows Postgres server OS - fix file path
                    if settings.gnaf_pg_server_local_directory[0:1] == "/":
                        file_path = file_path.replace("\\", "/")
                        # logger.info(file_path

                    sql = f"COPY {settings.raw_gnaf_schema}.{table} FROM '{file_path}' DELIMITER '|' CSV HEADER;"

                    sql_list.append(sql)

    return sql_list


# index raw gnaf using multiprocessing
def index_raw_gnaf(pg_cur):
    # Step 5 of 7 : create indexes
    start_time = datetime.now()

    raw_sql_list = geoscape.open_sql_file("01-05-raw-gnaf-create-indexes.sql").split("\n")
    sql_list = []
    for sql in raw_sql_list:
        if sql[0:2] != "--" and sql[0:2] != "":
            sql_list.append(sql)

    geoscape.multiprocess_list("sql", sql_list, logger)

    # # create distinct new & old locality pid lookup table
    # pg_cur.execute(geoscape.open_sql_file("01-05b-create-distinct-locality-pid-linkage-table.sql"))

    logger.info(f"\t- Step 5 of 7 : indexes created : {datetime.now() - start_time}")


# create raw gnaf primary & foreign keys (for data integrity) using multiprocessing
def create_primary_foreign_keys():
    start_time = datetime.now()

    key_sql = geoscape.open_sql_file("01-06-raw-gnaf-create-primary-foreign-keys.sql")
    key_sql_list = key_sql.split("--")
    sql_list = []

    for sql in key_sql_list:
        sql = sql.strip()
        if sql[0:6] == "ALTER ":
            # add schema to tables names, in case raw gnaf schema not the default
            sql = sql.replace(f"ALTER TABLE ONLY ", "ALTER TABLE ONLY {settings.raw_gnaf_schema}.")
            sql_list.append(sql)

    # run queries in separate processes
    geoscape.multiprocess_list("sql", sql_list, logger)

    logger.info(f"\t- Step 6 of 7 : primary & foreign keys created : {datetime.now() - start_time}")


# analyse raw GNAF tables that have not stats - need actual row counts for QA at the end
def analyse_raw_gnaf_tables(pg_cur):
    start_time = datetime.now()
    
    # get list of tables that haven't been analysed (i.e. that have no real row count)
    sql = f"""SELECT nspname|| '.' || relname AS table_name 
              FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
              WHERE nspname = '{settings.raw_gnaf_schema}' AND relkind='r' AND reltuples = 0"""
    pg_cur.execute(sql)

    sql_list = []

    for pg_row in pg_cur:
        sql_list.append(f"ANALYZE {pg_row[0]}")

    # run queries in separate processes
    geoscape.multiprocess_list("sql", sql_list, logger)

    logger.info(f"\t- Step 7 of 7 : tables analysed : {datetime.now() - start_time}")
    

# loads the admin bdy shapefiles using the shp2pgsql command line tool (part of PostGIS), using multiprocessing
def load_raw_admin_boundaries(pg_cur):
    start_time = datetime.now()

    # drop existing views
    pg_cur.execute(geoscape.open_sql_file("02-01-drop-admin-bdy-views.sql"))

    # add authority code tables
    settings.states_to_load.extend(["authority_code"])

    # get file list
    table_list = list()
    create_list = list()
    append_list = list()

    for state in settings.states_to_load:
        state = state.lower()
        # get a dictionary of Shapefiles and DBFs matching the state
        for root, dirs, files in os.walk(settings.admin_bdys_local_directory):
            for file_name in files:
                if file_name.lower().startswith(state + "_"):
                    if file_name.lower().endswith(".shp") or file_name.lower().endswith("_shp.dbf"):
                        file_dict = dict()

                        # list .shp files and standalone .dbf files - ignore the rest
                        if file_name.lower().endswith(".shp"):
                            file_dict["spatial"] = True
                            file_dict["file_path"] = os.path.join(root, file_name)
                        elif file_name.lower().endswith(".dbf") and not file_name.lower().endswith("_polygon_shp.dbf") and not file_name.lower().endswith("_point_shp.dbf"):
                            file_dict["spatial"] = False
                            file_dict["file_path"] = os.path.join(root, file_name)

                        if file_dict.get("file_path") is not None:
                            file_dict["pg_table"] = file_name.lower().replace(state + "_", "aus_", 1)\
                                .replace(".dbf", "").replace(".shp", "").replace("_shp", "")

                            file_dict["pg_schema"] = settings.raw_admin_bdys_schema

                            # set command line parameters depending on whether this is the 1st state
                            table_list_add = False

                            if file_dict["pg_table"] not in table_list:
                                table_list_add = True

                                file_dict["delete_table"] = True
                            else:
                                file_dict["delete_table"] = False

                            # if locality file from Towns folder: don't add - it's a duplicate
                            if "town points" not in file_dict["file_path"].lower():
                                if table_list_add:
                                    table_list.append(file_dict["pg_table"])
                                    create_list.append(file_dict)
                                else:
                                    # # don't add duplicates if more than one Authority Code file per boundary type
                                    # if "_aut_" not in file_name.lower():
                                    append_list.append(file_dict)
                            else:
                                if not file_dict["file_path"].lower().endswith("_locality_shp.dbf"):
                                    if table_list_add:
                                        table_list.append(file_dict["pg_table"])
                                        create_list.append(file_dict)
                                    else:
                                        # # don't add duplicates if more than one Authority Code file per boundary type
                                        # if "_aut_" not in file_name.lower():
                                        append_list.append(file_dict)

    # [print(table) for table in create_list]
    # print("---------------------------------------------------------------------------------------")
    # [print(table) for table in append_list]

    # are there any files to load?
    if len(create_list) == 0:
        logger.fatal("No admin boundary files found\nACTION: Check your 'admin-bdys-path' argument")
    else:
        # load files in separate processes
        geoscape.multiprocess_shapefile_load(create_list, logger)

        # Run the appends one at a time (Can't multiprocess as sets of parallel INSERTs can cause database deadlocks)
        for shp in append_list:
            result = geoscape.import_shapefile_to_postgres(shp["file_path"], shp["pg_table"], shp["pg_schema"],
                                                           shp["delete_table"], shp["spatial"])

            if result != "SUCCESS":
                logger.warning(result)

        logger.info(f"\t- Step 1 of 3 : raw admin boundaries loaded : {datetime.now() - start_time}")


def clean_authority_files(pg_cur, schema_name, create_indexes=False):
    # ensure authority tables have unique values - admin bdys now have duplicates
    start_time = datetime.now()

    error_count = 0

    # get table list for schema
    sql = f"""SELECT table_name
              FROM information_schema.tables
              WHERE table_schema='{schema_name}'
                  AND table_type='BASE TABLE'
                  AND table_name LIKE '%_aut'"""
    pg_cur.execute(sql)

    tables = pg_cur.fetchall()

    for table in tables:
        table_name = table[0]
        # print(table_name)

        # fix inconsistent field names with brute force method (issue loading Shapefile/DBF data)
        try:
            pg_cur.execute(f"ALTER TABLE {schema_name}.{table_name} RENAME COLUMN code_aut TO code")
        except psycopg2.Error:
            pass

        try:
            pg_cur.execute(f"ALTER TABLE {schema_name}.{table_name} RENAME COLUMN name_aut TO name")
        except psycopg2.Error:
            pass

        try:
            pg_cur.execute(f"ALTER TABLE {schema_name}.{table_name} RENAME COLUMN dscpn_aut TO description")
        except psycopg2.Error:
            pass

        try:
            pg_cur.execute(f"ALTER TABLE {schema_name}.{table_name} RENAME COLUMN desc_aut TO description")
        except psycopg2.Error:
            pass

        try:
            pg_cur.execute(f"ALTER TABLE {schema_name}.{table_name} RENAME COLUMN descriptio TO description")
        except psycopg2.Error:
            pass

        # fix inconsistent descriptions in meshblock authority table by setting them to null
        if table_name == "aus_mb_category_class_aut":
            pg_cur.execute(f"UPDATE {schema_name}.{table_name} SET description = NULL")

        # get original row count
        pg_cur.execute(f"SELECT count(*) FROM {schema_name}.{table_name}")
        old_row_count = int(pg_cur.fetchone()[0])

        # get distinct records
        sql = f"""DROP TABLE IF EXISTS temp_aut;
                  CREATE TABLE temp_aut AS
                  SELECT DISTINCT code, name, description FROM {schema_name}.{table_name};"""
        pg_cur.execute(sql)

        # get new row count
        pg_cur.execute("SELECT count(*) FROM temp_aut")
        new_row_count = int(pg_cur.fetchone()[0])

        # only delete and replace if duplicates found
        duplicate_row_count = old_row_count - new_row_count

        if duplicate_row_count > 0:
            # delete all rows
            pg_cur.execute(f"TRUNCATE TABLE {schema_name}.{table_name}")
            # insert distinct rows
            pg_cur.execute(f"INSERT INTO {schema_name}.{table_name} (code, name, description) SELECT * FROM temp_aut")

            logger.info(f"\t\t- {duplicate_row_count} duplicates removed from {schema_name}.{table_name}")

        # This is required due to complexities introduced by mix of authority
        #   and non-authority table admin bdy layers in the Aug 2021 release
        if create_indexes:
            # drop primary key on gid field
            try:
                pg_cur.execute(f"ALTER TABLE ONLY {schema_name}.{table_name} DROP CONSTRAINT {table_name}_pkey")
            except psycopg2.Error as e:
                pass

            # attempt to create a primary key on the authority code - failure will imply a raw data error from Geoscape
            try:
                pg_cur.execute(f"ALTER TABLE ONLY {schema_name}.{table_name} "
                               f"ADD CONSTRAINT {table_name}_pkey PRIMARY KEY (code)")
            except psycopg2.Error as ex:
                error_count += 1

                logger.warning(f"CAN'T CREATE PRIMARY KEY ON {schema_name}.{table_name} "
                               f"DUE TO DUPLICATE AUTHORITY CODE(S) : {ex}")

        # clean up
        pg_cur.execute("DROP TABLE IF EXISTS temp_aut")
        pg_cur.execute(f"VACUUM ANALYZE {schema_name}.{table_name}")

    # kill gnaf-loader if duplicates couldn't be fixed - significant data integrity issue
    if error_count > 0:
        exit()

    logger.info("\t\t- authority tables deduplicated")


def prep_admin_bdys(pg_cur):
    # Step 3 of 4 : create admin bdy tables read to be used
    start_time = datetime.now()

    # create tables using multiprocessing - using flag in file to split file up into sets of statements
    sql_list = geoscape.open_sql_file("02-02a-prep-admin-bdys-tables.sql").format(settings.srid).split("-- # --")
    sql_list = sql_list + geoscape.open_sql_file("02-02c-prep-census-2016-bdys-tables.sql").split("-- # --")
    sql_list = sql_list + geoscape.open_sql_file("02-02d-prep-census-2021-bdys-tables.sql").split("-- # --")

    # # Account for bdys that are not in states to load - not yet working
    # for sql in sql_list:
    #     if settings.states_to_load == ["OT"] and ".commonwealth_electorates " in sql:
    #         sql_list.remove(sql)
    #
    #     if settings.states_to_load == ["ACT"] and ".local_government_areas " in sql:
    #         sql_list.remove(sql)
    #
    #     logger.info(settings.states_to_load
    #
    #     if not ("NT" in settings.states_to_load or "SA" in settings.states_to_load
    #             or "VIC" in settings.states_to_load or "WA" in settings.states_to_load) \
    #             and ".local_government_wards " in sql:
    #         sql_list.remove(sql)
    #
    #     if settings.states_to_load == ["OT"] and ".state_lower_house_electorates " in sql:
    #         sql_list.remove(sql)
    #
    #     if not ("TAS" in settings.states_to_load or "VIC" in settings.states_to_load
    #             or "WA" in settings.states_to_load) and ".state_upper_house_electorates " in sql:
    #         sql_list.remove(sql)

    geoscape.multiprocess_list("sql", sql_list, logger)

    # Special case - remove custom outback bdy if South Australia not requested
    if "SA" not in settings.states_to_load:
        pg_cur.execute(geoscape.prep_sql("DELETE FROM admin_bdys.locality_bdys WHERE locality_pid = 'SA999999'"))
        pg_cur.execute(geoscape.prep_sql("VACUUM ANALYZE admin_bdys.locality_bdys"))

    logger.info(f"\t- Step 2 of 3 : admin boundaries prepped : {datetime.now() - start_time}")


def create_admin_bdys_for_analysis():
    # Step 3 of 3 : create admin bdy tables optimised for spatial analysis
    start_time = datetime.now()

    if settings.st_subdivide_supported:
        template_sql = geoscape.open_sql_file("02-03-create-admin-bdy-analysis-tables_template.sql")
        sql_list = list()

        for table in settings.admin_bdy_list:
            sql = template_sql.format(table[0], table[1], settings.srid)
            if table[0] == "locality_bdys":  # special case, need to change schema name
                # sql = sql.replace(settings.raw_admin_bdys_schema, settings.admin_bdys_schema)
                sql = sql.replace("name", "locality_name")
                # add postcodes
                sql = sql.replace("locality_name text NOT NULL,",
                                  "locality_name text NOT NULL, postcode text NULL,")
                sql = sql.replace("locality_name,", "locality_name, postcode,")

            sql_list.append(sql)
        geoscape.multiprocess_list("sql", sql_list, logger)
        logger.info(f"\t- Step 3 of 3 : admin boundaries for analysis created : {datetime.now() - start_time}")
    else:
        logger.warning("\t- Step 3 of 3 : admin boundaries for analysis NOT created - "
                       "requires PostGIS 2.2+ with GEOS 3.5.0+")


# create gnaf reference tables by flattening raw gnaf address, streets & localities into a usable form
# also creates all supporting lookup tables and usable admin bdy tables
def create_reference_tables(pg_cur):
    # set postgres search path back to the default
    pg_cur.execute("SET search_path = public, pg_catalog")

    # Step 1 of 14 : create reference tables
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-01-reference-create-tables.sql").format(settings.srid))
    logger.info(f"\t- Step  1 of 14 : create reference tables : {datetime.now() - start_time}")

    # Step 2 of 14 : populate localities
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-02-reference-populate-localities.sql").format(settings.srid))
    logger.info(f"\t- Step  2 of 14 : localities populated : {datetime.now() - start_time}")

    # Step 3 of 14 : populate locality aliases
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-03-reference-populate-locality-aliases.sql"))
    logger.info(f"\t- Step  3 of 14 : locality aliases populated : {datetime.now() - start_time}")

    # Step 4 of 14 : populate locality neighbours
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-04-reference-populate-locality-neighbours.sql"))
    logger.info(f"\t- Step  4 of 14 : locality neighbours populated : {datetime.now() - start_time}")

    # Step 5 of 14 : populate streets
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-05-reference-populate-streets.sql").format(settings.srid))
    logger.info(f"\t- Step  5 of 14 : streets populated : {datetime.now() - start_time}")

    # Step 6 of 14 : populate street aliases
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-06-reference-populate-street-aliases.sql"))
    logger.info(f"\t- Step  6 of 14 : street aliases populated : {datetime.now() - start_time}")

    # Step 7 of 14 : populate addresses, using multiprocessing
    start_time = datetime.now()
    sql = geoscape.open_sql_file("03-07-reference-populate-addresses-1.sql").format(settings.srid)
    sql_list = geoscape.split_sql_into_list(pg_cur, sql, settings.gnaf_schema, "streets", "str", "gid", logger)
    if sql_list is not None:
        geoscape.multiprocess_list("sql", sql_list, logger)
    pg_cur.execute(geoscape.prep_sql("ANALYZE gnaf.temp_addresses;"))
    logger.info(f"\t- Step  7 of 14 : addresses populated : {datetime.now() - start_time}")

    # Step 8 of 14 : populate principal alias lookup
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-08-reference-populate-address-alias-lookup.sql"))
    logger.info(f"\t- Step  8 of 14 : principal alias lookup populated : {datetime.now() - start_time}")

    # Step 9 of 14 : populate primary secondary lookup
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-09-reference-populate-address-secondary-lookup.sql"))
    pg_cur.execute(geoscape.prep_sql("VACUUM ANALYSE gnaf.address_secondary_lookup"))
    logger.info(f"\t- Step  9 of 14 : primary secondary lookup populated : {datetime.now() - start_time}")

    # Step 10 of 14 : split the Melbourne locality into its 2 postcodes (3000, 3004)
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-10-reference-split-melbourne.sql").format(settings.srid))
    logger.info(f"\t- Step 10 of 14 : Melbourne split : {datetime.now() - start_time}")

    # Step 11 of 14 : finalise localities assigned to streets and addresses
    start_time = datetime.now()
    pg_cur.execute(geoscape.open_sql_file("03-11-reference-finalise-localities.sql"))
    logger.info(f"\t- Step 11 of 14 : localities finalised : {datetime.now() - start_time}")

    # Step 12 of 14 : finalise addresses, using multiprocessing
    start_time = datetime.now()
    sql = geoscape.open_sql_file("03-12-reference-populate-addresses-2.sql")
    sql_list = geoscape.split_sql_into_list(pg_cur, sql, settings.gnaf_schema, "localities", "loc", "gid", logger)
    if sql_list is not None:
        geoscape.multiprocess_list("sql", sql_list, logger)

    # turf the temp address table
    pg_cur.execute(geoscape.prep_sql("DROP TABLE IF EXISTS gnaf.temp_addresses"))
    logger.info(f"\t- Step 12 of 14 : addresses finalised : {datetime.now() - start_time}")

    # Step 13 of 14 : create almost correct postcode boundaries by aggregating localities, using multiprocessing
    start_time = datetime.now()
    sql = geoscape.open_sql_file("03-13-reference-derived-postcode-bdys.sql")
    sql_list = []
    for state in settings.states_to_load:
        state_sql = sql.replace("GROUP BY ", f"WHERE state = '{state}' GROUP BY ")
        sql_list.append(state_sql)
    geoscape.multiprocess_list("sql", sql_list, logger)

    # create analysis table?
    if settings.st_subdivide_supported:
        pg_cur.execute(geoscape.open_sql_file("03-13a-create-postcode-analysis-table.sql")).format(settings.srid)

    logger.info(f"\t- Step 13 of 14 : postcode boundaries created : {datetime.now() - start_time}")

    # Step 14 of 14 : create indexes, primary and foreign keys, using multiprocessing
    start_time = datetime.now()
    raw_sql_list = geoscape.open_sql_file("03-14-reference-create-indexes.sql").split("\n")
    sql_list = []
    for sql in raw_sql_list:
        if sql[0:2] != "--" and sql[0:2] != "":
            sql_list.append(sql)
    geoscape.multiprocess_list("sql", sql_list, logger)
    logger.info(f"\t- Step 14 of 14 : create primary & foreign keys and indexes : {datetime.now() - start_time}")


def boundary_tag_gnaf(pg_cur):

    # create bdy table list
    # remove localities, postcodes and states as these IDs are already assigned to GNAF addresses
    table_list = list()
    for table in settings.admin_bdy_list:
        if table[0] not in ["locality_bdys", "postcode_bdys", "state_bdys"]:
            # if no analysis tables created - use the full tables instead of the subdivided ones
            # WARNING: this can add hours to the processing
            if settings.st_subdivide_supported:
                table_name = f"{table[0]}_analysis"
            else:
                table_name = table[0]

            table_list.append([table_name, table[1]])

    # create bdy tagged address tables
    for address_table in ["address_principal", "address_alias"]:
        pg_cur.execute(f"DROP TABLE IF EXISTS {settings.gnaf_schema}.{address_table}_admin_boundaries CASCADE")
        create_table_list = list()
        create_table_list.append(f"""CREATE TABLE {settings.gnaf_schema}.{address_table}_admin_boundaries (
                                 gid serial NOT NULL,
                                 gnaf_pid text NOT NULL,
                                 -- alias_principal character(1) NOT NULL,
                                 locality_pid text NOT NULL,
                                 -- old_locality_pid text NULL,
                                 locality_name text NOT NULL,
                                 postcode text,
                                 state text NOT NULL""")

        for table in table_list:
            pid_field = table[1]
            name_field = pid_field.replace("_pid", "_name")
            create_table_list.append(f", {pid_field} text, {name_field} text")
        create_table_list.append(f""") WITH (OIDS=FALSE);
                                     ALTER TABLE {settings.gnaf_schema}.{address_table}_admin_boundaries 
                                     OWNER TO {settings.pg_user}""")
        pg_cur.execute("".join(create_table_list))

    # Step 1 of 7 : tag gnaf addresses with admin boundary IDs, using multiprocessing
    start_time = datetime.now()

    # create temp tables
    template_sql = geoscape.open_sql_file("04-01a-bdy-tag-create-table-template.sql")
    for table in table_list:
        pg_cur.execute(template_sql.format(table[0],))

    # create temp tables of bdy tagged gnaf_pids
    template_sql = geoscape.open_sql_file("04-01b-bdy-tag-template.sql")
    sql_list = list()
    for table in table_list:
        sql = template_sql.format(table[0], table[1])

        short_sql_list = geoscape.split_sql_into_list(pg_cur, sql, settings.admin_bdys_schema, table[0],
                                                      "bdys", "gid", logger)

        if short_sql_list is not None:
            sql_list.extend(short_sql_list)

    # logger.info("\n".join(sql_list))

    if sql_list is not None:
        geoscape.multiprocess_list("sql", sql_list, logger)

    logger.info(f"\t- Step 1 of 7 : principal addresses tagged with admin boundary IDs: {datetime.now() - start_time}")
    start_time = datetime.now()

    # Step 2 of 7 : delete invalid matches, create indexes and analyse tables
    sql_list = list()
    for table in table_list:
        sql = f"""DELETE FROM {settings.gnaf_schema}.temp_{table[0]}_tags 
                      WHERE gnaf_state <> bdy_state AND gnaf_state <> 'OT';
                  CREATE INDEX temp_{table[0]}_tags_gnaf_pid_idx 
                      ON {settings.gnaf_schema}.temp_{table[0]}_tags USING btree(gnaf_pid);
                  ANALYZE {settings.gnaf_schema}.temp_{table[0]}_tags"""""
        sql_list.append(sql)
    geoscape.multiprocess_list("sql", sql_list, logger)

    logger.info(f"\t- Step 2 of 7 : principal addresses - invalid matches deleted & bdy tag indexes created : "
                f"{datetime.now() - start_time}")
    start_time = datetime.now()

    # Step 3 of 7 : insert boundary tagged addresses

    # create insert statement for multiprocessing
    insert_field_list = list()
    insert_field_list.append("(gnaf_pid, locality_pid, locality_name, postcode, state")

    insert_join_list = list()
    insert_join_list.append(f"FROM {settings.gnaf_schema}.address_principals AS pnts ")

    select_field_list = list()
    select_field_list.append("SELECT pnts.gnaf_pid, pnts.locality_pid, pnts.locality_name, pnts.postcode, pnts.state")

    drop_table_list = list()

    for table in table_list:
        pid_field = table[1]
        name_field = pid_field. replace("_pid", "_name")
        insert_field_list.append(f", {pid_field}, {name_field}")
        select_field_list.append(f", temp_{table[0]}_tags.bdy_pid, temp_{table[0]}_tags.bdy_name ")
        insert_join_list.append(f"LEFT OUTER JOIN {settings.gnaf_schema}.temp_{table[0]}_tags "
                                f"ON pnts.gnaf_pid = temp_{table[0]}_tags.gnaf_pid ")
        drop_table_list.append(f"DROP TABLE IF EXISTS {settings.gnaf_schema}.temp_{table[0]}_tags;")

    insert_field_list.append(") ")

    insert_statement_list = list()
    insert_statement_list.append(f"INSERT INTO {settings.gnaf_schema}.address_principal_admin_boundaries ")
    insert_statement_list.append("".join(insert_field_list))
    insert_statement_list.append("".join(select_field_list))
    insert_statement_list.append("".join(insert_join_list))

    sql = "".join(insert_statement_list) + ";"
    sql_list = geoscape.split_sql_into_list(pg_cur, sql, settings.gnaf_schema, "address_principals", 
                                            "pnts", "gid", logger)
    # logger.info("\n".join(sql_list)

    if sql_list is not None:
        geoscape.multiprocess_list("sql", sql_list, logger)

    # drop temp tables
    pg_cur.execute("".join(drop_table_list))

    # get stats
    pg_cur.execute(f"ANALYZE {settings.gnaf_schema}.address_principal_admin_boundaries ")

    logger.info(f"\t- Step 3 of 7 : principal addresses - bdy tags added to output table : "
                f"{datetime.now() - start_time}")

    start_time = datetime.now()

    # Step 4 of 7 : add index to output table
    sql = f"CREATE INDEX address_principal_admin_boundaries_gnaf_pid_idx " \
          f"ON {settings.gnaf_schema}.address_principal_admin_boundaries USING btree (gnaf_pid)"
    pg_cur.execute(sql)

    logger.info(f"\t- Step 4 of 7 : created index on bdy tagged address table : {datetime.now() - start_time}")
    start_time = datetime.now()

    # Step 5 of 7 : log duplicates - happens when 2 boundaries overlap by a very small amount
    # (can be ignored if there's a small number of records affected)
    sql = f"""SELECT gnaf_pid FROM (
                  SELECT Count(*) AS cnt, gnaf_pid 
                  FROM {settings.gnaf_schema}.address_principal_admin_boundaries 
                  GROUP BY gnaf_pid
              ) AS sqt WHERE cnt > 1"""
    pg_cur.execute(sql)

    # get cursor description to test if any rows returned safely
    columns = pg_cur.description

    # log gnaf_pids that got duplicate results
    if columns is not None:
        duplicates = pg_cur.fetchall()
        gnaf_pids = list()

        for duplicate in duplicates:
            gnaf_pids.append("\t\t" + duplicate[0])

        if len(gnaf_pids) > 0:
            logger.warning("\t- Step 5 of 7 : found boundary tag duplicates : {datetime.now() - start_time}")
            logger.warning("\n".join(gnaf_pids))
        else:
            logger.info("\t- Step 5 of 7 : no boundary tag duplicates : {datetime.now() - start_time}")
    else:
        logger.info("\t- Step 5 of 7 : no boundary tag duplicates : {datetime.now() - start_time}")

    # Step 6 of 7 : Copy principal boundary tags to alias addresses
    pg_cur.execute(geoscape.open_sql_file("04-06-bdy-tags-for-alias-addresses.sql"))
    logger.info("\t- Step 6 of 7 : alias addresses boundary tagged : {datetime.now() - start_time}")
    start_time = datetime.now()

    # Step 7 of 7 : Create view of all bdy tags
    pg_cur.execute(geoscape.open_sql_file("04-07-create-bdy-tag-view.sql"))
    logger.info("\t- Step 7 of 7 : boundary tagged address view created : {datetime.now() - start_time}")


def create_qa_tables(pg_cur):
    start_time = datetime.now()

    i = 0

    for schema in [settings.gnaf_schema, settings.admin_bdys_schema]:

        i += 1

        # STEP 1 - get row counts of tables in each schema, by state, for visual QA

        # create qa table of rows counts
        sql = f"""DROP TABLE IF EXISTS {schema}.qa;
                  CREATE TABLE {schema}.qa (table_name text, aus integer, act integer, nsw integer, nt integer, 
                      ot integer, qld integer, sa integer, tas integer, vic integer, wa integer) 
                  WITH (OIDS=FALSE);
                  ALTER TABLE {schema}.qa OWNER TO {settings.pg_user}"""
        pg_cur.execute(sql)

        # get table names in schema
        sql = f"""SELECT table_name 
                  FROM information_schema.tables 
                  WHERE table_schema = '{schema}' 
                      AND table_name <> 'qa' 
                  ORDER BY table_name"""
        pg_cur.execute(sql)

        table_names = []
        for pg_row in pg_cur:
            table_names.append(pg_row[0])

        # get row counts by state
        for table_name in table_names:
            sql = f"""INSERT INTO {schema}.qa 
                      SELECT '{table_name}', SUM(AUS), SUM(ACT), SUM(NSW), SUM(NT), SUM(OT), SUM(QLD), SUM(SA), 
                          SUM(TAS), SUM(VIC), SUM(WA) 
                      FROM (
                          SELECT 1 AS AUS,
                          CASE WHEN state = 'ACT' THEN 1 ELSE 0 END AS ACT,
                          CASE WHEN state = 'NSW' THEN 1 ELSE 0 END AS NSW,
                          CASE WHEN state = 'NT' THEN 1 ELSE 0 END AS NT,
                          CASE WHEN state = 'OT' THEN 1 ELSE 0 END AS OT,
                          CASE WHEN state = 'QLD' THEN 1 ELSE 0 END AS QLD,
                          CASE WHEN state = 'SA' THEN 1 ELSE 0 END AS SA,
                          CASE WHEN state = 'TAS' THEN 1 ELSE 0 END AS TAS,
                          CASE WHEN state = 'VIC' THEN 1 ELSE 0 END AS VIC,
                          CASE WHEN state = 'WA' THEN 1 ELSE 0 END AS WA 
                          FROM {schema}.{table_name}
                      ) AS sqt"""

            try:
                pg_cur.execute(sql)
            except psycopg2.Error:  # triggers when there is no state field in the table
                # change the query for an Australia count only
                sql = f"INSERT INTO {schema}.qa (table_name, aus) " \
                      f"SELECT '{table_name}', Count(*) FROM {schema}.{table_name}"

                try:
                    pg_cur.execute(sql)
                except Exception as ex:
                    # if no state field - change the query for an Australia count only
                    logger.warning(f"Couldn't get row count for {schema}.{table_name} : {ex}")

        pg_cur.execute(f"ANALYZE {schema}.qa")

        # STEP 2 - compare row counts with previous Geoscape release

        # get previous schema name
        if "gnaf_" in schema:
            previous_schema = settings.previous_gnaf_schema
        else:
            previous_schema = settings.previous_admin_bdys_schema

        # check if previous schema exists in database
        pg_cur.execute(f"SELECT schema_name FROM information_schema.schemata WHERE schema_name = '{previous_schema}'")
        test_schema_row = pg_cur.fetchone()

        if test_schema_row is not None:
            # create qa table of rows counts
            sql = f"""DROP TABLE IF EXISTS {schema}.qa_comparison;
                      CREATE TABLE {schema}.qa_comparison (
                          table_name text,
                          difference integer,
                          new_count integer,
                          old_count integer
                     ) WITH (OIDS=FALSE);
                     ALTER TABLE {schema}.qa_comparison OWNER TO {settings.pg_user}"""
            pg_cur.execute(sql)

            # into get counts into qa_comparison table
            sql = f"""INSERT INTO {schema}.qa_comparison
                      SELECT new.table_name,
                             new.aus - old.aus as difference,
                             new.aus as new_count,
                             old.aus as old_count
                      FROM {schema}.qa as new
                      INNER JOIN {previous_schema}.qa as old ON new.table_name = old.table_name"""
            pg_cur.execute(sql)

            pg_cur.execute(f"ANALYZE {schema}.qa_comparison")

            # pretty print row counts to screen
            pg_cur.execute(f"SELECT * FROM {schema}.qa_comparison ORDER BY table_name")
            rows = pg_cur.fetchall()

            logger.info("\t\t------------------------------------------------------------------------")
            logger.info("\t\t|{:39}|{:10}|{:9}|{:9}|".format("table_name", "difference", "new_count", "old_count"))
            logger.info("\t\t------------------------------------------------------------------------")

            for row in rows:
                logger.info("\t\t|{:39}|{:10}|{:9}|{:9}|".format(row[0], row[1], row[2], row[3]))

            logger.info("\t\t------------------------------------------------------------------------")

        else:
            logger.warning(f"\t\t- Previous schema ({previous_schema}) doesn't exist - row count comparison not done")

        logger.info(f"\t- Step {i} of 2 : got row counts for {schema} schema : {datetime.now() - start_time}")


if __name__ == "__main__":
    logger = logging.getLogger()

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

    logger.info("")
    logger.info("Start gnaf-loader")

    if main():
        logger.info("Finished successfully!")
    else:
        logger.fatal("Something bad happened!")

    logger.info("")
    logger.info("-------------------------------------------------------------------------------")
