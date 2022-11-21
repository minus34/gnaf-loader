### August 2022 Release
- Docker images have been upgraded to Postgres 14

- ### May 2022 Release
- Boundary concordance tables have been added to the GNAF schema (`boundary_concordance` & `boundary_concordance_score`. These solve the problem of trying to merge 2 or more datasets based on different census or administrative boundaries such as statistical areas or postcodes. Find out more [here](https://github.com/iag-geo/concord).

### November 2021 Release

#### Data
- Postgres dump files now support Postgres 13+ only. If you're running an earlier version of Postgres, you can still run the Python code to get full access to the data. Also consider using the Docker container as it's a very simple way to launch a server.
- Geoscape have removed the ABS Census 2011 boundaries and references from the GNAF tables
- _old_locality_pid_ field has been removed from the following GNAF tables as the new and old locality_pid lookup table has been removed. Maintaining the field would have introduced a dependancy on the previous version of GNAF, overcomplicating the processing: `address_principals, address_aliases, localities, streets, address_principal_admin_boundaries, address_alias_admin_boundaries`
- _old_locality_pid_ field has been removed from the following Admin Bdy tables for the above reasons: `locality_bdys, locality_bdys_analysis`
- The ABS Census meshblock boundary tables `abs_20**_mb` have had their meshblock code (`mb**_code`) fields changed to _bigint_ type to bring them inline with GNAF tables, to speed up joins
- All ABS Census 2021 boundary tables have had their columns re-ordered into a similar structure to the 2016 tables. The state_pid field has been removed
- Added fix for missing coordinates in default geocode table. Affects 10 South Australian addresses

#### Code
- Postgres connections have been reverted to standard connections. Due to a connection pool bug related to multiprocessing

### August 2021 Release

#### Data
- Existing locality_pids have been replaced by Geoscape
- _old_locality_pid_ field has been added to the following GNAF tables: `address_principals, address_aliases, localities, streets, address_principal_admin_boundaries, address_alias_admin_boundaries`
- _old_locality_pid_ field has been added to the following Admin Bdy tables: `locality_bdys, locality_bdys_analysis`
- Table, columns and foreign keys for ABS Census 2021 meshblocks have been added to GNAF
- _mb_2021_code_ field has been added to `address_principals, address_aliases`
- ABS Census 2021 meshblock, SA1, SA2, SA3, SA4 and GCSSA boundaries have been added to Admin Bdys
- QA process now checks row counts between new & previous versions
- `--previous-geoscape-version, --previous-gnaf-schema, --previous-admin-schema` runtime parameters added to enable QA row count dcomparison
- **minus34.com** is now a secure website (long overdue) - all file downloads are now over https:// only

#### Code
- Refactored input parameters & settings into a new .py file
- Postgres connections now come from a connection pool for better multiprocessing

### May 2021 Release
- Renamed all references to PSMA to Geoscape, reflecting the new data provider's name
- The docker image build process has been completely redone
- Changes in the Geoscape Admin Boundaries folder structure, resulting in duplicate Authority files, is now handled correctly.
- Due to the above fix, all authority tables now have a standardised table structure of `gid, code, name, description`.

### August 2018 Release
- GNAF now contains an *address_feature_pid* field for determining which addresses are new and which have changed. Previously the *address_detail_pid* on an address would change when a part of the address changed (e.g. 10 Smith St became 10 Smyth St) - even in cases where the building or dwelling it represents didn't change. This made determining which addresses were new and which had changed difficult. More info [here](https://www.psma.com.au/blog/blog/product-update-data-model-changes-improve-g-naf-product-scope)
- *address_feature_pid* is in the `raw_gnaf_201808.address_feature` table. In the future, the data in this table will be added to the de-normalised schema (i.e. the gnaf_201808 schema).
- Fixed a bug that prevented raw GNAF primary & foreign key creation.

### May 2018 Release
- Improved handing of Admin Boundary data errors

### Feb 2018 Release
- Admin boundary tags on alias addresses are now copied from each alias' principal address. This can reduce processing times significantly. Previously the boundary tags were processed using spatial queries. This has created 2 new tables: `address_principal_admin_boundaries` and `address_alias_admin_boundaries`. The previous table `address_admin_boundaries` is now a view. 

### May 2017 Release
- A `--no-boundary-tag` flag replaces the incorrectly implemented `--boundary-tag` flag. Including the `--no-boundary-tag` flag will prevent GNAF being tagging with PSMA Admin Boundary IDs and save ~15-45 minutes of processing time.

### February 2017 Release
- Refactored the raw admin boundary import process to avoid needing to set PGPASSWORD. This could have failed on some Postgres instances due to security settings. The new process imports the shapefiles into SQL and then runs it using psycopg instead of psql. 

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
