INSERT INTO gnaf.address_secondary_lookup
SELECT ps.primary_pid, ps.secondary_pid, aut.name AS join_type
  FROM raw_gnaf.primary_secondary AS ps
  INNER JOIN raw_gnaf.ps_join_type_aut AS aut ON ps.ps_join_type_code = aut.code;
  
DELETE FROM gnaf.address_secondary_lookup AS als
  USING raw_gnaf.address_detail AS adr
  WHERE als.primary_pid = adr.address_detail_pid AND adr.confidence = -1;
  
DELETE FROM gnaf.address_secondary_lookup AS als
  USING raw_gnaf.address_detail AS adr
  WHERE als.secondary_pid = adr.address_detail_pid AND adr.confidence = -1;
