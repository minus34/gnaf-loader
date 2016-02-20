# gnaf-loader

A quick way to load GNAF and the PSMA Admin Boundaries into Postgres, preprocessed and ready to use as a reference address dataset for geocoding, analysis and visualisation.

There are 2 options for loading the data:
1: Run the load-gnaf.py script and build the database yourself; or
2: Download the GNAF and/or Admin Bdys Postgres dump files and restore them in your database.

Q: How quick? A: A 32 core Windows server with SSDs loads it in under 15 mins. A MacBook Pro, ~45 mins. An 8 core commodity PC takes just under an hour.

Q: I like choices! A: You've got 2:

1: Either run the Python script to load and process the the data from scratch; or
2: Download the Postgres dump files and restore them to your database

Note: if you want raw GNAF and Admin boundaries - you'll need to run the Python script

Q: I don't know Postgres! A: You don't need to be a PG guru, just follow this guide...

** 1. postgres dump files **

1: Download the GNAF and/or Admin Bdys pg_dump files here: https://onedrive.live.com/redir?resid=4E1A421BC14CEBDD!4807&authkey=!AG70ANjJE5EfaiM&ithint=folder%2c
2: Make sure the folder where Postgres is installed is in the system PATH variable
3: Run this for each dump file:  


** 2. a single python script **


## Pre-requisites

- Postgres 9.x (tested on 9.3, 9.4 & 9.5 on Windows and 9.5 on OSX)
- PostGIS 2.x
- Python 2.7.x with Psycopg2 2.6.x

## Process

1: Download PSMA GNAF from www.data.gov.au
2: Download PSMA Administrative Boundaries from www.data.gov.au
2: Unzip them to a directory on your Postgres server
3: Alter security on the unzipped GNAF files to grant Postgres read access

4: Create the target database
5: Edit Postgres and GNAF parameters in load-gnaf.py
6: Run load-gnaf.py
7: Come back in 45-60 minutes; unless you have a juicy server with SSDs - in which case it could take ~15 mins!

## WARNING:
- The scripts will DROP ALL TABLES and recreate them using CASCADE; meaning you'll also LOSE YOUR VIEWS! If you want to keep the existing data - you'll need to change the schema names in the script or use a different database
- All raw GNAF tables can be created UNLOGGED to speed up the data load.  This will make them UNRECOVERABLE if your database is corrupted. You can run these scripts again to recreate them. If you think this sounds ok - set the unlogged_tables flag to True for a slightly faster load

## NOTES:
- If you're running the Python script locally (i.e. not on the Postgres server), you'll need to have access to a network path to the GNAF files on the database server to create the list of files to process. Otherwise, you'll need another copy of the raw files locally.
- The create tables script will add the PostGIS extension to the database in the public schema 



VACUUM flag after table drop note


Postgres config note - need to beef up default settings


----------------------------------------------------------------------------------------------------------
-- Creates a geocoded locality reference table for general purpose partying
--
-- NOTES:
--   * Postcodes are only populated where a locality name is non-unique within a state
--   * You could populate this table with postcodes from the address table, but it has ~200,000 addresses
--     with unofficial and incorrect postcodes on it, so caveat emptor trying that one!
--   * The only localities you should be using in anger are the Gazetted Localities or ACT Districts:
--       * SA Hundreds overlap gazetted localities and are problemetic becasue of this
--       * All other types of localities have no geospatial boundary, and hence can't be mapped
--   * BTW, you'd think in 2015 that all of Australia would have gazetted locality boundaries. Alas!
--     ACT and SA have large areas with no official locality:
--       * This is annoying, but only affects ~3,000 addresses
--   * POstcodes are stings BTW as NT postcodes start with a '0', e.g. '0820'
--
----------------------------------------------------------------------------------------------------------