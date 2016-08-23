
-- insert into unlogged table (as this is step 1 of 2 to create the flattened address table)
INSERT INTO gnaf.temp_addresses (gnaf_pid, street_locality_pid, locality_pid, alias_principal, 
                                 primary_secondary, building_name, lot_number, flat_number, level_number, 
                                 number_first, number_last, street_name, street_type, street_suffix, 
                                 postcode, confidence, legal_parcel_id, mb_2011_code, mb_2016_code, latitude,
                                 longitude, geocode_type, reliability, geom)
SELECT adr.address_detail_pid AS gnaf_pid,
       adr.street_locality_pid,
       adr.locality_pid,
       adr.alias_principal,
       adr.primary_secondary,
       adr.building_name,
       CASE WHEN TRIM(COALESCE(adr.lot_number_prefix,'') || COALESCE(adr.lot_number,'') || COALESCE(adr.lot_number_suffix,'')) <> ''
         THEN TRIM(COALESCE(adr.lot_number_prefix,'') || COALESCE(adr.lot_number,'') || COALESCE(adr.lot_number_suffix,''))
         ELSE NULL
       END AS lot_number,
       CASE WHEN TRIM(COALESCE(flt.name,'') || ' ' || COALESCE(adr.flat_number_prefix,'') || COALESCE(adr.flat_number::text,'') || COALESCE(adr.flat_number_suffix,'')) <> ''
         THEN TRIM(COALESCE(flt.name,'') || ' ' || COALESCE(adr.flat_number_prefix,'') || COALESCE(adr.flat_number::text,'') || COALESCE(adr.flat_number_suffix,''))
         ELSE NULL
       END AS flat_number,
       CASE WHEN TRIM(COALESCE(lvl.name,'') || ' ' || COALESCE(adr.level_number_prefix,'') || COALESCE(adr.level_number::text,'') || COALESCE(adr.level_number_suffix,'')) <> ''
         THEN TRIM(COALESCE(lvl.name,'') || ' ' || COALESCE(adr.level_number_prefix,'') || COALESCE(adr.level_number::text,'') || COALESCE(adr.level_number_suffix,''))
         ELSE NULL
       END AS level_number,
       CASE WHEN TRIM(COALESCE(adr.number_first_prefix,'') || COALESCE(adr.number_first::text,'') || COALESCE(adr.number_first_suffix,'')) <> ''
         THEN TRIM(COALESCE(adr.number_first_prefix,'') || COALESCE(adr.number_first::text,'') || COALESCE(adr.number_first_suffix,''))
         ELSE NULL
       END AS number_first,
       CASE WHEN TRIM(COALESCE(adr.number_last_prefix,'') || COALESCE(adr.number_last::text,'') || COALESCE(adr.number_last_suffix,'')) <> ''
         THEN TRIM(COALESCE(adr.number_last_prefix,'') || COALESCE(adr.number_last::text,'') || COALESCE(adr.number_last_suffix,''))
         ELSE NULL
       END AS number_last,
       str.street_name,
       str.street_type,
       str.street_suffix,
       adr.postcode,
       adr.confidence::smallint,
       adr.legal_parcel_id,
       mb11.mb_2011_code::bigint,
       mb16.mb_2016_code::bigint,
       pnt.latitude,
       pnt.longitude,
       gty.name AS geocode_type,
       CASE
         WHEN gty.name = 'GAP GEOCODE' THEN 3
         WHEN gty.name = 'STREET LOCALITY' THEN 4
         WHEN gty.name = 'LOCALITY' THEN 5
         ELSE 2
       END AS reliability,
       st_setsrid(st_makepoint(pnt.longitude, pnt.latitude), 4283) AS geom
  FROM raw_gnaf.address_detail AS adr
  INNER JOIN gnaf.streets AS str ON adr.street_locality_pid = str.street_locality_pid
  INNER JOIN raw_gnaf.address_default_geocode as pnt ON adr.address_detail_pid = pnt.address_detail_pid
  LEFT OUTER JOIN raw_gnaf.geocode_type_aut AS gty ON pnt.geocode_type_code = gty.code
  LEFT OUTER JOIN raw_gnaf.flat_type_aut AS flt ON adr.flat_type_code = flt.code
  LEFT OUTER JOIN raw_gnaf.level_type_aut AS lvl ON adr.level_type_code = lvl.code
  LEFT OUTER JOIN (
  SELECT mb1.address_detail_pid, mb2.mb_2011_code
    FROM raw_gnaf.address_mesh_block_2011 AS mb1
    INNER JOIN raw_gnaf.mb_2011 AS mb2 ON mb1.mb_2011_pid = mb2.mb_2011_pid
  ) AS mb11 ON adr.address_detail_pid = mb11.address_detail_pid
  LEFT OUTER JOIN (
  SELECT mb1.address_detail_pid, mb2.mb_2016_code
    FROM raw_gnaf.address_mesh_block_2016 AS mb1
    INNER JOIN raw_gnaf.mb_2016 AS mb2 ON mb1.mb_2016_pid = mb2.mb_2016_pid
  ) AS mb16 ON adr.address_detail_pid = mb16.address_detail_pid
  WHERE adr.confidence > -1;