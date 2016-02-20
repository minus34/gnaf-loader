CREATE UNIQUE INDEX address_default_geocode_pid_idx ON raw_gnaf.address_default_geocode USING btree (address_detail_pid);
CREATE UNIQUE INDEX address_mesh_block_2011_pid_idx ON raw_gnaf.address_mesh_block_2011 USING btree (address_detail_pid);
CREATE INDEX street_locality_loc_pid_idx ON raw_gnaf.street_locality USING btree (locality_pid);
CREATE UNIQUE INDEX mb_2011_pid_idx ON raw_gnaf.mb_2011 USING btree (mb_2011_pid);
-- CREATE INDEX address_detail_locality_pid_idx ON raw_gnaf.address_detail USING btree (locality_pid);
-- CREATE UNIQUE INDEX address_alias_pid_idx ON raw_gnaf.address_alias USING btree (alias_pid);
-- CREATE UNIQUE INDEX primary_secondary_pid_idx ON raw_gnaf.primary_secondary USING btree (secondary_pid);