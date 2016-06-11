INSERT INTO gnaf.temp_{0}_tags (gnaf_pid, gnaf_state, alias_principal, bdy_pid, bdy_name, bdy_state)
SELECT pnts.gnaf_pid,
       pnts.state,
       'P',
       bdys.{1},
       bdys.name,
       bdys.state
  FROM gnaf.address_principals AS pnts
  INNER JOIN admin_bdys.{0} AS bdys
  ON ST_Within(pnts.geom, bdys.geom);

INSERT INTO gnaf.temp_{0}_tags (gnaf_pid, gnaf_state, alias_principal, bdy_pid, bdy_name, bdy_state)
SELECT pnts.gnaf_pid,
       pnts.state,
       'A',
       bdys.{1},
       bdys.name,
       bdys.state
  FROM gnaf.address_aliases AS pnts
  INNER JOIN admin_bdys.{0} AS bdys
  ON ST_Within(pnts.geom, bdys.geom);


-- select gnaf.* from gnaf.temp_locality_bdys_tags as tags
-- inner join gnaf.addresses as gnaf
-- on tags.gnaf_pid = gnaf.gnaf_pid
-- and tags.locality_pid <> gnaf.locality_pid;