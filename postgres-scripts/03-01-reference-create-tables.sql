
-- temp addresses table
DROP TABLE IF EXISTS gnaf.temp_addresses CASCADE;
CREATE TABLE gnaf.temp_addresses
(
  gid SERIAL NOT NULL,
  gnaf_pid text NOT NULL,
  street_locality_pid text NOT NULL,
  locality_pid text NOT NULL,
  alias_principal character(1) NOT NULL,
  primary_secondary text NULL,
  building_name text NULL,
  lot_number text NULL,
  flat_number text NULL,
  level_number text NULL,
  number_first text NULL,
  number_last text NULL,
  street_name text NOT NULL,
  street_type text NULL,
  street_suffix text NULL,
  postcode text NULL,
  confidence smallint NOT NULL,
  legal_parcel_id text NULL,
  mb_2011_code bigint NULL,
  mb_2016_code bigint NULL,
  latitude numeric(10,8) NOT NULL,
  longitude numeric(11,8) NOT NULL,
  geocode_type text NOT NULL,
  reliability smallint NOT NULL,
  geom geometry(Point, 4283, 2) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE gnaf.temp_addresses OWNER TO postgres;


-- principal addresses
DROP TABLE IF EXISTS gnaf.address_principals CASCADE;
CREATE TABLE gnaf.address_principals
(
  gid SERIAL NOT NULL,
  gnaf_pid text NOT NULL,
  street_locality_pid text NOT NULL,
  locality_pid text NOT NULL,
  alias_principal character(1) NOT NULL,
  primary_secondary text NULL,
  building_name text NULL,
  lot_number text NULL,
  flat_number text NULL,
  level_number text NULL,
  number_first text NULL,
  number_last text NULL,
  street_name text NOT NULL,
  street_type text NULL,
  street_suffix text NULL,
  address text NOT NULL,
  locality_name text NOT NULL,
  postcode text NULL,
  state text NOT NULL,
  locality_postcode text NULL,
  confidence smallint NOT NULL,
  legal_parcel_id text NULL,
  mb_2011_code bigint NULL,
  mb_2016_code bigint NULL,
  latitude numeric(10,8) NOT NULL,
  longitude numeric(11,8) NOT NULL,
  geocode_type text NOT NULL,
  reliability smallint NOT NULL,
  geom geometry(Point, 4283, 2) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE gnaf.address_principals OWNER TO postgres;


-- alias addresses
DROP TABLE IF EXISTS gnaf.address_aliases CASCADE;
CREATE TABLE gnaf.address_aliases
(
  gid SERIAL NOT NULL,
  gnaf_pid text NOT NULL,
  street_locality_pid text NOT NULL,
  locality_pid text NOT NULL,
  alias_principal character(1) NOT NULL,
  primary_secondary text NULL,
  building_name text NULL,
  lot_number text NULL,
  flat_number text NULL,
  level_number text NULL,
  number_first text NULL,
  number_last text NULL,
  street_name text NOT NULL,
  street_type text NULL,
  street_suffix text NULL,
  address text NOT NULL,
  locality_name text NOT NULL,
  postcode text NULL,
  state text NOT NULL,
  locality_postcode text NULL,
  confidence smallint NOT NULL,
  legal_parcel_id text NULL,
  mb_2011_code bigint NULL,
  mb_2016_code bigint NULL,
  latitude numeric(10,8) NOT NULL,
  longitude numeric(11,8) NOT NULL,
  geocode_type text NOT NULL,
  reliability smallint NOT NULL,
  geom geometry(Point, 4283, 2) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE gnaf.address_aliases OWNER TO postgres;


-- create view of all addresses
DROP VIEW IF EXISTS gnaf.addresses;
CREATE VIEW gnaf.addresses AS
  SELECT * FROM gnaf.address_principals
  UNION
  SELECT * FROM gnaf.address_aliases;


-- streets
DROP TABLE IF EXISTS gnaf.streets CASCADE;
CREATE TABLE gnaf.streets(
  gid SERIAL NOT NULL,
  street_locality_pid text NOT NULL,
  locality_pid text NOT NULL,
  street_name text NOT NULL,
  street_type text,
  street_suffix text,
  full_street_name text NOT NULL,
  locality_name text NOT NULL,
  postcode text NULL,
  state text NOT NULL,
  street_type_abbrev text,
  street_suffix_abbrev text,
  street_class text,
  latitude numeric(10, 8) NULL,
  longitude numeric(11, 8) NULL,
  reliability smallint NOT NULL DEFAULT 4,
  address_count integer NOT NULL DEFAULT 0,
  geom geometry(Point, 4283, 2) NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.streets OWNER TO postgres;


-- street aliases
DROP TABLE IF EXISTS gnaf.street_aliases CASCADE;
CREATE TABLE gnaf.street_aliases(
  gid SERIAL NOT NULL,
  street_locality_pid text NOT NULL,
  alias_street_name text NOT NULL,
  alias_street_type text,
  alias_street_suffix text,
  full_alias_street_name text NOT NULL,
  alias_type text NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.street_aliases OWNER TO postgres;


-- localities
DROP TABLE IF EXISTS gnaf.localities CASCADE;
CREATE TABLE gnaf.localities(
  gid SERIAL NOT NULL,
  locality_pid text NOT NULL,
  locality_name text NOT NULL,
  postcode text NULL,
  state text NOT NULL,
  std_locality_name text NOT NULL DEFAULT '',
  latitude numeric(10, 8) NULL,
  longitude numeric(11, 8) NULL,
  locality_class text NOT NULL,
  reliability smallint NOT NULL DEFAULT 6,
  address_count integer NOT NULL DEFAULT 0,
  street_count integer NOT NULL DEFAULT 0,
  has_boundary character(1) NOT NULL DEFAULT 'N',
  unique_locality_state character(1) NOT NULL DEFAULT 'N',
  geom geometry(Point, 4283, 2) NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.localities OWNER TO postgres;


-- locality aliases
DROP TABLE IF EXISTS gnaf.locality_aliases CASCADE;
CREATE TABLE gnaf.locality_aliases(
  locality_pid text NOT NULL,
  locality_name text NOT NULL,
  postcode text NULL,
  state text NOT NULL,
  locality_alias_name text NOT NULL,
  std_alias_name text NOT NULL,
  alias_type text NULL,
   unique_alias_state char(1) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.locality_aliases OWNER TO postgres;


-- locality neighbours
DROP TABLE IF EXISTS gnaf.locality_neighbour_lookup CASCADE;
CREATE TABLE gnaf.locality_neighbour_lookup(
  locality_pid text NOT NULL,
  neighbour_locality_pid text NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.locality_neighbour_lookup OWNER TO postgres;


-- principal alias address lookup
DROP TABLE IF EXISTS gnaf.address_alias_lookup CASCADE;
CREATE TABLE gnaf.address_alias_lookup(
  principal_pid text NOT NULL,
  alias_pid text NOT NULL,
  alias_type text NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.address_alias_lookup OWNER TO postgres;


-- primary secondary address lookup
DROP TABLE IF EXISTS gnaf.address_secondary_lookup CASCADE;
CREATE TABLE gnaf.address_secondary_lookup(
  primary_pid text NOT NULL,
  secondary_pid text NOT NULL,
  join_type text NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.address_secondary_lookup OWNER TO postgres;
