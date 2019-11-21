
-- Import MB counts CSV file
DROP TABLE IF EXISTS testing.mb_2016_counts;
CREATE TABLE testing.mb_2016_counts (
    mb_2016_code bigint,
    mb_category_name_2016 text,
    area_albers_sqkm double precision,
    dwelling integer,
    person integer,
	address_count integer,
    state smallint,
    CONSTRAINT abs_2011_mb_pk PRIMARY KEY (mb_2016_code)
);

COPY testing.mb_2016_counts (mb_2016_code, mb_category_name_2016, area_albers_sqkm, dwelling, person, state)
FROM '/Users/hugh.saalmans/Downloads/2016 census mesh block counts.csv' WITH (FORMAT CSV, HEADER);


-- Get address counts per MB
WITH counts AS (
	SELECT mb_2016_code,
		   count(*) AS address_count
	FROM gnaf_201911.address_principals
	GROUP BY mb_2016_code
)
UPDATE testing.mb_2016_counts AS mb
  SET address_count = counts.address_count
  FROM counts
  WHERE mb.mb_2016_code = counts.mb_2016_code
;

SELECT * FROM testing.mb_2016_counts
WHERE person > 0
limit 100;

