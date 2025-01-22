import argparse
import geopandas
import os
import sqlalchemy

# get test number
parser = argparse.ArgumentParser(description="Test load SHP > Postgres")
parser.add_argument("--test", help="the test number")
parser.add_argument("--path", help="path to the input SHP file")
args = parser.parse_args()
test_number = args.test
file_path = args.path

# -- START EDIT SETTINGS ----------------------------------------------------------------------------------------------

# postgres connect string - format: "postgresql+psycopg://<username>:<password>@<host>:<port>/<database>"
sql_alchemy_engine_string = "postgresql+psycopg://postgres:password@localhost:5432/geo"

# -- END EDIT SETTINGS ------------------------------------------------------------------------------------------------

states = ["ACT", "NSW", "NT", "OT", "QLD", "SA", "TAS", "VIC", "WA"]

schema_name = "testing"
table_name = "locality_geopandas_{}".format(test_number)

# Set PyGEOS to True to speed up GeoPandas
geopandas.options.use_pygeos = True

# create database engine
sql_engine = sqlalchemy.create_engine(sql_alchemy_engine_string, isolation_level="AUTOCOMMIT")

# process each state sequentially
for state in states:
    input_file = os.path.join(file_path, "{}_localities.shp".format(state))

    if state == "ACT":
        print(f"  - importing {state}", end="")
        table_action = "replace"
    else:
        print(f", {state}", end="")
        table_action = "append"

    # import Shapefile to GeoPandas
    df = geopandas.read_file(input_file)

    # Export to Postgres
    df.to_postgis(table_name, sql_engine, schema=schema_name, if_exists=table_action, index=False)
