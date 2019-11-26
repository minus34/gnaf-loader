
-- create basic version of principal addresses for dot density mapping
DROP TABLE IF EXISTS gnaf_201608.basic_address_principals;
CREATE TABLE gnaf_201608.basic_address_principals AS
WITH points AS (
SELECT adr.address_detail_pid AS gnaf_pid,
       mb16.mb_2016_code::bigint,
       gty.name AS geocode_type,
       CASE
         WHEN gty.name = 'GAP GEOCODE' THEN 3
         WHEN gty.name = 'STREET LOCALITY' THEN 4
         WHEN gty.name = 'LOCALITY' THEN 5
         ELSE 2
       END AS reliability,
       st_setsrid(st_makepoint(pnt.longitude, pnt.latitude), 4283)::geometry(point, 4283) AS geom
  FROM raw_gnaf_201608.address_detail AS adr
  INNER JOIN raw_gnaf_201608.address_default_geocode as pnt ON adr.address_detail_pid = pnt.address_detail_pid
  LEFT OUTER JOIN raw_gnaf_201608.geocode_type_aut AS gty ON pnt.geocode_type_code = gty.code
  LEFT OUTER JOIN (
  SELECT mb1.address_detail_pid, mb2.mb_2011_code
    FROM raw_gnaf_201608.address_mesh_block_2011 AS mb1
    INNER JOIN raw_gnaf_201608.mb_2011 AS mb2 ON mb1.mb_2011_pid = mb2.mb_2011_pid
  ) AS mb11 ON adr.address_detail_pid = mb11.address_detail_pid
  LEFT OUTER JOIN (
  SELECT mb1.address_detail_pid, mb2.mb_2016_code
    FROM raw_gnaf_201608.address_mesh_block_2016 AS mb1
    INNER JOIN raw_gnaf_201608.mb_2016 AS mb2 ON mb1.mb_2016_pid = mb2.mb_2016_pid
  ) AS mb16 ON adr.address_detail_pid = mb16.address_detail_pid
  WHERE adr.confidence > -1
    AND adr.alias_principal = 'P'
)
SELECT gnaf_pid, mb_2016_code, geom FROM points
    WHERE reliability < 4;

ANALYSE gnaf_201608.basic_address_principals;

CREATE INDEX basic_address_principals_geom_idx ON gnaf_201608.basic_address_principals USING gist (geom);
ALTER TABLE gnaf_201608.basic_address_principals CLUSTER ON basic_address_principals_geom_idx;

CREATE INDEX basic_address_principals_mb_2016_code_idx ON gnaf_201608.basic_address_principals USING btree(mb_2016_code);
