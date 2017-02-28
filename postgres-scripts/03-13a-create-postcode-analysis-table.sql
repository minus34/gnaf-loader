
--------------------------------------------------------------------------------------
-- derived postcode boundaries
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS admin_bdys.postcode_bdys_analysis CASCADE;
CREATE UNLOGGED TABLE admin_bdys.postcode_bdys_analysis
(
  gid SERIAL NOT NULL,
  postcode text,
  state text NOT NULL,
  geom geometry(Polygon,4283) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.postcode_bdys_analysis OWNER TO postgres;

INSERT INTO admin_bdys.postcode_bdys_analysis (postcode, state, geom)
SELECT postcode,
       state, 
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM admin_bdys.locality_bdys;

CREATE INDEX postcode_analysis_geom_idx ON admin_bdys.postcode_bdys_analysis USING gist(geom);
ALTER TABLE admin_bdys.postcode_bdys_analysis CLUSTER ON postcode_analysis_geom_idx;

ANALYZE admin_bdys.postcode_bdys_analysis;
