-- Get partitions of equal record counts - numeric(8,4)
WITH cte AS (
    SELECT longitude AS partition_id FROM gnaf_202008.address_principals
)
SELECT
  MIN(partition_id) - 0.0001 AS part_01,
  percentile_cont(0.05) WITHIN GROUP (ORDER BY partition_id) AS part_02,
  percentile_cont(0.10) WITHIN GROUP (ORDER BY partition_id) AS part_03,
  percentile_cont(0.15) WITHIN GROUP (ORDER BY partition_id) AS part_04,
  percentile_cont(0.20) WITHIN GROUP (ORDER BY partition_id) AS part_05,
  percentile_cont(0.25) WITHIN GROUP (ORDER BY partition_id) AS part_06,
  percentile_cont(0.30) WITHIN GROUP (ORDER BY partition_id) AS part_07,
  percentile_cont(0.35) WITHIN GROUP (ORDER BY partition_id) AS part_08,
  percentile_cont(0.40) WITHIN GROUP (ORDER BY partition_id) AS part_09,
  percentile_cont(0.45) WITHIN GROUP (ORDER BY partition_id) AS part_10,
  percentile_cont(0.50) WITHIN GROUP (ORDER BY partition_id) AS part_11,
  percentile_cont(0.55) WITHIN GROUP (ORDER BY partition_id) AS part_12,
  percentile_cont(0.60) WITHIN GROUP (ORDER BY partition_id) AS part_13,
  percentile_cont(0.65) WITHIN GROUP (ORDER BY partition_id) AS part_14,
  percentile_cont(0.70) WITHIN GROUP (ORDER BY partition_id) AS part_15,
  percentile_cont(0.75) WITHIN GROUP (ORDER BY partition_id) AS part_16,
  percentile_cont(0.80) WITHIN GROUP (ORDER BY partition_id) AS part_17,
  percentile_cont(0.85) WITHIN GROUP (ORDER BY partition_id) AS part_18,
  percentile_cont(0.90) WITHIN GROUP (ORDER BY partition_id) AS part_19,
  percentile_cont(0.95) WITHIN GROUP (ORDER BY partition_id) AS part_20,
  MAX(partition_id) + 0.0001 AS part_21
FROM cte;




SELECT unnest(
  (select array_agg(fraction) from generate_series(0, 1, 0.05) AS fraction)
) as percentile,
unnest(
  (select percentile_cont((select array_agg(s) from generate_series(0, 1, 0.05) as s)) WITHIN GROUP (ORDER BY longitude) as longitude FROM gnaf_202008.address_principals)
) as value;