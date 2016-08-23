
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

-- drop raw admin boundaries
DROP TABLE IF EXISTS raw_admin_bdys.aus_comm_electoral CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_comm_electoral_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_gccsa_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_gccsa_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_iare_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_iare_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_iloc_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_iloc_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_ireg_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_ireg_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_lga CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_lga_locality CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_lga_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_locality CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_locality_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_locality_town CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2016 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_mb_2016_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_remoteness_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_remoteness_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sa1_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sa1_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sa2_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sa2_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sa3_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sa3_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sa4_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sa4_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_seifa_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sos_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sos_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sosr_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sosr_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_state CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_state_electoral CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_state_electoral_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_state_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sua_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_sua_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_town CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_town_point CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_ucl_2011 CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_ucl_2011_polygon CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_ward CASCADE;
DROP TABLE IF EXISTS raw_admin_bdys.aus_ward_polygon CASCADE;

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
DROP TABLE IF EXISTS admin_bdys.locality_bdys CASCADE;
DROP TABLE IF EXISTS admin_bdys.locality_bdys_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.postcode_bdys CASCADE;
DROP TABLE IF EXISTS admin_bdys.postcode_bdys_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.state_bdys_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.commonwealth_electorates_analysis CASCADE;

DROP TABLE IF EXISTS admin_bdys.gccsa_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.iare_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.iloc_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.ireg_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.lga_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.mb_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.remoteness_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.sa1_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.sa2_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.sa3_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.sa4_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.sos_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.sosr_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.state_electoral_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.sua_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.ucl_2011_analysis CASCADE;
DROP TABLE IF EXISTS admin_bdys.ward_analysis CASCADE;
