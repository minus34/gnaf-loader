

-- rules applied as per ABC News (14/08/2021)
-- https://www.abc.net.au/news/2021-08-14/nsw-new-covid-rules-and-fines/100377514
--
-- From 12:01am Monday, August 16, anyone in Greater Sydney
-- (which includes the Blue Mountains, Central Coast, Wollongong and Shellharbour)
-- can only shop, exercise or engage in outdoor recreation within their local government area (LGA)
-- or, if outside your LGA, within 5 kilometres of your home.
--

DROP TABLE IF EXISTS testing.five_km_radius;
CREATE TABLE testing.five_km_radius AS
WITH pnt AS (
    SELECT st_setsrid(st_makepoint(longitude, latitude), 4283) AS geom
	FROM gnaf_202105.address_principals
	WHERE address = '<your address in upper case with full street type e.g. 123 GEORGE STREET'
	AND locality_name = '<your suburb in upper case e.g. NORTH SYDNEY'
	-- AND state = 'NSW'
)
SELECT st_union(st_setsrid(st_buffer(pnt.geom::geography, 5000.0, 128)::geometry, 4283), bdy.geom) AS geom
FROM admin_bdys_202105.local_government_areas as bdy
INNER JOIN pnt ON st_intersects(pnt.geom, bdy.geom)
;
