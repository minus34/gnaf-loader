DROP TABLE IF EXISTS raw_gnaf.locality_pid_linkage_distinct;
CREATE TABLE raw_gnaf.locality_pid_linkage_distinct AS
SELECT DISTINCT locality_pid,
                ab_locality_pid AS old_locality_pid,
                state
FROM raw_gnaf.locality_pid_linkage;

-- get rid of the one 2 into 1 locality_pid change (WOOROONOORAN, QLD 4860). No addresses impacted
DELETE FROM raw_gnaf.locality_pid_linkage_distinct
where locality_pid = 'loc1cbcbc887cf5'
  AND old_locality_pid = 'QLD3352';

ALTER TABLE ONLY raw_gnaf.locality_pid_linkage_distinct
    ADD CONSTRAINT locality_pid_linkage_distinct_pk PRIMARY KEY (locality_pid);
