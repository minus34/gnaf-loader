
-- Get partitions of equal record counts
DROP TABLE IF EXISTS testing2.gnaf_partitions;
CREATE TABLE testing2.gnaf_partitions AS
WITH parts AS(
    SELECT unnest((select array_agg(counter) from generate_series(1, 99, 1) AS counter)) as partition_id,
           unnest((select array_agg(fraction) from generate_series(0.01, 0.99, 0.01) AS fraction)) as percentile,
           unnest((select percentile_cont((select array_agg(s) from generate_series(0.01, 0.99, 0.01) as s)) WITHIN GROUP (ORDER BY longitude) FROM gnaf_202102.address_principals)) as longitude
), parts2 AS (
SELECT 0 AS partition_id, 0.0 AS percentile, min(longitude) - 0.0001 AS longitude FROM gnaf_202102.address_principals
UNION ALL
SELECT * FROM parts
UNION ALL
SELECT 100 AS partition_id, 1.0 AS percentile, max(longitude) - 0.0001 AS longitude FROM gnaf_202102.address_principals
)
SELECT partition_id,
       percentile,
       longitude as min_longitude,
       lead(longitude) OVER (ORDER BY partition_id) as max_longitude,
       st_multi(ST_MakeEnvelope(longitude, -43.58311104::double precision, lead(longitude) OVER (ORDER BY partition_id), -9.22990371::double precision, 4283)) AS geom
FROM parts2
;

ANALYZE testing2.gnaf_partitions;
commit;


DROP TABLE IF EXISTS testing2.commonwealth_electorates_partitioned CASCADE;
CREATE TABLE testing2.commonwealth_electorates_partitioned (
  gid SERIAL NOT NULL PRIMARY KEY,
  partition_id smallint not null,
  ce_pid text NOT NULL,
  name text NOT NULL,
  state text NOT NULL,
  geom geometry(Polygon, 4283, 2) NOT NULL
) WITH (OIDS=FALSE);
ALTER TABLE testing2.commonwealth_electorates_partitioned OWNER TO postgres
;

WITH merge AS (
    SELECT ce_pid,
           partition_id,
           name,
           state,
           st_intersection(bdy.geom, part.geom) AS geom
    FROM admin_bdys_202102.commonwealth_electorates as bdy
    INNER JOIN testing2.gnaf_partitions as part ON st_intersects(bdy.geom, part.geom)
)
INSERT INTO testing2.commonwealth_electorates_partitioned (partition_id, ce_pid, name, state, geom)
SELECT partition_id,
       ce_pid,
       name,
       state, 
       ST_Subdivide((ST_Dump(ST_Buffer(geom, 0.0))).geom, 512)
  FROM merge
;

CREATE INDEX commonwealth_electorates_partitioned_geom_idx ON testing2.commonwealth_electorates_partitioned USING gist(geom);
ALTER TABLE testing2.commonwealth_electorates_partitioned CLUSTER ON commonwealth_electorates_partitioned_geom_idx;

ANALYZE testing2.commonwealth_electorates_partitioned;

commit;


select count(*) from testing2.commonwealth_electorates_partitioned;

select count(*) from admin_bdys_202102.commonwealth_electorates_analysis;
