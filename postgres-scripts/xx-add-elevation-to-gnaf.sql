
-- create table of ~100m grid of gnaf address points for weather analysis
DROP TABLE IF EXISTS testing.gnaf_points_with_pop_and_height;
CREATE TABLE testing.gnaf_points_with_pop_and_height AS
    SELECT st_y(geom)::numeric(5,3) as latitude,
           st_x(geom)::numeric(6,3) as longitude,
           sum(person) as count,
           avg(ST_Value(dem.rast, gnaf.geom)) as elevation
    FROM testing.address_principals_persons as gnaf
    INNER JOIN gnaf_202102.srtm_3s_dem as dem on ST_Intersects(gnaf.geom, dem.rast)
    GROUP BY latitude, longitude
;
ALTER TABLE testing.gnaf_points_with_pop_and_height OWNER to postgres;

ANALYZE testing.gnaf_points_with_pop_and_height;


-- SELECT ST_Value(dem.rast, gnaf.geom) as elevation,
--        *
-- FROM gnaf_202102.address_principals as gnaf
-- INNER JOIN gnaf_202102.srtm_3s_dem as dem on ST_Intersects(gnaf.geom, dem.rast) limit 100;



