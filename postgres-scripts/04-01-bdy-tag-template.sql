
DROP TABLE IF EXISTS gnaf.temp_{0}_tags;
CREATE UNLOGGED TABLE gnaf.temp_{0}_tags (
  gnaf_pid character varying(16) NOT NULL,
  alias_principal character(1) NOT NULL,
  {1} character varying(16) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.temp_{0}_tags OWNER TO postgres;

INSERT INTO gnaf.temp_{0}_tags (gnaf_pid, alias_principal, {1})
SELECT pnts.gnaf_pid,
       'P',
       bdys.{1}
  FROM gnaf.address_principals AS pnts
  INNER JOIN admin_bdys.{0}_analysis AS bdys
  ON ST_Within(pnts.geom, bdys.geom);

INSERT INTO gnaf.temp_{0}_tags (gnaf_pid, alias_principal, {1})
SELECT pnts.gnaf_pid,
       'A',
       bdys.{1}
  FROM gnaf.address_aliases AS pnts
  INNER JOIN admin_bdys.{0}_analysis AS bdys
  ON ST_Within(pnts.geom, bdys.geom);

CREATE INDEX temp_{0}_tags_gnaf_pid_idx ON gnaf.temp_{0}_tags USING btree(gnaf_pid);

ANALYZE gnaf.temp_{0}_tags;
