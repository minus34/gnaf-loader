
import math
import os
import psycopg2

# create postgres connect string
settings = dict()
settings['pg_host'] = os.getenv("PGHOST", "localhost")
settings['pg_port'] = os.getenv("PGPORT", 5432)
settings['pg_db'] = os.getenv("PGDATABASE", "psma_201605")
settings['pg_user'] = os.getenv("PGUSER", "postgres")
settings['pg_password'] = os.getenv("PGPASSWORD", "password")
settings['pg_schema'] = "govhack2016"

settings['pg_connect_string'] = "dbname='{0}' host='{1}' port='{2}' user='{3}' password='{4}'".format(
    settings['pg_db'], settings['pg_host'], settings['pg_port'], settings['pg_user'], settings['pg_password'])


def main():

    # Try to connect to Postgres
    try:
        pg_conn = psycopg2.connect(settings['pg_connect_string'])
    except psycopg2.Error:
        return "Unable to connect to the database."

    pg_cur = pg_conn.cursor()

    table_name = "display_geoms"

    sql = "SELECT division_name || ', ' || state AS name, percent, pop_percent, " \
          "ST_AsGeoJSON(geom, 3) AS geometry " \
          "FROM govhack2016.commonwealth_electorates_pe"

    try:
        pg_cur.execute(sql)
    except psycopg2.Error:
        return "I can't SELECT : " + sql

    # Retrieve the results of the query
    rows = pg_cur.fetchall()
    # row_count = pg_cur.rowcount

    # Get the column names returned
    col_names = [desc[0] for desc in pg_cur.description]

    # Find the index of the column that holds the geometry
    geom_index = col_names.index("geometry")

    # output is the main content, row_output is the content from each record returned
    output = ['{"type":"FeatureCollection","features":[']
    i = 0

    # For each row returned...
    while i < len(rows):
        # Make sure the geometry exists
        if rows[i][geom_index] is not None:
            # If it's the first record, don't add a comma
            comma = "," if i > 0 else ""
            feature = [''.join([comma, '{"type":"Feature","geometry":', rows[i][geom_index], ',"properties":{'])]

            j = 0
            # For each field returned, assemble the properties object
            while j < len(col_names):
                if col_names[j] != 'geometry':
                    comma = "," if j > 0 else ""
                    feature.append(''.join([comma, '"', col_names[j], '":"', str(rows[i][j]), '"']))

                j += 1

            feature.append('}}')
            row_output = ''.join([item for item in feature])
            output.append(row_output)

        # start over
        i += 1

    output.append(']}')

    # Assemble the GeoJSON
    total_output = ''.join([item for item in output])

    pg_cur.close()
    pg_conn.close()

    text_file = open("/Users/hugh/GitHub/please-explain/web/geoms.json", "w")
    text_file.write(total_output)
    text_file.close()

if __name__ == '__main__':
    main()