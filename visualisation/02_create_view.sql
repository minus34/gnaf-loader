DROP VIEW IF EXISTS gnaf_202108.vw_temp_address_principals;
CREATE VIEW gnaf_202108.vw_temp_address_principals AS
SELECT gid,
       longitude AS x,
       latitude AS y
FROM gnaf_202108.address_principals;

