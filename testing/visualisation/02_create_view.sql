--DROP TABLE IF EXISTS gnaf_202211.temp_address_principals;
--CREATE TABLE gnaf_202211.temp_address_principals AS

COPY (
	SELECT longitude AS x,
           latitude AS y
    FROM gnaf_202211.address_principals
) TO '/Users/hugh.saalmans/tmp/address_principals_point.csv' HEADER CSV;


--
--
--SELECT gid,
--       longitude AS x,
--       latitude AS y
--FROM gnaf_202211.address_principals;
--
--ALTER TABLE ONLY gnaf_202211.temp_address_principals
--    ADD CONSTRAINT temp_address_principals_pk PRIMARY KEY (gid);
