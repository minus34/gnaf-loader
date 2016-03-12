
--------------------------------------------------------------------------------------
-- locality boundaries
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.locality_bdys_analysis CASCADE;
CREATE TABLE admin_bdys.locality_bdys_analysis (
  gid SERIAL NOT NULL PRIMARY KEY,
  locality_pid character varying(15) NOT NULL,
  state character varying(3) NOT NULL,
  geom geometry(Polygon, 4283, 2) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.locality_bdys_analysis OWNER TO postgres;

INSERT INTO admin_bdys.locality_bdys_analysis (locality_pid, state, geom)
SELECT locality_pid,
       state, 
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM admin_bdys.locality_bdys;

CREATE INDEX localities_analysis_geom_idx ON admin_bdys.locality_bdys_analysis USING gist(geom);
ALTER TABLE admin_bdys.locality_bdys_analysis CLUSTER ON localities_analysis_geom_idx;

ANALYZE admin_bdys.locality_bdys_analysis;


--------------------------------------------------------------------------------------
-- states
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.state_bdys_analysis CASCADE;
CREATE TABLE admin_bdys.state_bdys_analysis (
  gid SERIAL NOT NULL PRIMARY KEY,
  state_pid character varying(15) NOT NULL,
  state character varying(3) NOT NULL,
  geom geometry(Polygon, 4283, 2) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.state_bdys_analysis OWNER TO postgres;

INSERT INTO admin_bdys.state_bdys_analysis (state_pid, state, geom)
SELECT state_pid,
       state,
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM raw_admin_bdys.state_bdys;

CREATE INDEX states_analysis_geom_idx ON admin_bdys.state_bdys_analysis USING gist(geom);
ALTER TABLE admin_bdys.state_bdys_analysis CLUSTER ON states_analysis_geom_idx;

ANALYZE admin_bdys.state_bdys_analysis;


--------------------------------------------------------------------------------------
-- commonwealth electoral boundaries
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.commonwealth_electorates_analysis CASCADE;
CREATE TABLE admin_bdys.commonwealth_electorates_analysis (
  gid SERIAL NOT NULL PRIMARY KEY,
  ce_pid character varying(15) NOT NULL,
  state character varying(3) NOT NULL,
  geom geometry(Polygon, 4283, 2) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.commonwealth_electorates_analysis OWNER TO postgres;

INSERT INTO admin_bdys.commonwealth_electorates_analysis (ce_pid, state, geom)
SELECT ce_pid,
       state,
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM raw_admin_bdys.commonwealth_electorates;

CREATE INDEX commonwealth_electorates_analysis_geom_idx ON admin_bdys.commonwealth_electorates_analysis USING gist(geom);
ALTER TABLE admin_bdys.commonwealth_electorates_analysis CLUSTER ON commonwealth_electorates_analysis_geom_idx;

ANALYZE admin_bdys.commonwealth_electorates_analysis;


---------------------------------------------------------------------------------------------------
-- state electoral boundaries - choose bdys that will be current until at least 3 months from now
---------------------------------------------------------------------------------------------------

-- lower house
DROP TABLE IF EXISTS admin_bdys.state_lower_house_electorates_analysis CASCADE;
CREATE TABLE admin_bdys.state_lower_house_electorates_analysis (
  gid SERIAL NOT NULL PRIMARY KEY,
  se_pid character varying(15),
  state character varying(3),
  geom geometry(Polygon, 4283, 2)
) WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.state_lower_house_electorates_analysis OWNER TO postgres;

INSERT INTO admin_bdys.state_lower_house_electorates_analysis (se_pid, state, geom)
SELECT se_pid,
       state,
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM raw_admin_bdys.state_lower_house_electorates;

CREATE INDEX state_lower_house_electorates_analysis_geom_idx ON admin_bdys.state_lower_house_electorates_analysis USING gist(geom);
ALTER TABLE admin_bdys.state_lower_house_electorates_analysis CLUSTER ON state_lower_house_electorates_analysis_geom_idx;

ANALYZE admin_bdys.state_lower_house_electorates_analysis;


-- upper house
DROP TABLE IF EXISTS admin_bdys.state_upper_house_electorates_analysis CASCADE;
CREATE TABLE admin_bdys.state_upper_house_electorates_analysis (
  gid SERIAL NOT NULL PRIMARY KEY,
  se_pid character varying(15),
  state character varying(3),
  geom geometry(Polygon, 4283, 2)
) WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.state_upper_house_electorates_analysis OWNER TO postgres;

INSERT INTO admin_bdys.state_upper_house_electorates_analysis (se_pid, state, geom)
SELECT se_pid,
       state,
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM raw_admin_bdys.state_upper_house_electorates;

CREATE INDEX state_upper_house_electorates_analysis_geom_idx ON admin_bdys.state_upper_house_electorates_analysis USING gist(geom);
ALTER TABLE admin_bdys.state_upper_house_electorates_analysis CLUSTER ON state_upper_house_electorates_analysis_geom_idx;

ANALYZE admin_bdys.state_upper_house_electorates_analysis;


--------------------------------------------------------------------------------------
-- local government areas
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.local_government_areas_analysis CASCADE;
CREATE TABLE admin_bdys.local_government_areas_analysis (
  gid SERIAL NOT NULL PRIMARY KEY,
  lga_pid character varying(15),
  state character varying(3),
  geom geometry(Polygon, 4283, 2)
) WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.local_government_areas_analysis OWNER TO postgres;

INSERT INTO admin_bdys.local_government_areas_analysis (lga_pid, state, geom)
SELECT lga_pid,
       state,
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM raw_admin_bdys.local_government_areas;

CREATE INDEX local_government_areas_analysis_geom_idx ON admin_bdys.local_government_areas_analysis USING gist(geom);
ALTER TABLE admin_bdys.local_government_areas_analysis CLUSTER ON local_government_areas_analysis_geom_idx;

ANALYZE admin_bdys.local_government_areas_analysis;


--------------------------------------------------------------------------------------
-- local government wards
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.local_government_wards_analysis CASCADE;
CREATE TABLE admin_bdys.local_government_wards_analysis (
  gid SERIAL NOT NULL PRIMARY KEY,
  ward_pid character varying(15),
  state character varying(3),
  geom geometry(Polygon, 4283, 2)
) WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.local_government_wards_analysis OWNER TO postgres;

INSERT INTO admin_bdys.local_government_wards_analysis (ward_pid, state, geom)
SELECT ward_pid,
       state,
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM raw_admin_bdys.local_government_wards;

CREATE INDEX local_government_wards_analysis_geom_idx ON admin_bdys.local_government_wards_analysis USING gist(geom);
ALTER TABLE admin_bdys.local_government_wards_analysis CLUSTER ON local_government_wards_analysis_geom_idx;

ANALYZE admin_bdys.local_government_wards_analysis;




--TO DO:
--  - Do the above for all admin bdy types


