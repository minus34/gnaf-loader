-- create view of all address boundary tags
DROP VIEW IF EXISTS gnaf.address_admin_boundaries;
CREATE VIEW gnaf.address_admin_boundaries AS
  SELECT * FROM gnaf.address_principal_admin_boundaries
  UNION
  SELECT * FROM gnaf.address_alias_admin_boundaries;