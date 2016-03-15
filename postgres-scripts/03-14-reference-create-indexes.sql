
-- analyse tables, add geometry indexes and create primary and foreign keys for gnaf reference tables

ANALYZE gnaf.address_principals;
ANALYZE gnaf.address_aliases;
ANALYZE gnaf.streets;
ANALYZE gnaf.locality_aliases;
ANALYZE gnaf.locality_neighbour_lookup;
ANALYZE gnaf.address_alias_lookup;
ANALYZE gnaf.address_secondary_lookup;
ANALYSE gnaf.street_aliases;

-- spatial indexes
CREATE INDEX address_principals_geom_idx ON gnaf.address_principals USING gist (geom); ALTER TABLE gnaf.address_principals CLUSTER ON address_principals_geom_idx
CREATE INDEX address_aliases_geom_idx ON gnaf.address_aliases USING gist (geom); ALTER TABLE gnaf.address_aliases CLUSTER ON address_aliases_geom_idx
CREATE INDEX streets_geom_idx ON gnaf.streets USING gist (geom); ALTER TABLE gnaf.streets CLUSTER ON streets_geom_idx
CREATE INDEX localities_geom_idx ON gnaf.localities USING gist (geom); ALTER TABLE gnaf.localities CLUSTER ON localities_geom_idx
CREATE INDEX postcode_bdys_geom_idx ON admin_bdys.postcode_bdys USING gist (geom); ALTER TABLE admin_bdys.postcode_bdys CLUSTER ON postcode_bdys_geom_idx

-- primary keys
ALTER TABLE ONLY gnaf.address_principals ADD CONSTRAINT address_principals_pk PRIMARY KEY (gnaf_pid);
ALTER TABLE ONLY gnaf.address_aliases ADD CONSTRAINT address_aliases_pk PRIMARY KEY (gnaf_pid);
ALTER TABLE ONLY gnaf.locality_aliases ADD CONSTRAINT locality_aliases_pk PRIMARY KEY (locality_pid, locality_alias_name);
ALTER TABLE ONLY gnaf.locality_neighbour_lookup ADD CONSTRAINT locality_neighbour_lookup_pk PRIMARY KEY (locality_pid, neighbour_locality_pid);
ALTER TABLE ONLY gnaf.address_alias_lookup ADD CONSTRAINT address_alias_lookup_pk PRIMARY KEY (alias_pid);
ALTER TABLE ONLY gnaf.address_secondary_lookup ADD CONSTRAINT address_secondary_lookup_pk PRIMARY KEY (secondary_pid);
ALTER TABLE ONLY gnaf.street_aliases ADD CONSTRAINT street_aliases_pk PRIMARY KEY (street_locality_pid, full_alias_street_name);
ALTER TABLE ONLY admin_bdys.postcode_bdys ADD CONSTRAINT postcode_bdys_pk PRIMARY KEY (gid);

-- required for boundary tagging
CREATE INDEX address_principals_gid_idx ON gnaf.address_principals USING btree(gid);
CREATE INDEX address_aliases_gid_idx ON gnaf.address_principals USING btree(gid);

-- foreign keys

-- address_principals
ALTER TABLE ONLY gnaf.address_principals ADD CONSTRAINT address_principals_fk1 FOREIGN KEY (locality_pid) REFERENCES gnaf.localities(locality_pid);
ALTER TABLE ONLY gnaf.address_principals ADD CONSTRAINT address_principals_fk2 FOREIGN KEY (street_locality_pid) REFERENCES gnaf.streets(street_locality_pid);

-- address_aliases
ALTER TABLE ONLY gnaf.address_aliases ADD CONSTRAINT address_aliases_fk1 FOREIGN KEY (locality_pid) REFERENCES gnaf.localities(locality_pid);
ALTER TABLE ONLY gnaf.address_aliases ADD CONSTRAINT address_aliases_fk2 FOREIGN KEY (street_locality_pid) REFERENCES gnaf.streets(street_locality_pid);

-- address_alias_lookup
ALTER TABLE ONLY gnaf.address_alias_lookup ADD CONSTRAINT address_alias_lookup_fk1 FOREIGN KEY (alias_pid) REFERENCES gnaf.address_aliases(gnaf_pid);
ALTER TABLE ONLY gnaf.address_alias_lookup ADD CONSTRAINT address_alias_lookup_fk2 FOREIGN KEY (principal_pid) REFERENCES gnaf.address_principals(gnaf_pid);

-- -- address_secondary_lookup - can't add foreign keys as addreses are split into principals and aliases
-- ALTER TABLE ONLY gnaf.address_secondary_lookup ADD CONSTRAINT address_secondary_lookup_fk1 FOREIGN KEY (primary_pid) REFERENCES gnaf.address_principals(gnaf_pid);
-- ALTER TABLE ONLY gnaf.address_secondary_lookup ADD CONSTRAINT address_secondary_lookup_fk2 FOREIGN KEY (secondary_pid) REFERENCES gnaf.address_principals(gnaf_pid);

-- streets
ALTER TABLE ONLY gnaf.streets ADD CONSTRAINT streets_fk1 FOREIGN KEY (locality_pid) REFERENCES gnaf.localities(locality_pid);

-- street_aliases
ALTER TABLE ONLY gnaf.street_aliases ADD CONSTRAINT street_aliases_fk1 FOREIGN KEY (street_locality_pid) REFERENCES gnaf.streets(street_locality_pid);

-- locality_aliases
ALTER TABLE ONLY gnaf.locality_aliases ADD CONSTRAINT locality_aliases_fk1 FOREIGN KEY (locality_pid) REFERENCES gnaf.localities(locality_pid);

-- locality_neighbour_lookup
ALTER TABLE ONLY gnaf.locality_neighbour_lookup ADD CONSTRAINT locality_neighbour_lookup_fk1 FOREIGN KEY (locality_pid) REFERENCES gnaf.localities(locality_pid);
ALTER TABLE ONLY gnaf.locality_neighbour_lookup ADD CONSTRAINT locality_neighbour_lookup_fk2 FOREIGN KEY (neighbour_locality_pid) REFERENCES gnaf.localities(locality_pid);
