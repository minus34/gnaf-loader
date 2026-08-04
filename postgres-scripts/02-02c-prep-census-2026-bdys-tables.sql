
--------------------------------------------------------------------------------------
-- ABS census 2026 - meshblocks
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_mb CASCADE;
CREATE TABLE admin_bdys.abs_2026_mb AS
SELECT tab.gid,
       mb_26ppid,
       tab.dt_create,
       mb_26pid::text,
       mb26_code::bigint,
       mb_cat::text,
       chng_flag::integer,
       chng_label::text,
       sa1_26pid::text,
       sa1_26code,
       sa2_26code,
       sa2_26name::text,
       sa3_26code,
       sa3_26name::text,
       sa4_26code,
       sa4_26name::text,
       gcc_26code::text,
       gcc_26name::text,
       ste.st_abbrev::text AS state,
       area_sqm,
       mb26_dwell,
       mb26_pop,
       loci26_uri::text,
       geom
  FROM raw_admin_bdys.aus_mb_2026 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2026_mb ADD CONSTRAINT abs_2026_mb_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_mb_geom_idx ON admin_bdys.abs_2026_mb USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_mb CLUSTER ON abs_2026_mb_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - statistical area 1's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_sa1 CASCADE;
CREATE TABLE admin_bdys.abs_2026_sa1 AS
SELECT tab.gid,
       sa1_26ppid,
       tab.dt_create,
       sa1_26pid,
       sa1_26code,
       chng_flag,
       chng_label::text,
       sa2_26pid,
       sa2_26code,
       sa2_26name::text,
       sa3_26code,
       sa3_26name::text,
       sa4_26code,
       sa4_26name::text,
       gcc_26code,
       gcc_26name::text,
       ste.st_abbrev::text AS state,
       area_sqm,
       loci26_uri::text,
       geom
  FROM raw_admin_bdys.aus_sa1_2026 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2026_sa1 ADD CONSTRAINT abs_2026_sa1_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_sa1_geom_idx ON admin_bdys.abs_2026_sa1 USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_sa1 CLUSTER ON abs_2026_sa1_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - statistical area 2's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_sa2 CASCADE;
CREATE TABLE admin_bdys.abs_2026_sa2 AS
SELECT tab.gid,
       sa2_26ppid,
       tab.dt_create,
       sa2_26pid,
       sa2_26code,
       sa2_26name::text,
       chng_flag,
       chng_label::text,
       sa3_26pid,
       sa3_26code,
       sa3_26name::text,
       sa4_26code,
       sa4_26name::text,
       gcc_26code,
       gcc_26name::text,
       ste.st_abbrev::text AS state,
       area_sqm,
       loci26_uri::text,
       geom
  FROM raw_admin_bdys.aus_sa2_2026 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2026_sa2 ADD CONSTRAINT abs_2026_sa2_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_sa2_geom_idx ON admin_bdys.abs_2026_sa2 USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_sa2 CLUSTER ON abs_2026_sa2_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - statistical area 3's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_sa3 CASCADE;
CREATE TABLE admin_bdys.abs_2026_sa3 AS
SELECT tab.gid,
       sa3_26ppid,
       tab.dt_create,
       sa3_26pid,
       sa3_26code,
       sa3_26name::text,
       chng_flag,
       chng_label::text,
       sa4_26pid,
       sa4_26code,
       sa4_26name::text,
       gcc_26code,
       gcc_26name::text,
       ste.st_abbrev::text AS state,
       area_sqm,
       loci26_uri::text,
       geom
  FROM raw_admin_bdys.aus_sa3_2026 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2026_sa3 ADD CONSTRAINT abs_2026_sa3_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_sa3_geom_idx ON admin_bdys.abs_2026_sa3 USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_sa3 CLUSTER ON abs_2026_sa3_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - statistical area 4's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_sa4 CASCADE;
CREATE TABLE admin_bdys.abs_2026_sa4 AS
SELECT tab.gid,
       sa4_26ppid,
       tab.dt_create,
       sa4_26pid,
       sa4_26code,
       sa4_26name::text,
       chng_flag,
       chng_label::text,
       gcc_26pid,
       gcc_26code,
       gcc_26name::text,
       ste.st_abbrev::text AS state,
       area_sqm,
       loci26_uri::text,
       geom
  FROM raw_admin_bdys.aus_sa4_2026 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2026_sa4 ADD CONSTRAINT abs_2026_sa4_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_sa4_geom_idx ON admin_bdys.abs_2026_sa4 USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_sa4 CLUSTER ON abs_2026_sa4_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - greater capital city statistical areas
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_gccsa CASCADE;
CREATE TABLE admin_bdys.abs_2026_gccsa AS
SELECT tab.gid,
       gcc_26ppid,
       tab.dt_create,
       gcc_26pid,
       gcc_26code,
       gcc_26name::text,
       chng_flag,
       chng_label::text,
       ste.st_abbrev::text AS state,
       area_sqm,
       loci26_uri::text,
       geom
  FROM raw_admin_bdys.aus_gccsa_2026 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2026_gccsa ADD CONSTRAINT abs_2026_gccsa_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_gccsa_geom_idx ON admin_bdys.abs_2026_gccsa USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_gccsa CLUSTER ON abs_2026_gccsa_geom_idx;
