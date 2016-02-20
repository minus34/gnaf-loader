
-- main insert -- 684781 rows
INSERT INTO gnaf.streets (street_locality_pid, locality_pid, street_name, street_type, street_suffix, full_street_name, locality_name, postcode, state, street_type_abbrev, street_suffix_abbrev, street_class, latitude, longitude, geom)
SELECT str.street_locality_pid,
       str.locality_pid,
       str.street_name,
       str.street_type_code AS street_type,
       suf.name AS street_suffix,
       str.street_name ||
       CASE WHEN str.street_type_code IS NOT NULL
         THEN ' ' ||  str.street_type_code
         ELSE '' END ||
       CASE WHEN suf.name IS NOT NULL
         THEN ' ' || suf.name
         ELSE '' END AS full_street_name,
       loc.locality_name,
       loc.postcode,
       loc.state,
       typ.name AS street_type_abbrev,
       str.street_suffix_code AS street_suffix_abbrev,
       cls.name AS street_class,
       pnt.latitude,
	     pnt.longitude,
	     st_setsrid(st_makepoint(pnt.longitude, pnt.latitude), 4283) AS geom
  FROM raw_gnaf.street_locality AS str
  LEFT OUTER JOIN raw_gnaf.street_locality_point AS pnt ON str.street_locality_pid = pnt.street_locality_pid
  LEFT OUTER JOIN gnaf.localities AS loc ON str.locality_pid = loc.locality_pid
  LEFT OUTER JOIN raw_gnaf.street_type_aut AS typ ON str.street_type_code = typ.code
  LEFT OUTER JOIN raw_gnaf.street_suffix_aut AS suf ON str.street_suffix_code = suf.code
  LEFT OUTER JOIN raw_gnaf.street_class_aut AS cls ON str.street_class_code = cls.code;

---------------------------------------------------------------------------------------------------------
-- update stats, add an index & primary key for integrity and to speed up creation of addresses table
---------------------------------------------------------------------------------------------------------

ANALYZE gnaf.streets;

ALTER TABLE ONLY gnaf.streets ADD CONSTRAINT streets_pk PRIMARY KEY (street_locality_pid);

CREATE UNIQUE INDEX streets_gid_idx ON gnaf.streets USING btree (gid);









-- 
-- -- get coords and geometries -- 682075 rows updated
-- UPDATE gnaf.streets AS str
-- 	SET latitude = pnt.latitude,
-- 	    longitude = pnt.longitude,
-- 	    geom = st_setsrid(st_makepoint(pnt.longitude, pnt.latitude), 4283)
-- FROM raw_gnaf.street_locality_point AS pnt 
-- WHERE str.street_locality_pid = pnt.street_locality_pid;

-- 
-- -- get address counts
-- UPDATE gnaf.streets AS str
-- 	SET address_count = adr.cnt
-- 	FROM (
-- 		SELECT Count(*) AS cnt, street_locality_pid
-- 		  FROM raw_gnaf.address_detail
-- 		  WHERE confidence > -1
-- 		  GROUP BY street_locality_pid
-- ) AS adr
-- WHERE str.street_locality_pid = adr.street_locality_pid;
-- 
-- 
-- --Update stats
-- ANALYZE gnaf.streets;
-- 
-- 
-- select (select count(*) from raw_gnaf.street_locality) - (select count(*) from gnaf.streets) AS diff; -- 0


-- QA

-- 
-- select Count(*) from gnaf.streets where geom IS NULL OR street_class = 'UNCONFIRMED'; -- 18318
-- 
-- -- select Count(*) from gnaf.streets where confidence IS NULL; -- 208738
-- 
-- 
-- -- addresses without a good street -- 77533 rows
-- select Count(*) from address_detail
--   where street_locality_pid in (select street_locality_pid from gnaf.streets where geom IS NULL OR street_class = 'UNCONFIRMED')
--   and confidence > -1;
-- 
-- -- streets with addresses but not confirmed or no geom -- 12245 rows
-- select DISTINCT str.*
--   from address_detail as adr
--   inner join gnaf.streets as str on adr.street_locality_pid = str.street_locality_pid
--   where (str.street_class = 'UNCONFIRMED')
--   and adr.confidence > -1;
-- 
-- 
-- select * from gnaf.streets where street_name = 'CRIMSON' and locality_name LIKE 'ASH%';
-- 
-- select * from gnaf.streets where street_locality_pid = 'NSW2810167';
-- 
-- select * from address_detail where street_locality_pid = 'NSW2810167';
-- select * from address_detail where street_locality_pid = 'NSW3381908';
-- 
-- select latitude, longitude, * from address_default_geocode where address_detail_pid = 'GANSW704192748';
-- 
-- 
-- 
-- -- Any addresses in non-geographic streets? -- 16258
-- select Count(*), street_locality_pid from address_detail
--   where street_locality_pid not in (select street_locality_pid from gnaf.streets where geom IS NOT NULL)
--   and confidence > -1
--   group by street_locality_pid order by street_locality_pid;
-- 
-- 
-- 
-- 
-- 
-- select * from gnaf.streets limit 2000;


