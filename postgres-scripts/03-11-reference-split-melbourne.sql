
-- split Melbourne into its 2 postcode areas: 3000 (north of the Yarra River) and 3004 (south):
--   - update Melbourne addresses and streets with the 2 new locality pids (VIC1634_1 & VIC1634_2)
--   - delete the original Melbourne locality (VIC1634) from the gnaf localities table

-----------------------------------------------------------------------------------------------------------------------------
-- update addresses & streets (point in polygon update)
-----------------------------------------------------------------------------------------------------------------------------

-- update addresses
UPDATE gnaf.temp_addresses AS pnt -- 90327 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_bdys AS bdy
  WHERE ST_Within(pnt.geom, bdy.geom)
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

-- update addresses just outside the bdy (with an increasing tolerance to get the correct postcode)
UPDATE gnaf.temp_addresses AS pnt -- 7 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_bdys AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0001))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

UPDATE gnaf.temp_addresses AS pnt -- 0 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_bdys AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0002))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

UPDATE gnaf.temp_addresses AS pnt -- 0 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_bdys AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0003))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

-- --update addreses further out rest by their postcode
-- UPDATE gnaf.temp_addresses SET locality_pid = 'VIC1634_1' WHERE locality_pid = 'VIC1634' AND postcode = '3000'; -- 0
-- UPDATE gnaf.temp_addresses SET locality_pid = 'VIC1634_2' WHERE locality_pid = 'VIC1634' AND postcode = '3004'; -- 1

-- update streets
UPDATE gnaf.streets AS pnt -- 358 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_bdys AS bdy
  WHERE ST_Within(pnt.geom, bdy.geom)
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

-- update streets just outside the bdy (with an increasing tolerance to get the correct postcode)
UPDATE gnaf.streets AS pnt -- 41 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_bdys AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0001))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

UPDATE gnaf.streets AS pnt -- 30 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_bdys AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0002))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

UPDATE gnaf.streets AS pnt -- 1 record
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_bdys AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0003))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

--update the rest (manually checked - they have no geometry but are in Melbourne, 3000) -- 7 records
UPDATE gnaf.streets
  SET locality_pid = 'VIC1634_1',
      postcode = '3000'
  WHERE locality_pid = 'VIC1634';

-----------------------------------------------------------------------------------------------------------------------------
-- gnaf localities, locality aliases and locality neighbours
-----------------------------------------------------------------------------------------------------------------------------
INSERT INTO gnaf.localities(locality_pid, locality_name, postcode, state, std_locality_name, latitude, longitude, locality_class, reliability, address_count, street_count, has_boundary, unique_locality_state, geom)
SELECT locality_pid || '_1',
       locality_name,
       postcode,
       state,
       locality_name AS std_locality_name,
       -37.81348464 AS latitude,
       144.96326770 AS longitude,
       locality_class,
       5 AS reliability,
       0 AS address_count,
       0 AS street_count,
       'Y' AS has_boundary,
       'N' AS unique_locality_state,
       ST_SetSRID(ST_MakePoint(144.96326770, -37.81348464), 4283) AS geom
  FROM gnaf.localities
  WHERE locality_pid = 'VIC1634';

INSERT INTO gnaf.localities(locality_pid, locality_name, postcode, state, std_locality_name, latitude, longitude, locality_class, reliability, address_count, street_count, has_boundary, unique_locality_state, geom)
SELECT locality_pid || '_2',
       locality_name,
       '3004',
       state,
       locality_name AS std_locality_name,
       -37.83356762 AS latitude,
       144.97757127 AS longitude,
       locality_class,
       5 AS reliability,
       0 AS address_count,
       0 AS street_count,
       'Y' AS has_boundary,
       'N' AS unique_locality_state,
       ST_SetSRID(ST_MakePoint(144.97757127, -37.83356762), 4283) AS geom
  FROM gnaf.localities
  WHERE locality_pid = 'VIC1634';

-- delete the replaced Melbourne locality
DELETE FROM gnaf.localities WHERE locality_pid = 'VIC1634';


-- update locality_aliases for Melbourne
UPDATE gnaf.locality_aliases
  SET locality_pid = locality_pid || '_1'
  WHERE locality_pid = 'VIC1634'
  AND locality_alias_name IN ('CARLTON', 'EAST MELBOURNE', 'UNIVERSITY OF MELBOURNE');

UPDATE gnaf.locality_aliases
  SET locality_pid = locality_pid || '_2'
  WHERE locality_pid = 'VIC1634'
  AND locality_alias_name = 'SOUTH YARRA';


-- update locality_neighbours for Melbourne
DELETE FROM gnaf.locality_neighbour_lookup WHERE locality_pid = 'VIC1634';
DELETE FROM gnaf.locality_neighbour_lookup WHERE neighbour_locality_pid = 'VIC1634';

INSERT INTO gnaf.locality_neighbour_lookup
SELECT 'VIC1634_1', locality_pid
  FROM admin_bdys.locality_bdys
  WHERE st_intersects((SELECT st_buffer(geom, 0.001) FROM admin_bdys.locality_bdys WHERE locality_pid LIKE 'VIC1634_1'), geom)
  AND locality_pid <> 'VIC1634_1';

INSERT INTO gnaf.locality_neighbour_lookup
SELECT 'VIC1634_2', locality_pid
  FROM admin_bdys.locality_bdys
  WHERE st_intersects((SELECT st_buffer(geom, 0.001) FROM admin_bdys.locality_bdys WHERE locality_pid LIKE 'VIC1634_2'), geom)
  AND locality_pid <> 'VIC1634_2';
