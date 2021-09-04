
-- -- sample sql to get the table list from a schema
-- SELECT 'DROP TABLE IF EXISTS ' ||table_schema || '.' || table_name || ' CASCADE;'
--   FROM information_schema.tables
--   WHERE table_schema = 'admin_bdys'
--   ORDER BY table_name;


-- raw gnaf tables
DROP TABLE IF EXISTS raw_gnaf.street_locality_point CASCADE;
DROP TABLE IF EXISTS raw_gnaf.primary_secondary CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_site_geocode CASCADE;
DROP TABLE IF EXISTS raw_gnaf.locality_alias CASCADE;
DROP TABLE IF EXISTS raw_gnaf.locality_point CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_mesh_block_2011 CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_mesh_block_2016 CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_alias CASCADE;
DROP TABLE IF EXISTS raw_gnaf.locality_neighbour CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_default_geocode CASCADE;
DROP TABLE IF EXISTS raw_gnaf.street_locality_alias CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_detail CASCADE;
DROP TABLE IF EXISTS raw_gnaf.mb_match_code_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.mb_2011 CASCADE;
DROP TABLE IF EXISTS raw_gnaf.mb_2016 CASCADE;
DROP TABLE IF EXISTS raw_gnaf.street_locality_alias_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.locality_alias_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.geocode_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_alias_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.ps_join_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.geocoded_level_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.street_locality CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_site CASCADE;
DROP TABLE IF EXISTS raw_gnaf.level_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.flat_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.street_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.locality CASCADE;
DROP TABLE IF EXISTS raw_gnaf.street_class_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.street_suffix_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_type_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.locality_class_aut CASCADE;
DROP TABLE IF EXISTS raw_gnaf.state CASCADE;
DROP TABLE IF EXISTS raw_gnaf.geocode_reliability_aut CASCADE;
-- new for August 2018
DROP TABLE IF EXISTS raw_gnaf.address_feature CASCADE;
DROP TABLE IF EXISTS raw_gnaf.address_change_type_aut CASCADE;
-- new for August 2021
DROP TABLE IF EXISTS raw_gnaf.address_mesh_block_2021 CASCADE;
DROP TABLE IF EXISTS raw_gnaf.mb_2021 CASCADE;
DROP TABLE IF EXISTS raw_gnaf.locality_pid_linkage CASCADE;

---- drop raw admin boundaries - bit of a who cares...
--DROP TABLE IF EXISTS raw_admin_bdys.aus_comm_electoral CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_comm_electoral_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_gccsa_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_gccsa_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_iare_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_iare_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_iloc_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_iloc_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_ireg_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_ireg_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_lga CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_lga_locality CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_lga_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_locality CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_locality_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_locality_town CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2016 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2016_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_remoteness_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_remoteness_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sa1_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sa1_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sa2_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sa2_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sa3_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sa3_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sa4_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sa4_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_seifa_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sos_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sos_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sosr_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sosr_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_state CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_state_electoral CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_state_electoral_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_state_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sua_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_sua_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_town CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_town_point CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_ucl_2011 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_ucl_2011_polygon CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_ward CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_ward_polygon CASCADE;
---- new for August 2021
--DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2021 CASCADE;
--DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2021_polygon CASCADE;

-- drop reference gnaf
DROP TABLE IF EXISTS gnaf.address_alias_lookup CASCADE;
DROP TABLE IF EXISTS gnaf.address_boundary_tags CASCADE;
DROP TABLE IF EXISTS gnaf.address_secondary_lookup CASCADE;
DROP TABLE IF EXISTS gnaf.address_principals CASCADE;
DROP TABLE IF EXISTS gnaf.address_aliases CASCADE;
DROP TABLE IF EXISTS gnaf.localities CASCADE;
DROP TABLE IF EXISTS gnaf.locality_aliases CASCADE;
DROP TABLE IF EXISTS gnaf.locality_neighbour_lookup CASCADE;
DROP TABLE IF EXISTS gnaf.streets CASCADE;

-- drop reference admin boundaries
DROP TABLE IF EXISTS admin_bdys.commonwealth_electorates CASCADE;
DROP TABLE IF EXISTS admin_bdys.commonwealth_electorates_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.local_government_areas CASCADE;
DROP TABLE IF EXISTS admin_bdys.local_government_areas_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.local_government_wards CASCADE;
DROP TABLE IF EXISTS admin_bdys.local_government_wards_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.locality_bdys CASCADE;
DROP TABLE IF EXISTS admin_bdys.locality_bdys_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.postcode_bdys CASCADE;
DROP TABLE IF EXISTS admin_bdys.postcode_bdys_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.state_bdys_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.state_lower_house_electorates CASCADE;
DROP TABLE IF EXISTS admin_bdys.state_lower_house_electorates_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.state_upper_house_electorates CASCADE;
DROP TABLE IF EXISTS admin_bdys.stateupper_house_electorates_analysis CASCADE;

DROP TABLE IF EXISTS admin_bdys.abs_2011_gccsa CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2011_mb CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2011_sa1 CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2011_sa2 CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2011_sa3 CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2011_sa4 CASCADE;

DROP TABLE IF EXISTS admin_bdys.abs_2016_gccsa CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2016_mb CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2016_sa1 CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2016_sa2 CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2016_sa3 CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2016_sa4 CASCADE;

DROP TABLE IF EXISTS admin_bdys.abs_2021_gccsa CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2021_mb CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2021_sa1 CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2021_sa2 CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2021_sa3 CASCADE;
DROP TABLE IF EXISTS admin_bdys.abs_2021_sa4 CASCADE;
