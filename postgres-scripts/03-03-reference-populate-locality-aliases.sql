
-- main insert
INSERT INTO gnaf.locality_aliases(locality_pid, locality_name, postcode, state, locality_alias_name, std_alias_name, unique_alias_state)
SELECT DISTINCT loc.locality_pid,
       loc.locality_name,
       loc.postcode,
       loc.state,
       als.name,
       '' AS std_alias_name,
       'N' AS unique_alias_state
FROM raw_gnaf.locality_alias AS als
INNER JOIN gnaf.localities AS loc ON als.locality_pid = loc.locality_pid
WHERE als.name <> loc.locality_name
ORDER BY loc.state,
         loc.locality_name,
         loc.postcode,
         als.name;


-- update alias_type -- need to update after the insert as there are duplicates caused by 2 identical alias records with different alias_types!
UPDATE gnaf.locality_aliases AS als
  SET alias_type = aut.name
  FROM raw_gnaf.locality_alias AS loc,
  raw_gnaf.locality_alias_type_aut AS aut
  WHERE als.locality_pid = loc.locality_pid
  AND als.locality_alias_name = loc.name
  AND loc.alias_type_code = aut.code;


-- standardise locality names to check for uniqueness
UPDATE gnaf.locality_aliases SET std_alias_name = REPLACE(locality_alias_name, '''','') WHERE POSITION('''' IN locality_alias_name) > 0;
UPDATE gnaf.locality_aliases SET std_alias_name = REPLACE(locality_alias_name, '-','') WHERE POSITION('-' IN locality_alias_name) > 0;
UPDATE gnaf.locality_aliases SET std_alias_name = REPLACE(locality_alias_name, '.','') WHERE POSITION('.' IN locality_alias_name) > 0;

UPDATE gnaf.locality_aliases SET std_alias_name = REPLACE(locality_alias_name, 'ST ','SAINT ') WHERE LEFT(locality_alias_name, 3) = 'ST ';
UPDATE gnaf.locality_aliases SET std_alias_name = REPLACE(locality_alias_name, ' ST ',' SAINT ') WHERE locality_alias_name LIKE '% ST %';

UPDATE gnaf.locality_aliases SET std_alias_name = 'EAST ' || LEFT(locality_alias_name, LENGTH(locality_alias_name) - 5) WHERE RIGHT(locality_alias_name, 5) = ' EAST';
UPDATE gnaf.locality_aliases SET std_alias_name = 'WEST ' || LEFT(locality_alias_name, LENGTH(locality_alias_name) - 5) WHERE RIGHT(locality_alias_name, 5) = ' WEST';
UPDATE gnaf.locality_aliases SET std_alias_name = 'NORTH ' || LEFT(locality_alias_name, LENGTH(locality_alias_name) - 6) WHERE RIGHT(locality_alias_name, 6) = ' NORTH';
UPDATE gnaf.locality_aliases SET std_alias_name = 'SOUTH ' || LEFT(locality_alias_name, LENGTH(locality_alias_name) - 6) WHERE RIGHT(locality_alias_name, 6) = ' SOUTH';
UPDATE gnaf.locality_aliases SET std_alias_name = 'UPPER ' || LEFT(locality_alias_name, LENGTH(locality_alias_name) - 6) WHERE RIGHT(locality_alias_name, 6) = ' UPPER';
UPDATE gnaf.locality_aliases SET std_alias_name = 'LOWER ' || LEFT(locality_alias_name, LENGTH(locality_alias_name) - 6) WHERE RIGHT(locality_alias_name, 6) = ' LOWER';
UPDATE gnaf.locality_aliases SET std_alias_name = 'CENTRAL ' || LEFT(locality_alias_name, LENGTH(locality_alias_name) - 8) WHERE RIGHT(locality_alias_name, 8) = ' CENTRAL';
UPDATE gnaf.locality_aliases SET std_alias_name = LEFT(locality_alias_name, LENGTH(locality_alias_name) - 5) WHERE RIGHT(locality_alias_name, 5) = ' CITY' AND locality_alias_name <> 'BRISBANE CITY';

-- update the leftovers to just their name
UPDATE gnaf.locality_aliases SET std_alias_name = locality_alias_name WHERE std_alias_name = ''; -- 15213

-- set unique locality/state combination flag -- 6933 rows
UPDATE gnaf.locality_aliases AS loc
	SET unique_alias_state = 'Y'
FROM (
	SELECT Count(*) AS cnt
	      ,std_alias_name
	      ,state
		FROM gnaf.locality_aliases
  	GROUP BY std_alias_name
	          ,state
) AS sqt2
WHERE loc.std_alias_name = sqt2.std_alias_name
AND loc.state = sqt2.state
AND sqt2.cnt = 1;
