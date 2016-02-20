
-- merge locality bdys into postcodes -- 15 mins
INSERT INTO admin_bdys.postcode_boundaries (postcode, state, address_count, geom)
SELECT postcode,
       state,
       SUM(address_count),
       ST_Multi(ST_Buffer(ST_Union(ST_Buffer(geom, 0.0000001)), -0.0000001))
  FROM admin_bdys.localities
  GROUP BY postcode,
           state;
