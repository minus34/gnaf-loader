
-- main insert -- 684781 rows
INSERT INTO gnaf.streets (street_locality_pid, locality_pid, street_name, street_type, street_suffix, full_street_name, locality_name, postcode, state, street_type_abbrev, street_suffix_abbrev, street_class, latitude, longitude, geom)
SELECT str.street_locality_pid,
       str.locality_pid,
       str.street_name,
       str.street_type_code AS street_type,
       suf.name AS street_suffix,
       str.street_name ||
       CASE WHEN str.street_type_code IS NOT NULL
         THEN ' ' ||  str.street_type_code
         ELSE '' END ||
       CASE WHEN suf.name IS NOT NULL
         THEN ' ' || suf.name
         ELSE '' END AS full_street_name,
       loc.locality_name,
       loc.postcode,
       loc.state,
       typ.name AS street_type_abbrev,
       str.street_suffix_code AS street_suffix_abbrev,
       cls.name AS street_class,
       pnt.latitude,
	     pnt.longitude,
	     st_setsrid(st_makepoint(pnt.longitude, pnt.latitude), 4283) AS geom
  FROM raw_gnaf.street_locality AS str
  LEFT OUTER JOIN raw_gnaf.street_locality_point AS pnt ON str.street_locality_pid = pnt.street_locality_pid
  LEFT OUTER JOIN gnaf.localities AS loc ON str.locality_pid = loc.locality_pid
  LEFT OUTER JOIN raw_gnaf.street_type_aut AS typ ON str.street_type_code = typ.code
  LEFT OUTER JOIN raw_gnaf.street_suffix_aut AS suf ON str.street_suffix_code = suf.code
  LEFT OUTER JOIN raw_gnaf.street_class_aut AS cls ON str.street_class_code = cls.code;

---------------------------------------------------------------------------------------------------------
-- update stats, add an index & primary key for integrity and to speed up creation of addresses table
---------------------------------------------------------------------------------------------------------

ANALYZE gnaf.streets;

ALTER TABLE ONLY gnaf.streets ADD CONSTRAINT streets_pk PRIMARY KEY (street_locality_pid);

CREATE UNIQUE INDEX streets_gid_idx ON gnaf.streets USING btree (gid);

