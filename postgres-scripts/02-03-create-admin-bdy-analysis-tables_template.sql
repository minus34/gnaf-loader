
DROP TABLE IF EXISTS admin_bdys.{0}_analysis CASCADE;
CREATE TABLE admin_bdys.{0}_analysis (
  gid SERIAL NOT NULL PRIMARY KEY,
  {1} character varying(16) NOT NULL,
  name character varying(100) NOT NULL,
  state character varying(3) NOT NULL,
  geom geometry(Polygon, 4283, 2) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE admin_bdys.{0}_analysis OWNER TO postgres;

INSERT INTO admin_bdys.{0}_analysis ({1}, name, state, geom)
SELECT {1},
       name,
       state, 
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM admin_bdys.{0};

CREATE INDEX {0}_analysis_geom_idx ON admin_bdys.{0}_analysis USING gist(geom);
ALTER TABLE admin_bdys.{0}_analysis CLUSTER ON {0}_analysis_geom_idx;

ANALYZE admin_bdys.{0}_analysis;
