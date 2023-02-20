
select *
from admin_bdys_202302.locality_bdys_display;


select count(*)
from gnaf_202302.address_principals;


-- addresses missing bdy tags
drop view if exists gnaf_202302.vw_address_principal_admin_boundaries;
create view gnaf_202302.vw_address_principal_admin_boundaries as
select bdy.*,
       geom
from gnaf_202302.address_principal_admin_boundaries as bdy
inner join gnaf_202302.address_principals as gnaf on gnaf.gnaf_pid = bdy.gnaf_pid
where bdy.lga_pid is null
  and bdy.state <> 'ACT'
;

select *
from gnaf_202302.address_principal_admin_boundaries
;



-- addresses missing bdy tags
select count(*) as address_count,
       locality_pid,
       locality_name,
       postcode,
       state
from gnaf_202302.address_principal_admin_boundaries
where ce_pid is null
    and state <> 'ACT'
group by locality_pid,
         locality_name,
         postcode,
         state
order by address_count desc
;


-- REINDEX DATABASE geo;


select count(*) from gnaf_202302.address_principals; -- 14404238

-- find geoms that don't match
select count(*)
from gnaf_202302.address_principals as old
inner join gnaf_202302_gda94.address_principals as new on old.gnaf_pid = new.gnaf_pid
	and not st_equals(old.geom, new.geom)
;


-- root        : INFO     SQL FAILED! : ALTER TABLE ONLY gnaf_202302.locality_neighbour_lookup ADD CONSTRAINT locality_neighbour_lookup_pk PRIMARY KEY (locality_pid, neighbour_locality_pid); : could not create unique index "locality_neighbour_lookup_pk"
-- DETAIL:  Key (locality_pid, neighbour_locality_pid)=(loc46e919f53d9f, loc5ecbe4a59b8c) is duplicated.


select * from gnaf_202302.locality_neighbour_lookup
where locality_pid = 'loc46e919f53d9f'
and neighbour_locality_pid = 'loc5ecbe4a59b8c'

;

select * from gnaf_202302.localities
where locality_pid = 'loc46e919f53d9f'
;


select count(*) from gnaf_202302.locality_neighbour_lookup -- 88868

-- 88284 (584 duplicates)
with fred as (
    select distinct locality_pid, neighbour_locality_pid from gnaf_202302.locality_neighbour_lookup
)
select count(*) from fred
;


select * from admin_bdys_202302.qa_comparison;


select gid,
       mb_21ppid,
       dt_create,
       mb_21pid,
       mb21_code,
       mb_cat,
       chng_flag,
       chng_label,
       sa1_21pid,
       sa1_21code,
       sa2_21code,
       sa2_21name,
       sa3_21code,
       sa3_21name,
       sa4_21code,
       sa4_21name,
       gcc_21code,
       gcc_21name,
       state_pid,
       area_sqm,
       mb21_dwell,
       mb21_pop,
       loci21_uri,
       geom
from raw_admin_bdys_202302.aus_mb_2021;


-- yes, you can transorm a geom to its own SRID! (simplifies supporting 2 coord systems in one set of code
select 'yep' where ST_SetSRID(ST_MakePoint(115.81778, -31.98092), 4283) =
       ST_transform(ST_SetSRID(ST_MakePoint(115.81778, -31.98092), 4283), 4283);


select Find_SRID('admin_bdys_202302', 'locality_bdys', 'geom');
