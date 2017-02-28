
--------------------------------------------------------------------------------------
-- ABS census 2011 - meshblocks
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2011_mb CASCADE;
CREATE TABLE admin_bdys.abs_2011_mb AS
SELECT bdy.gid,
       tab.mb_11code::text,
       aut.name::text AS mb_category,
       tab.sa1_11main,
       tab.sa1_11_7cd,
       tab.sa2_11main,
       tab.sa2_11_5cd,
       tab.sa2_11name::text,
       tab.sa3_11code,
       tab.sa3_11name::text,
       tab.sa4_11code,
       tab.sa4_11name::text,
       tab.gcc_11code::text,
       tab.gcc_11name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       tab.mb11_pop,
       tab.mb11_dwell,
       bdy.geom
  FROM raw_admin_bdys.aus_mb_2011 AS tab
  INNER JOIN raw_admin_bdys.aus_mb_2011_polygon AS bdy ON tab.mb_11pid = bdy.mb_11pid
  INNER JOIN (SELECT DISTINCT code, name FROM raw_admin_bdys.aus_mb_category_class_aut) AS aut ON tab.mb_cat_cd = aut.code
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2011_mb ADD CONSTRAINT abs_2011_mb_pk PRIMARY KEY (gid);
CREATE INDEX abs_2011_mb_geom_idx ON admin_bdys.abs_2011_mb USING gist(geom);
ALTER TABLE admin_bdys.abs_2011_mb CLUSTER ON abs_2011_mb_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2011 - statistical area 1's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2011_sa1 CASCADE;
CREATE TABLE admin_bdys.abs_2011_sa1 AS
SELECT bdy.gid,
       tab.sa1_11main,
       tab.sa1_11_7cd,
       tab.sa2_11main,
       tab.sa2_11_5cd,
       tab.sa2_11name::text,
       tab.sa3_11code,
       tab.sa3_11name::text,
       tab.sa4_11code,
       tab.sa4_11name::text,
       tab.gcc_11code::text,
       tab.gcc_11name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_sa1_2011 AS tab
  INNER JOIN raw_admin_bdys.aus_sa1_2011_polygon AS bdy ON tab.sa1_11pid = bdy.sa1_11pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2011_sa1 ADD CONSTRAINT abs_2011_sa1_pk PRIMARY KEY (gid);
CREATE INDEX abs_2011_sa1_geom_idx ON admin_bdys.abs_2011_sa1 USING gist(geom);
ALTER TABLE admin_bdys.abs_2011_sa1 CLUSTER ON abs_2011_sa1_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2011 - statistical area 2's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2011_sa2 CASCADE;
CREATE TABLE admin_bdys.abs_2011_sa2 AS
SELECT bdy.gid,
       tab.sa2_11main,
       tab.sa2_11_5cd,
       tab.sa2_11name::text,
       tab.sa3_11code,
       tab.sa3_11name::text,
       tab.sa4_11code,
       tab.sa4_11name::text,
       tab.gcc_11code::text,
       tab.gcc_11name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_sa2_2011 AS tab
  INNER JOIN raw_admin_bdys.aus_sa2_2011_polygon AS bdy ON tab.sa2_11pid = bdy.sa2_11pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2011_sa2 ADD CONSTRAINT abs_2011_sa2_pk PRIMARY KEY (gid);
CREATE INDEX abs_2011_sa2_geom_idx ON admin_bdys.abs_2011_sa2 USING gist(geom);
ALTER TABLE admin_bdys.abs_2011_sa2 CLUSTER ON abs_2011_sa2_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2011 - statistical area 3's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2011_sa3 CASCADE;
CREATE TABLE admin_bdys.abs_2011_sa3 AS
SELECT bdy.gid,
       tab.sa3_11code,
       tab.sa3_11name::text,
       tab.sa4_11code,
       tab.sa4_11name::text,
       tab.gcc_11code::text,
       tab.gcc_11name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_sa3_2011 AS tab
  INNER JOIN raw_admin_bdys.aus_sa3_2011_polygon AS bdy ON tab.sa3_11pid = bdy.sa3_11pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2011_sa3 ADD CONSTRAINT abs_2011_sa3_pk PRIMARY KEY (gid);
CREATE INDEX abs_2011_sa3_geom_idx ON admin_bdys.abs_2011_sa3 USING gist(geom);
ALTER TABLE admin_bdys.abs_2011_sa3 CLUSTER ON abs_2011_sa3_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2011 - statistical area 4's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2011_sa4 CASCADE;
CREATE TABLE admin_bdys.abs_2011_sa4 AS
SELECT bdy.gid,
       tab.sa4_11code,
       tab.sa4_11name::text,
       tab.gcc_11code::text,
       tab.gcc_11name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_sa4_2011 AS tab
  INNER JOIN raw_admin_bdys.aus_sa4_2011_polygon AS bdy ON tab.sa4_11pid = bdy.sa4_11pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2011_sa4 ADD CONSTRAINT abs_2011_sa4_pk PRIMARY KEY (gid);
CREATE INDEX abs_2011_sa4_geom_idx ON admin_bdys.abs_2011_sa4 USING gist(geom);
ALTER TABLE admin_bdys.abs_2011_sa4 CLUSTER ON abs_2011_sa4_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2011 - greater capital city statistical areas
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2011_gccsa CASCADE;
CREATE TABLE admin_bdys.abs_2011_gccsa AS
SELECT bdy.gid,
       tab.gcc_11code::text,
       tab.gcc_11name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_gccsa_2011 AS tab
  INNER JOIN raw_admin_bdys.aus_gccsa_2011_polygon AS bdy ON tab.gcc_11pid = bdy.gcc_11pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2011_gccsa ADD CONSTRAINT abs_2011_gccsa_pk PRIMARY KEY (gid);
CREATE INDEX abs_2011_gccsa_geom_idx ON admin_bdys.abs_2011_gccsa USING gist(geom);
ALTER TABLE admin_bdys.abs_2011_gccsa CLUSTER ON abs_2011_gccsa_geom_idx;
