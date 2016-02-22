
-- main insert
INSERT INTO gnaf.street_aliases (street_locality_pid, alias_street_name, alias_street_type, alias_street_suffix, full_alias_street_name)
SELECT DISTINCT str.street_locality_pid,
       str.street_name,
       str.street_type_code AS street_type,
       suf.name AS street_suffix,
       str.street_name ||
       CASE WHEN str.street_type_code IS NOT NULL
         THEN ' ' ||  str.street_type_code
         ELSE '' END ||
       CASE WHEN suf.name IS NOT NULL
         THEN ' ' || suf.name
         ELSE '' END AS full_street_name
  FROM raw_gnaf.street_locality_alias AS str
  INNER JOIN raw_gnaf.street_locality_alias_type_aut AS aut ON str.alias_type_code = aut.code
  LEFT OUTER JOIN raw_gnaf.street_type_aut AS typ ON str.street_type_code = typ.code
  LEFT OUTER JOIN raw_gnaf.street_suffix_aut AS suf ON str.street_suffix_code = suf.code;


-- update alias_type -- need to update after the insert as there are duplicates caused by 2 identical alias records with different alias_types!
UPDATE gnaf.street_aliases AS als
  SET alias_type = aut.name
  FROM raw_gnaf.street_locality_alias AS str,
  raw_gnaf.street_locality_alias_type_aut AS aut
  WHERE als.street_locality_pid = str.street_locality_pid
  AND als.alias_street_name = str.street_name
  AND str.alias_type_code = aut.code;