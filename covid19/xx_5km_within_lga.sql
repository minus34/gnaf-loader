
DROP TABLE IF EXISTS testing.five_km_radius;
CREATE TABLE testing.five_km_radius AS
WITH pnt AS (
    SELECT st_setsrid(st_makepoint(longitude, latitude), 4283) AS geom
	FROM gnaf_202105.address_principals
	WHERE address = ''
	AND locality_name = ''
	-- AND state = 'NSW'
)
SELECT st_intersection(st_buffer(pnt.geom::geography, 5000.0, 128), bdy.geom::geography) AS geom
FROM admin_bdys_202105.local_government_areas as bdy
INNER JOIN pnt ON st_intersects(pnt.geom, bdy.geom)
;

