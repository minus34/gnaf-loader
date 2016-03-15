DROP TABLE IF EXISTS gnaf.temp_{0}_tags;
CREATE UNLOGGED TABLE gnaf.temp_{0}_tags (
  gnaf_pid character varying(16) NOT NULL,
  gnaf_state character varying(3) NOT NULL,
  alias_principal character(1) NOT NULL,
  bdy_pid character varying(15) NOT NULL,
  bdy_name character varying(100) NOT NULL,
  bdy_state character varying(3) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE gnaf.temp_{0}_tags OWNER TO postgres;