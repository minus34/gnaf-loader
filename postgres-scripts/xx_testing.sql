

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
