


select *
from gnaf_202405.address_principal_census_2021_boundaries;

drop table if exists testing.census_dwelling_projections;
create table rollin.census_dwelling_projections
(
    poa_name_2021   text,
    poa_code_2021   text,
    address_count_202111 integer,
    residential_address_count_202111 integer,
    current_address_count integer,
    current_residential_address_count integer,
    dwelling_count_2021 integer,
    residential_address_diff integer,
    current_dwelling_count integer
);
alter table rollin.census_dwelling_projections owner to postgres;

-- add current residential address counts
insert into rollin.census_dwelling_projections (poa_name_2021, poa_code_2021, current_residential_address_count)
select poa_name_2021,
       poa_code_2021,
       count(*) as address_count
from gnaf_202405.address_principal_census_2021_boundaries
where poa_name_2021 is not null
  and mb_category_2021 in ('Residential', 'Primary Production')
group by poa_name_2021,
         poa_code_2021
;