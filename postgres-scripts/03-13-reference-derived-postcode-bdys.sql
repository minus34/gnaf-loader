INSERT INTO admin_bdys.postcode_bdys (postcode, state, address_count, street_count, geom)
SELECT postcode,
       state,
       SUM(address_count),
       SUM(street_count),
       ST_Multi(ST_Buffer(ST_Union(ST_Buffer(geom, 0.0000001)), -0.0000001))
  FROM admin_bdys.locality_bdys
  GROUP BY postcode,
           state;