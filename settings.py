# takes the command line parameters and creates a dictionary of settings

import os
import argparse
import geoscape

from datetime import datetime


# set the command line arguments for the script
def get_settings():

    parser = argparse.ArgumentParser(
        description="A quick way to load the complete GNAF and Geoscape Admin Boundaries into Postgres, "
                    "simplified and ready to use as reference data for geocoding, analysis and visualisation.")

    parser.add_argument(
        "--prevacuum", action="store_true", help="Forces database to be vacuumed after dropping tables.")
    parser.add_argument(
        "--raw-fk", action="store_true",
        help="Creates primary & foreign keys for the raw GNAF tables (adds time to data load)")
    parser.add_argument(
        "--raw-unlogged", action="store_true",
        help="Creates unlogged raw GNAF tables, speeding up the import. Only specify this option if you don\"t care "
             "about the raw data afterwards - they will be lost if the server crashes!")
    parser.add_argument(
        "--max-processes", type=int, default=4,
        help="Maximum number of parallel processes to use for the data load. (Set it to the number of cores on the "
             "Postgres server minus 2, limit to 12 if 16+ cores - there is minimal benefit beyond 12). Defaults to 4.")
    parser.add_argument(
        "--no-boundary-tag", action="store_true", dest="no_boundary_tag",
        help="DO NOT tag all addresses with admin boundary IDs for creating aggregates and choropleth maps. "
             "IMPORTANT: this will contribute 15-60 minutes to the process if you have PostGIS 2.2+. "
             "WARNING: if you have PostGIS 2.1 or lower - this process can take hours")

    # PG Options
    parser.add_argument(
        "--pghost",
        help="Host name for Postgres server. Defaults to PGHOST environment variable if set, otherwise localhost.")
    parser.add_argument(
        "--pgport", type=int,
        help="Port number for Postgres server. Defaults to PGPORT environment variable if set, otherwise 5432.")
    parser.add_argument(
        "--pgdb",
        help="Database name for Postgres server. Defaults to PGDATABASE environment variable if set, "
             "otherwise geoscape.")
    parser.add_argument(
        "--pguser",
        help="Username for Postgres server. Defaults to PGUSER environment variable if set, otherwise postgres.")
    parser.add_argument(
        "--pgpassword",
        help="Password for Postgres server. Defaults to PGPASSWORD environment variable if set, "
             "otherwise \"password\".")

    # schema names for the raw gnaf, flattened reference and admin boundary tables
    geoscape_version = geoscape.get_geoscape_version(datetime.today())
    parser.add_argument(
        "--geoscape-version", default=geoscape_version,
        help="Geoscape Version number as YYYYMM. Defaults to last release year and month \"<geoscape-version>\".")
    parser.add_argument(
        "--raw-gnaf-schema",
        help="Schema name to store raw GNAF tables in. Defaults to \"raw_gnaf_<geoscape-version>\".")
    parser.add_argument(
        "--raw-admin-schema",
        help="Schema name to store raw admin boundary tables in. Defaults to \"raw_admin_bdys_<geoscape-version>\".")
    parser.add_argument(
        "--gnaf-schema",
        help="Destination schema name to store final GNAF tables in. Defaults to \"gnaf_<geoscape-version>\".")
    parser.add_argument(
        "--admin-schema",
        help="Destination schema name to store final admin boundary tables in. Defaults to \"admin_bdys_"
             + geoscape_version + "\".")

    # directories
    parser.add_argument(
        "--gnaf-tables-path", required=True,
        help="Path to source GNAF tables (*.psv files). This directory must be accessible by the Postgres server, "
             "and the local path to the directory for the server must be set via the local-server-dir argument "
             "if it differs from this path.")
    parser.add_argument(
        "--local-server-dir",
        help="Local path on server corresponding to gnaf-tables-path, if different to gnaf-tables-path.")
    parser.add_argument(
        "--admin-bdys-path", required=True, help="Local path to source admin boundary files.")

    # states to load
    parser.add_argument("--states", nargs="+", choices=["ACT", "NSW", "NT", "OT", "QLD", "SA", "TAS", "VIC", "WA"],
                        default=["ACT", "NSW", "NT", "OT", "QLD", "SA", "TAS", "VIC", "WA"],
                        help="List of states to load data for. Defaults to all states.")

    args = parser.parse_args()

    settings = dict()

    settings["vacuum_db"] = args.prevacuum
    settings["primary_foreign_keys"] = args.raw_fk
    settings["unlogged_tables"] = args.raw_unlogged
    settings["max_processes"] = args.max_processes
    settings["geoscape_version"] = args.geoscape_version
    settings["states_to_load"] = args.states
    settings["no_boundary_tag"] = args.no_boundary_tag
    settings["raw_gnaf_schema"] = args.raw_gnaf_schema or "raw_gnaf_" + settings["geoscape_version"]
    settings["raw_admin_bdys_schema"] = args.raw_admin_schema or "raw_admin_bdys_" + settings["geoscape_version"]
    settings["gnaf_schema"] = args.gnaf_schema or "gnaf_" + settings["geoscape_version"]
    settings["admin_bdys_schema"] = args.admin_schema or "admin_bdys_" + settings["geoscape_version"]
    settings["gnaf_network_directory"] = args.gnaf_tables_path.replace("\\", "/")
    if args.local_server_dir:
        settings["gnaf_pg_server_local_directory"] = args.local_server_dir.replace("\\", "/")
    else:
        settings["gnaf_pg_server_local_directory"] = settings["gnaf_network_directory"]
    settings["admin_bdys_local_directory"] = args.admin_bdys_path.replace("\\", "/")

    # create postgres connect string
    settings["pg_host"] = args.pghost or os.getenv("PGHOST", "localhost")
    settings["pg_port"] = args.pgport or os.getenv("PGPORT", 5432)
    settings["pg_db"] = args.pgdb or os.getenv("PGDATABASE", "geoscape")
    settings["pg_user"] = args.pguser or os.getenv("PGUSER", "postgres")
    settings["pg_password"] = args.pgpassword or os.getenv("PGPASSWORD", "password")

    settings["pg_connect_string"] = "dbname='{0}' host='{1}' port='{2}' user='{3}' password='{4}'".format(
        settings["pg_db"], settings["pg_host"], settings["pg_port"], settings["pg_user"], settings["pg_password"])

    # set postgres script directory
    settings["sql_dir"] = os.path.join(os.path.dirname(os.path.realpath(__file__)), "postgres-scripts")

    settings["sql_dir"] = os.path.join(os.path.dirname(os.path.realpath(__file__)), "postgres-scripts")

    # set the list of admin bdys to create analysis tables for and to boundary tag with
    admin_bdy_list = list()
    admin_bdy_list.append(["state_bdys", "state_pid"])
    admin_bdy_list.append(["locality_bdys", "locality_pid"])

    # only process bdys if states to load have them
    if settings["states_to_load"] != ["OT"]:
        admin_bdy_list.append(["commonwealth_electorates", "ce_pid"])
    if settings["states_to_load"] != ["ACT"]:
        admin_bdy_list.append(["local_government_areas", "lga_pid"])
    if "NT" in settings["states_to_load"] or "SA" in settings["states_to_load"] \
            or "VIC" in settings["states_to_load"] or "WA" in settings["states_to_load"]:
        admin_bdy_list.append(["local_government_wards", "ward_pid"])
    if settings["states_to_load"] != ["OT"]:
        admin_bdy_list.append(["state_lower_house_electorates", "se_lower_pid"])
    if "TAS" in settings["states_to_load"] or "VIC" in settings["states_to_load"] or "WA" in settings["states_to_load"]:
        admin_bdy_list.append(["state_upper_house_electorates", "se_upper_pid"])
    settings["admin_bdy_list"] = admin_bdy_list

    return settings
