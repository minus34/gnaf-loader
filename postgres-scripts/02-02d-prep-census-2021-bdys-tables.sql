
--------------------------------------------------------------------------------------
-- ABS census 2021 - meshblocks
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2021_mb CASCADE;
CREATE TABLE admin_bdys.abs_2021_mb AS
SELECT tab.*,
       ste.st_abbrev::text AS state
  FROM raw_admin_bdys.aus_mb_2021 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2021_mb ADD CONSTRAINT abs_2021_mb_pk PRIMARY KEY (gid);
CREATE INDEX abs_2021_mb_geom_idx ON admin_bdys.abs_2021_mb USING gist(geom);
ALTER TABLE admin_bdys.abs_2021_mb CLUSTER ON abs_2021_mb_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2021 - statistical area 1's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2021_sa1 CASCADE;
CREATE TABLE admin_bdys.abs_2021_sa1 AS
SELECT tab.*,
       ste.st_abbrev::text AS state
  FROM raw_admin_bdys.aus_sa1_2021 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2021_sa1 ADD CONSTRAINT abs_2021_sa1_pk PRIMARY KEY (gid);
CREATE INDEX abs_2021_sa1_geom_idx ON admin_bdys.abs_2021_sa1 USING gist(geom);
ALTER TABLE admin_bdys.abs_2021_sa1 CLUSTER ON abs_2021_sa1_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2021 - statistical area 2's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2021_sa2 CASCADE;
CREATE TABLE admin_bdys.abs_2021_sa2 AS
SELECT tab.*,
       ste.st_abbrev::text AS state
  FROM raw_admin_bdys.aus_sa2_2021 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2021_sa2 ADD CONSTRAINT abs_2021_sa2_pk PRIMARY KEY (gid);
CREATE INDEX abs_2021_sa2_geom_idx ON admin_bdys.abs_2021_sa2 USING gist(geom);
ALTER TABLE admin_bdys.abs_2021_sa2 CLUSTER ON abs_2021_sa2_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2021 - statistical area 3's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2021_sa3 CASCADE;
CREATE TABLE admin_bdys.abs_2021_sa3 AS
SELECT tab.*,
       ste.st_abbrev::text AS state
  FROM raw_admin_bdys.aus_sa3_2021 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2021_sa3 ADD CONSTRAINT abs_2021_sa3_pk PRIMARY KEY (gid);
CREATE INDEX abs_2021_sa3_geom_idx ON admin_bdys.abs_2021_sa3 USING gist(geom);
ALTER TABLE admin_bdys.abs_2021_sa3 CLUSTER ON abs_2021_sa3_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2021 - statistical area 4's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2021_sa4 CASCADE;
CREATE TABLE admin_bdys.abs_2021_sa4 AS
SELECT tab.*,
       ste.st_abbrev::text AS state
  FROM raw_admin_bdys.aus_sa4_2021 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2021_sa4 ADD CONSTRAINT abs_2021_sa4_pk PRIMARY KEY (gid);
CREATE INDEX abs_2021_sa4_geom_idx ON admin_bdys.abs_2021_sa4 USING gist(geom);
ALTER TABLE admin_bdys.abs_2021_sa4 CLUSTER ON abs_2021_sa4_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2021 - greater capital city statistical areas
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2021_gccsa CASCADE;
CREATE TABLE admin_bdys.abs_2021_gccsa AS
SELECT tab.*,
       ste.st_abbrev::text AS state
  FROM raw_admin_bdys.aus_gccsa_2021 AS tab
  INNER JOIN raw_admin_bdys.aus_state AS ste ON tab.state_pid = ste.state_pid;

ALTER TABLE admin_bdys.abs_2021_gccsa ADD CONSTRAINT abs_2021_gccsa_pk PRIMARY KEY (gid);
CREATE INDEX abs_2021_gccsa_geom_idx ON admin_bdys.abs_2021_gccsa USING gist(geom);
ALTER TABLE admin_bdys.abs_2021_gccsa CLUSTER ON abs_2021_gccsa_geom_idx;
