
--------------------------------------------------------------------------------------
-- ABS census 2016 - meshblocks
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2016_mb CASCADE;
CREATE TABLE admin_bdys.abs_2016_mb AS
SELECT bdy.gid,
       tab.mb_16code::text,
       aut.name::text AS mb_category,
       tab.sa1_16main,
       tab.sa1_16_7cd,
       tab.sa2_16main,
       tab.sa2_16_5cd,
       tab.sa2_16name::text,
       tab.sa3_16code,
       tab.sa3_16name::text,
       tab.sa4_16code,
       tab.sa4_16name::text,
       tab.gcc_16code::text,
       tab.gcc_16name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       tab.mb16_pop,
       tab.mb16_dwell,
       bdy.geom
  FROM raw_admin_bdys.aus_mb_2016 AS tab
  INNER JOIN raw_admin_bdys.aus_mb_2016_polygon AS bdy ON tab.mb_16pid = bdy.mb_16pid
  INNER JOIN (SELECT DISTINCT code, name FROM raw_admin_bdys.aus_mb_category_class_aut) AS aut ON tab.mb_cat_cd = aut.code
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2016_mb ADD CONSTRAINT abs_2016_mb_pk PRIMARY KEY (gid);
CREATE INDEX abs_2016_mb_geom_idx ON admin_bdys.abs_2016_mb USING gist(geom);
ALTER TABLE admin_bdys.abs_2016_mb CLUSTER ON abs_2016_mb_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2016 - statistical area 1's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2016_sa1 CASCADE;
CREATE TABLE admin_bdys.abs_2016_sa1 AS
SELECT bdy.gid,
       tab.sa1_16main,
       tab.sa1_16_7cd,
       tab.sa2_16main,
       tab.sa2_16_5cd,
       tab.sa2_16name::text,
       tab.sa3_16code,
       tab.sa3_16name::text,
       tab.sa4_16code,
       tab.sa4_16name::text,
       tab.gcc_16code::text,
       tab.gcc_16name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_sa1_2016 AS tab
  INNER JOIN raw_admin_bdys.aus_sa1_2016_polygon AS bdy ON tab.sa1_16pid = bdy.sa1_16pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2016_sa1 ADD CONSTRAINT abs_2016_sa1_pk PRIMARY KEY (gid);
CREATE INDEX abs_2016_sa1_geom_idx ON admin_bdys.abs_2016_sa1 USING gist(geom);
ALTER TABLE admin_bdys.abs_2016_sa1 CLUSTER ON abs_2016_sa1_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2016 - statistical area 2's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2016_sa2 CASCADE;
CREATE TABLE admin_bdys.abs_2016_sa2 AS
SELECT bdy.gid,
       tab.sa2_16main,
       tab.sa2_16_5cd,
       tab.sa2_16name::text,
       tab.sa3_16code,
       tab.sa3_16name::text,
       tab.sa4_16code,
       tab.sa4_16name::text,
       tab.gcc_16code::text,
       tab.gcc_16name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_sa2_2016 AS tab
  INNER JOIN raw_admin_bdys.aus_sa2_2016_polygon AS bdy ON tab.sa2_16pid = bdy.sa2_16pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2016_sa2 ADD CONSTRAINT abs_2016_sa2_pk PRIMARY KEY (gid);
CREATE INDEX abs_2016_sa2_geom_idx ON admin_bdys.abs_2016_sa2 USING gist(geom);
ALTER TABLE admin_bdys.abs_2016_sa2 CLUSTER ON abs_2016_sa2_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2016 - statistical area 3's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2016_sa3 CASCADE;
CREATE TABLE admin_bdys.abs_2016_sa3 AS
SELECT bdy.gid,
       tab.sa3_16code,
       tab.sa3_16name::text,
       tab.sa4_16code,
       tab.sa4_16name::text,
       tab.gcc_16code::text,
       tab.gcc_16name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_sa3_2016 AS tab
  INNER JOIN raw_admin_bdys.aus_sa3_2016_polygon AS bdy ON tab.sa3_16pid = bdy.sa3_16pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2016_sa3 ADD CONSTRAINT abs_2016_sa3_pk PRIMARY KEY (gid);
CREATE INDEX abs_2016_sa3_geom_idx ON admin_bdys.abs_2016_sa3 USING gist(geom);
ALTER TABLE admin_bdys.abs_2016_sa3 CLUSTER ON abs_2016_sa3_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2016 - statistical area 4's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2016_sa4 CASCADE;
CREATE TABLE admin_bdys.abs_2016_sa4 AS
SELECT bdy.gid,
       tab.sa4_16code,
       tab.sa4_16name::text,
       tab.gcc_16code::text,
       tab.gcc_16name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_sa4_2016 AS tab
  INNER JOIN raw_admin_bdys.aus_sa4_2016_polygon AS bdy ON tab.sa4_16pid = bdy.sa4_16pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2016_sa4 ADD CONSTRAINT abs_2016_sa4_pk PRIMARY KEY (gid);
CREATE INDEX abs_2016_sa4_geom_idx ON admin_bdys.abs_2016_sa4 USING gist(geom);
ALTER TABLE admin_bdys.abs_2016_sa4 CLUSTER ON abs_2016_sa4_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2016 - greater capital city statistical areas
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2016_gccsa CASCADE;
CREATE TABLE admin_bdys.abs_2016_gccsa AS
SELECT bdy.gid,
       tab.gcc_16code::text,
       tab.gcc_16name::text,
       ste.st_abbrev::text AS state,
       tab.area_sqm,
       bdy.geom
  FROM raw_admin_bdys.aus_gccsa_2016 AS tab
  INNER JOIN raw_admin_bdys.aus_gccsa_2016_polygon AS bdy ON tab.gcc_16pid = bdy.gcc_16pid
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2016_gccsa ADD CONSTRAINT abs_2016_gccsa_pk PRIMARY KEY (gid);
CREATE INDEX abs_2016_gccsa_geom_idx ON admin_bdys.abs_2016_gccsa USING gist(geom);
ALTER TABLE admin_bdys.abs_2016_gccsa CLUSTER ON abs_2016_gccsa_geom_idx;
