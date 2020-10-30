
-- Get partitions of equal record counts
DROP TABLE IF EXISTS testing.gnaf_partitions;
CREATE TABLE testing.gnaf_partitions AS
WITH parts AS(
    SELECT unnest((select array_agg(counter) from generate_series(2, 20, 1) AS counter)) as partition_id,
           unnest((select array_agg(fraction) from generate_series(0.05, 0.95, 0.05) AS fraction)) as percentile,
           unnest((select percentile_cont((select array_agg(s) from generate_series(0.05, 0.95, 0.05) as s)) WITHIN GROUP (ORDER BY longitude) FROM gnaf_202008.address_principals)) as longitude
), parts2 AS (
SELECT 1 AS partition_id, 0.0 AS percentile, min(longitude) - 0.0001 AS longitude FROM gnaf_202008.address_principals
UNION ALL
SELECT * FROM parts
UNION ALL
SELECT 21 AS partition_id, 1.0 AS percentile, max(longitude) - 0.0001 AS longitude FROM gnaf_202008.address_principals
)
SELECT *,
       ST_MakeEnvelope(longitude, -43.58311104::double precision, lead(longitude) OVER (ORDER BY partition_id), -9.22990371::double precision, 4823) AS geom
FROM parts2
;







ST_MakeEnvelope(float xmin, -43.58311104, float xmax, -9.22990371, integer srid=unknown);

select max(latitude) FROM gnaf_202008.address_principals
