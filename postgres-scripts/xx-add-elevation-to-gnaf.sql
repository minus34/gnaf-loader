

-- create temp table of ~100m grid of gnaf address points
DROP TABLE IF EXISTS temp_gnaf_100m_points;
CREATE TEMPORARY TABLE temp_gnaf_100m_points AS
WITH gnaf as (
    SELECT st_y(geom)::numeric(5,3) as latitude,
           st_x(geom)::numeric(6,3) as longitude,
           person
    FROM testing.address_principals_persons
)
SELECT latitude,
       longitude,
       sum(person) as count,
       st_setsrid(st_makepoint(longitude, latitude), 4326) as geom
    FROM gnaf
    GROUP BY latitude,
             longitude
;
ALTER TABLE temp_gnaf_100m_points OWNER to postgres;
ANALYZE temp_gnaf_100m_points;

CREATE INDEX temp_gnaf_100m_points_geom_idx ON temp_gnaf_100m_points USING GIST (geom);
ALTER TABLE temp_gnaf_100m_points CLUSTER ON temp_gnaf_100m_points_geom_idx;

-- add elevation
DROP TABLE IF EXISTS testing.gnaf_points_with_pop_and_height;
CREATE TABLE testing.gnaf_points_with_pop_and_height AS
SELECT gnaf.latitude,
       gnaf.longitude,
       gnaf.count,
       ST_Value(dem.rast, gnaf.geom) as elevation
FROM temp_gnaf_100m_points as gnaf
INNER JOIN testing.srtm_3s_dem as dem on ST_Intersects(gnaf.geom, dem.rast)
;
ALTER TABLE testing.gnaf_points_with_pop_and_height OWNER to postgres;

ANALYZE testing.gnaf_points_with_pop_and_height;


DROP TABLE IF EXISTS temp_gnaf_100m_points;

--
-- SELECT ST_Value(dem.rast, gnaf.geom) as elevation,
--        *
-- FROM gnaf_202308.address_principals as gnaf
-- INNER JOIN gnaf_202308.srtm_3s_dem as dem on ST_Intersects(gnaf.geom, dem.rast) limit 100;


