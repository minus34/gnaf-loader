
-- main insert -- 16385 rows
INSERT INTO gnaf.localities(locality_pid, locality_name, postcode, state, latitude, longitude, locality_class, reliability, geom)
SELECT loc.locality_pid,
       loc.locality_name,
       loc.primary_postcode AS postcode,
       st.state_abbreviation AS state,
       pnt.latitude,
	     pnt.longitude,
       aut.name AS locality_class,
       loc.gnaf_reliability_code,
	     st_setsrid(st_makepoint(pnt.longitude, pnt.latitude), 4283) AS geom
FROM raw_gnaf.locality AS loc
INNER JOIN raw_gnaf.state AS st ON loc.state_pid = st.state_pid
INNER JOIN raw_gnaf.locality_class_aut AS aut ON loc.locality_class_code = aut.code
LEFT OUTER JOIN raw_gnaf.locality_point AS pnt ON loc.locality_pid = pnt.locality_pid
ORDER BY st.state_abbreviation,
         loc.locality_name,
         loc.primary_postcode;

-- standardise locality names to check for uniqueness and for addres validation purposes
UPDATE gnaf.localities SET std_locality_name = REPLACE(locality_name, '''','') WHERE POSITION('''' IN locality_name) > 0;
UPDATE gnaf.localities SET std_locality_name = REPLACE(locality_name, '-','') WHERE POSITION('-' IN locality_name) > 0;
UPDATE gnaf.localities SET std_locality_name = REPLACE(locality_name, '.','') WHERE POSITION('.' IN locality_name) > 0;

UPDATE gnaf.localities SET std_locality_name = REPLACE(locality_name, 'ST ','SAINT ') WHERE LEFT(locality_name, 3) = 'ST ';
UPDATE gnaf.localities SET std_locality_name = REPLACE(locality_name, ' ST ',' SAINT ') WHERE locality_name LIKE '% ST %';

UPDATE gnaf.localities SET std_locality_name = 'EAST ' || LEFT(locality_name, LENGTH(locality_name) - 5) WHERE RIGHT(locality_name, 5) = ' EAST';
UPDATE gnaf.localities SET std_locality_name = 'WEST ' || LEFT(locality_name, LENGTH(locality_name) - 5) WHERE RIGHT(locality_name, 5) = ' WEST';
UPDATE gnaf.localities SET std_locality_name = 'NORTH ' || LEFT(locality_name, LENGTH(locality_name) - 6) WHERE RIGHT(locality_name, 6) = ' NORTH';
UPDATE gnaf.localities SET std_locality_name = 'SOUTH ' || LEFT(locality_name, LENGTH(locality_name) - 6) WHERE RIGHT(locality_name, 6) = ' SOUTH';
UPDATE gnaf.localities SET std_locality_name = 'UPPER ' || LEFT(locality_name, LENGTH(locality_name) - 6) WHERE RIGHT(locality_name, 6) = ' UPPER';
UPDATE gnaf.localities SET std_locality_name = 'LOWER ' || LEFT(locality_name, LENGTH(locality_name) - 6) WHERE RIGHT(locality_name, 6) = ' LOWER';
UPDATE gnaf.localities SET std_locality_name = 'CENTRAL ' || LEFT(locality_name, LENGTH(locality_name) - 8) WHERE RIGHT(locality_name, 8) = ' CENTRAL';
UPDATE gnaf.localities SET std_locality_name = LEFT(locality_name, LENGTH(locality_name) - 5) WHERE RIGHT(locality_name, 5) = ' CITY' AND locality_name <> 'BRISBANE CITY';

-- update the leftovers to just their name
UPDATE gnaf.localities SET std_locality_name = locality_name WHERE std_locality_name = ''; -- 15213

-- set unique locality/state combination flag -- 15453 rows
UPDATE gnaf.localities AS loc
	SET unique_locality_state = 'Y'
FROM (
	SELECT Count(*) AS cnt
	      ,std_locality_name
	      ,state
		FROM gnaf.localities
  	GROUP BY std_locality_name,
	           state
) AS sqt2
WHERE loc.std_locality_name = sqt2.std_locality_name
AND loc.state = sqt2.state
AND sqt2.cnt = 1;
