import argparse
import geopandas
import sqlalchemy

# get test number
parser = argparse.ArgumentParser(description="Test load SHP > Postgres")
parser.add_argument("--test", help="the test number")
args = parser.parse_args()
test_number = args.test

# -- START EDIT SETTINGS ----------------------------------------------------------------------------------------------

# postgres connect string - format: "postgresql+psycopg2://<username>:<password>@<host>:<port>/<database>"
sql_alchemy_engine_string = "postgresql+psycopg2://postgres:password@localhost:5432/geo"

# -- END EDIT SETTINGS ------------------------------------------------------------------------------------------------

input_file_path = "/Users/s57405/Downloads/AUG21_Admin_Boundaries_ESRIShapefileorDBFfile/Localities_AUG21_GDA94_SHP/Localities/Localities AUGUST 2021/Standard/{}_localities.shp"

states = ["ACT", "NSW", "NT", "OT", "QLD", "SA", "TAS", "VIC", "WA"]

schema_name = "testing"
table_name = "locality_geopandas_{}".format(test_number)

# Set PyGEOS to True to speed up GeoPandas
geopandas.options.use_pygeos = True

# create database engine
sql_engine = sqlalchemy.create_engine(sql_alchemy_engine_string, isolation_level="AUTOCOMMIT")

# process each state sequentially
for state in states:
    input_file = input_file_path.format(state)

    if state == "ACT":
        print("  - importing {}".format(state), end="")
        table_action = "replace"
    else:
        print(", {}".format(state), end="")
        table_action = "append"

    # import Shapefile to GeoPandas
    df = geopandas.read_file(input_file)

    # Export to Postgres
    df.to_postgis(table_name, sql_engine, schema=schema_name, if_exists=table_action, index=False)
