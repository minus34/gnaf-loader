
--------------------------------------------------------------------------------------
-- ABS census 2026 - meshblocks
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_mb CASCADE;
CREATE TABLE admin_bdys.abs_2026_mb AS
SELECT gid,
       mb_ply_26::text,
       dt_create,
       mb_pid_26::text,
       mb_code_26::bigint,
       mb_cat_26::text,
       chn_flg_26::integer,
       chn_lbl_26::text,
       s1_pid_26::text,
       s1_code_26,
       s2_code_26,
       s2_name_26::text,
       s3_code_26,
       s3_name_26::text,
       s4_code_26,
       s4_name_26::text,
       gc_code_26::text,
       gc_name_26::text,
       state,
       mb_ar_sqkm,
      --  mb26_dwell,
      --  mb26_pop,
       geom
FROM raw_admin_bdys.aus_mb_2026;

ALTER TABLE admin_bdys.abs_2026_mb ADD CONSTRAINT abs_2026_mb_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_mb_geom_idx ON admin_bdys.abs_2026_mb USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_mb CLUSTER ON abs_2026_mb_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - statistical area 1's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_sa1 CASCADE;
CREATE TABLE admin_bdys.abs_2026_sa1 AS
SELECT gid,
       s1_ply_26,
       dt_create,
       s1_pid_26,
       s1_code_26,
       chn_flg_26,
       chn_lbl_26::text,
       s2_pid_26,
       s2_code_26,
       s2_name_26::text,
       s3_code_26,
       s3_name_26::text,
       s4_code_26,
       s4_name_26::text,
       gc_code_26,
       gc_name_26::text,
       state,
       s1_ar_sqkm,
       geom
FROM raw_admin_bdys.aus_sa1_2026;

ALTER TABLE admin_bdys.abs_2026_sa1 ADD CONSTRAINT abs_2026_sa1_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_sa1_geom_idx ON admin_bdys.abs_2026_sa1 USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_sa1 CLUSTER ON abs_2026_sa1_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - statistical area 2's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_sa2 CASCADE;
CREATE TABLE admin_bdys.abs_2026_sa2 AS
SELECT gid,
       s2_ply_26,
       dt_create,
       s2_pid_26,
       s2_code_26,
       s2_name_26::text,
       chn_flg_26,
       chn_lbl_26::text,
       s3_pid_26,
       s3_code_26,
       s3_name_26::text,
       s4_code_26,
       s4_name_26::text,
       gc_code_26,
       gc_name_26::text,
       state,
       s2_ar_sqkm,
       geom
FROM raw_admin_bdys.aus_sa2_2026;

ALTER TABLE admin_bdys.abs_2026_sa2 ADD CONSTRAINT abs_2026_sa2_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_sa2_geom_idx ON admin_bdys.abs_2026_sa2 USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_sa2 CLUSTER ON abs_2026_sa2_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - statistical area 3's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_sa3 CASCADE;
CREATE TABLE admin_bdys.abs_2026_sa3 AS
SELECT gid,
       s3_ply_26,
       dt_create,
       s3_pid_26,
       s3_code_26,
       s3_name_26::text,
       chn_flg_26,
       chn_lbl_26::text,
       s4_pid_26,
       s4_code_26,
       s4_name_26::text,
       gc_code_26,
       gc_name_26::text,
       state,
       s3_ar_sqkm,
       geom
FROM raw_admin_bdys.aus_sa3_2026;

ALTER TABLE admin_bdys.abs_2026_sa3 ADD CONSTRAINT abs_2026_sa3_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_sa3_geom_idx ON admin_bdys.abs_2026_sa3 USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_sa3 CLUSTER ON abs_2026_sa3_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - statistical area 4's
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_sa4 CASCADE;
CREATE TABLE admin_bdys.abs_2026_sa4 AS
SELECT gid,
       s4_ply_26,
       dt_create,
       s4_pid_26,
       s4_code_26,
       s4_name_26::text,
       chn_flg_26,
       chn_lbl_26::text,
       gc_pid_26,
       gc_code_26,
       gc_name_26::text,
       state,
       s4_ar_sqkm,
       geom
FROM raw_admin_bdys.aus_sa4_2026;

ALTER TABLE admin_bdys.abs_2026_sa4 ADD CONSTRAINT abs_2026_sa4_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_sa4_geom_idx ON admin_bdys.abs_2026_sa4 USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_sa4 CLUSTER ON abs_2026_sa4_geom_idx;


-- # ---------------------------------------------------------------------------------
-- ABS census 2026 - greater capital city statistical areas
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.abs_2026_gccsa CASCADE;
CREATE TABLE admin_bdys.abs_2026_gccsa AS
SELECT gid,
       gc_ply_26,
       dt_create,
       gc_pid_26,
       gc_code_26,
       gc_name_26::text,
       chn_flg_26,
       chn_lbl_26::text,
       state,
       gc_ar_sqkm,
       geom
FROM raw_admin_bdys.aus_gccsa_2026;

ALTER TABLE admin_bdys.abs_2026_gccsa ADD CONSTRAINT abs_2026_gccsa_pk PRIMARY KEY (gid);
CREATE INDEX abs_2026_gccsa_geom_idx ON admin_bdys.abs_2026_gccsa USING gist(geom);
ALTER TABLE admin_bdys.abs_2026_gccsa CLUSTER ON abs_2026_gccsa_geom_idx;
