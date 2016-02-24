# gnaf-loader
A quick way to load the complete GNAF and PSMA Admin Boundaries into Postgres, simplified and ready to use as reference data for geocoding, analysis and visualisation.

### What's GNAF?
Have a look at [these intro slides](http://minus34.com/opendata/intro-to-gnaf.pptx) ([PDF](http://minus34.com/opendata/intro-to-gnaf.pdf)), as well as the [PSMA product page](http://www.psma.com.au/products/g-naf).


### There are 2 options for loading the data
1. Run a Python script and build the database in a single step
2. (COMING SOON) Download the GNAF and/or Admin Bdys Postgres dump or text files & restore them in your database

## Option 1 - Run load.gnaf.py
Running the Python script takes 15-60 minutes on a Postgres server configured for performance.

My benchmarks are:
- 3 year old, 32 core Windows server with SSDs = ~15 mins
- MacBook Pro = ~45 mins
- 3 year old, 8 core commodity PC = ~45 mins.

### Performance
To get the good load times you'll need to configure your Postgres server for performance. There's a good guide [here](http://revenant.ca/www/postgis/workshop/tuning.html), noting it's a few years old and some of the memory parameters can be beefed up if you have the RAM.

### Pre-requisites (the 4 P's)
- Postgres 9.3+ with PostGIS 2.2 (tested on 9.3, 9.4 & 9.5 on Windows and 9.5 on OSX)
- Python 2.7 with Psycopg2 2.6

### Process
1. Download PSMA GNAF from www.data.gov.au
2. Download PSMA Administrative Boundaries from www.data.gov.au
3. Unzip GNAF to a directory on your Postgres server
4. Alter security on the directory to grant Postgres read access
5. Unzip Admin Bdys to a local directory
6. Create the target database (if required)
7. Edit the Postgres and GNAF parameters at the top of the Python script
8. Run the script, come back in 15-60 minutes and enjoy!

## (COMING SOON) Option 2 - Load PG_DUMP Files
This option will be available soon after the data is made open!

Not sure how long this takes since I haven't tested it thoroughly yet...

### Pre-requisites
- Postgres 9.5 with PostGIS 2.2 only
- A knowledge of [Postgres pg_restore parameters](http://www.postgresql.org/docs/9.5/static/app-pgrestore.html)

### Process
1. Download gnaf.dmp from <url>
2. Download admin_bdys.dmp from <url>
3. Edit the pg_restore .bat/.sh script in the Supporting File folder for your database parameters
4. Run the script, come back in 15-60 minutes and enjoy!

## DATA CUSTOMISATION
GNAF and the Admin Bdys have been customised to remove some of the more common annoyances with the data. The most notable are:
- All addresses link to a gazetted locality that has a boundary. Those small number of addresses that don't in raw GNAF have had their locality_pid changed to a gazetted equivalent
- Localities have had address and street counts added to them
- Suburb-Locality bdys have been flattened into a single continuous layer of localities - South Australian Hundreds have been removed and ACT districts have been added where there are no gazetted localities
- The Melbourne, VIC locality has been split into Melbourne, 3000 and Melbourne 3004 localities (the new locality PIDs are VIC 1634_1 & VIC 1634_2). The split occurs at the Yarra River (based on the postcodes in the Melbourne addresses)
- A postcode boundaries layer has been created using the postcodes in the address tables. Whilst this closely emulates the official PSMA postcode boundaries, there are several hundred addresses that are in the wrong postcode bdy. Do not treat this data as authoritative

## WARNING:
- The scripts will DROP ALL TABLES and recreate them using CASCADE; meaning you'll LOSE YOUR VIEWS if you have created any! If you want to keep the existing data - you'll need to change the schema names in the script or use a different database
- All raw GNAF tables can be created UNLOGGED to speed up the data load. This will make them UNRECOVERABLE if your database is corrupted. You can run these scripts again to recreate them. If you think this sounds ok - set the unlogged_tables flag to True for a slightly faster load

## NOTES:
- Whilst you can choose which 4 schemas to load the data into, I haven't QA'd every permutation. Stick with the defaults if you have limited Postgres experience 
- If you're not running the Python script on the Postgres server, you'll need to have access to a network path to the GNAF files on the database server (to create the list of files to process). The alternative is to have a local copy of the raw files
- The 'create tables' sql script will add the PostGIS extension to the database in the public schema, you don't need to add it to your database
- There is an option to VACUUM the database at the start after dropping the existing GNAF/Admin Bdy tables - this doesn't really do anything outside of repeated testing. (I was too lazy to take it out of the code as it meant renumbering all the SQL files and I'd like to go to bed now)  

## TO DO:
- Automatically detect the CPU count on the server (for multiprocessing)
- Create bash script for restoring the Postgres dump files
- Create views and analysis tables for all Admin Bdys (only localities, states and commonwealth electorates are currently done)
- Output reference tables to PSV & SHP
- List final record counts
- Build QA into the Python script
- Boundary tag addresses for admin bdys
- Script the creation of pg_dump files
- Script the copying of pg_dump, PSV & SHP file to Amazon S3
