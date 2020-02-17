
-- Import MB counts CSV file
DROP TABLE IF EXISTS testing.mb_2016_counts;
CREATE TABLE testing.mb_2016_counts (
    mb_2016_code bigint,
    mb_category_name_2016 text NOT NULL,
    area_albers_sqkm double precision,
    dwelling integer default 0,
    person integer default 0,
	address_count integer default 0,
    state smallint NOT NULL,
    geom geometry(MultiPolygon, 4283),
    CONSTRAINT abs_2011_mb_pk PRIMARY KEY (mb_2016_code)
);

COPY testing.mb_2016_counts (mb_2016_code, mb_category_name_2016, area_albers_sqkm, dwelling, person, state)
FROM '/Users/s57405/Downloads/2016 census mesh block counts.csv' WITH (FORMAT CSV, HEADER);

ANALYSE testing.mb_2016_counts;

-- Get address counts per meshblock -- 1 min
WITH counts AS (
	SELECT mb_2016_code,
		   count(*) AS address_count
	FROM gnaf_202002.address_principals
	GROUP BY mb_2016_code
)
UPDATE testing.mb_2016_counts AS mb
  SET address_count = counts.address_count
  FROM counts
  WHERE mb.mb_2016_code = counts.mb_2016_code
;

ANALYSE testing.mb_2016_counts;

-- add geoms
UPDATE testing.mb_2016_counts AS mb
  SET geom = bdys.geom
  FROM admin_bdys_202002.abs_2016_mb as bdys
  WHERE mb.mb_2016_code = bdys.mb_16code::bigint;

ANALYSE testing.mb_2016_counts;

CREATE INDEX mb_2016_counts_geom_idx ON testing.mb_2016_counts USING gist(geom);
ALTER TABLE testing.mb_2016_counts CLUSTER ON mb_2016_counts_geom_idx;


-- create an address accurate dwelling map of Australia
-- get the correct number of addresses from GNAF for each meshblock, based on dwelling counts -- 10 mins

--    1. where address count is greater than dwelling count
DROP TABLE IF EXISTS testing.address_principals_dwelling;
CREATE TABLE testing.address_principals_dwelling AS
WITH adr AS (
	SELECT gnaf.gnaf_pid,
           gnaf.mb_2016_code,
	       mb.dwelling,
	       mb.person,
           mb.address_count,
           gnaf.geom
	FROM gnaf_202002.address_principals as gnaf
	INNER JOIN testing.mb_2016_counts AS mb on gnaf.mb_2016_code = mb.mb_2016_code
	WHERE mb.address_count >= mb.dwelling
	  AND mb.dwelling > 0
), row_nums as (
    SELECT *, row_number() OVER (PARTITION BY mb_2016_code ORDER BY random()) as row_num
    FROM adr
)
SELECT gnaf_pid,
	   mb_2016_code,
	   address_count,
	   dwelling,
	   person,
	   'too many addresses'::text as dwelling_count_type,
	   geom
FROM row_nums
WHERE row_num <= dwelling
ORDER BY mb_2016_code,
         row_num
;

ANALYSE testing.address_principals_dwelling;

--    2. where address count is less than dwelling count
INSERT INTO testing.address_principals_dwelling
WITH adr AS (
	SELECT gnaf.gnaf_pid,
           gnaf.mb_2016_code,
	       mb.dwelling,
	       mb.person,
           mb.address_count,
           gnaf.geom,
		   generate_series(1, ceiling(mb.dwelling::float / mb.address_count::float)::integer) as duplicate_number
	FROM gnaf_202002.address_principals as gnaf
	INNER JOIN testing.mb_2016_counts AS mb on gnaf.mb_2016_code = mb.mb_2016_code
	WHERE mb.address_count < mb.dwelling
), row_nums as (
    SELECT *, row_number() OVER (PARTITION BY mb_2016_code ORDER BY duplicate_number, random()) as row_num
    FROM adr
)
SELECT gnaf_pid,
	   mb_2016_code,
	   address_count,
	   dwelling,
	   person,
	   'too few addresses' as dwelling_count_type,
	   geom
FROM row_nums
WHERE row_num <= dwelling
ORDER BY mb_2016_code,
         row_num
;

ANALYSE testing.address_principals_dwelling;

--   3. add random points in meshblocks that have no addresses (8,903 dwellings affected)
INSERT INTO testing.address_principals_dwelling
SELECT 'MB' || mb_2016_code::text || '_' || (row_number() OVER ())::text as gnaf_pid,
	   mb_2016_code,
	   address_count,
	   dwelling,
	   person,
	   'no addresses' as dwelling_count_type,
	   ST_RandomPointsInPolygon(geom, dwelling) as geom
FROM testing.mb_2016_counts
WHERE geom is not null
AND address_count = 0
AND dwelling > 0
;

ANALYSE testing.address_principals_dwelling;


CREATE INDEX basic_address_principals_dwelling_geom_idx ON testing.address_principals_dwelling USING gist (geom);
ALTER TABLE testing.address_principals_dwelling CLUSTER ON basic_address_principals_dwelling_geom_idx;

CREATE INDEX basic_address_principals_dwelling_mb_2016_code_idx ON testing.address_principals_dwelling USING btree(mb_2016_code);


-- create an address accurate population map of Australia
-- get the correct number of addresses from GNAF for each meshblock, based on population -- 23 mins

--    1. where dwellings are greater than population
DROP TABLE IF EXISTS testing.address_principals_persons;
CREATE TABLE testing.address_principals_persons AS
WITH adr AS (
	SELECT gnaf.gnaf_pid,
           gnaf.mb_2016_code,
	       mb.dwelling,
	       mb.person,
           mb.address_count,
           gnaf.geom
	FROM testing.address_principals_dwelling as gnaf
	INNER JOIN testing.mb_2016_counts AS mb on gnaf.mb_2016_code = mb.mb_2016_code
	WHERE mb.dwelling >= mb.person
	  AND mb.dwelling > 0
), row_nums as (
    SELECT *, row_number() OVER (PARTITION BY mb_2016_code ORDER BY random()) as row_num
    FROM adr
)
SELECT gnaf_pid,
	   mb_2016_code,
	   address_count,
	   dwelling,
	   person,
	   'too many dwellings'::text as person_count_type,
	   geom
FROM row_nums
WHERE row_num <= person
ORDER BY mb_2016_code,
         row_num
;

ANALYSE testing.address_principals_persons;

--    2. where dwelling count is less than population (in other words - multiple people live at each address)
INSERT INTO testing.address_principals_persons
WITH adr AS (
	SELECT gnaf.gnaf_pid,
           gnaf.mb_2016_code,
	       mb.dwelling,
	       mb.person,
           mb.address_count,
           gnaf.geom,
		   generate_series(1, ceiling(mb.person::float / mb.dwelling::float)::integer) as duplicate_number
	FROM testing.address_principals_dwelling as gnaf
	INNER JOIN testing.mb_2016_counts AS mb on gnaf.mb_2016_code = mb.mb_2016_code
	WHERE mb.dwelling < mb.person
), row_nums as (
    SELECT *, row_number() OVER (PARTITION BY mb_2016_code ORDER BY duplicate_number, random()) as row_num
    FROM adr
)
SELECT gnaf_pid,
	   mb_2016_code,
	   address_count,
	   dwelling,
	   person,
	   'too few dwellings' as person_count_type,
	   geom
FROM row_nums
WHERE row_num <= person
ORDER BY mb_2016_code,
         row_num
;

ANALYSE testing.address_principals_persons;

--    3. where dwellings = 0 and addresses are greater than population
INSERT INTO testing.address_principals_persons
WITH adr AS (
	SELECT gnaf.gnaf_pid,
           gnaf.mb_2016_code,
	       mb.dwelling,
	       mb.person,
           mb.address_count,
           gnaf.geom
	FROM gnaf_202002.address_principals as gnaf
	INNER JOIN testing.mb_2016_counts AS mb on gnaf.mb_2016_code = mb.mb_2016_code
	WHERE mb.address_count >= mb.person
	  AND mb.dwelling = 0
), row_nums as (
    SELECT *, row_number() OVER (PARTITION BY mb_2016_code ORDER BY random()) as row_num
    FROM adr
)
SELECT gnaf_pid,
	   mb_2016_code,
	   address_count,
	   dwelling,
	   person,
	   'too many addresses'::text as person_count_type,
	   geom
FROM row_nums
WHERE row_num <= person
ORDER BY mb_2016_code,
         row_num
;

ANALYSE testing.address_principals_persons;

--    4. where dwellings = 0 and addresses are less than population
INSERT INTO testing.address_principals_persons
WITH adr AS (
	SELECT gnaf.gnaf_pid,
           gnaf.mb_2016_code,
	       mb.dwelling,
	       mb.person,
           mb.address_count,
           gnaf.geom,
		   generate_series(1, ceiling(mb.person::float / mb.address_count::float)::integer) as duplicate_number
	FROM gnaf_202002.address_principals as gnaf
	INNER JOIN testing.mb_2016_counts AS mb on gnaf.mb_2016_code = mb.mb_2016_code
	WHERE mb.address_count < mb.person
	  AND mb.dwelling = 0
), row_nums as (
    SELECT *, row_number() OVER (PARTITION BY mb_2016_code ORDER BY duplicate_number, random()) as row_num
    FROM adr
)
SELECT gnaf_pid,
	   mb_2016_code,
	   address_count,
	   dwelling,
	   person,
	   'too few addresses' as person_count_type,
	   geom
FROM row_nums
WHERE row_num <= person
ORDER BY mb_2016_code,
         row_num
;

ANALYSE testing.address_principals_persons;

--   5. add random points in meshblocks that have no addresses (8,903 dwellings affected)
INSERT INTO testing.address_principals_persons
SELECT 'MB' || mb_2016_code::text || '_' || (row_number() OVER ())::text as gnaf_pid,
	   mb_2016_code,
	   address_count,
	   dwelling,
	   person,
	   'no addresses' as dwelling_count_type,
	   ST_RandomPointsInPolygon(geom, person) as geom
FROM testing.mb_2016_counts
WHERE geom is not null
AND address_count = 0
AND dwelling = 0
AND person > 0
;

ANALYSE testing.address_principals_persons;

CREATE INDEX basic_address_principals_persons_geom_idx ON testing.address_principals_persons USING gist (geom);
ALTER TABLE testing.address_principals_persons CLUSTER ON basic_address_principals_persons_geom_idx;

CREATE INDEX basic_address_principals_persons_mb_2016_code_idx ON testing.address_principals_persons USING btree(mb_2016_code);


-- QA

-- check dwelling counts by meshblock -- all good!
select sum(dwelling) from testing.mb_2016_counts where geom is not null; -- 9913151
select sum(dwelling) from testing.mb_2016_counts where geom is null; -- 286
select count(*) from testing.address_principals_dwelling; -- 9913151

select * from testing.mb_2016_counts
where mb_2016_code NOT IN (select distinct mb_2016_code from testing.address_principals_dwelling)
and geom is not null
and dwelling > 0;

with gnaf as (
	select  mb_2016_code, count(*) as dwelling from testing.address_principals_dwelling group by mb_2016_code
)
select mb.* from testing.mb_2016_counts as mb
inner join gnaf on mb.mb_2016_code = gnaf.mb_2016_code
and mb.dwelling <> gnaf.dwelling;

-- check population counts by meshblock -- all good!
select sum(person) from testing.mb_2016_counts where geom is not null; -- 23351637
select sum(person) from testing.mb_2016_counts where geom is null; -- 46354
select count(*) from testing.address_principals_persons; -- 23351637

select * from testing.mb_2016_counts
where mb_2016_code NOT IN (select distinct mb_2016_code from testing.address_principals_persons)
and geom is not null
and person > 0
;

with gnaf as (
	select  mb_2016_code, count(*) as person from testing.address_principals_persons group by mb_2016_code
)
select mb.* from testing.mb_2016_counts as mb
inner join gnaf on mb.mb_2016_code = gnaf.mb_2016_code
and mb.person <> gnaf.person;


-- TO DO
-- create a table of random points per person based on meshblocks




-- testing

---- 32509 MBs with less addresses than dwellings
--SELECT count(*) as cnt,
--       avg(dwelling - address_count),
--	   max(dwelling - address_count)
--FROM testing.mb_2016_counts
--WHERE address_count < dwelling;
--
--select *, dwelling - address_count as extra_dwellings
--FROM testing.mb_2016_counts
--WHERE address_count < dwelling
--order by extra_dwellings desc;

-- -- 269858 MBs with more addresses than dwellings
-- SELECT count(*) FROM testing.mb_2016_counts
-- WHERE address_count > dwelling;

-- -- 15363 MBs with the same address count as dwellings
-- SELECT count(*) FROM testing.mb_2016_counts
-- WHERE address_count = dwelling;


---- 8484 MBs with less population than dwellings
--SELECT count(*) as cnt,
--       avg(dwelling - person),
--	   max(dwelling - person)
--FROM testing.mb_2016_counts
--WHERE person < dwelling;
--
--select *, dwelling - person as extra_dwellings
--FROM testing.mb_2016_counts
--WHERE person < dwelling
--order by extra_dwellings desc;
