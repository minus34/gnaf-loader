
--------------------------------------------------------------------------------------
-- locality boundaries
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.locality_bdys CASCADE;
CREATE TABLE admin_bdys.locality_bdys(
  gid SERIAL NOT NULL,
  locality_pid text NOT NULL,
  locality_name text NOT NULL,
  postcode text NULL,
  state text NOT NULL,
  locality_class text NOT NULL,
  address_count integer NOT NULL DEFAULT 0,
  street_count integer NOT NULL DEFAULT 0,
  geom geometry(Multipolygon, 4283, 2) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.locality_bdys OWNER TO postgres;

INSERT INTO admin_bdys.locality_bdys (locality_pid, locality_name, postcode, state, locality_class, geom)
SELECT dat.loc_pid,
       dat.name,
       dat.postcode,
       ste.st_abbrev,
       aut.name_aut,
       st_multi(st_union(st_buffer(bdy.geom, 0.0)))
  FROM raw_admin_bdys.aus_locality AS dat
  INNER JOIN raw_admin_bdys.aus_locality_polygon AS bdy ON dat.loc_pid = bdy.loc_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON dat.state_pid = ste.state_pid
  INNER JOIN raw_admin_bdys.aus_locality_class_aut AS aut ON dat.loccl_code = aut.code_aut
  WHERE dat.loccl_code = 'G'
  GROUP BY dat.loc_pid,
       dat.name,
       dat.postcode,
       ste.st_abbrev,
       aut.name_aut;

ANALYZE admin_bdys.locality_bdys;


-- cookie cut ACT districts to areas without a gazetted locality; and add to locality bdys table

-- create temp table of ACT districts
DROP TABLE IF EXISTS temp_districts;
CREATE TEMPORARY TABLE temp_districts (
  locality_pid text NOT NULL PRIMARY KEY,
  locality_name text NOT NULL,
  postcode text NULL,
  state text NOT NULL,
  locality_class text NOT NULL,
  geom geometry(Multipolygon, 4283, 2) NULL
) WITH (OIDS=FALSE);
ALTER TABLE temp_districts OWNER TO postgres;

CREATE INDEX temp_districts_geom_idx ON temp_districts USING gist(geom);
ALTER TABLE temp_districts CLUSTER ON temp_districts_geom_idx;

INSERT INTO temp_districts
SELECT dat.loc_pid,
       dat.name,
       dat.postcode,
       ste.st_abbrev,
       aut.name_aut,
       ST_Multi(ST_Union(ST_Buffer(bdy.geom, 0.0)))
  FROM raw_admin_bdys.aus_locality AS dat
  INNER JOIN raw_admin_bdys.aus_locality_polygon AS bdy ON dat.loc_pid = bdy.loc_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON dat.state_pid = ste.state_pid
  INNER JOIN raw_admin_bdys.aus_locality_class_aut AS aut ON dat.loccl_code = aut.code_aut
  WHERE dat.loccl_code = 'D'
  AND ste.st_abbrev = 'ACT'
  GROUP BY dat.loc_pid,
       dat.name,
       dat.postcode,
       ste.st_abbrev,
       aut.name_aut;

ANALYZE temp_districts;

-- Insert the ACT localities merged into a single multipolygon as the cookie cutter
INSERT INTO temp_districts
  SELECT 'DUMMY',
         'DUMMY',
         NULL,
         'XYZ',
         'DUMMY',
         ST_Multi(ST_Union(geom)) AS geom
  FROM admin_bdys.locality_bdys
  WHERE state = 'ACT';

-- cookie cut the districts up by the merged localities (buffer required to remove slivers)
UPDATE temp_districts AS dist
  SET geom = ST_Multi(ST_Buffer(ST_Buffer(ST_Difference(dist.geom, (SELECT geom FROM temp_districts WHERE locality_pid = 'DUMMY')), 0.00000001), -0.00000001))
  WHERE locality_pid <> 'DUMMY';

-- delete the cookie cutter
DELETE FROM temp_districts WHERE locality_pid = 'DUMMY';


-- while we're at it - fill the big gap in SA with an unincorporated area
INSERT INTO temp_districts
SELECT 'SA999999',
       'UNINCORPORATED',
       NULL,
       'SA',
       'UNOFFICIAL SUBURB',
       ST_Multi(ST_Buffer(ST_Difference(ST_SetSRID(ST_GeomFromText('POLYGON((128.96007125417 -25.9721745610671,133.1115 -25.9598957395068,133.12 -26.6761603305237,133.797926948924 -26.6925320926041,133.724254019562 -27.5888860665053,133.867506937766 -28.0513883452762,133.892064580886 -29.5739622187522,133.138963525189 -29.5125681109508,133.110312941548 -30.6094761703367,131.645040235353 -30.494873835774,128.98053595677 -30.789565553221,128.96007125417 -25.9721745610671))'), 4283), ST_Union(geom)), 0.0))
  FROM admin_bdys.locality_bdys
  WHERE ST_Intersects(geom, ST_SetSRID(ST_GeomFromText('POLYGON((128.96007125417 -25.9721745610671,133.1115 -25.9598957395068,133.12 -26.6761603305237,133.797926948924 -26.6925320926041,133.724254019562 -27.5888860665053,133.867506937766 -28.0513883452762,133.892064580886 -29.5739622187522,133.138963525189 -29.5125681109508,133.110312941548 -30.6094761703367,131.645040235353 -30.494873835774,128.98053595677 -30.789565553221,128.96007125417 -25.9721745610671))'), 4283));


-- insert the districts into the gazetted localities, whilst ignoring the remaining slivers (Admin boundary topology is not perfect)
INSERT INTO admin_bdys.locality_bdys (locality_pid, locality_name, postcode, state, locality_class, geom)
SELECT locality_pid,
       locality_name,
       postcode,
       state,
       locality_class,
       ST_Multi(ST_Union(geom))
  FROM (
    SELECT locality_pid,
           locality_name,
           postcode,
           state,
           locality_class,
           ST_Area((ST_Dump(geom)).geom) AS area,
           (ST_Dump(geom)).geom as geom
      FROM temp_districts
  ) AS sqt
  WHERE area > 0.000001
  GROUP BY locality_pid,
           locality_name,
           postcode,
           state,
           locality_class;

DROP TABLE temp_districts;


-- insert the missing boundary for Thistle Island, SA - from a polygon in the raw state boundaries
INSERT INTO admin_bdys.locality_bdys (locality_pid, locality_name, postcode, state, locality_class, geom)
SELECT '250190776' AS locality_pid,
       'THISTLE ISLAND' AS locality_name,
       null AS postcode,
       'SA' AS state,
       'TOPOGRAPHIC LOCALITY' AS locality_class,
       ST_Multi(ST_Buffer(geom, 0.0)) AS geom
       --ST_Multi(ST_Buffer((SELECT geom FROM raw_admin_bdys.aus_state_polygon WHERE ST_Intersects(ST_SetSRID(ST_MakePoint(136.1757, -35.0310), 4283), geom)), 0.0)) as geom;
  FROM raw_admin_bdys.aus_state_polygon
  WHERE ST_Intersects(ST_SetSRID(ST_MakePoint(136.1757, -35.0310), 4283), geom);
  

-- split Melbourne into its 2 postcode areas: 3000 (north of the Yarra River) and 3004 (south)
DROP TABLE IF EXISTS temp_bdys;
CREATE UNLOGGED TABLE temp_bdys
(
  locality_pid text NOT NULL,
  locality_name text NOT NULL,
  postcode text NULL,
  state text NOT NULL,
	locality_class text NOT NULL,
  geom geometry(Multipolygon, 4283, 2) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE temp_bdys OWNER TO postgres;

insert into temp_bdys
select locality_pid,
       locality_name,
       '3000' AS postcode,
       state,
       locality_class,
       ST_Multi((ST_Dump(ST_Split(geom, ST_GeomFromText('LINESTRING(144.96691 -37.82135,144.96826 -37.81924,144.97045 -37.81911,144.97235 -37.81921,144.97345 -37.81955,144.97465 -37.82049,144.97734 -37.82321,144.97997 -37.82602,144.98154 -37.82696,144.98299 -37.82735,144.98499 -37.82766,144.9866 -37.82985)', 4283)))).geom) AS geom
  from admin_bdys.locality_bdys
  where locality_pid = 'VIC1634';

-- update the locality_pids of the 2 new boundaries
UPDATE temp_bdys
  SET locality_pid = locality_pid || '_2',
      postcode = '3004'
  WHERE ST_Intersects(ST_SetSRID(ST_MakePoint(144.9781, -37.8275), 4283), geom);

UPDATE temp_bdys
  SET locality_pid = locality_pid || '_1'
  WHERE postcode = '3000';

-- insert the new boundaries into the main table, the old record doesn't get deleted yet!
INSERT INTO admin_bdys.locality_bdys (locality_pid, locality_name, postcode, state, locality_class, geom)
SELECT locality_pid,
       locality_name,
       postcode,
       state,
       locality_class,
       geom
  FROM temp_bdys;

DROP TABLE temp_bdys;

-- delete the replaced Melbourne locality
DELETE FROM admin_bdys.locality_bdys WHERE locality_pid = 'VIC1634';


-- update stats
ANALYZE admin_bdys.locality_bdys;

-- create indexes for later use
ALTER TABLE admin_bdys.locality_bdys ADD CONSTRAINT locality_bdys_pk PRIMARY KEY (locality_pid);
CREATE UNIQUE INDEX locality_bdys_gid_idx ON admin_bdys.locality_bdys USING btree(gid);
CREATE INDEX locality_bdys_geom_idx ON admin_bdys.locality_bdys USING gist(geom);
ALTER TABLE admin_bdys.locality_bdys CLUSTER ON locality_bdys_geom_idx;


-- uncomment this if your want an SA Hundreds boundary table (historical bdys)

-- -- create South Australian Hundreds table -- 1s
-- DROP TABLE IF EXISTS admin_bdys.hundreds_sa_only;
-- CREATE UNLOGGED TABLE admin_bdys.hundreds_sa_only
-- (
--   gid SERIAL NOT NULL,
--   locality_pid text NOT NULL PRIMARY KEY,
--   locality_name text NOT NULL,
--   postcode text NULL,
--   state text NOT NULL,
-- 	locality_class text NOT NULL,
--   geom geometry(Multipolygon, 4283, 2) NOT NULL
-- )
-- WITH (OIDS=FALSE);
-- ALTER TABLE admin_bdys.hundreds_sa_only OWNER TO postgres;
-- 
-- INSERT INTO admin_bdys.hundreds_sa_only (locality_pid, locality_name, postcode, state, locality_class, geom)
-- SELECT dat.loc_pid,
--        dat.name,
--        dat.postcode,
--        ste.st_abbrev,
--        aut.name,
--        ST_Multi(ST_Buffer(ST_Union(ST_Buffer(bdy.geom, 0.0000001)), -0.0000001))
--   FROM raw_admin_bdys.aus_locality AS dat
--   INNER JOIN raw_admin_bdys.aus_locality_polygon AS bdy ON dat.loc_pid = bdy.loc_pid
--   INNER JOIN raw_admin_bdys.aus_state AS ste ON dat.state_pid = ste.state_pid
--   INNER JOIN locality_class_aut AS aut ON dat.loccl_code = aut.code
--   WHERE dat.loccl_code = 'H'
--   AND ste.st_abbrev = 'SA'
--   GROUP BY dat.loc_pid,
--        dat.name,
--        dat.postcode,
--        ste.st_abbrev,
--        aut.name;
-- 
-- -- update stats
-- ANALYZE admin_bdys.hundreds_sa_only;
-- 
-- CREATE UNIQUE INDEX hundreds_sa_only_gid_idx ON admin_bdys.hundreds_sa_only USING btree(gid);
-- CREATE INDEX hundreds_sa_only_geom_idx ON admin_bdys.hundreds_sa_only USING gist(geom);
-- ALTER TABLE admin_bdys.hundreds_sa_only CLUSTER ON hundreds_sa_only_geom_idx;


-- # ---------------------------------------------------------------------------------
-- derived postcode boundaries -- insert done using multiprocessing in load.gnaf.py
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.postcode_bdys CASCADE;
CREATE UNLOGGED TABLE admin_bdys.postcode_bdys
(
  gid SERIAL NOT NULL,
  postcode text,
  state text NOT NULL,
  address_count integer NOT NULL,
  street_count integer NOT NULL,
  geom geometry(Multipolygon, 4283, 2) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.postcode_bdys OWNER TO postgres;


-- # ---------------------------------------------------------------------------------
-- states
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.state_bdys CASCADE;
CREATE TABLE admin_bdys.state_bdys AS
SELECT bdy.gid,
       tab.state_pid,
       tab.state_name AS name,
       tab.st_abbrev AS state,
       bdy.geom
  FROM raw_admin_bdys.aus_state AS tab
  INNER JOIN raw_admin_bdys.aus_state_polygon AS bdy ON tab.state_pid = bdy.state_pid;

ALTER TABLE admin_bdys.state_bdys ADD CONSTRAINT state_bdys_pk PRIMARY KEY (gid);
CREATE INDEX state_bdys_geom_idx ON admin_bdys.state_bdys USING gist(geom);
ALTER TABLE admin_bdys.state_bdys CLUSTER ON state_bdys_geom_idx;


-- # ---------------------------------------------------------------------------------
-- commonwealth electoral boundaries
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.commonwealth_electorates CASCADE;
CREATE TABLE admin_bdys.commonwealth_electorates AS
SELECT bdy.gid,
       tab.ce_pid,
       tab.name,
       tab.dt_gazetd,
       ste.st_abbrev AS state,
       tab.redistyear,
       bdy.geom
  FROM raw_admin_bdys.aus_comm_electoral AS tab
  INNER JOIN raw_admin_bdys.aus_comm_electoral_polygon AS bdy ON tab.ce_pid = bdy.ce_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.commonwealth_electorates ADD CONSTRAINT commonwealth_electorates_pk PRIMARY KEY (gid);
CREATE INDEX commonwealth_electorates_geom_idx ON admin_bdys.commonwealth_electorates USING gist(geom);
ALTER TABLE admin_bdys.commonwealth_electorates CLUSTER ON commonwealth_electorates_geom_idx;


-- # ----------------------------------------------------------------------------------------------
-- state electoral boundaries - choose bdys that will be current until at least 3 months from now
---------------------------------------------------------------------------------------------------

-- create lower house table
DROP TABLE IF EXISTS admin_bdys.state_lower_house_electorates CASCADE;
CREATE TABLE admin_bdys.state_lower_house_electorates AS
SELECT bdy.gid,
       tab.se_pid AS se_lower_pid,
       tab.name,
       tab.dt_gazetd,
       tab.eff_start, 
       tab.eff_end,
       aut.name_aut AS electorate_class,
       ste.st_abbrev AS state,
       bdy.geom
  FROM raw_admin_bdys.aus_state_electoral AS tab
  INNER JOIN raw_admin_bdys.aus_state_electoral_polygon AS bdy ON tab.se_pid = bdy.se_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid
  INNER JOIN raw_admin_bdys.aus_state_electoral_class_aut AS aut ON tab.secl_code = aut.code_aut
  WHERE (tab.eff_end > now() + interval '3 months'
    OR (tab.eff_start <= now() + interval '3 months' AND tab.eff_end IS NULL))
  AND tab.secl_code <> '3';

ALTER TABLE admin_bdys.state_lower_house_electorates ADD CONSTRAINT state_lower_house_electorates_pk PRIMARY KEY (gid);
CREATE INDEX state_lower_house_electorates_geom_idx ON admin_bdys.state_lower_house_electorates USING gist(geom);
ALTER TABLE admin_bdys.state_lower_house_electorates CLUSTER ON state_lower_house_electorates_geom_idx;

-- # --
-- create upper house table
DROP TABLE IF EXISTS admin_bdys.state_upper_house_electorates CASCADE;
CREATE TABLE admin_bdys.state_upper_house_electorates AS
SELECT bdy.gid,
       tab.se_pid AS se_upper_pid,
       tab.name,
       tab.dt_gazetd,
       tab.eff_start, 
       tab.eff_end,
       aut.name_aut AS electorate_class,
       ste.st_abbrev AS state,
       bdy.geom
  FROM raw_admin_bdys.aus_state_electoral AS tab
  INNER JOIN raw_admin_bdys.aus_state_electoral_polygon AS bdy ON tab.se_pid = bdy.se_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid
  INNER JOIN raw_admin_bdys.aus_state_electoral_class_aut AS aut ON tab.secl_code = aut.code_aut
  WHERE (tab.eff_end > now() + interval '3 months'
    OR (tab.eff_start <= now() AND tab.eff_end IS NULL))
  AND tab.secl_code = '3'
  AND ste.st_abbrev NOT IN ('NSW', 'SA');

ALTER TABLE admin_bdys.state_upper_house_electorates ADD CONSTRAINT state_upper_house_electorates_pk PRIMARY KEY (gid);
CREATE INDEX state_upper_house_electorates_geom_idx ON admin_bdys.state_upper_house_electorates USING gist(geom);
ALTER TABLE admin_bdys.state_upper_house_electorates CLUSTER ON state_upper_house_electorates_geom_idx;


-- # ---------------------------------------------------------------------------------
-- local government areas
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.local_government_areas CASCADE;
CREATE TABLE admin_bdys.local_government_areas AS
SELECT bdy.gid,
       tab.lga_pid,
       tab.abb_name AS name,
       tab.lga_name AS full_name,
       ste.st_abbrev AS state,
       bdy.geom
  FROM raw_admin_bdys.aus_lga AS tab
  INNER JOIN raw_admin_bdys.aus_lga_polygon AS bdy ON tab.lga_pid = bdy.lga_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.local_government_areas ADD CONSTRAINT local_government_areas_pk PRIMARY KEY (gid);
CREATE INDEX local_government_areas_geom_idx ON admin_bdys.local_government_areas USING gist(geom);
ALTER TABLE admin_bdys.local_government_areas CLUSTER ON local_government_areas_geom_idx;


-- # ---------------------------------------------------------------------------------
-- local government wards
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.local_government_wards CASCADE;
CREATE TABLE admin_bdys.local_government_wards AS
SELECT bdy.gid,
       tab.ward_pid,
       lga.lga_pid,
       tab.name,
       tab.name AS lga_name,
       ste.st_abbrev AS state,
       bdy.geom
  FROM raw_admin_bdys.aus_ward AS tab
  INNER JOIN raw_admin_bdys.aus_lga AS lga ON tab.lga_pid = lga.lga_pid
  INNER JOIN raw_admin_bdys.aus_ward_polygon AS bdy ON tab.ward_pid = bdy.ward_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.local_government_wards ADD CONSTRAINT local_government_wards_pk PRIMARY KEY (gid);
CREATE INDEX local_government_wards_geom_idx ON admin_bdys.local_government_wards USING gist(geom);
ALTER TABLE admin_bdys.local_government_wards CLUSTER ON local_government_wards_geom_idx;
