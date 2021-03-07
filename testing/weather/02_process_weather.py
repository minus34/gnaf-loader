# script gets all Australian BoM weather station observations
# ... and applies an interpolated temperature to all GNAF points in a 100m grid

# TODO:
#  1. remove temperature biases due to altitude differences
#       a. Add SRTM altitudes to GNAF
#       b. Add interpolated altitude from weather stations to GNAF
#       c. adjust where the difference is > 100m
#  2. generate temps outside the weather station network to catch the ~3,100 GNAF points outside the interpolated area
#

import geopandas
import io
import json
import logging
import matplotlib.pyplot as plt
import multiprocessing
import numpy
import os
import pandas
import psycopg2
import requests
import scipy.interpolate
import sqlalchemy
import struct
import urllib.request
import zipfile

from bs4 import BeautifulSoup
from datetime import datetime
from osgeo import gdal

# where to save the files
output_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "data")

# states to include (note: no "ACT" or "OT" state, Antarctica is part of TAS in BoM observations)
states = [{"name": "NSW", "product": "IDN60801"},
          {"name": "NT", "product": "IDD60801"},
          {"name": "QLD", "product": "IDQ60801"},
          {"name": "SA", "product": "IDS60801"},
          {"name": "TAS", "product": "IDT60801"},
          {"name": "VIC", "product": "IDV60801"},
          {"name": "WA", "product": "IDW60801"},
          {"name": "ANT", "product": "IDT60801"}]

# urls for each state's weather observations
base_url = "http://www.bom.gov.au/{0}/observations/{0}all.shtml"

# postgres connect strings
pg_connect_string = "dbname='geo' host='localhost' port='5432' user='postgres' password='password'"
sql_alchemy_engine_string = "postgresql+psycopg2://postgres:password@localhost/geo"


def main():
    start_time = datetime.now()

    # connect to Postgres
    try:
        pg_conn = psycopg2.connect(pg_connect_string)
        pg_conn.autocommit = True
        pg_cur = pg_conn.cursor()
    except psycopg2.Error:
        logger.fatal("Unable to connect to database\nACTION: Check your Postgres parameters and/or database security")
        return False

    # download weather stations
    station_list = get_weather_stations()
    logger.info("Downloaded {:,} weather stations : {}".format(len(station_list), datetime.now() - start_time))

    obs_list = get_weather_observations(station_list)
    logger.info("Downloaded {:,} latest observations : {}".format(len(obs_list), datetime.now() - start_time))
    start_time = datetime.now()

    # create dataframe of weather stations
    station_df = pandas.DataFrame(station_list)

    # create dataframe of weather obs
    obs_df = pandas.DataFrame(obs_list).drop_duplicates()

    # merge data and add points to dataframe
    df = (obs_df.merge(station_df, on="wmo")
          .drop(["lat", "lon"], axis=1)
          )
    # gdf = geopandas.GeoDataFrame(df, geometry=geopandas.points_from_xy(df.longitude, df.latitude), crs="EPSG:4283")

    # select rows from the last hour with air temps
    air_temp_df = df[(df["utc_time_diff"] < 3600.0) & (df["air_temp"].notna())
                     & (df["longitude"] > 112.0) & (df["longitude"] < 162.0)
                     & (df["latitude"] > -45.0) & (df["latitude"] < -8.0)]

    # # testing - get histogram of observation time
    # air_temp_df.hist("utc_time")
    # plt.savefig(os.path.join(output_path, "histogram.png"), dpi=300, facecolor="w", pad_inches=0.0, metadata=None)

    # export dataframe to PostGIS
    export_dataframe(pg_cur, air_temp_df, "testing", "weather_stations", "replace")
    logger.info("Exported weather station dataframe to PostGIS: {}".format(datetime.now() - start_time))
    start_time = datetime.now()

    # # save to disk for debugging
    # air_temp_df.to_feather(os.path.join(output_path "temp_df.ipc"))

    # # load from disk if debugging
    # temp_df = pandas.read_feather(os.path.join(output_path "temp_df.ipc"))

    # extract lat, long and air temp as arrays
    x = air_temp_df["longitude"].to_numpy()
    y = air_temp_df["latitude"].to_numpy()
    z = air_temp_df["air_temp"].to_numpy()
    h = air_temp_df["altitude"].to_numpy()

    logger.info("Filtered observations dataframe with weather station coordinates : {} rows : {}"
                .format(len(air_temp_df.index), datetime.now() - start_time))
    start_time = datetime.now()

    # # open SRTM 3 second DEM of Australia (ESRI Binary Grid format)
    # dem_file_name = "/Users/hugh.saalmans/Downloads/3secSRTM_DEM/DEM_ESRI_GRID_16bit_Integer/dem3s_int/hdr.adf"
    # dem_dataset = gdal.Open(dem_file_name, gdal.GA_ReadOnly)
    # dem_geotransform = dem_dataset.GetGeoTransform()
    #
    # # get DEM origin point and pixel size to create numpy arrays from
    # dem_num_x, dem_num_y = dem_dataset.RasterXSize, dem_dataset.RasterYSize
    # dem_origin_x, dem_origin_y = dem_geotransform[0], dem_geotransform[3]
    # dem_origin_delta_x, dem_origin_delta_y = dem_geotransform[1], dem_geotransform[5]

    # select GNAF coordinates - group by 3 decimal places to create a ~100m grid of addresses
    # sql = """SELECT latitude::numeric(5,3) as latitude, longitude::numeric(6,3) as longitude, count(*) as address_count
    #          FROM gnaf_202102.address_principals
    #          GROUP BY latitude::numeric(5,3), longitude::numeric(6,3)"""
    sql = """SELECT * FROM testing.gnaf_points_with_pop_and_height"""
    gnaf_df = pandas.read_sql_query(sql, pg_conn)

    # save to feather file for future use (GNAF only changes once every 3 months)
    gnaf_df.to_feather(os.path.join(output_path, "gnaf.ipc"))

    # # load from feather file
    # gnaf_df = pandas.read_feather(os.path.join(output_path, "gnaf.ipc"))

    gnaf_x = gnaf_df["longitude"].to_numpy()
    gnaf_y = gnaf_df["latitude"].to_numpy()
    gnaf_counts = gnaf_df["count"].to_numpy()
    gnaf_dem_elevation = gnaf_df["elevation"].to_numpy()

    logger.info("Loaded {:,} GNAF points : {}".format(len(gnaf_df.index), datetime.now() - start_time))
    start_time = datetime.now()

    # # interpolate temperatures for GNAF coordinates
    gnaf_points = numpy.array((gnaf_x.flatten(), gnaf_y.flatten())).T
    gnaf_temps = scipy.interpolate.griddata((x, y), z, gnaf_points, method="linear")
    gnaf_weather_elevation = scipy.interpolate.griddata((x, y), h, gnaf_points, method="linear")

    # create results dataframe
    temperature_df = pandas.DataFrame({"latitude": gnaf_y, "longitude": gnaf_x,
                                       "count": gnaf_counts, "dem_elevation": gnaf_dem_elevation,
                                       "weather_elevation": gnaf_weather_elevation, "air_temp": gnaf_temps})

    # add temperatures adjusted for altitude differences between GNAF point and nearby weather stations
    temperature_df["adjusted_temp"] = temperature_df["air_temp"] + \
                                      (temperature_df["weather_elevation"] - temperature_df["dem_elevation"]) / 150.0

    # print(temperature_df)

    # get count of rows with a temperature
    row_count = len(temperature_df[temperature_df["air_temp"].notna()].index)

    logger.info("Got {:,} interpolated temperatures and elevations for GNAF points : {}"
                .format(row_count, datetime.now() - start_time))
    start_time = datetime.now()

    # # plot a map of gnaf points by temperature
    # temperature_df.plot.scatter("longitude", "latitude", c="air_temp", colormap="jet")
    # plt.axis("off")
    # plt.savefig(os.path.join(output_path, "interpolated.png"), dpi=300, facecolor="w", pad_inches=0.0, metadata=None)
    #
    # logger.info("Plotted points to PNG file : {}".format(datetime.now() - start_time))
    # start_time = datetime.now()

    # export dataframe to PostGIS
    export_dataframe(pg_cur, temperature_df, "testing", "gnaf_temperature", "replace")
    logger.info("Exported GNAF temperature dataframe to PostGIS: {}".format(datetime.now() - start_time))
    # start_time = datetime.now()

    return True


def export_dataframe(pg_cur, df, schema_name, table_name, export_mode):
    # create geodataframe
    gdf = geopandas.GeoDataFrame(df, geometry=geopandas.points_from_xy(df.longitude, df.latitude), crs="EPSG:4283")

    # export to GeoPackage
    # gdf.to_file(os.path.join(output_path, "{}.gpkg".format(table_name)), driver="GPKG")
    #
    # logger.info("Exported points to GeoPackage : {}".format(datetime.now() - start_time))
    # start_time = datetime.now()

    # export to PostGIS
    engine = sqlalchemy.create_engine(sql_alchemy_engine_string)
    gdf.to_postgis(table_name, engine, schema=schema_name, if_exists=export_mode)

    pg_cur.execute("ANALYSE {}.{}".format(schema_name, table_name))
    # pg_cur.execute("ALTER TABLE testing.weather_stations ADD CONSTRAINT weather_stations_pkey PRIMARY KEY (wmo)"
    #                .format(schema_name, table_name))
    pg_cur.execute("ALTER TABLE {}.{} RENAME COLUMN geometry TO geom".format(schema_name, table_name))
    pg_cur.execute("CREATE INDEX sidx_{1}_geom ON {0}.{1} USING gist (geom)".format(schema_name, table_name))
    pg_cur.execute("ALTER TABLE {0}.{1} CLUSTER ON sidx_{1}_geom".format(schema_name, table_name))


def get_weather_observations(station_list):
    start_time = datetime.now()

    obs_urls = list()
    obs_list = list()
    for state in states:
        # get URL for web page to scrape
        input_url = base_url.format(state["name"].lower())

        # load and parse web page
        r = requests.get(input_url)
        soup = BeautifulSoup(r.content, features="html.parser")

        # get all links
        links = soup.find_all("a", href=True)

        for link in links:
            url = link["href"]

            if "/products/" in url:
                # only include weather station observations in their home state (border weather obs are duplicated)
                for station in station_list:
                    if station["state"] == state["name"] and station["wmo"] == int(url.split(".")[1]):
                        # change URL to get JSON file of weather obs and add to list
                        obs_url = url.replace("/products/", "http://www.bom.gov.au/fwo/").replace(".shtml", ".json")
                        obs_urls.append(obs_url)

        # with open(os.path.join(output_path, "weather_observations_urls.txt"), "w", newline="") as output_file:
        #     output_file.write("\n".join(obs_urls))

        logger.info("\t - {} : got obs file list : {}".format(state["name"], datetime.now() - start_time))
        start_time = datetime.now()

    # download each obs file using multiprocessing
    pool = multiprocessing.Pool(processes=16)
    results = pool.imap_unordered(run_multiprocessing, obs_urls)

    pool.close()
    pool.join()

    for result in list(results):
        if result.get("error") is not None:
            logger.warning("\t- Failed to parse {}".format(result["error"]))
        else:
            obs_list.append(result)

    return obs_list


def get_weather_stations():
    # get weather stations - obs have poor coordinates
    response = urllib.request.urlopen("ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip")
    data = io.BytesIO(response.read())
    station_file = zipfile.ZipFile(data, "r", zipfile.ZIP_DEFLATED).read("stations.txt").decode("utf-8")
    stations = station_file.split("\r\n")

    station_list = list()

    # split fixed width file and get the fields we want
    field_widths = (-8, -6, 41, -8, -7, 9, 10, -15, 4, 11, -9, 7)  # negative widths represent ignored fields
    format_string = " ".join("{}{}".format(abs(fw), "x" if fw < 0 else "s") for fw in field_widths)
    field_struct = struct.Struct(format_string)
    parser = field_struct.unpack_from
    # print("fmtstring: {!r}, recsize: {} chars".format(fmtstring, fieldstruct.size))

    # skip first 5 rows (lazy coding!)
    stations.pop(0)
    stations.pop(0)
    stations.pop(0)
    stations.pop(0)
    stations.pop(0)

    # add each station to a list of dictionaries
    for station in stations:
        if len(station) > 128:
            fields = parser(bytes(station, "utf-8"))

            # convert to list
            field_list = list()

            for field in fields:
                field_list.append(field.decode("utf-8").lstrip().rstrip())

            if field_list[5] != "..":
                station_dict = dict()
                station_dict["name"] = field_list[0]
                station_dict["latitude"] = float(field_list[1])
                station_dict["longitude"] = float(field_list[2])
                station_dict["state"] = field_list[3]
                if field_list[4] != "..":
                    station_dict["altitude"] = float(field_list[4])
                station_dict["wmo"] = int(field_list[5])

                station_list.append(station_dict)

    return station_list


def run_multiprocessing(url):
    # file_path = os.path.join(output_path, "obs", url.split("/")[-1])

    # try:
    obs_text = requests.get(url).text

    # with open(file_path, "w", newline="") as output_file:
    #     output_file.write(obs_text)

    obs_json = json.loads(obs_text)
    obs_list = obs_json["observations"]["data"]

    try:
        # default is an error for when there are no observations
        result = dict()
        result["error"] = "{} : No observations".format(url)

        for obs in obs_list:
            if obs["sort_order"] == 0:
                result = obs

                # add utc time
                obs["utc_time"] = datetime.strptime(obs["aifstime_utc"], "%Y%m%d%H%M%S")
                obs["utc_time_diff"] = (datetime.utcnow() - obs["utc_time"]).total_seconds()

    except Exception as ex:
        result = dict()
        result["error"] = "{} : {}".format(url, ex)
        # print(result)

    return result


if __name__ == "__main__":
    full_start_time = datetime.now()

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
    logger.info("Start weather obs download")
    # psma.check_python_version(logger)

    if main():
        logger.info("Finished successfully! : {}".format(datetime.now() - full_start_time))
    else:
        logger.fatal("Something bad happened!")

    logger.info("")
    logger.info("-------------------------------------------------------------------------------")
