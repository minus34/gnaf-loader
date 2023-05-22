# gnaf-loader
A quick way to load the complete Geocoded National Address File of Australia (GNAF) and Australian Administrative Boundaries into Postgres, simplified and ready to use as reference data for geocoding, analysis, visualisation and aggregation.

### What's GNAF?
Have a look at [these intro slides](https://minus34.com/opendata/intro-to-gnaf.pptx) ([PDF](https://minus34.com/opendata/intro-to-gnaf.pdf)), as well as the [data.gov.au page](https://data.gov.au/dataset/geocoded-national-address-file-g-naf).

### There are 4 options for loading the data
1. [Run](https://github.com/minus34/gnaf-loader#option-1---run-loadgnafpy) the load-gnaf Python script and build the database yourself in a single step
2. [Pull](https://github.com/minus34/gnaf-loader#option-2---run-the-database-in-a-docker-container) the database from Docker Hub and run it in a container
3. [Download](https://github.com/minus34/gnaf-loader#option-3---load-pg_dump-files) the GNAF and/or Admin Bdys Postgres dump files & restore them in your Postgres 14+ database
4. [Use or download](https://github.com/minus34/gnaf-loader#option-4---parquet-files-in-s3) Parquet Files in S3 for your data & analytics workflows; either in AWS or your own platform.

## Option 1 - Run load.gnaf.py
Running the Python script takes 30-120 minutes on a Postgres server configured to take advantage of the RAM available.

You can process the GDA94 or GDA2020 version of the data - just ensure that you download the same version for both GNAF and the Administrative Boundaries. If you don't know what GDA94 or GDA2020 is, download the GDA94 versions (FYI - they're different coordinate systems) 

### Performance
To get a good load time you'll need to configure your Postgres server for performance. There's a good guide [here](https://postgis.net/workshops/postgis-intro/tuning.html), noting it's a few years old and some of the memory parameters can be beefed up if you have the RAM.

### Pre-requisites
- Postgres 10.x and above with PostGIS 2.2+
- Add the Postgres bin directory to your system PATH
- Python 3.6+ with Psycopg 3.x

### Process
1. Download [Geoscape GNAF from data.gov.au](https://data.gov.au/dataset/geocoded-national-address-file-g-naf) (GDA94 or GDA2020)
2. Download [Geoscape Administrative Boundaries from data.gov.au](https://data.gov.au/dataset/geoscape-administrative-boundaries) (**download the ESRI Shapefile (GDA94 or GDA2020) version**)
3. Unzip GNAF to a directory on your Postgres server
4. Unzip Admin Bdys to a local directory
5. Alter security on those directories to grant Postgres read access
6. Create the target database (if required)
7. Add PostGIS to the database (if required) by running the following SQL: `CREATE EXTENSION postgis`
8. Check the available and required arguments by running load-gnaf.py with the `-h` argument (see command line examples below)
9. Run the script, come back in 30-120 minutes and enjoy!

### Command Line Options
The behaviour of gnaf-loader can be controlled by specifying various command line options to the script. Supported arguments are:

#### Required Arguments
* `--gnaf-tables-path` specifies the path to the extracted source GNAF tables (eg *.psv files). This should match the extracted directory which contains the subfolders `Authority Code` and `Standard`. __This directory must be accessible by the Postgres server__, and the corresponding local path for the server to this directory may need to be set via the `local-server-dir` argument
* `--local-server-dir` specifies the local path on the Postgres server corresponding to `gnaf-tables-path`. If the server is running locally this argument can be omitted.
* `--admin-bdys-path` specifies the path to the extracted source admin boundary files. This path should contain a subfolder named `Administrative Boundaries`. Unlike `gnaf-tables-path`, this path does not necessarily have to be accessible to the remote Postgres server.

#### Postgres Parameters
* `--pghost` the host name for the Postgres server. This defaults to the `PGHOST` environment variable if set, otherwise defaults to `localhost`.
* `--pgport` the port number for the Postgres server. This defaults to the `PGPORT` environment variable if set, otherwise `5432`.
* `--pgdb` the database name for Postgres server. This defaults to the `PGDATABASE` environment variable if set, otherwise `geoscape`.
* `--pguser` the username for accessing the Postgres server. This defaults to the `PGUSER` environment variable if set, otherwise `postgres`.
* `--pgpassword` password for accessing the Postgres server. This defaults to the `PGPASSWORD` environment variable if set, otherwise `password`.

#### Optional Arguments
* `--srid` Sets the coordinate system of the input data. Valid values are `4283` (the default: GDA94 lat/long) and `7844` (GDA2020 lat/long).
* `--geoscape-version` Geoscape version number in YYYYMM format. Defaults to current year and last release month. e.g. `202305`.
* `--previous-geoscape-version` Previous Geoscape release version number as YYYYMM; used for QA comparison. e.g. `202302`.
* `--raw-gnaf-schema` schema name to store raw GNAF tables in. Defaults to `raw_gnaf_<geoscape_version>`.
* `--raw-admin-schema` schema name to store raw admin boundary tables in. Defaults to `raw_admin_bdys_<geoscape_version>`.
* `--gnaf-schema` destination schema name to store final GNAF tables in. Defaults to `gnaf_<geoscape_version>`.
* `--admin-schema` destination schema name to store final admin boundary tables in. Defaults to `admin_bdys_<geoscape_version>`.
* `--previous-gnaf-schema` Schema with previous version of GNAF tables in. Defaults to `gnaf_<previous_geoscape_version>`.
* `--previous-admin-schema` Schema with previous version of admin boundary tables in. Defaults to `admin_bdys_<previous_geoscape_version>`.
* `--states` space separated list of states to load, eg `--states VIC TAS`. Defaults to loading all states.
* `--prevacuum` forces the database to be vacuumed after dropping tables. Defaults to off, and specifying this option will slow the import process.
* `--raw-fk` creates both primary & foreign keys for the raw GNAF tables. Defaults to off, and will slow the import process if specified. Use this option
  if you intend to utilise the raw GNAF tables as anything more then a temporary import step. Note that the final processed tables will always have appropriate
  primary and foreign keys set.
* `--raw-unlogged` creates unlogged raw GNAF tables, speeding up the import. Defaults to off. Only specify this option if you don't care about the raw data tables after the import - they will be lost if the server crashes!
* `--max-processes` specifies the maximum number of parallel processes to use for the data load. Set this to the number of cores on the Postgres server minus 2, but limit to 12 if 16+ cores - there is minimal benefit beyond 12. Defaults to 4.
* `--no-boundary-tag` DO NOT tag all addresses with some of the key admin boundary IDs for creating aggregates and choropleth maps.

### Example Command Line Arguments
* Local Postgres server: `python load-gnaf.py --gnaf-tables-path="C:\temp\geoscape_202305\G-NAF" --admin-bdys-path="C:\temp\geoscape_202305\Administrative Boundaries"` Loads the GNAF tables to a Postgres server running locally. GNAF archives have been extracted to the folder `C:\temp\geoscape_202305\G-NAF`, and admin boundaries have been extracted to the `C:\temp\geoscape_202305\Administrative Boundaries` folder.
* Remote Postgres server: `python load-gnaf.py --gnaf-tables-path="\\svr\shared\gnaf" --local-server-dir="f:\shared\gnaf" --admin-bdys-path="c:\temp\unzipped\AdminBounds_ESRI"` Loads the GNAF tables which have been extracted to the shared folder `\\svr\shared\gnaf`. This shared folder corresponds to the local `f:\shared\gnaf` folder on the Postgres server. Admin boundaries have been extracted to the `c:\temp\unzipped\AdminBounds_ESRI` folder.
* Loading only selected states: `python load-gnaf.py --states VIC TAS NT ...` Loads only the data for Victoria, Tasmania and Northern Territory

### Advanced
You can load the Admin Boundaries without GNAF. To do this: comment out steps 1, 3 and 4 in def main.

Note: you can't load GNAF without the Admin Bdys due to dependencies required to split Melbourne and to fix non-boundary locality_pids on addresses.

### Attribution
When using the resulting data from this process - you will need to adhere to the attribution requirements on the data.gov.au pages for [GNAF](https://data.gov.au/dataset/geocoded-national-address-file-g-naf) and the [Admin Bdys](https://data.gov.au/dataset/geoscape-administrative-boundaries), as part of the open data licensing requirements.

### WARNING:
- The scripts will DROP ALL TABLES using CASCADE in the GNAF and Admin Bdy schemas and then recreate them; meaning you'll LOSE YOUR VIEWS if you have created any! If you want to keep the existing data - you'll need to change the schema names in the script or use a different database
- All raw GNAF tables can be created UNLOGGED to speed up the data load. This will make them UNRECOVERABLE if your database is corrupted. You can run these scripts again to recreate them. If you think this sounds ok - set the unlogged_tables flag to True for a slightly faster load
- Boundary tagging (on by default) will add 15-60 minutes to the process if you have PostGIS 2.2+. If you have PostGIS 2.1 or lower - it can take HOURS as the boundary tables can't be optimised!

### IMPORTANT:
- Whilst you can choose which 4 schemas to load the data into, I haven't QA'd every permutation. Stick with the defaults if you have limited Postgres experience
- If you're not running the Python script on the Postgres server, you'll need to have access to a network path to the GNAF files on the database server (to create the list of files to process). The alternative is to have a local copy of the raw files
- The 'create tables' sql script will add the PostGIS extension to the database in the public schema, you don't need to add it to your database
- There is an option to VACUUM the database at the start after dropping the existing GNAF/Admin Bdy tables - this doesn't really do anything outside of repeated testing. (I was too lazy to take it out of the code as it meant renumbering all the SQL files and I'd like to go to bed now)

## Option 2 - Run the database in a docker container

GNAF and the Admin Boundaries are ready to use in Postgres in an image on Docker Hub.

### Process
1. In your docker environment pull the image using `docker pull minus34/gnafloader:latest`
2. Run using `docker run --publish=5433:5432 minus34/gnafloader:latest`
3. Access Postgres in the container via port `5433`. Default login is - user: `postgres`, password: `password`

*Note: the compressed Docker image is 8Gb, uncompressed is 25Gb*

**WARNING: The default postgres superuser password is insecure and should be changed using:**

`ALTER USER postgres PASSWORD '<something a lot more secure>'`

## Option 3 - Load PG_DUMP Files
Download Postgres dump files and restore them in your database.

Should take 15-60 minutes.

### Pre-requisites
- Postgres 14+ with PostGIS 3.0+
- A knowledge of [Postgres pg_restore parameters](https://www.postgresql.org/docs/14/app-pgrestore.html)

### Process
1. Download the [GNAF dump file](https://minus34.com/opendata/geoscape-202305/gnaf-202305.dmp) or [GNAF GDA2020 dump file](https://minus34.com/opendata/geoscape-202305-gda2020/gnaf-202305.dmp) (~2.0Gb)
2. Download the [Admin Bdys dump file](https://minus34.com/opendata/geoscape-202305/admin-bdys-202305.dmp) or [Admin Bdys GDA2020 dump file](https://minus34.com/opendata/geoscape-202305-gda2020/admin-bdys-202305.dmp) (~2.8Gb)
3. Edit the _restore-gnaf-admin-bdys.bat_ or _.sh_ script in the supporting-files folder for your dump file names, database parameters and for the location of pg_restore
5. Run the script, come back in 15-60 minutes and enjoy!

## Option 4 - Parquet Files in S3
Parquet versions of all the tables are in a public S3 bucket for use directly in an AWS application or service. They can also be downloaded using the AWS CLI.

Geometries are stored as Well Known Text (WKT) strings with WGS84 lat/long coordinates (SRID/EPSG:4326). They can be queried using spatial extensions to analytical platforms, such as [Apache Sedona](https://sedona.apache.org/) running on [Apache Spark](https://spark.apache.org/).

The files are here: `s3://minus34.com/opendata/geoscape-202305/parquet/` or `s3://minus34.com/opendata/geoscape-202305-gda2020/parquet/`

### AWS CLI Examples:
- List all datasets: `aws s3 ls s3://minus34.com/opendata/geoscape-202305/parquet/`
- Copy all datasets: `aws s3 sync s3://minus34.com/opendata/geoscape-202305/parquet/ <my-local-folder>`

## DATA LICENSES

Incorporates or developed using G-NAF © [Geoscape Australia](https://geoscape.com.au/legal/data-copyright-and-disclaimer/) licensed by the Commonwealth of Australia under the [Open Geo-coded National Address File (G-NAF) End User Licence Agreement](https://data.gov.au/dataset/ds-dga-19432f89-dc3a-4ef3-b943-5326ef1dbecc/distribution/dist-dga-09f74802-08b1-4214-a6ea-3591b2753d30/details?q=).

Incorporates or developed using Administrative Boundaries © [Geoscape Australia](https://geoscape.com.au/legal/data-copyright-and-disclaimer/) licensed by the Commonwealth of Australia under [Creative Commons Attribution 4.0 International licence (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

## DATA CUSTOMISATION
GNAF and the Admin Bdys have been customised to remove some of the known, minor limitations with the data. The most notable are:
- All addresses link to a gazetted locality that has a boundary. Those small number of addresses that don't in raw GNAF have had their locality_pid changed to a gazetted equivalent
- Localities have had address and street counts added to them
- Suburb-Locality bdys have been flattened into a single continuous layer of localities - South Australian Hundreds have been removed and ACT districts have been added where there are no gazetted localities
- The Melbourne, VIC locality has been split into Melbourne, 3000 and Melbourne 3004 localities (the new locality PIDs are `loc9901d119afda_1` & `loc9901d119afda_2`). The split occurs at the Yarra River (based on the postcodes in the Melbourne addresses)
- A postcode boundaries layer has been created using the postcodes in the address tables. Whilst this closely emulates the official Geoscape postcode boundaries, there are several hundred addresses that are in the wrong postcode bdy. Do not treat this data as authoritative
