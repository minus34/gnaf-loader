### Feb 2018 Release
- Admin boundary tags on alias addresses are now copied from each alias' principal address. This can reduce processing times significantly. Previously the boundary tags were processed using spatial queries. This has created 2 new tables: `address_principal_admin_boundaries` and `address_alias_admin_boundaries`. The previous table `address_admin_boundaries` is now a view. 

### May 2017 Release
- A `--no-boundary-tag` flag replaces the incorrectly implemented `--boundary-tag` flag. Including the `--no-boundary-tag` flag will prevent GNAF being tagging with PSMA Admin Boundary IDs and save ~15-45 minutes of processing time.

### February 2017 Release
- Refactored the raw admin boundary import process to avoid needing to set PGPASSWORD. This could have failed on some Postgres instances due to security settings. The new process imports the shapefiles into SQL and then runs it using Psycopg2 instead of psql. 

### November 2016 Release
- Logging is now written to load-gnaf.log in your local repo directory as well as to the console 
- Added `--psma-version` to the parameters. Represents the PSMA version number in YYYYMM format and is used to add a suffix to the default schema names. Defaults to current year and latest release month. e.g. `201611`. Valid values are `<year>02` `<year>05` `<year>08` `<year>11`, and is based on the PSMA quarterly release months 
- All default schema names are now suffixed with `--psma-version` to avoid clashes with previous versions. e.g. `gnaf_201611`
- Postgres 9.6 dump files for the November 2016 PSMA release are [available](https://github.com/minus34/gnaf-loader#option-3---load-pg_dump-files)
- load-gnaf.py now works with Python 2.7 and Python 3.5
- load-gnaf.py has been successfully tested on Postgres 9.6 and PostGIS 2.3
    - Note: Limited performance testing on Postgres 9.6 has shown setting the maximum number of parallel processes `--max-processes` to 3 is the most efficient value on non-SSD machines
- Final row counts are stored in a new 'qa' table in the gnaf and admin_bdys schemas for checking the results
- Code has been refactored to simplify it a bit and move some common functions to a new psma.py file
