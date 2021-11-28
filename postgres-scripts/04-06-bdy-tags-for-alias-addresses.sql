INSERT INTO gnaf.address_alias_admin_boundaries (gnaf_pid, locality_pid, locality_name, postcode, state, ce_pid, ce_name, lga_pid, lga_name, ward_pid, ward_name, se_lower_pid, se_lower_name, se_upper_pid, se_upper_name)
SELECT als.gnaf_pid, pcl.locality_pid, pcl.locality_name,
       pcl.postcode, pcl.state, pcl.ce_pid, pcl.ce_name, pcl.lga_pid, pcl.lga_name, pcl.ward_pid,
       pcl.ward_name, pcl.se_lower_pid, pcl.se_lower_name, pcl.se_upper_pid, pcl.se_upper_name
  FROM gnaf.address_principal_admin_boundaries AS pcl
  INNER JOIN gnaf.address_alias_lookup AS lkp ON pcl.gnaf_pid = lkp.principal_pid
  INNER JOIN gnaf.address_aliases AS als ON lkp.alias_pid = als.gnaf_pid;

ANALYZE gnaf.address_alias_admin_boundaries;
