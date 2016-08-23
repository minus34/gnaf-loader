
-- principals insert
INSERT INTO gnaf.address_principals(
            gnaf_pid, street_locality_pid, locality_pid, alias_principal, 
            primary_secondary, building_name, lot_number, flat_number, level_number, 
            number_first, number_last, street_name, street_type, street_suffix, address,
            locality_name, postcode, state, locality_postcode, confidence, 
            legal_parcel_id, mb_2011_code, mb_2016_code, latitude, longitude, geocode_type, reliability,
            geom)
SELECT adr.gnaf_pid,
       adr.street_locality_pid,
       adr.locality_pid,
       adr.alias_principal,
       adr.primary_secondary,
       adr.building_name,
       adr.lot_number,
       adr.flat_number,
       adr.level_number,
       adr.number_first,
       adr.number_last,
       adr.street_name,
       adr.street_type,
       adr.street_suffix,
       CASE WHEN adr.flat_number IS NOT NULL THEN adr.flat_number || ', ' ELSE '' END ||
       CASE WHEN adr.level_number IS NOT NULL THEN adr.level_number || ', ' ELSE '' END ||
       CASE WHEN adr.number_first IS NOT NULL THEN adr.number_first ||
         CASE WHEN adr.number_last IS NOT NULL THEN '-' || adr.number_last || ' ' ELSE ' ' END
         ELSE
           CASE WHEN adr.lot_number IS NOT NULL
             THEN 'LOT ' || adr.lot_number || ' '
             ELSE '' END
         END ||
       adr.street_name ||
       CASE WHEN adr.street_type IS NOT NULL
         THEN ' ' || adr.street_type
         ELSE '' END ||
       CASE WHEN adr.street_suffix IS NOT NULL
         THEN ' ' || adr.street_suffix
         ELSE '' END AS address,
       loc.locality_name,
       adr.postcode,
       loc.state,
       loc.postcode AS locality_postcode,
       adr.confidence,
       adr.legal_parcel_id,
       adr.mb_2011_code,
       adr.mb_2016_code,
       adr.latitude,
       adr.longitude,
       adr.geocode_type,
       CASE
         WHEN adr.geocode_type = 'LOCALITY' THEN loc.reliability
         ELSE adr.reliability
       END AS reliability,
       adr.geom
  FROM gnaf.temp_addresses AS adr
  INNER JOIN gnaf.localities AS loc ON adr.locality_pid = loc.locality_pid
  WHERE adr.alias_principal = 'P';


-- aliases insert
INSERT INTO gnaf.address_aliases(
            gnaf_pid, street_locality_pid, locality_pid, alias_principal, 
            primary_secondary, building_name, lot_number, flat_number, level_number, 
            number_first, number_last, street_name, street_type, street_suffix, address,
            locality_name, postcode, state, locality_postcode, confidence, 
            legal_parcel_id, mb_2011_code, mb_2016_code, latitude, longitude, geocode_type, reliability,
            geom)
SELECT adr.gnaf_pid,
       adr.street_locality_pid,
       adr.locality_pid,
       adr.alias_principal,
       adr.primary_secondary,
       adr.building_name,
       adr.lot_number,
       adr.flat_number,
       adr.level_number,
       adr.number_first,
       adr.number_last,
       adr.street_name,
       adr.street_type,
       adr.street_suffix,
       CASE WHEN adr.flat_number IS NOT NULL THEN adr.flat_number || ', ' ELSE '' END ||
       CASE WHEN adr.level_number IS NOT NULL THEN adr.level_number || ', ' ELSE '' END ||
       CASE WHEN adr.number_first IS NOT NULL THEN adr.number_first ||
         CASE WHEN adr.number_last IS NOT NULL THEN '-' || adr.number_last || ' ' ELSE ' ' END
         ELSE
           CASE WHEN adr.lot_number IS NOT NULL
             THEN 'LOT ' || adr.lot_number || ' '
             ELSE '' END
         END ||
       adr.street_name ||
       CASE WHEN adr.street_type IS NOT NULL
         THEN ' ' || adr.street_type
         ELSE '' END ||
       CASE WHEN adr.street_suffix IS NOT NULL
         THEN ' ' || adr.street_suffix
         ELSE '' END AS address,
       loc.locality_name,
       adr.postcode,
       loc.state,
       loc.postcode AS locality_postcode,
       adr.confidence,
       adr.legal_parcel_id,
       adr.mb_2011_code,
       adr.mb_2016_code,
       adr.latitude,
       adr.longitude,
       adr.geocode_type,
       CASE
         WHEN adr.geocode_type = 'LOCALITY' THEN loc.reliability
         ELSE adr.reliability
       END AS reliability,
       adr.geom
  FROM gnaf.temp_addresses AS adr
  INNER JOIN gnaf.localities AS loc ON adr.locality_pid = loc.locality_pid
  WHERE adr.alias_principal = 'A';