
-- temp addresses table
DROP TABLE IF EXISTS gnaf.temp_addresses CASCADE;
CREATE TABLE gnaf.temp_addresses
(
  gid SERIAL NOT NULL,
  gnaf_pid character varying(16) NOT NULL,
  street_locality_pid character varying(16) NOT NULL,
  locality_pid character varying(16) NOT NULL,
  alias_principal character(1) NOT NULL,
  primary_secondary character varying(1) NULL,
  building_name character varying(45) NULL,
  lot_number character varying(9) NULL,
  flat_number character varying(50) NULL,
  level_number character varying(50) NULL,
  number_first character varying(11) NULL,
  number_last character varying(11) NULL,
  street_name character varying(100) NOT NULL,
  street_type character varying(15) NULL,
  street_suffix character varying(15) NULL,
  postcode character varying(4) NULL,
  confidence smallint NOT NULL,
  legal_parcel_id character varying(20) NULL,
  mb_2011_code bigint NULL,
  mb_2016_code bigint NULL,
  latitude numeric(10,8) NOT NULL,
  longitude numeric(11,8) NOT NULL,
  geocode_type character varying(50) NOT NULL,
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
  gnaf_pid character varying(16) NOT NULL,
  street_locality_pid character varying(16) NOT NULL,
  locality_pid character varying(16) NOT NULL,
  alias_principal character(1) NOT NULL,
  primary_secondary character varying(1) NULL,
  building_name character varying(45) NULL,
  lot_number character varying(9) NULL,
  flat_number character varying(50) NULL,
  level_number character varying(50) NULL,
  number_first character varying(11) NULL,
  number_last character varying(11) NULL,
  street_name character varying(100) NOT NULL,
  street_type character varying(15) NULL,
  street_suffix character varying(15) NULL,
  address character varying(255) NOT NULL,
  locality_name character varying(100) NOT NULL,
  postcode character varying(4) NULL,
  state character varying(3) NOT NULL,
  locality_postcode character varying(4) NULL,
  confidence smallint NOT NULL,
  legal_parcel_id character varying(20) NULL,
  mb_2011_code bigint NULL,
  mb_2016_code bigint NULL,
  latitude numeric(10,8) NOT NULL,
  longitude numeric(11,8) NOT NULL,
  geocode_type character varying(50) NOT NULL,
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
  gnaf_pid character varying(16) NOT NULL,
  street_locality_pid character varying(16) NOT NULL,
  locality_pid character varying(16) NOT NULL,
  alias_principal character(1) NOT NULL,
  primary_secondary character varying(1) NULL,
  building_name character varying(45) NULL,
  lot_number character varying(9) NULL,
  flat_number character varying(50) NULL,
  level_number character varying(50) NULL,
  number_first character varying(11) NULL,
  number_last character varying(11) NULL,
  street_name character varying(100) NOT NULL,
  street_type character varying(15) NULL,
  street_suffix character varying(15) NULL,
  address character varying(255) NOT NULL,
  locality_name character varying(100) NOT NULL,
  postcode character varying(4) NULL,
  state character varying(3) NOT NULL,
  locality_postcode character varying(4) NULL,
  confidence smallint NOT NULL,
  legal_parcel_id character varying(20) NULL,
  mb_2011_code bigint NULL,
  mb_2016_code bigint NULL,
  latitude numeric(10,8) NOT NULL,
  longitude numeric(11,8) NOT NULL,
  geocode_type character varying(50) NOT NULL,
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
  street_locality_pid character varying(16) NOT NULL,
  locality_pid character varying(16) NOT NULL,
  street_name character varying(100) NOT NULL,
  street_type character varying(15),
  street_suffix character varying(15),
  full_street_name character varying(150) NOT NULL,
	locality_name character varying(100) NOT NULL,
	postcode character varying(4) NULL,
	state character varying(3) NOT NULL,
  street_type_abbrev character varying(15),
  street_suffix_abbrev character varying(15),
  street_class character varying(50),
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
  street_locality_pid character varying(16) NOT NULL,
  alias_street_name character varying(100) NOT NULL,
  alias_street_type character varying(15),
  alias_street_suffix character varying(15),
  full_alias_street_name character varying(150) NOT NULL,
	alias_type character varying(50) NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.street_aliases OWNER TO postgres;


-- localities
DROP TABLE IF EXISTS gnaf.localities CASCADE;
CREATE TABLE gnaf.localities(
  gid SERIAL NOT NULL,
	locality_pid character varying(16) NOT NULL,
	locality_name character varying(100) NOT NULL,
	postcode character varying(4) NULL,
	state character varying(3) NOT NULL,
	std_locality_name character varying(100) NOT NULL DEFAULT '',
	latitude numeric(10, 8) NULL,
	longitude numeric(11, 8) NULL,
	locality_class character varying(50) NOT NULL,
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
	locality_pid character varying(16) NOT NULL,
	locality_name character varying(100) NOT NULL,
	postcode character varying(4) NULL,
	state character varying(3) NOT NULL,
	locality_alias_name character varying(100) NOT NULL,
	std_alias_name character varying(100) NOT NULL,
	alias_type character varying(50) NULL,
 	unique_alias_state char(1) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.locality_aliases OWNER TO postgres;


-- locality neighbours
DROP TABLE IF EXISTS gnaf.locality_neighbour_lookup CASCADE;
CREATE TABLE gnaf.locality_neighbour_lookup(
  locality_pid character varying(16) NOT NULL,
  neighbour_locality_pid character varying(16) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.locality_neighbour_lookup OWNER TO postgres;


-- principal alias address lookup
DROP TABLE IF EXISTS gnaf.address_alias_lookup CASCADE;
CREATE TABLE gnaf.address_alias_lookup(
  principal_pid character varying(16) NOT NULL,
  alias_pid character varying(16) NOT NULL,
  alias_type character varying(50) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.address_alias_lookup OWNER TO postgres;


-- primary secondary address lookup
DROP TABLE IF EXISTS gnaf.address_secondary_lookup CASCADE;
CREATE TABLE gnaf.address_secondary_lookup(
  primary_pid character varying(16) NOT NULL,
  secondary_pid character varying(16) NOT NULL,
  join_type character varying(50) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.address_secondary_lookup OWNER TO postgres;
