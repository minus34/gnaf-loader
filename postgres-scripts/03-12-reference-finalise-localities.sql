
-----------------------------------------------------------------------------------------------
-- convert addresses with non-boundary localities to an equivalent boundary locality
-----------------------------------------------------------------------------------------------

-- update localities "has_boundary" flag
UPDATE gnaf.localities AS loc
  SET has_boundary = 'Y'
  FROM admin_bdys.locality_bdys AS bdy
  WHERE loc.locality_pid = bdy.locality_pid;

-- -- address counts by locality pid without a boundary (201511 GNAF), all have equivalent locality boundaries
-- -- 1,500207010,BENI,2830,NSW
-- -- 55,500220140,MAJURA,2609,ACT
-- -- 17,500223209,GUNGAHLIN,2914,ACT
-- -- 86,500223207,BELCONNEN,2615,ACT
-- -- 123,500220138,JERRABOMBERRA,2620,ACT

-- addresses - change locality pids from a non-boundary pid to a boundary one -- 282 records
UPDATE gnaf.temp_addresses AS pnt
  SET locality_pid = bdy.locality_pid
  FROM admin_bdys.locality_bdys AS bdy,
  gnaf.localities AS loc
  WHERE pnt.locality_pid = loc.locality_pid
  AND ST_Within(pnt.geom, bdy.geom)
  AND loc.has_boundary = 'N';

-- -- any addresses in non-boundary localities? -- no!
-- select Count(*) as addresses, loc.locality_pid, loc.locality_name, loc.postcode, loc.state
--   from gnaf.temp_addresses AS adr,
--   gnaf.localities AS loc
--   WHERE adr.locality_pid = loc.locality_pid
--   AND loc.has_boundary = 'N'
--   group by loc.locality_pid, loc.locality_name, loc.postcode, loc.state;

-- streets - change locality pids from a non-boundary pid to a boundary one -- 224 records
UPDATE gnaf.streets AS pnt
  SET locality_pid = bdy.locality_pid
  FROM admin_bdys.locality_bdys AS bdy,
  gnaf.localities AS loc
  WHERE pnt.locality_pid = loc.locality_pid
  AND ST_Within(pnt.geom, bdy.geom)
  AND loc.has_boundary = 'N';

-- -- any streets in non-boundary localities? -- no!
-- select Count(*) as streets, loc.locality_pid, loc.locality_name, loc.postcode, loc.state
--   from gnaf.streets AS str,
--   gnaf.localities AS loc
--   WHERE str.locality_pid = loc.locality_pid
--   AND loc.has_boundary = 'N'
--   AND str.geom IS NOT NULL
--   group by loc.locality_pid, loc.locality_name, loc.postcode, loc.state;


-----------------------------------------------------------------------------------------------
-- finalise street and address counts
-----------------------------------------------------------------------------------------------

-- localities - finalise address counts
UPDATE gnaf.localities AS loc
	SET address_count = adr.cnt
	FROM (
		SELECT Count(*) AS cnt, locality_pid
		  FROM gnaf.temp_addresses
		  GROUP BY locality_pid
) AS adr
WHERE loc.locality_pid = adr.locality_pid;

-- localities - finalise street counts
UPDATE gnaf.localities AS loc
	SET street_count = str.cnt
	FROM (
		SELECT Count(*) AS cnt, locality_pid
		  FROM gnaf.streets
		  GROUP BY locality_pid
) AS str
WHERE loc.locality_pid = str.locality_pid;

-- streets - finalise address counts -- 15138 rows updated
UPDATE gnaf.streets AS str
	SET address_count = adr.cnt
	FROM (
		SELECT Count(*) AS cnt, street_locality_pid
		  FROM gnaf.temp_addresses
		  GROUP BY street_locality_pid
) AS adr
WHERE str.street_locality_pid = adr.street_locality_pid;


-----------------------------------------------------------------------------------------------
-- finalise postcodes assigned to localities, streets and addresses
-----------------------------------------------------------------------------------------------

-- assign postcodes to localities using address postcodes
-- create address count table by locality and postcode
DROP TABLE IF EXISTS temp_locality_postcode;
SELECT Count(*) as address_count, locality_pid, postcode
  INTO TEMPORARY TABLE temp_locality_postcode
  FROM gnaf.temp_addresses
  WHERE reliability < 4
  GROUP BY locality_pid, postcode;

-- update address postcodes in localities
UPDATE gnaf.localities AS loc
  SET postcode = loc_pc.postcode
  FROM (
    SELECT MAX(address_count) AS max_address_count, locality_pid FROM temp_locality_postcode GROUP BY locality_pid
  ) AS sqt,
  temp_locality_postcode AS loc_pc
  WHERE loc.locality_pid = sqt.locality_pid
  AND sqt.locality_pid = loc_pc.locality_pid
  AND sqt.max_address_count = loc_pc.address_count
  AND (loc.postcode IS NULL OR loc.postcode = '9999');

DROP TABLE temp_locality_postcode;


-- streets - reassign locality name, postcode and state
UPDATE gnaf.streets AS str 
	SET locality_name = loc.locality_name,
	    postcode = loc.postcode,
      state = loc.state
	FROM gnaf.localities AS loc
  WHERE str.locality_pid = loc.locality_pid;


-- addresses - update geocode reliability for district locality geocodes -- 146 records
UPDATE gnaf.temp_addresses AS adr
	SET reliability = loc.reliability
	FROM gnaf.localities AS loc
  WHERE adr.locality_pid = loc.locality_pid
  AND adr.geocode_type = 'LOCALITY'
  AND loc.reliability = 6;


-----------------------------------------------------------------------------------------------
-- update locality boundaries
-----------------------------------------------------------------------------------------------

-- get postcodes and street & address counts from gnaf localities table
UPDATE admin_bdys.locality_bdys as bdy
  SET postcode = loc.postcode,
      address_count = loc.address_count,
      street_count = loc.street_count
  FROM gnaf.localities AS loc
  WHERE bdy.locality_pid = loc.locality_pid;

-----------------------------------------------------------------------------------------------
-- clean up
-----------------------------------------------------------------------------------------------

-- -- delete gnaf locality records with no lat/long and no addresses - these also aren't gazetted and have no boundary - i.e. they're close to useless (and can be misleading duplicates, so goodbye!) -- 531 rows
-- DELETE FROM gnaf.localities WHERE geom IS NULL AND address_count = 0 AND street_count = 0 AND has_boundary = 'N';

---------------------------------------------------------------------------------------------------------
-- update stats, add an index & primary key for integrity and to speed up creation of addresses table
---------------------------------------------------------------------------------------------------------

ANALYZE gnaf.localities;

ALTER TABLE ONLY gnaf.localities ADD CONSTRAINT localities_pkey PRIMARY KEY(locality_pid);

CREATE UNIQUE INDEX localities_gid_idx ON gnaf.localities USING btree (gid);






                             
-- -- 
-- -- -- qa
-- -- 
-- 
-- SELECT count(*), geocode_type, reliability
--   FROM gnaf.temp_addresses group by geocode_type, reliability
--    order by reliability, geocode_type;

-- 
-- 
-- -- test using state to remove unwanted localities - too many unwanted artifacts - requires advance scripting or a lot of manual cleansing
-- 
-- DROP TABLE IF EXISTS admin_bdys.temp_bdys;
-- CREATE UNLOGGED TABLE admin_bdys.temp_bdys
-- (
--   gid integer NOT NULL,
--   locality_pid character varying(16) NOT NULL,
--   locality_name character varying(100) NOT NULL,
--   postcode character(4),
--   state character varying(3) NOT NULL,
--   locality_class character varying(50) NOT NULL,
--   address_count integer NOT NULL,
--   street_count integer NOT NULL,
--   geom geometry(Polygon,4283) NOT NULL,
--   area float NULL
-- )
-- WITH (OIDS=FALSE);
-- ALTER TABLE admin_bdys.temp_bdys OWNER TO postgres;
-- 
-- 
-- INSERT INTO admin_bdys.temp_bdys 
-- SELECT loc.gid,
--        loc.locality_pid,
--        loc.locality_name,
--        loc.postcode,
--        loc.state,
--        loc.locality_class,
--        loc.address_count,
--        loc.street_count,
--        ((ST_Dump(ST_Intersection(loc.geom, ste.geom))).geom)
--   FROM admin_bdys.locality_bdys AS loc
--   INNER JOIN raw_admin_bdys.aus_state_polygon AS ste
--   ON ST_Intersects(loc.geom, ste.geom)
--   --WHERE loc.locality_name IN ('SWAN BAY', 'SWAN ISLAND', 'QUEENSCLIFF')
--   WHERE loc.state = 'QLD';
-- 
-- UPDATE admin_bdys.temp_bdys SET area = ST_Area(ST_Transform(geom, 3577));
-- 
-- DELETE FROM admin_bdys.temp_bdys WHERE area < 50000;
-- 
-- --SELECT * FROM admin_bdys.temp_bdys ORDER BY area desc;











-- -- create view of addresses with conflicting postcodes
-- drop view if exists gnaf.vw_diff_postcode;
-- create view gnaf.vw_diff_postcode as
-- select * from gnaf.temp_addresses where postcode <> locality_postcode; -- 14582
-- 
-- -- postcode diffs by locality -- 2215 localities
-- select * from (
--   select Count(*) AS adr_count, locality_pid, locality_name, locality_postcode, state
--     from gnaf.temp_addresses
--     where postcode <> locality_postcode
--     group by locality_pid, locality_name, locality_postcode, state
-- ) as sqt
-- order by adr_count desc;
-- 
-- 
-- -- postcodes that are wrong -- 514
-- select adr.* from gnaf.temp_addresses as adr
--   inner join admin_bdys.aus_locality_postcode as loc on adr.locality_pid = loc.loc_pid
--   inner join admin_bdys.aus_postcode as pc on loc.pc_pid = pc.pc_pid
--   where adr.locality_postcode <> pc.postcode
--   and adr.postcode <> adr.locality_postcode;
-- 
-- 
-- 
-- select * from (
--   select Count(*) AS adr_count, adr.locality_pid, adr.locality_name, adr.locality_postcode, adr.state
--     from gnaf.temp_addresses as adr
--     inner join admin_bdys.aus_locality_postcode as loc on adr.locality_pid = loc.loc_pid
--     inner join admin_bdys.aus_postcode as pc on loc.pc_pid = pc.pc_pid
--     where adr.locality_postcode <> pc.postcode
--     and adr.postcode <> adr.locality_postcode
--     group by adr.locality_pid, adr.locality_name, adr.locality_postcode, adr.state
-- ) as sqt
-- order by adr_count desc;
-- 
-- 
-- 
-- 
-- 
-- select * from gnaf.localities where locality_name = 'EUMUNGERIE'; -- NSW1474
-- 
-- select * from gnaf.temp_addresses where locality_name = 'COLLINGULLIE';


