

-- : null value in column "latitude" of relation "temp_addresses" violates not-null constraint
--DETAIL:  Failing row contains (586652, GASA_720237538, SA3616793, loc553beb711212, P, null, null, null, null, null, 284, null, SALEYARDS, ROAD, null, 5353, 1, D/89746/A/20, 40013032000, 40013032000, null, null, PROPERTY ACCESS POINT SETBACK, 2, null).

select *
from raw_gnaf_202111.address_default_geocode
where latitude is null or longitude is null;

--GASA_424662224
--GASA_424664998
--GASA_424826328
--GASA_425108741
--GASA_718982294
--GASA_719772942
--GASA_719778496
--GASA_720237538
--GASA_720495806
--GASA_720586798

select *
from raw_gnaf_202111.address_site_geocode
where latitude is null or longitude is null;
















-- root        : INFO     SQL FAILED! : ALTER TABLE ONLY gnaf_202108.locality_neighbour_lookup ADD CONSTRAINT locality_neighbour_lookup_pk PRIMARY KEY (locality_pid, neighbour_locality_pid); : could not create unique index "locality_neighbour_lookup_pk"
-- DETAIL:  Key (locality_pid, neighbour_locality_pid)=(loc46e919f53d9f, loc5ecbe4a59b8c) is duplicated.


select * from gnaf_202108.locality_neighbour_lookup
where locality_pid = 'loc46e919f53d9f'
and neighbour_locality_pid = 'loc5ecbe4a59b8c'

;

select * from gnaf_202108.localities
where locality_pid = 'loc46e919f53d9f'
;


select count(*) from gnaf_202108.locality_neighbour_lookup -- 88868

-- 88284 (584 duplicates)
with fred as (
    select distinct locality_pid, neighbour_locality_pid from gnaf_202108.locality_neighbour_lookup
)
select count(*) from fred
;


select * from admin_bdys_202108.qa_comparison;


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
from raw_admin_bdys_202108.aus_mb_2021
