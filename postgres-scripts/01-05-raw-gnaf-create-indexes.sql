CREATE UNIQUE INDEX address_default_geocode_pid_idx ON raw_gnaf.address_default_geocode USING btree (address_detail_pid);
CREATE UNIQUE INDEX address_mesh_block_2011_pid_idx ON raw_gnaf.address_mesh_block_2011 USING btree (address_detail_pid);
CREATE UNIQUE INDEX address_mesh_block_2016_pid_idx ON raw_gnaf.address_mesh_block_2016 USING btree (address_detail_pid);
CREATE UNIQUE INDEX address_mesh_block_2021_pid_idx ON raw_gnaf.address_mesh_block_2021 USING btree (address_detail_pid);
CREATE INDEX street_locality_loc_pid_idx ON raw_gnaf.street_locality USING btree (locality_pid);
CREATE UNIQUE INDEX mb_2011_pid_idx ON raw_gnaf.mb_2011 USING btree (mb_2011_pid);
CREATE UNIQUE INDEX mb_2016_pid_idx ON raw_gnaf.mb_2016 USING btree (mb_2016_pid);
CREATE UNIQUE INDEX mb_2021_pid_idx ON raw_gnaf.mb_2021 USING btree (mb_2021_pid);


-- TODO: put this somewhere more logical
DROP TABLE IF EXISTS raw_gnaf.locality_pid_linkage_distinct;
CREATE TABLE raw_gnaf.locality_pid_linkage_distinct AS
SELECT DISTINCT locality_pid,
                ab_locality_pid AS old_locality_pid, 
                state
FROM raw_gnaf.locality_pid_linkage;

-- get rid of the one 2 into 1 locality_pid change (WOOROONOORAN, QLD 4860). No addresses impacted
DELETE FROM raw_gnaf.locality_pid_linkage_distinct
where locality_pid = 'loc1cbcbc887cf5'
  AND old_locality_pid = 'QLD3352';

ANALYSE raw_gnaf.locality_pid_linkage_distinct;

ALTER TABLE ONLY raw_gnaf.locality_pid_linkage_distinct
    ADD CONSTRAINT locality_pid_linkage_distinct_pk PRIMARY KEY (locality_pid);
