DROP TABLE IF EXISTS gnaf.temp_{0}_tags;
CREATE UNLOGGED TABLE gnaf.temp_{0}_tags (
  gnaf_pid text NOT NULL,
  gnaf_state text NOT NULL,
  alias_principal character(1) NOT NULL,
  bdy_pid text NOT NULL,
  bdy_name text NOT NULL,
  bdy_state text NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.temp_{0}_tags OWNER TO postgres;