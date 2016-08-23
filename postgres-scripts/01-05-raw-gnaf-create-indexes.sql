CREATE UNIQUE INDEX address_default_geocode_pid_idx ON raw_gnaf.address_default_geocode USING btree (address_detail_pid);
CREATE UNIQUE INDEX address_mesh_block_2011_pid_idx ON raw_gnaf.address_mesh_block_2011 USING btree (address_detail_pid);
CREATE UNIQUE INDEX address_mesh_block_2016_pid_idx ON raw_gnaf.address_mesh_block_2016 USING btree (address_detail_pid);
CREATE INDEX street_locality_loc_pid_idx ON raw_gnaf.street_locality USING btree (locality_pid);
CREATE UNIQUE INDEX mb_2011_pid_idx ON raw_gnaf.mb_2011 USING btree (mb_2011_pid);
CREATE UNIQUE INDEX mb_2016_pid_idx ON raw_gnaf.mb_2016 USING btree (mb_2016_pid);
