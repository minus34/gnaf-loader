
-- create localities table - will contain:
--   - gazetted localities;
--   - ACT districts (cut around the gazetted localities); and
--   - a manually added boundary for Thistle Island, SA (based on a state boundary polygon);

INSERT INTO admin_bdys.locality_boundaries (locality_pid, locality_name, postcode, state, locality_class, address_count, street_count, geom)
SELECT dat.loc_pid,
       dat.name,
       dat.postcode,
       ste.st_abbrev,
       aut.name,
       0,
       0,
       st_multi(st_buffer(st_union(st_snaptogrid(bdy.geom, 0.0000001)), 0.0))
  FROM raw_admin_bdys.aus_locality AS dat
  INNER JOIN raw_admin_bdys.aus_locality_polygon AS bdy ON dat.loc_pid = bdy.loc_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON dat.state_pid = ste.state_pid
  INNER JOIN raw_gnaf.locality_class_aut AS aut ON dat.loccl_code = aut.code
  WHERE dat.loccl_code = 'G'
  GROUP BY dat.loc_pid,
       dat.name,
       dat.postcode,
       ste.st_abbrev,
       aut.name;


-- cookie cut ACT districts to areas without a gazetted locality; and add to locality bdys table
-- create temp table of ACT districts
DROP TABLE IF EXISTS temp_districts;
CREATE TEMPORARY TABLE temp_districts
(
  gid SERIAL NOT NULL,
  locality_pid character varying(16) NOT NULL PRIMARY KEY,
  locality_name character varying(100) NOT NULL,
  postcode char(4) NULL,
  state character varying(3) NOT NULL,
	locality_class character varying(50) NOT NULL,
  geom geometry(Multipolygon, 4283, 2) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE temp_districts OWNER TO postgres;

CREATE UNIQUE INDEX temp_districts_gid_idx ON temp_districts USING btree(gid);
CREATE INDEX temp_districts_geom_idx ON temp_districts USING gist(geom);
ALTER TABLE temp_districts CLUSTER ON temp_districts_geom_idx;

INSERT INTO temp_districts (locality_pid, locality_name, postcode, state, locality_class, geom)
SELECT dat.loc_pid,
       dat.name,
       dat.postcode,
       ste.st_abbrev,
       aut.name,
       ST_Multi(ST_Buffer(ST_Union(st_snaptogrid(bdy.geom, 0.0000001)), 0.0))
  FROM raw_admin_bdys.aus_locality AS dat
  INNER JOIN raw_admin_bdys.aus_locality_polygon AS bdy ON dat.loc_pid = bdy.loc_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON dat.state_pid = ste.state_pid
  INNER JOIN raw_gnaf.locality_class_aut AS aut ON dat.loccl_code = aut.code
  WHERE dat.loccl_code = 'D'
  AND ste.st_abbrev = 'ACT'
  GROUP BY dat.loc_pid,
       dat.name,
       dat.postcode,
       ste.st_abbrev,
       aut.name;

ANALYZE temp_districts;

-- Insert the ACT localities merged into a single multipolygon as the cookie cutter
INSERT INTO temp_districts (locality_pid, locality_name, postcode, state, locality_class, geom)
  SELECT 'DUMMY', 'DUMMY', '9999', 'XYZ', 'DUMMY', ST_Multi(ST_Buffer(ST_Union(st_snaptogrid(geom, 0.0000001)), 0.0)) As geom FROM admin_bdys.locality_boundaries WHERE state = 'ACT';

-- cookie cut the districts up by the merged localities
UPDATE temp_districts AS dist
  SET geom = ST_Multi(ST_Buffer(ST_Difference(dist.geom, (SELECT geom FROM temp_districts WHERE locality_pid = 'DUMMY')), 0.0));

-- delete the cookie cutter
DELETE FROM temp_districts WHERE locality_pid = 'DUMMY';

-- insert the districts into the gazetted localities, whilst ignoring the slivers created in the process (Admin boundary topology is not good)
INSERT INTO admin_bdys.locality_boundaries (locality_pid, locality_name, postcode, state, locality_class, address_count, street_count, geom)
SELECT locality_pid,
       locality_name,
       postcode,
       state,
       locality_class,
       0,
       0,
       ST_Multi(ST_Union(geom))
  FROM (
    SELECT locality_pid, locality_name, postcode, state, locality_class, ST_Area((ST_Dump(geom)).geom) AS area, (ST_Dump(geom)).geom as geom
      FROM temp_districts
  ) AS sqt
  WHERE area > 0.0000001
  GROUP BY locality_pid,
           locality_name,
           postcode,
           state,
           locality_class;

DROP TABLE temp_districts;


-- insert the missing boundary for Thistle Island, SA - from a polygon in the raw state boundaries
INSERT INTO admin_bdys.locality_boundaries (locality_pid, locality_name, postcode, state, locality_class, address_count, street_count, geom)
SELECT '250190776' AS locality_pid,
       'THISTLE ISLAND' AS locality_name,
       null AS postcode,
       'SA' AS state,
       'TOPOGRAPHIC LOCALITY' AS locality_class,
       0,
       0,
       ST_Multi(ST_Buffer(st_snaptogrid(ST_Multi((SELECT geom FROM raw_admin_bdys.aus_state_polygon WHERE ST_Intersects(ST_SetSRID(ST_MakePoint(136.1757, -35.0310), 4283), geom))), 0.0000001), 0.0)) as geom;


-- fill the big gap in SA with an unincorporated area
INSERT INTO admin_bdys.locality_boundaries(locality_pid, locality_name, postcode, state, locality_class, address_count, street_count, geom)
SELECT 'SA999999',
       'UNINCORPORATED',
       NULL,
       'SA',
       'UNOFFICIAL SUBURB',
       0,
       0,
       ST_Multi(ST_Difference(ST_SetSRID(ST_GeomFromText('POLYGON((128.96007125417 -25.9721745610671,133.134870584669 -25.9598957395068,133.147149406229 -26.6761603305237,133.797926948924 -26.6925320926041,133.724254019562 -27.5888860665053,133.867506937766 -28.0513883452762,133.892064580886 -29.5739622187522,133.138963525189 -29.5125681109508,133.110312941548 -30.6094761703367,131.645040235353 -30.494873835774,128.98053595677 -30.789565553221,128.96007125417 -25.9721745610671))'), 4283), ST_Union(geom)))
  FROM admin_bdys.locality_boundaries
  WHERE ST_Intersects(geom, ST_SetSRID(ST_GeomFromText('POLYGON((128.96007125417 -25.9721745610671,133.134870584669 -25.9598957395068,133.147149406229 -26.6761603305237,133.797926948924 -26.6925320926041,133.724254019562 -27.5888860665053,133.867506937766 -28.0513883452762,133.892064580886 -29.5739622187522,133.138963525189 -29.5125681109508,133.110312941548 -30.6094761703367,131.645040235353 -30.494873835774,128.98053595677 -30.789565553221,128.96007125417 -25.9721745610671))'), 4283));
-- 
-- -- fix some slivers that the above created
-- UPDATE admin_bdys.locality_boundaries
--   SET geom = ST_Multi(ST_Buffer(ST_Buffer(geom, -0.00001), 0.00001))
-- WHERE locality_pid = 'SA999999'

-- update stats
ANALYZE admin_bdys.locality_boundaries;

-- indexes
CREATE UNIQUE INDEX locality_boundaries_gid_idx ON admin_bdys.locality_boundaries USING btree(gid);
CREATE INDEX locality_boundaries_geom_idx ON admin_bdys.locality_boundaries USING gist(geom);
ALTER TABLE admin_bdys.locality_boundaries CLUSTER ON locality_boundaries_geom_idx;



-- uncomment this if your want an SA Hundreds boundary table (historical bdys)

-- -- create South Australian Hundreds table -- 1s
-- DROP TABLE IF EXISTS admin_bdys.hundreds_sa_only;
-- CREATE UNLOGGED TABLE admin_bdys.hundreds_sa_only
-- (
--   gid SERIAL NOT NULL,
--   locality_pid character varying(16) NOT NULL PRIMARY KEY,
--   locality_name character varying(100) NOT NULL,
--   postcode char(4) NULL,
--   state character varying(3) NOT NULL,
-- 	locality_class character varying(50) NOT NULL,
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
