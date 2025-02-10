
drop table if exists testing.census_dwelling_projections_lga cascade;
create table testing.census_dwelling_projections_lga
(
    lga_name_2021                       text,
    lga_code_2021                       text,
    address_count_202111                integer,
    residential_address_count_202111    integer,
    dwelling_count_2021                 integer,
    dwelling_with_vehicle_count_2021    integer,
    population_count_2021               integer,
    population_over_15_count_2021       integer,
    vehicle_count_2021                  integer,
    average_household_size_2021         float,
    current_address_count               integer,
    current_residential_address_count   integer,
    residential_address_diff            integer,
    address_diff                        integer,
    current_dwelling_count              integer,
    current_dwelling_with_vehicle_count integer,
    current_population_count            integer,
    current_population_over_15_count    integer,
    current_vehicle_count               integer
);
alter table testing.census_dwelling_projections_lga owner to postgres;

-- add current residential address counts
insert into testing.census_dwelling_projections_lga (lga_name_2021, lga_code_2021, current_residential_address_count)
select lga_name_2021,
       lga_code_2021,
       count(*) as address_count
from gnaf_202502.address_principal_census_2021_boundaries
where lga_code_2021 is not null
  and mb_category_2021 in ('Residential', 'Primary Production', 'Other')
group by lga_name_2021,
         lga_code_2021
;

-- current address counts
with gnaf as (
    select lga_code_2021,
           count(*) as address_count
    from gnaf_202502.address_principal_census_2021_boundaries
    where lga_code_2021 is not null
    group by lga_code_2021
)
update testing.census_dwelling_projections_lga as dw
    set current_address_count = gnaf.address_count
from gnaf
where dw.lga_code_2021 = gnaf.lga_code_2021
;

-- Nov 2021 residential address counts
with gnaf as (
    select lga_code_2021,
           count(*) as address_count
    from gnaf_202111.address_principal_census_2021_boundaries
    where lga_code_2021 is not null
      and mb_category_2021 in ('Residential', 'Primary Production', 'Other')
    group by lga_code_2021
)
update testing.census_dwelling_projections_lga as dw
set residential_address_count_202111 = gnaf.address_count,
    residential_address_diff = current_residential_address_count - gnaf.address_count
from gnaf
where dw.lga_code_2021 = gnaf.lga_code_2021
;

-- Nov 2021 address counts
with gnaf as (
    select lga_code_2021,
           count(*) as address_count
    from gnaf_202111.address_principal_census_2021_boundaries
    where lga_code_2021 is not null
    group by lga_code_2021
)
update testing.census_dwelling_projections_lga as dw
set address_count_202111 = gnaf.address_count,
    address_diff = current_address_count - gnaf.address_count
from gnaf
where dw.lga_code_2021 = gnaf.lga_code_2021
;


-- add census dwelling & vehicle counts
with abs as (
    select region_id as lga_code_2021,
           g9351 as dwelling_count_2021,
           g9351 - g9344 as dwelling_with_vehicle_count_2021,
           (g9345 + g9346 * 2 + g9347 * 3 + g9348 * 4.5)::integer as vehicle_count_2021
    from census_2021_data.lga_g34
)
update testing.census_dwelling_projections_lga as dw
set dwelling_count_2021 = abs.dwelling_count_2021,
    dwelling_with_vehicle_count_2021 = abs.dwelling_with_vehicle_count_2021,
    vehicle_count_2021 = abs.vehicle_count_2021
from abs
where dw.lga_code_2021 = abs.lga_code_2021
;

-- add avg household size
with abs as (
    select region_id as lga_code_2021,
           g116 as average_household_size_2021
    from census_2021_data.lga_g02
)
update testing.census_dwelling_projections_lga as dw
set average_household_size_2021 = abs.average_household_size_2021
from abs
where dw.lga_code_2021 = abs.lga_code_2021
;


-- select * from census_2021_data.metadata_stats
-- where table_number = 'G04A'
-- order by sequential_id
-- ;


-- add population
with abs as (
    select b.region_id as lga_code_2021,
           g562 as population_count_2021,
           g562 - g274 - g292 - g310 - g313 as population_over_15_count_2021
    from census_2021_data.lga_g04b as b
    inner join census_2021_data.lga_g04a as a on b.region_id = a.region_id
)
update testing.census_dwelling_projections_lga as dw
set population_count_2021 = abs.population_count_2021,
    population_over_15_count_2021 = abs.population_over_15_count_2021
from abs
where dw.lga_code_2021 = abs.lga_code_2021
;

-- add projections based on increase in residential address counts
update testing.census_dwelling_projections_lga
    set current_dwelling_count = ceil(dwelling_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float)),
        current_dwelling_with_vehicle_count = ceil(dwelling_with_vehicle_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float)),
        current_population_count = ceil(population_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float)),
        current_population_over_15_count = ceil(population_over_15_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float)),
        current_vehicle_count = ceil(vehicle_count_2021 * (current_residential_address_count::float / residential_address_count_202111::float))
;


select *
from testing.census_dwelling_projections_lga
;



-- -- create view
-- drop view if exists testing.vw_census_dwelling_projections_lga;
-- create view testing.vw_census_dwelling_projections_lga as
-- select stats.*,
--     bdy.geom
-- from testing.census_dwelling_projections_lga as stats
-- inner join census_2021_bdys_gda94.lga_2021_aust_gda94 as bdy on stats.lga_code_2021 = bdy.lga_code_2021
--
--
--
-- select distinct mb_category_2021
-- from census_2021_bdys_gda94.mb_2021_aust_gda94
-- where mb_category_2021 not in (
-- 'ANTARCTICA',
-- 'MIGRATORY',
-- 'NOUSUALRESIDENCE',
-- 'OFFSHORE',
-- 'Outside Australia',
-- 'SHIPPING'
-- )
--
-- -- QGIS filter
-- -- mb_category_2021 in (
-- -- 'Parkland',
-- -- 'Primary Production',
-- -- 'Other',
-- -- 'Residential'
-- -- )
