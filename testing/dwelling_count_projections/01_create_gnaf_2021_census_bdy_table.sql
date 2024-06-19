
-- get all ABS Census boundaries for each GNAF address (GNAF only links directly to meshblocks, SAs & GCCs)

-- step 1 - create a bunch of temp tables merging meshblocks with non-ABS structures (LGA, RAs etc...)
-- use meshblock bdy centroids to get the bdy ID
-- this approach is simpler than downloading & importing ABS correspondence files, which are subject to change
-- also RA, SED and CED bdys are groups of SA1s; the rest are groups of meshblocks. Meshblocks are used for all bdys to keep the code simple (performance hit is minimal)

-- TODO: find out which 6 addresses got NULL bdy IDs and dropped off

-- create temp table of meshblock centroids (ensure centroid is within polygon by using ST_PointOnSurface)
drop table if exists temp_mb;
create temporary table temp_mb as
select mb_code_2021,
       ST_Transform(ST_PointOnSurface(geom), 4283) as geom
from census_2021_bdys_gda94.mb_2021_aust_gda94
;
analyse temp_mb;
create index temp_mb_geom_idx on temp_mb using gist (geom);
alter table temp_mb cluster on temp_mb_geom_idx;

-- get temp tables of meshblock IDs per boundary

drop table if exists temp_ced_mb;
create temporary table temp_ced_mb as
select distinct temp_mb.mb_code_2021, bdy.ced_code_2021 as ced_code_2021, bdy.ced_name_2021 as ced_name_2021 from temp_mb
inner join census_2021_bdys_gda94.ced_2021_aust_gda94 as bdy on st_intersects(temp_mb.geom, bdy.geom);
analyse temp_ced_mb;

drop table if exists temp_lga_mb;
create temporary table temp_lga_mb as
select distinct temp_mb.mb_code_2021, bdy.lga_code_2021 as lga_code_2021, bdy.lga_name_2021 as lga_name_2021 from temp_mb
inner join census_2021_bdys_gda94.lga_2021_aust_gda94 as bdy on st_intersects(temp_mb.geom, bdy.geom);
analyse temp_lga_mb;

drop table if exists temp_poa_mb;
create temporary table temp_poa_mb as
select distinct temp_mb.mb_code_2021, bdy.poa_code_2021 as poa_code_2021, bdy.poa_name_2021 as poa_name_2021 from temp_mb
inner join census_2021_bdys_gda94.poa_2021_aust_gda94 as bdy on st_intersects(temp_mb.geom, bdy.geom);
analyse temp_poa_mb;

drop table if exists temp_ra_mb;
create temporary table temp_ra_mb as
select distinct temp_mb.mb_code_2021, bdy.ra_code_2021 as ra_code_2021, bdy.ra_name_2021 as ra_name_2021 from temp_mb
inner join census_2021_bdys_gda94.ra_2021_aust_gda94 as bdy on st_intersects(temp_mb.geom, bdy.geom);
analyse temp_ra_mb;

drop table if exists temp_sed_mb;
create temporary table temp_sed_mb as
select distinct temp_mb.mb_code_2021, bdy.sed_code_2021 as sed_code_2021, bdy.sed_name_2021 as sed_name_2021 from temp_mb
inner join census_2021_bdys_gda94.sed_2021_aust_gda94 as bdy on st_intersects(temp_mb.geom, bdy.geom);
analyse temp_sed_mb;

drop table if exists temp_ucl_mb;
create temporary table temp_ucl_mb as
select distinct temp_mb.mb_code_2021, bdy.ucl_code_2021 as ucl_code_2021, bdy.ucl_name_2021 as ucl_name_2021 from temp_mb
inner join census_2021_bdys_gda94.ucl_2021_aust_gda94 as bdy on st_intersects(temp_mb.geom, bdy.geom);
analyse temp_ucl_mb;

drop table temp_mb;


-- step 2 -- get ABS bdy IDs for all addresses -- 14,451,352 rows in 5 mins
drop table if exists gnaf_202111.address_principal_census_2021_boundaries;
create table gnaf_202111.address_principal_census_2021_boundaries as
with abs as (
    select mb.mb_code_2021,
           mb_category_2021,
           sa1_code_2021,
           sa2_code_2021,
           sa2_name_2021,
           sa3_code_2021,
           sa3_name_2021,
           sa4_code_2021,
           sa4_name_2021,
           gccsa_code_2021,
           gccsa_name_2021,
           ced_code_2021,
           ced_name_2021,
           lga_code_2021,
           lga_name_2021,
           poa_code_2021,
           poa_name_2021,
           ra_code_2021,
           ra_name_2021,
           sed_code_2021,
           sed_name_2021,
           ucl_code_2021,
           ucl_name_2021,
           mb.state_code_2021,
           mb.state_name_2021
    from census_2021_bdys_gda94.mb_2021_aust_gda94 as mb
    inner join temp_ced_mb as ced on ced.mb_code_2021 = mb.mb_code_2021
    inner join temp_lga_mb as lga on lga.mb_code_2021 = mb.mb_code_2021
    inner join temp_poa_mb as poa on poa.mb_code_2021 = mb.mb_code_2021
    inner join temp_ra_mb as ra on ra.mb_code_2021 = mb.mb_code_2021
    inner join temp_ucl_mb as ucl on ucl.mb_code_2021 = mb.mb_code_2021
    left outer join temp_sed_mb as sed on sed.mb_code_2021 = mb.mb_code_2021
)
select gid,
       adr.gnaf_pid,
       abs.*
from gnaf_202111.address_principals as adr
     inner join abs on abs.mb_code_2021 = adr.mb_2021_code::varchar(11)
;
analyse gnaf_202111.address_principal_census_2021_boundaries;

alter table gnaf_202111.address_principal_census_2021_boundaries add constraint address_principal_census_2021_boundaries_pkey primary key (gnaf_pid);
alter table gnaf_202111.address_principal_census_2021_boundaries cluster on address_principal_census_2021_boundaries_pkey;

drop table if exists temp_ced_mb;
drop table if exists temp_lga_mb;
drop table if exists temp_poa_mb;
drop table if exists temp_ra_mb;
drop table if exists temp_ucl_mb;
drop table if exists temp_sed_mb;


select count(*) from gnaf_202111.address_principals; -- 14,451,352
select count(*) from gnaf_202111.address_principal_census_2021_boundaries; -- 14,451,346
