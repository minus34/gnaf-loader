
-- Create temp table of CE - postcode/state combinations
DROP TABLE IF EXISTS temp_pc_ce;
SELECT state, ce_name, postcode, cnt, 'N'::char(1) as max
  INTO TEMPORARY temp_pc_ce
  FROM (
  SELECT Count(*) as cnt, postcode, state, ce_name FROM gnaf.address_admin_boundaries WHERE ce_name IS NOT NULL GROUP BY postcode, state, ce_name
) as sqt
ORDER BY postcode, state, ce_name;

--Fix state differences between CEs and the state bdys
UPDATE temp_pc_ce SET state = 'ACT' WHERE ce_name = 'FENNER';
UPDATE temp_pc_ce SET state = 'NT' WHERE ce_name = 'LINGIARI';

-- Flag the records that have the max address counts for each postcode - these are the postcodes we'll assign to the CEs
UPDATE temp_pc_ce as tmp
  SET max = 'Y'
  FROM (
    SELECT state, postcode, max(cnt) AS cnt FROM temp_pc_ce GROUP BY state, postcode
  ) as sqt
  WHERE sqt.state = tmp.state
  AND sqt.postcode = tmp.postcode
  AND sqt.cnt = tmp.cnt;

-- Delete unwanted records
DELETE FROM temp_pc_ce WHERE max = 'N';

-- create results table
DROP TABLE IF EXISTS admin_bdys.commonwealth_electorate_postcode_lookup;
SELECT postcode, state, ce_name
  INTO admin_bdys.commonwealth_electorate_postcode_lookup
FROM temp_pc_ce ORDER BY state, postcode

ALTER TABLE admin_bdys.commonwealth_electorate_postcode_lookup ADD PRIMARY KEY (postcode, state);

DROP TABLE temp_pc_ce;

-- Output the result
COPY admin_bdys.commonwealth_electorate_postcode_lookup TO 'C:\temp\psma_201605\ce-pc.csv' CSV HEADER;

SELECT * FROM admin_bdys.commonwealth_electorate_postcode_lookup;






--SELECT Count(*) as cnt, postcode, state FROM gnaf.address_admin_boundaries WHERE postcode IS NOT NULL GROUP BY postcode, state ORDER BY postcode, state; -- 2669

-- SELECT Count(*) as cnt, postcode, state FROM gnaf.address_admin_boundaries GROUP BY postcode, state; -- 2669
-- 
-- SELECT Count(*) as cnt, ce_name FROM gnaf.address_admin_boundaries GROUP BY ce_name; -- 151, including NULL
-- 
-- SELECT Count(*) as cnt, adr.postcode, adr.state, adr.ce_name, ce.state FROM gnaf.address_admin_boundaries as adr
-- INNER JOIN admin_bdys.commonwealth_electorates AS ce ON adr.ce_name = ce.name
-- WHERE adr.state <> ce.state
-- GROUP BY adr.postcode, adr.state, adr.ce_name, ce.state;
-- 
-- 
-- select * from gnaf.address_admin_boundaries where postcode = '6798';