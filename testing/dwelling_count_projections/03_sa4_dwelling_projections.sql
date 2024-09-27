
drop table if exists testing.census_dwelling_projections_sa4;
create table testing.census_dwelling_projections_sa4
(
    sa4_name_2021                       text,
    sa4_code_2021                       text,
    address_count_202111                integer,
    residential_address_count_202111    integer,
    dwelling_count_2021                 integer,
    dwelling_with_vehicle_count_2021    integer,
    population_count_2021               integer,
    vehicle_count_2021                  integer,
    average_household_size_2021         float,
    current_address_count               integer,
    current_residential_address_count   integer,
    residential_address_diff            integer,
    address_diff                        integer,
    current_dwelling_count              integer,
    current_dwelling_with_vehicle_count integer,
    current_population_count            integer,
    current_vehicle_count               integer
);
alter table testing.census_dwelling_projections_sa4 owner to postgres;

-- add current residential address counts
insert into testing.census_dwelling_projections_sa4 (sa4_name_2021, sa4_code_2021, current_residential_address_count)
select sa4_name_2021,
       sa4_code_2021,
       count(*) as address_count
from gnaf_202408.address_principal_census_2021_boundaries
where sa4_code_2021 is not null
  and mb_category_2021 in ('Residential', 'Primary Production', 'Other')
group by sa4_name_2021,
         sa4_code_2021
;

-- current address counts
with gnaf as (
    select sa4_code_2021,
           count(*) as address_count
    from gnaf_202408.address_principal_census_2021_boundaries
    where sa4_code_2021 is not null
    group by sa4_code_2021
)
update testing.census_dwelling_projections_sa4 as dw
    set current_address_count = gnaf.address_count
from gnaf
where dw.sa4_code_2021 = gnaf.sa4_code_2021
;

-- Nov 2021 residential address counts
with gnaf as (
    select sa4_code_2021,
           count(*) as address_count
    from gnaf_202111.address_principal_census_2021_boundaries
    where sa4_code_2021 is not null
      and mb_category_2021 in ('Residential', 'Primary Production', 'Other')
    group by sa4_code_2021
)
update testing.census_dwelling_projections_sa4 as dw
set residential_address_count_202111 = gnaf.address_count,
    residential_address_diff = current_residential_address_count - gnaf.address_count
from gnaf
where dw.sa4_code_2021 = gnaf.sa4_code_2021
;

-- Nov 2021 address counts
with gnaf as (
    select sa4_code_2021,
           count(*) as address_count
    from gnaf_202111.address_principal_census_2021_boundaries
    where sa4_code_2021 is not null
    group by sa4_code_2021
)
update testing.census_dwelling_projections_sa4 as dw
set address_count_202111 = gnaf.address_count,
    address_diff = current_address_count - gnaf.address_count
from gnaf
where dw.sa4_code_2021 = gnaf.sa4_code_2021
;


-- add census dwelling & vehicle counts
with abs as (
    select region_id as sa4_code_2021,
           g9351 as dwelling_count_2021,
           g9351 - g9344 as dwelling_with_vehicle_count_2021,
           (g9345 + g9346 * 2 + g9347 * 3 + g9348 * 4.5)::integer as vehicle_count_2021
    from census_2021_data.sa4_g34
)
update testing.census_dwelling_projections_sa4 as dw
set dwelling_count_2021 = abs.dwelling_count_2021,
    dwelling_with_vehicle_count_2021 = abs.dwelling_with_vehicle_count_2021,
    vehicle_count_2021 = abs.vehicle_count_2021
from abs
where dw.sa4_code_2021 = abs.sa4_code_2021
;

-- add avg household size
with abs as (
    select region_id as sa4_code_2021,
           g116 as average_household_size_2021
    from census_2021_data.sa4_g02
)
update testing.census_dwelling_projections_sa4 as dw
set average_household_size_2021 = abs.average_household_size_2021
from abs
where dw.sa4_code_2021 = abs.sa4_code_2021
;

-- add population
with abs as (
    select region_id as sa4_code_2021,
           g562 as population_count_2021
    from census_2021_data.sa4_g04b
)
update testing.census_dwelling_projections_sa4 as dw
set population_count_2021 = abs.population_count_2021
from abs
where dw.sa4_code_2021 = abs.sa4_code_2021
;

-- add projections based on increase in residential address counts
update testing.census_dwelling_projections_sa4
    set current_dwelling_count = ceil(dwelling_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float)),
        current_dwelling_with_vehicle_count = ceil(dwelling_with_vehicle_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float)),
        current_population_count = ceil(population_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float)),
        current_vehicle_count = ceil(vehicle_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float))
;




select *
from testing.census_dwelling_projections_sa4
-- where poa_name_2021 = '3052'
;



-- select *
-- from census_2021_data.metadata_stats
-- where table_number = 'G04B'
-- order by sequential_id
-- ;
