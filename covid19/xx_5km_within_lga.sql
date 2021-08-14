
DROP TABLE IF EXISTS testing.five_km_radius;
CREATE TABLE testing.five_km_radius AS
SELECT st_buffer(st_setsrid(st_makepoint(longitude, latitude), 4283)::geography, 5000.0, 128) AS geom
FROM gnaf_202105.address_principals
WHERE address = ''
AND locality_name = ''
-- AND state = 'NSW'
;
