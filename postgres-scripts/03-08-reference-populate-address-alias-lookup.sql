INSERT INTO gnaf.address_alias_lookup
SELECT aa.principal_pid, aa.alias_pid, aut.name AS join_type
  FROM raw_gnaf.address_alias AS aa
  INNER JOIN gnaf.temp_addresses AS adr ON aa.alias_pid = adr.gnaf_pid
  INNER JOIN gnaf.temp_addresses AS adr2 ON aa.principal_pid = adr2.gnaf_pid
  INNER JOIN raw_gnaf.address_alias_type_aut AS aut ON aa.alias_type_code = aut.code
  WHERE adr2.alias_principal = 'P'; -- GNAF 2015-11, there are 23 aliases that are listed as principals in the raw_gnaf.address_alias - these need to be excluded