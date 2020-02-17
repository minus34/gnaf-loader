SELECT als.gnaf_pid, als.street_locality_pid, als.locality_pid, als.alias_principal,
       als.address, als.locality_name, als.postcode, als.state, als.latitude, als.longitude,
       als.geocode_type, als.reliability, gnaf.address, gnaf.locality_name, gnaf.postcode, gnaf.state, gnaf.latitude, gnaf.longitude,
       gnaf.geocode_type, gnaf.reliability,
       ST_Distance(
					ST_MakePoint(als.longitude, als.latitude)::geography,
					ST_MakePoint(gnaf.longitude, gnaf.latitude)::geography
				) as distance
  FROM gnaf_202002.address_aliases as als
  INNER JOIN gnaf_202002.address_alias_lookup as lkp on als.gnaf_pid = lkp.alias_pid
  INNER JOIN gnaf_202002.address_principals as gnaf on lkp.principal_pid = gnaf.gnaf_pid
  WHERE als.latitude <> gnaf.latitude
  OR als.longitude <> als.longitude
  order by ST_Distance(
					ST_MakePoint(als.longitude, als.latitude)::geography,
					ST_MakePoint(gnaf.longitude, gnaf.latitude)::geography
				) desc;
