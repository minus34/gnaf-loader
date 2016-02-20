
-- split Melbourne into its 2 postcode areas: 3000 (north of the Yarra River) and 3004 (south):
--   - do it for both the gnaf localities table and the locality boundaries
--   - update Melbourne addresses and streets with the 2 new locality pids (VIC1634_1 & VIC1634_2)
--   - delete the original Melbourne locality (VIC1634) from both the gnaf localities table and the locality boundaries

-----------------------------------------------------------------------------------------------------------------------------
-- locality boundaries
-----------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS temp_bdys;
CREATE UNLOGGED TABLE temp_bdys
(
  locality_pid character varying(16) NOT NULL,
  locality_name character varying(100) NOT NULL,
  postcode char(4) NULL,
  state character varying(3) NOT NULL,
	locality_class character varying(50) NOT NULL,
  address_count integer NOT NULL,
  street_count integer NOT NULL,
  geom geometry(Multipolygon, 4283, 2) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE temp_bdys OWNER TO postgres;

insert into temp_bdys
select locality_pid,
       locality_name,
       '3000' AS postcode,
       state,
       locality_class,
       0,
       0,
       ST_Multi((ST_Dump(ST_Split(geom, ST_GeomFromText('LINESTRING(144.96691 -37.82135,144.96826 -37.81924,144.97045 -37.81911,144.97235 -37.81921,144.97345 -37.81955,144.97465 -37.82049,144.97734 -37.82321,144.97997 -37.82602,144.98154 -37.82696,144.98299 -37.82735,144.98499 -37.82766,144.9866 -37.82985)', 4283)))).geom) AS geom
  from admin_bdys.locality_boundaries
  where locality_pid = 'VIC1634';

-- update the locality_pids of the 2 new boundaries
UPDATE temp_bdys
  SET locality_pid = locality_pid || '_2',
      postcode = '3004'
  WHERE ST_Intersects(ST_SetSRID(ST_MakePoint(144.9781, -37.8275), 4283), geom);

UPDATE temp_bdys
  SET locality_pid = locality_pid || '_1'
  WHERE postcode = '3000';

-- insert the new boundaries into the main table, the old record doesn't get deleted yet!
INSERT INTO admin_bdys.locality_boundaries (locality_pid, locality_name, postcode, state, locality_class, address_count, street_count, geom)
SELECT locality_pid, locality_name, postcode, state, locality_class, address_count, street_count, geom FROM temp_bdys;

DROP TABLE temp_bdys;

-- delete the replaced Melbourne locality
DELETE FROM admin_bdys.locality_boundaries WHERE locality_pid = 'VIC1634';

-- update stats
ANALYZE admin_bdys.locality_boundaries;

-----------------------------------------------------------------------------------------------------------------------------
-- update addresses & streets (point in polygon update)
-----------------------------------------------------------------------------------------------------------------------------

-- update addresses
UPDATE gnaf.temp_addresses AS pnt -- 90327 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_boundaries AS bdy
  WHERE ST_Within(pnt.geom, bdy.geom)
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

-- update addresses just outside the bdy (with an increasing tolerance to get the correct postcode)
UPDATE gnaf.temp_addresses AS pnt -- 7 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_boundaries AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0001))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

UPDATE gnaf.temp_addresses AS pnt -- 0 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_boundaries AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0002))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

UPDATE gnaf.temp_addresses AS pnt -- 0 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_boundaries AS bdy
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
  FROM admin_bdys.locality_boundaries AS bdy
  WHERE ST_Within(pnt.geom, bdy.geom)
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

-- update streets just outside the bdy (with an increasing tolerance to get the correct postcode)
UPDATE gnaf.streets AS pnt -- 41 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_boundaries AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0001))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

UPDATE gnaf.streets AS pnt -- 30 records
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_boundaries AS bdy
  WHERE ST_Within(pnt.geom, ST_Buffer(bdy.geom, 0.0002))
  AND pnt.locality_pid = 'VIC1634'
  AND bdy.locality_pid LIKE 'VIC1634_%';

UPDATE gnaf.streets AS pnt -- 1 record
  SET locality_pid = bdy.locality_pid,
      postcode = bdy.postcode
  FROM admin_bdys.locality_boundaries AS bdy
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
  FROM admin_bdys.locality_boundaries
  WHERE st_intersects((SELECT st_buffer(geom, 0.001) FROM admin_bdys.locality_boundaries WHERE locality_pid LIKE 'VIC1634_1'), geom)
  AND locality_pid <> 'VIC1634_1';

INSERT INTO gnaf.locality_neighbour_lookup
SELECT 'VIC1634_2', locality_pid
  FROM admin_bdys.locality_boundaries
  WHERE st_intersects((SELECT st_buffer(geom, 0.001) FROM admin_bdys.locality_boundaries WHERE locality_pid LIKE 'VIC1634_2'), geom)
  AND locality_pid <> 'VIC1634_2';


