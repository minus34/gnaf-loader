
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
  FROM admin_bdys.state_bdys;

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
  FROM admin_bdys.commonwealth_electorates;

CREATE INDEX commonwealth_electorates_analysis_geom_idx ON admin_bdys.commonwealth_electorates_analysis USING gist(geom);
ALTER TABLE admin_bdys.commonwealth_electorates_analysis CLUSTER ON commonwealth_electorates_analysis_geom_idx;

ANALYZE admin_bdys.commonwealth_electorates_analysis;



--TO DO:
--  - Do the above for all admin bdy types


