
drop table if exists testing.census_dwelling_projections;
create table testing.census_dwelling_projections
(
    poa_name_2021   text,
    poa_code_2021   text,
    address_count_202111 integer,
    residential_address_count_202111 integer,
    dwelling_count_2021 integer,
    dwelling_with_vehicle_count_2021 integer,
    population_count_2021 integer,
    vehicle_count_2021 integer,
    average_household_size_2021 float,
    current_address_count integer,
    current_residential_address_count integer,
    residential_address_diff integer,
    address_diff integer,
    current_dwelling_count integer,
    current_dwelling_with_vehicle_count integer,
    current_population_count integer,
    current_vehicle_count integer
);
alter table testing.census_dwelling_projections owner to postgres;

-- add current residential address counts
insert into testing.census_dwelling_projections (poa_name_2021, poa_code_2021, current_residential_address_count)
select poa_name_2021,
       poa_code_2021,
       count(*) as address_count
from gnaf_202405.address_principal_census_2021_boundaries
where poa_code_2021 is not null
  and mb_category_2021 in ('Residential', 'Primary Production', 'Other')
group by poa_name_2021,
         poa_code_2021
;

-- current address counts
with gnaf as (
    select poa_code_2021,
           count(*) as address_count
    from gnaf_202405.address_principal_census_2021_boundaries
    where poa_code_2021 is not null
    group by poa_code_2021
)
update testing.census_dwelling_projections as dw
    set current_address_count = gnaf.address_count
from gnaf
where dw.poa_code_2021 = gnaf.poa_code_2021
;

-- Nov 2021 residential address counts
with gnaf as (
    select poa_code_2021,
           count(*) as address_count
    from gnaf_202111.address_principal_census_2021_boundaries
    where poa_code_2021 is not null
      and mb_category_2021 in ('Residential', 'Primary Production', 'Other')
    group by poa_code_2021
)
update testing.census_dwelling_projections as dw
set residential_address_count_202111 = gnaf.address_count,
    residential_address_diff = current_residential_address_count - gnaf.address_count
from gnaf
where dw.poa_code_2021 = gnaf.poa_code_2021
;

-- Nov 2021 address counts
with gnaf as (
    select poa_code_2021,
           count(*) as address_count
    from gnaf_202111.address_principal_census_2021_boundaries
    where poa_code_2021 is not null
    group by poa_code_2021
)
update testing.census_dwelling_projections as dw
set address_count_202111 = gnaf.address_count,
    address_diff = current_address_count - gnaf.address_count
from gnaf
where dw.poa_code_2021 = gnaf.poa_code_2021
;


-- add census dwelling & vehicle counts
with abs as (
    select region_id as poa_code_2021,
           g9351 as dwelling_count_2021,
           g9351 - g9344 as dwelling_with_vehicle_count_2021,
           (g9345 + g9346 * 2 + g9347 * 3 + g9348 * 4.5)::integer as vehicle_count_2021
    from census_2021_data.poa_g34
)
update testing.census_dwelling_projections as dw
set dwelling_count_2021 = abs.dwelling_count_2021,
    dwelling_with_vehicle_count_2021 = abs.dwelling_with_vehicle_count_2021,
    vehicle_count_2021 = abs.vehicle_count_2021
from abs
where dw.poa_code_2021 = abs.poa_code_2021
;

-- add avg household size
with abs as (
    select region_id as poa_code_2021,
           g116 as average_household_size_2021
    from census_2021_data.poa_g02
)
update testing.census_dwelling_projections as dw
set average_household_size_2021 = abs.average_household_size_2021
from abs
where dw.poa_code_2021 = abs.poa_code_2021
;

-- add population
with abs as (
    select region_id as poa_code_2021,
           g562 as population_count_2021
    from census_2021_data.poa_g04b
)
update testing.census_dwelling_projections as dw
set population_count_2021 = abs.population_count_2021
from abs
where dw.poa_code_2021 = abs.poa_code_2021
;

-- add projections based on increase in residential address counts
select poa_name_2021,
       current_residential_address_count,
       residential_address_count_202111,
       current_residential_address_count::float / residential_address_count_202111::float as percent_change,
       dwelling_count_2021,
       ceil(dwelling_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float)) as current_dwelling_count
from testing.census_dwelling_projections
order by percent_change desc
;





select *
from testing.census_dwelling_projections
where poa_name_2021 = '3052'
;



-- select *
-- from census_2021_data.metadata_stats
-- where table_number = 'G04B'
-- order by sequential_id
-- ;
