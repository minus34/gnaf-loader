

SELECT ST_Value(dem.rast, gnaf.geom) as elevation,
       *
FROM gnaf_202102.address_principals as gnaf
INNER JOIN gnaf_202102.srtm_3s_dem as dem on ST_Intersects(gnaf.geom, dem.rast) limit 100;