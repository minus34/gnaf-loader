



DROP VIEW IF EXISTS raw_admin_bdys_202505.vw_tenp_state_electorates;
CREATE VIEW raw_admin_bdys_202505.vw_tenp_state_electorates AS
SELECT dat.*,
	   aut.name,
	   bdy.se_ply_pid,
	   bdy.geom
	FROM raw_admin_bdys_202505.aus_state_electoral as dat
	INNER JOIN raw_admin_bdys_202505.aus_state_electoral_class_aut as aut on dat.secl_code = aut.code
	INNER JOIN raw_admin_bdys_202505.aus_state_electoral_polygon as bdy on dat.se_pid = bdy.se_pid
-- 	where name = 'KEW'
;

select * from raw_admin_bdys_202505.vw_tenp_state_electorates
	where name = 'KEW'
	order by se_pid,
	         dt_create
	;



select * from raw_admin_bdys_202505.aus_state_electoral_polygon
	where se_pid = 'VIC292'
	order by se_pid,
	         dt_create
	;



