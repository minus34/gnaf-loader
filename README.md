# gnaf-loader
A quick way to load the complete Geocoded National Address File of Australia (GNAF) and Australian Administrative Boundaries into Postgres, simplified and ready to use as reference data for geocoding, analysis, visualisation and aggregation.

### What's GNAF?
Have a look at [these intro slides](http://minus34.com/opendata/intro-to-gnaf.pptx) ([PDF](http://minus34.com/opendata/intro-to-gnaf.pdf)), as well as the [data.gov.au page](http://data.gov.au/dataset/geocoded-national-address-file-g-naf).

### There are 3 options for loading the data
1. [Run](https://github.com/minus34/gnaf-loader#option-1---run-loadgnafpy) the load-gnaf Python script and build the database in a single step
2. [Build](https://github.com/minus34/gnaf-loader#option-2---build-the-database-in-a-docker-environment) the database in a docker environment
3. [Download](https://github.com/minus34/gnaf-loader#option-3---load-pg_dump-files) the GNAF and/or Admin Bdys Postgres dump files & restore them in your database

## Option 1 - Run load.gnaf.py
Running the Python script takes 30-120 minutes on a Postgres server configured to take advantage of the RAM available.

### Performance
To get a good load time you'll need to configure your Postgres server for performance. There's a good guide [here](http://revenant.ca/www/postgis/workshop/tuning.html), noting it's a few years old and some of the memory parameters can be beefed up if you have the RAM.

### Pre-requisites
- Postgres 9.3+ with PostGIS 2.2+ (tested on 9.3, 9.4, 9.5 on Windows and 9.5, 9.6, 10 on macOS)
- Add the Postgres bin directory to your system PATH
- Python 2.7+ or Python 3.6+ with Psycopg2 2.6+

### Process
1. Download [PSMA GNAF from data.gov.au](http://data.gov.au/dataset/geocoded-national-address-file-g-naf)
2. Download [PSMA Administrative Boundaries from data.gov.au](http://data.gov.au/dataset/psma-administrative-boundaries) (**download the ESRI Shapefile version**)
3. Unzip GNAF to a directory on your Postgres server
4. Alter security on the directory to grant Postgres read access
5. Unzip Admin Bdys to a local directory
6. Create the target database (if required)
7. Check the available and required arguments by running load-gnaf.py with the `-h` argument (see command line examples below)
8. Run the script, come back in 30-120 minutes and enjoy!

### Command Line Options
The behaviour of gnaf-loader can be controlled by specifying various command line options to the script. Supported arguments are:

#### Required Arguments
* `--gnaf-tables-path` specifies the path to the extracted source GNAF tables (eg *.psv files). This should match the extracted directory which contains the subfolders `Authority Code` and `Standard`. __This directory must be accessible by the Postgres server__, and the corresponding local path for the server to this directory may need to be set via the `local-server-dir` argument
* `--local-server-dir` specifies the local path on the Postgres server corresponding to `gnaf-tables-path`. If the server is running locally this argument can be omitted.
* `--admin-bdys-path` specifies the path to the extracted source admin boundary files. This path should contain a subfolder named `Administrative Boundaries`. Unlike `gnaf-tables-path`, this path does not necessarily have to be accessible to the remote Postgres server.

#### Postgres Parameters
* `--pghost` the host name for the Postgres server. This defaults to the `PGHOST` environment variable if set, otherwise defaults to `localhost`.
* `--pgport` the port number for the Postgres server. This defaults to the `PGPORT` environment variable if set, otherwise `5432`.
* `--pgdb` the database name for Postgres server. This defaults to the `PGDATABASE` environment variable if set, otherwise `psma_201805`.
* `--pguser` the username for accessing the Postgres server. This defaults to the `PGUSER` environment variable if set, otherwise `postgres`.
* `--pgpassword` password for accessing the Postgres server. This defaults to the `PGPASSWORD` environment variable if set, otherwise `password`.

#### Optional Arguments
* `--psma-version` PSMA version number in YYYYMM format. Defaults to current year and last release month. e.g. `201805`.
* `--raw-gnaf-schema` schema name to store raw GNAF tables in. Defaults to `raw_gnaf_<psma_version>`.
* `--raw-admin-schema` schema name to store raw admin boundary tables in. Defaults to `raw_admin_bdys_<psma_version>`.
* `--gnaf-schema` destination schema name to store final GNAF tables in. Defaults to `gnaf_<psma_version>`.
* `--admin-schema` destination schema name to store final admin boundary tables in. Defaults to `admin_bdys_<psma_version>`.
* `--states` space separated list of states to load, eg `--states VIC TAS`. Defaults to loading all states.
* `--prevacuum` forces the database to be vacuumed after dropping tables. Defaults to off, and specifying this option will slow the import process.
* `--raw-fk` creates both primary & foreign keys for the raw GNAF tables. Defaults to off, and will slow the import process if specified. Use this option
if you intend to utilise the raw GNAF tables as anything more then a temporary import step. Note that the final processed tables will always have appropriate
primary and foreign keys set.
* `--raw-unlogged` creates unlogged raw GNAF tables, speeding up the import. Defaults to off. Only specify this option if you don't care about the raw data tables after the import - they will be lost if the server crashes!
* `--max-processes` specifies the maximum number of parallel processes to use for the data load. Set this to the number of cores on the Postgres server minus 2, but limit to 12 if 16+ cores - there is minimal benefit beyond 12. Defaults to 3.
* `--no-boundary-tag` DO NOT tag all addresses with some of the key admin boundary IDs for creating aggregates and choropleth maps.

### Example Command Line Arguments
* Local Postgres server: `python load-gnaf.py --gnaf-tables-path="C:\temp\psma_201805\G-NAF" --admin-bdys-path="C:\temp\psma_201805\Administrative Boundaries"` Loads the GNAF tables to a Postgres server running locally. GNAF archives have been extracted to the folder `C:\temp\psma_201805\G-NAF`, and admin boundaries have been extracted to the `C:\temp\psma_201805\Administrative Boundaries` folder.
* Remote Postgres server: `python load-gnaf.py --gnaf-tables-path="\\svr\shared\gnaf" --local-server-dir="f:\shared\gnaf" --admin-bdys-path="c:\temp\unzipped\AdminBounds_ESRI"` Loads the GNAF tables which have been extracted to the shared folder `\\svr\shared\gnaf`. This shared folder corresponds to the local `f:\shared\gnaf` folder on the Postgres server. Admin boundaries have been extracted to the `c:\temp\unzipped\AdminBounds_ESRI` folder.
* Loading only selected states: `python load-gnaf.py --states VIC TAS NT ...` Loads only the data for Victoria, Tasmania and Northern Territory

### Advanced
You can load the Admin Boundaries without GNAF. To do this: comment out steps 1, 3 and 4 in def main.

Note: you can't load GNAF without the Admin Bdys due to dependencies required to split Melbourne and to fix non-boundary locality_pids on addresses.

### Attribution
When using the resulting data from this process - you will need to adhere to the attribution requirements on the data.gov.au pages for [GNAF](http://data.gov.au/dataset/geocoded-national-address-file-g-naf) and the [Admin Bdys](http://data.gov.au/dataset/psma-administrative-boundaries), as part of the open data licensing requirements.

### WARNING:
- The scripts will DROP ALL TABLES using CASCADE in the GNAF and Admin Bdy schemas and then recreate them; meaning you'll LOSE YOUR VIEWS if you have created any! If you want to keep the existing data - you'll need to change the schema names in the script or use a different database
- All raw GNAF tables can be created UNLOGGED to speed up the data load. This will make them UNRECOVERABLE if your database is corrupted. You can run these scripts again to recreate them. If you think this sounds ok - set the unlogged_tables flag to True for a slightly faster load
- Boundary tagging (on by default) will add 15-60 minutes to the process if you have PostGIS 2.2+. If you have PostGIS 2.1 or lower - it can take HOURS as the boundary tables can't be optimised!

### IMPORTANT:
- Whilst you can choose which 4 schemas to load the data into, I haven't QA'd every permutation. Stick with the defaults if you have limited Postgres experience 
- If you're not running the Python script on the Postgres server, you'll need to have access to a network path to the GNAF files on the database server (to create the list of files to process). The alternative is to have a local copy of the raw files
- The 'create tables' sql script will add the PostGIS extension to the database in the public schema, you don't need to add it to your database
- There is an option to VACUUM the database at the start after dropping the existing GNAF/Admin Bdy tables - this doesn't really do anything outside of repeated testing. (I was too lazy to take it out of the code as it meant renumbering all the SQL files and I'd like to go to bed now) 

## Option 2 - Build the database in a docker environment

Create a Docker container with GNAF and the Admin Bdys ready to go, so they can be deployed anywhere.

### Process
1. Download [PSMA GNAF from data.gov.au](http://data.gov.au/dataset/geocoded-national-address-file-g-naf)
2. Download [PSMA Administrative Boundaries from data.gov.au](http://data.gov.au/dataset/psma-administrative-boundaries) (download the ESRI Shapefile version)
3. Unzip GNAF and the Admin Bdys in the data/ directory of this repository
4. Run docker-compose: `docker-compose up`. The database will be built.
5. Use the constructed database as you wish.

## Option 3 - Load PG_DUMP Files
Download Postgres dump files and restore them in your database.

Should take 15-60 minutes.

### Pre-requisites
- Postgres 9.6+ with PostGIS 2.2+
- A knowledge of [Postgres pg_restore parameters](http://www.postgresql.org/docs/9.5/static/app-pgrestore.html)

### Process
1. Download [gnaf-201805.dmp](http://minus34.com/opendata/psma-201805/gnaf-201805.dmp) (~1.2Gb)
2. Download [admin-bdys-201805.dmp](http://minus34.com/opendata/psma-201805/admin-bdys-201805.dmp) (~2.4Gb)
3. Edit the restore-gnaf-admin-bdys.bat or .sh script in the supporting-files folder for your database parameters and for the location of pg_restore
5. Run the script, come back in 15-60 minutes and enjoy!

### Data Licenses

Incorporates or developed using G-NAF ©PSMA Australia Limited licensed by the Commonwealth of Australia under the [Open Geo-coded National Address File (G-NAF) End User Licence Agreement](http://data.gov.au/dataset/19432f89-dc3a-4ef3-b943-5326ef1dbecc/resource/09f74802-08b1-4214-a6ea-3591b2753d30/download/20160226---EULA---Open-G-NAF.pdf).

Incorporates or developed using Administrative Boundaries ©PSMA Australia Limited licensed by the Commonwealth of Australia under [Creative Commons Attribution 4.0 International licence (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

## DATA CUSTOMISATION
GNAF and the Admin Bdys have been customised to remove some of the known, minor limitations with the data. The most notable are:
- All addresses link to a gazetted locality that has a boundary. Those small number of addresses that don't in raw GNAF have had their locality_pid changed to a gazetted equivalent
- Localities have had address and street counts added to them
- Suburb-Locality bdys have been flattened into a single continuous layer of localities - South Australian Hundreds have been removed and ACT districts have been added where there are no gazetted localities
- The Melbourne, VIC locality has been split into Melbourne, 3000 and Melbourne 3004 localities (the new locality PIDs are VIC 1634_1 & VIC 1634_2). The split occurs at the Yarra River (based on the postcodes in the Melbourne addresses)
- A postcode boundaries layer has been created using the postcodes in the address tables. Whilst this closely emulates the official PSMA postcode boundaries, there are several hundred addresses that are in the wrong postcode bdy. Do not treat this data as authoritative
