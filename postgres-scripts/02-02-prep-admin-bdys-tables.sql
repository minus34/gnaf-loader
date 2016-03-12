
--------------------------------------------------------------------------------------
-- locality boundaries
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.locality_bdys CASCADE;
CREATE TABLE admin_bdys.locality_bdys(
  gid SERIAL NOT NULL,
  locality_pid character varying(16) NOT NULL,
  locality_name character varying(100) NOT NULL,
  postcode char(4) NULL,
  state character varying(3) NOT NULL,
	locality_class character varying(50) NOT NULL,
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
  locality_pid character varying(16) NOT NULL PRIMARY KEY,
  locality_name character varying(100) NOT NULL,
  postcode char(4) NULL,
  state character varying(3) NOT NULL,
	locality_class character varying(50) NOT NULL,
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
  locality_pid character varying(16) NOT NULL,
  locality_name character varying(100) NOT NULL,
  postcode char(4) NULL,
  state character varying(3) NOT NULL,
	locality_class character varying(50) NOT NULL,
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


--------------------------------------------------------------------------------------
-- derived postcode boundaries -- insert done using multiprocessing in load.gnaf.py
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.postcode_bdys CASCADE;
CREATE UNLOGGED TABLE admin_bdys.postcode_bdys
(
  gid SERIAL NOT NULL,
  postcode character(4),
  state character varying(3) NOT NULL,
  address_count integer NOT NULL,
  street_count integer NOT NULL,
  geom geometry(Multipolygon,4283) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.postcode_bdys OWNER TO postgres;


--------------------------------------------------------------------------------------
-- states
--------------------------------------------------------------------------------------

DROP VIEW IF EXISTS raw_admin_bdys.state_bdys CASCADE;
CREATE VIEW raw_admin_bdys.state_bdys AS
SELECT bdy.gid,
       tab.state_pid,
       tab.state_name AS name,
       tab.st_abbrev AS state,
       bdy.geom
  FROM raw_admin_bdys.aus_state AS tab
  INNER JOIN raw_admin_bdys.aus_state_polygon AS bdy ON tab.state_pid = bdy.state_pid;


--------------------------------------------------------------------------------------
-- commonwealth electoral boundaries
--------------------------------------------------------------------------------------

-- create view
DROP VIEW IF EXISTS raw_admin_bdys.commonwealth_electorates CASCADE;
CREATE VIEW raw_admin_bdys.commonwealth_electorates AS
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


---------------------------------------------------------------------------------------------------
-- state electoral boundaries - choose bdys that will be current until at least 3 months from now
---------------------------------------------------------------------------------------------------

-- create lower house view
DROP VIEW IF EXISTS raw_admin_bdys.state_lower_house_electorates CASCADE;
CREATE VIEW raw_admin_bdys.state_lower_house_electorates AS
SELECT bdy.gid,
       tab.se_pid,
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
  AND tab.secl_code <> '3';

-- create upper house view
DROP VIEW IF EXISTS raw_admin_bdys.state_upper_house_electorates CASCADE;
CREATE VIEW raw_admin_bdys.state_upper_house_electorates AS
SELECT bdy.gid,
       tab.se_pid,
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


--------------------------------------------------------------------------------------
-- local government areas
--------------------------------------------------------------------------------------

-- create view
DROP VIEW IF EXISTS raw_admin_bdys.local_government_areas CASCADE;
CREATE VIEW raw_admin_bdys.local_government_areas AS
SELECT bdy.gid,
       tab.lga_pid,
       tab.abb_name AS name,
       tab.lga_name AS full_name,
       ste.st_abbrev AS state,
       bdy.geom
  FROM raw_admin_bdys.aus_lga AS tab
  INNER JOIN raw_admin_bdys.aus_lga_polygon AS bdy ON tab.lga_pid = bdy.lga_pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;


--------------------------------------------------------------------------------------
-- local government wards
--------------------------------------------------------------------------------------

-- create view
DROP VIEW IF EXISTS raw_admin_bdys.local_government_wards CASCADE;
CREATE VIEW raw_admin_bdys.local_government_wards AS
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















--TO DO:
--  - Do the above for all admin bdy types



-- IGNORE THE CODE BELOW - IT'S A JUNKYEARD OF CREATE TABLE STATEMENTS FOR CUTTING AND PASTING THE GOOD BITS FROM...







-- 
-- CREATE TABLE admin_bdys.aus_gccsa_2011 (
--     gid integer NOT NULL,
--     gcc_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     gcc_11code character varying(5),
--     gcc_11name character varying(50),
--     state_pid character varying(15),
--     area_sqm numeric
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_gccsa_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_gccsa_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_gccsa_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_gccsa_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_gccsa_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_gccsa_2011_gid_seq OWNED BY aus_gccsa_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_gccsa_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_gccsa_2011_polygon (
--     gid integer NOT NULL,
--     gcc_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     gcc_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_gccsa_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_gccsa_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_gccsa_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_gccsa_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_gccsa_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_gccsa_2011_polygon_gid_seq OWNED BY aus_gccsa_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_iare_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_iare_2011 (
--     gid integer NOT NULL,
--     iare_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     iare_11cod character varying(6),
--     iare_11nam character varying(50),
--     ireg_11pid character varying(15),
--     ireg_11cod integer,
--     ireg_11nam character varying(50),
--     state_pid character varying(15),
--     area_sqkm double precision
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_iare_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_iare_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_iare_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_iare_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_iare_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_iare_2011_gid_seq OWNED BY aus_iare_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_iare_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_iare_2011_polygon (
--     gid integer NOT NULL,
--     iar_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     iare_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_iare_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_iare_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_iare_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_iare_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_iare_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_iare_2011_polygon_gid_seq OWNED BY aus_iare_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_iloc_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_iloc_2011 (
--     gid integer NOT NULL,
--     iloc_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     iloc_11cod integer,
--     iloc_11nam character varying(50),
--     iare_11pid character varying(15),
--     iare_11cod character varying(6),
--     iare_11nam character varying(50),
--     ireg_11pid character varying(15),
--     ireg_11cod integer,
--     ireg_11nam character varying(50),
--     state_pid character varying(15),
--     area_sqkm double precision
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_iloc_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_iloc_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_iloc_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_iloc_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_iloc_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_iloc_2011_gid_seq OWNED BY aus_iloc_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_iloc_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_iloc_2011_polygon (
--     gid integer NOT NULL,
--     ilo_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     iloc_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_iloc_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_iloc_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_iloc_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_iloc_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_iloc_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_iloc_2011_polygon_gid_seq OWNED BY aus_iloc_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_ireg_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_ireg_2011 (
--     gid integer NOT NULL,
--     ireg_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     ireg_11cod integer,
--     ireg_11nam character varying(50),
--     state_pid character varying(15),
--     area_sqkm double precision
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ireg_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ireg_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_ireg_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ireg_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ireg_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_ireg_2011_gid_seq OWNED BY aus_ireg_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_ireg_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_ireg_2011_polygon (
--     gid integer NOT NULL,
--     ire_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     ireg_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ireg_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ireg_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_ireg_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ireg_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ireg_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_ireg_2011_polygon_gid_seq OWNED BY aus_ireg_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_lga; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_lga (
--     gid integer NOT NULL,
--     lga_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     lga_name character varying(100),
--     abb_name character varying(100),
--     dt_gazetd date,
--     state_pid character varying(15)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_lga OWNER TO postgres;
-- 
-- --
-- -- Name: aus_lga_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_lga_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_lga_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_lga_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_lga_gid_seq OWNED BY aus_lga.gid;
-- 
-- 
-- --
-- -- Name: aus_lga_locality; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_lga_locality (
--     gid integer NOT NULL,
--     lg_loc_pid character varying(20),
--     dt_create date,
--     dt_retire date,
--     lga_pid character varying(15),
--     loc_pid character varying(15)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_lga_locality OWNER TO postgres;
-- 
-- --
-- -- Name: aus_lga_locality_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_lga_locality_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_lga_locality_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_lga_locality_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_lga_locality_gid_seq OWNED BY aus_lga_locality.gid;
-- 
-- 
-- --
-- -- Name: aus_lga_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_lga_polygon (
--     gid integer NOT NULL,
--     lg_ply_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     lga_pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_lga_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_lga_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_lga_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_lga_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_lga_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_lga_polygon_gid_seq OWNED BY aus_lga_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_locality; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_locality (
--     gid integer NOT NULL,
--     loc_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     name character varying(100),
--     postcode character varying(4),
--     prim_pcode character varying(4),
--     loccl_code character varying(1),
--     dt_gazetd date,
--     state_pid character varying(15)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_locality OWNER TO postgres;
-- 
-- --
-- -- Name: aus_locality_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_locality_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_locality_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_locality_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_locality_gid_seq OWNED BY aus_locality.gid;
-- 
-- 
-- --
-- -- Name: aus_locality_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_locality_polygon (
--     gid integer NOT NULL,
--     lc_ply_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     loc_pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_locality_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_locality_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_locality_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_locality_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_locality_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_locality_polygon_gid_seq OWNED BY aus_locality_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_locality_town; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_locality_town (
--     gid integer NOT NULL,
--     locality_t character varying(15),
--     date_creat date,
--     date_retir date,
--     locality_p character varying(15),
--     town_pid character varying(15)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_locality_town OWNER TO postgres;
-- 
-- --
-- -- Name: aus_locality_town_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_locality_town_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_locality_town_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_locality_town_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_locality_town_gid_seq OWNED BY aus_locality_town.gid;
-- 
-- 
-- --
-- -- Name: aus_mb_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_mb_2011 (
--     gid integer NOT NULL,
--     mb_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sa1_11pid character varying(15),
--     mb_cat_cd character varying(10),
--     mb_11code character varying(15),
--     sa1_11main double precision,
--     sa1_11_7cd integer,
--     sa2_11main integer,
--     sa2_11_5cd integer,
--     sa2_11name character varying(50),
--     sa3_11code integer,
--     sa3_11name character varying(50),
--     sa4_11code integer,
--     sa4_11name character varying(50),
--     gcc_11code character varying(5),
--     gcc_11name character varying(50),
--     state_pid character varying(15),
--     area_sqm numeric,
--     mb11_pop integer,
--     mb11_dwell integer
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_mb_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_mb_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_mb_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_mb_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_mb_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_mb_2011_gid_seq OWNED BY aus_mb_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_mb_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_mb_2011_polygon (
--     gid integer NOT NULL,
--     mb_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     mb_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_mb_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_mb_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_mb_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_mb_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_mb_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_mb_2011_polygon_gid_seq OWNED BY aus_mb_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_remoteness_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_remoteness_2011 (
--     gid integer NOT NULL,
--     rem11_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     rem11_ccd character varying(15),
--     rem11_code integer,
--     state_pid character varying(15),
--     areasqkm double precision
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_remoteness_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_remoteness_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_remoteness_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_remoteness_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_remoteness_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_remoteness_2011_gid_seq OWNED BY aus_remoteness_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_remoteness_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_remoteness_2011_polygon (
--     gid integer NOT NULL,
--     rem11_ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     rem11_pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_remoteness_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_remoteness_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_remoteness_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_remoteness_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_remoteness_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_remoteness_2011_polygon_gid_seq OWNED BY aus_remoteness_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_sa1_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sa1_2011 (
--     gid integer NOT NULL,
--     sa1_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sa2_11pid character varying(15),
--     sa1_11main double precision,
--     sa1_11_7cd integer,
--     sa2_11main integer,
--     sa2_11_5cd integer,
--     sa2_11name character varying(50),
--     sa3_11code integer,
--     sa3_11name character varying(50),
--     sa4_11code integer,
--     sa4_11name character varying(50),
--     gcc_11code character varying(5),
--     gcc_11name character varying(50),
--     state_pid character varying(15),
--     area_sqm numeric
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa1_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa1_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sa1_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa1_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa1_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sa1_2011_gid_seq OWNED BY aus_sa1_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_sa1_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sa1_2011_polygon (
--     gid integer NOT NULL,
--     sa1_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sa1_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa1_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa1_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sa1_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa1_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa1_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sa1_2011_polygon_gid_seq OWNED BY aus_sa1_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_sa2_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sa2_2011 (
--     gid integer NOT NULL,
--     sa2_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sa3_11pid character varying(15),
--     sa2_11main integer,
--     sa2_11_5cd integer,
--     sa2_11name character varying(50),
--     sa3_11code integer,
--     sa3_11name character varying(50),
--     sa4_11code integer,
--     sa4_11name character varying(50),
--     gcc_11code character varying(5),
--     gcc_11name character varying(50),
--     state_pid character varying(15),
--     area_sqm numeric
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa2_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa2_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sa2_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa2_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa2_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sa2_2011_gid_seq OWNED BY aus_sa2_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_sa2_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sa2_2011_polygon (
--     gid integer NOT NULL,
--     sa2_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sa2_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa2_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa2_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sa2_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa2_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa2_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sa2_2011_polygon_gid_seq OWNED BY aus_sa2_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_sa3_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sa3_2011 (
--     gid integer NOT NULL,
--     sa3_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sa4_11pid character varying(15),
--     sa3_11code integer,
--     sa3_11name character varying(50),
--     sa4_11code integer,
--     sa4_11name character varying(50),
--     gcc_11code character varying(5),
--     gcc_11name character varying(50),
--     state_pid character varying(15),
--     area_sqm numeric
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa3_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa3_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sa3_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa3_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa3_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sa3_2011_gid_seq OWNED BY aus_sa3_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_sa3_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sa3_2011_polygon (
--     gid integer NOT NULL,
--     sa3_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sa3_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa3_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa3_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sa3_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa3_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa3_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sa3_2011_polygon_gid_seq OWNED BY aus_sa3_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_sa4_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sa4_2011 (
--     gid integer NOT NULL,
--     sa4_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     gcc_11pid character varying(15),
--     sa4_11code integer,
--     sa4_11name character varying(50),
--     gcc_11code character varying(5),
--     gcc_11name character varying(50),
--     state_pid character varying(15),
--     area_sqm numeric
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa4_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa4_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sa4_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa4_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa4_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sa4_2011_gid_seq OWNED BY aus_sa4_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_sa4_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sa4_2011_polygon (
--     gid integer NOT NULL,
--     sa4_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sa4_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa4_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa4_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sa4_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sa4_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sa4_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sa4_2011_polygon_gid_seq OWNED BY aus_sa4_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_seifa_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_seifa_2011 (
--     gid integer NOT NULL,
--     seifa11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sa1_11pid character varying(15),
--     pop integer,
--     irsad_scr integer,
--     irsad_a_rk integer,
--     irsad_a_dc character varying(2),
--     irsad_a_pc character varying(3),
--     irsad_s_rk integer,
--     irsad_s_dc character varying(2),
--     irsad_s_pc character varying(3),
--     irsd_scr integer,
--     irsd_a_rk integer,
--     irsd_a_dc character varying(2),
--     irsd_a_pc character varying(3),
--     irsd_s_rk integer,
--     irsd_s_dc character varying(2),
--     irsd_s_pc character varying(3),
--     ier_scr integer,
--     ier_a_rk integer,
--     ier_a_dc character varying(2),
--     ier_a_pc character varying(3),
--     ier_s_rk integer,
--     ier_s_dc character varying(2),
--     ier_s_pc character varying(3),
--     ieo_scr integer,
--     ieo_a_rk integer,
--     ieo_a_dc character varying(2),
--     ieo_a_pc character varying(3),
--     ieo_s_rk integer,
--     ieo_s_dc character varying(2),
--     ieo_s_pc character varying(3)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_seifa_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_seifa_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_seifa_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_seifa_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_seifa_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_seifa_2011_gid_seq OWNED BY aus_seifa_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_sos_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sos_2011 (
--     gid integer NOT NULL,
--     sos_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sos_11code integer,
--     sos_11name character varying(50),
--     state_pid character varying(15),
--     area_sqkm double precision
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sos_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sos_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sos_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sos_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sos_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sos_2011_gid_seq OWNED BY aus_sos_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_sos_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sos_2011_polygon (
--     gid integer NOT NULL,
--     sos_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sos_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sos_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sos_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sos_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sos_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sos_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sos_2011_polygon_gid_seq OWNED BY aus_sos_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_sosr_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sosr_2011 (
--     gid integer NOT NULL,
--     ssr_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     ssr_11code integer,
--     ssr_11name character varying(50),
--     sos_11code integer,
--     sos_11name character varying(50),
--     state_pid character varying(15),
--     area_sqkm double precision
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sosr_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sosr_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sosr_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sosr_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sosr_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sosr_2011_gid_seq OWNED BY aus_sosr_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_sosr_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sosr_2011_polygon (
--     gid integer NOT NULL,
--     ssr_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     ssr_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sosr_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sosr_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sosr_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sosr_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sosr_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sosr_2011_polygon_gid_seq OWNED BY aus_sosr_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_state; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_state (
--     gid integer NOT NULL,
--     state_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     state_name character varying(50),
--     st_abbrev character varying(3)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_state OWNER TO postgres;
-- 
-- --
-- -- Name: aus_state_electoral; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_state_electoral (
--     gid integer NOT NULL,
--     se_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     name character varying(50),
--     dt_gazetd date,
--     eff_start date,
--     eff_end date,
--     state_pid character varying(15),
--     secl_code character varying(10)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_state_electoral OWNER TO postgres;
-- 
-- --
-- -- Name: aus_state_electoral_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_state_electoral_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_state_electoral_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_state_electoral_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_state_electoral_gid_seq OWNED BY aus_state_electoral.gid;
-- 
-- 
-- --
-- -- Name: aus_state_electoral_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_state_electoral_polygon (
--     gid integer NOT NULL,
--     se_ply_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     se_pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_state_electoral_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_state_electoral_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_state_electoral_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_state_electoral_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_state_electoral_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_state_electoral_polygon_gid_seq OWNED BY aus_state_electoral_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_state_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_state_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_state_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_state_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_state_gid_seq OWNED BY aus_state.gid;
-- 
-- 
-- --
-- -- Name: aus_state_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_state_polygon (
--     gid integer NOT NULL,
--     st_ply_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     state_pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_state_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_state_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_state_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_state_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_state_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_state_polygon_gid_seq OWNED BY aus_state_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_sua_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sua_2011 (
--     gid integer NOT NULL,
--     sua_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sua_11code integer,
--     sua_11name character varying(50),
--     area_sqkm double precision
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sua_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sua_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sua_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sua_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sua_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sua_2011_gid_seq OWNED BY aus_sua_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_sua_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_sua_2011_polygon (
--     gid integer NOT NULL,
--     sua_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     sua_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sua_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sua_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_sua_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_sua_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_sua_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_sua_2011_polygon_gid_seq OWNED BY aus_sua_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_town; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_town (
--     gid integer NOT NULL,
--     town_pid character varying(15),
--     date_creat date,
--     date_retir date,
--     town_class character varying(1),
--     town_name character varying(50),
--     population character varying(15),
--     state_pid character varying(15)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_town OWNER TO postgres;
-- 
-- --
-- -- Name: aus_town_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_town_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_town_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_town_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_town_gid_seq OWNED BY aus_town.gid;
-- 
-- 
-- --
-- -- Name: aus_town_point; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_town_point (
--     gid integer NOT NULL,
--     town_point character varying(15),
--     date_creat date,
--     date_retir date,
--     town_pid character varying(15)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_town_point OWNER TO postgres;
-- 
-- --
-- -- Name: aus_town_point_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_town_point_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_town_point_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_town_point_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_town_point_gid_seq OWNED BY aus_town_point.gid;
-- 
-- 
-- --
-- -- Name: aus_ucl_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_ucl_2011 (
--     gid integer NOT NULL,
--     ucl_11pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     ucl_11code integer,
--     ucl_11name character varying(50),
--     ssr_11code integer,
--     ssr_11name character varying(50),
--     sos_11code integer,
--     sos_11name character varying(50),
--     state_pid character varying(15),
--     area_sqkm double precision
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ucl_2011 OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ucl_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_ucl_2011_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ucl_2011_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ucl_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_ucl_2011_gid_seq OWNED BY aus_ucl_2011.gid;
-- 
-- 
-- --
-- -- Name: aus_ucl_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_ucl_2011_polygon (
--     gid integer NOT NULL,
--     ucl_11ppid character varying(15),
--     dt_create date,
--     dt_retire date,
--     ucl_11pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ucl_2011_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ucl_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_ucl_2011_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ucl_2011_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ucl_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_ucl_2011_polygon_gid_seq OWNED BY aus_ucl_2011_polygon.gid;
-- 
-- 
-- --
-- -- Name: aus_ward; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_ward (
--     gid integer NOT NULL,
--     ward_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     name character varying(100),
--     dt_gazetd date,
--     lga_pid character varying(15),
--     state_pid character varying(15)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ward OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ward_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_ward_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ward_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ward_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_ward_gid_seq OWNED BY aus_ward.gid;
-- 
-- 
-- --
-- -- Name: aus_ward_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- CREATE TABLE admin_bdys.aus_ward_polygon (
--     gid integer NOT NULL,
--     wd_ply_pid character varying(15),
--     dt_create date,
--     dt_retire date,
--     ward_pid character varying(15),
--     geom public.geometry(MultiPolygon,4283)
-- );
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ward_polygon OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ward_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- CREATE SEQUENCE aus_ward_polygon_gid_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
-- 
-- 
-- ALTER TABLE admin_bdys.aus_ward_polygon_gid_seq OWNER TO postgres;
-- 
-- --
-- -- Name: aus_ward_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER SEQUENCE aus_ward_polygon_gid_seq OWNED BY aus_ward_polygon.gid;
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_comm_electoral ALTER COLUMN gid SET DEFAULT nextval('aus_comm_electoral_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_comm_electoral_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_comm_electoral_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_gccsa_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_gccsa_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_gccsa_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_gccsa_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_iare_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_iare_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_iare_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_iare_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_iloc_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_iloc_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_iloc_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_iloc_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ireg_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_ireg_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ireg_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_ireg_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_lga ALTER COLUMN gid SET DEFAULT nextval('aus_lga_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_lga_locality ALTER COLUMN gid SET DEFAULT nextval('aus_lga_locality_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_lga_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_lga_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_locality ALTER COLUMN gid SET DEFAULT nextval('aus_locality_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_locality_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_locality_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_locality_town ALTER COLUMN gid SET DEFAULT nextval('aus_locality_town_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_mb_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_mb_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_mb_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_mb_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_remoteness_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_remoteness_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_remoteness_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_remoteness_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa1_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sa1_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa1_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sa1_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa2_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sa2_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa2_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sa2_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa3_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sa3_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa3_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sa3_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa4_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sa4_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa4_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sa4_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_seifa_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_seifa_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sos_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sos_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sos_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sos_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sosr_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sosr_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sosr_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sosr_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_state ALTER COLUMN gid SET DEFAULT nextval('aus_state_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_state_electoral ALTER COLUMN gid SET DEFAULT nextval('aus_state_electoral_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_state_electoral_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_state_electoral_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_state_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_state_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sua_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sua_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sua_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sua_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_town ALTER COLUMN gid SET DEFAULT nextval('aus_town_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_town_point ALTER COLUMN gid SET DEFAULT nextval('aus_town_point_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ucl_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_ucl_2011_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ucl_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_ucl_2011_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ward ALTER COLUMN gid SET DEFAULT nextval('aus_ward_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ward_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_ward_polygon_gid_seq'::regclass);
-- 
-- 
-- --
-- -- Name: aus_comm_electoral_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_comm_electoral
--     ADD CONSTRAINT aus_comm_electoral_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_comm_electoral_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_comm_electoral_polygon
--     ADD CONSTRAINT aus_comm_electoral_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_gccsa_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_gccsa_2011
--     ADD CONSTRAINT aus_gccsa_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_gccsa_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_gccsa_2011_polygon
--     ADD CONSTRAINT aus_gccsa_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_iare_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_iare_2011
--     ADD CONSTRAINT aus_iare_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_iare_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_iare_2011_polygon
--     ADD CONSTRAINT aus_iare_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_iloc_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_iloc_2011
--     ADD CONSTRAINT aus_iloc_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_iloc_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_iloc_2011_polygon
--     ADD CONSTRAINT aus_iloc_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_ireg_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ireg_2011
--     ADD CONSTRAINT aus_ireg_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_ireg_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ireg_2011_polygon
--     ADD CONSTRAINT aus_ireg_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_lga_locality_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_lga_locality
--     ADD CONSTRAINT aus_lga_locality_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_lga_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_lga
--     ADD CONSTRAINT aus_lga_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_lga_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_lga_polygon
--     ADD CONSTRAINT aus_lga_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_locality_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_locality
--     ADD CONSTRAINT aus_locality_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_locality_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_locality_polygon
--     ADD CONSTRAINT aus_locality_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_locality_town_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_locality_town
--     ADD CONSTRAINT aus_locality_town_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_mb_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_mb_2011
--     ADD CONSTRAINT aus_mb_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_mb_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_mb_2011_polygon
--     ADD CONSTRAINT aus_mb_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_remoteness_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_remoteness_2011
--     ADD CONSTRAINT aus_remoteness_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_remoteness_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_remoteness_2011_polygon
--     ADD CONSTRAINT aus_remoteness_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sa1_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa1_2011
--     ADD CONSTRAINT aus_sa1_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sa1_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa1_2011_polygon
--     ADD CONSTRAINT aus_sa1_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sa2_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa2_2011
--     ADD CONSTRAINT aus_sa2_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sa2_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa2_2011_polygon
--     ADD CONSTRAINT aus_sa2_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sa3_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa3_2011
--     ADD CONSTRAINT aus_sa3_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sa3_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa3_2011_polygon
--     ADD CONSTRAINT aus_sa3_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sa4_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa4_2011
--     ADD CONSTRAINT aus_sa4_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sa4_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sa4_2011_polygon
--     ADD CONSTRAINT aus_sa4_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_seifa_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_seifa_2011
--     ADD CONSTRAINT aus_seifa_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sos_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sos_2011
--     ADD CONSTRAINT aus_sos_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sos_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sos_2011_polygon
--     ADD CONSTRAINT aus_sos_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sosr_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sosr_2011
--     ADD CONSTRAINT aus_sosr_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sosr_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sosr_2011_polygon
--     ADD CONSTRAINT aus_sosr_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_state_electoral_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_state_electoral
--     ADD CONSTRAINT aus_state_electoral_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_state_electoral_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_state_electoral_polygon
--     ADD CONSTRAINT aus_state_electoral_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_state_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_state
--     ADD CONSTRAINT aus_state_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_state_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_state_polygon
--     ADD CONSTRAINT aus_state_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sua_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sua_2011
--     ADD CONSTRAINT aus_sua_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_sua_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_sua_2011_polygon
--     ADD CONSTRAINT aus_sua_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_town_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_town
--     ADD CONSTRAINT aus_town_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_town_point_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_town_point
--     ADD CONSTRAINT aus_town_point_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_ucl_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ucl_2011
--     ADD CONSTRAINT aus_ucl_2011_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_ucl_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ucl_2011_polygon
--     ADD CONSTRAINT aus_ucl_2011_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_ward_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ward
--     ADD CONSTRAINT aus_ward_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- Name: aus_ward_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
-- --
-- 
-- ALTER TABLE admin_bdys.ONLY aus_ward_polygon
--     ADD CONSTRAINT aus_ward_polygon_pkey PRIMARY KEY (gid);
-- 
-- 
-- --
-- -- PostgreSQL database dump complete
-- --
-- 
