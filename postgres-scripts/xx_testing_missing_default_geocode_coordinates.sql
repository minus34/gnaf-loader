
-- Error in gnaf-loader

-- : null value in column "latitude" of relation "temp_addresses" violates not-null constraint
--DETAIL:  Failing row contains (586652, GASA_720237538, SA3616793, loc553beb711212, P, null, null, null, null, null, 284, null, SALEYARDS, ROAD, null, 5353, 1, D/89746/A/20, 40013032000, 40013032000, null, null, PROPERTY ACCESS POINT SETBACK, 2, null).

-- find default geocodes with no lat/longs -- 10 records
select *
from raw_gnaf_202408.address_default_geocode
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


-- get address_site_pids for gnaf_pids with no coords
select address_detail_pid, address_site_pid from raw_gnaf_202408.address_detail
where address_detail_pid in (
'GASA_424662224',
'GASA_424664998',
'GASA_424826328',
'GASA_425108741',
'GASA_718982294',
'GASA_719772942',
'GASA_719778496',
'GASA_720237538',
'GASA_720495806',
'GASA_720586798'
)
;

--GASA_424662224	424747613
--GASA_424664998	424750387
--GASA_424826328	424911716
--GASA_425108741	425194442
--GASA_718982294	714367327
--GASA_719772942	715157969
--GASA_719778496	715163523
--GASA_720237538	715622599
--GASA_720495806	715880847
--GASA_720586798	715971839


-- check if lat/longs exist in full geocode table using address_site_pids: all 10 have coords & good geocodes
select *
from raw_gnaf_202408.address_site_geocode
where address_site_pid in (
'424747613',
'424750387',
'424911716',
'425194442',
'714367327',
'715157969',
'715163523',
'715622599',
'715880847',
'715971839'
)
and geocode_type_code = 'PAPS'
;


-- workaround for missing default coordinates
with missing as (
    select address_detail_pid
    from raw_gnaf_202408.address_default_geocode
    where latitude is null or longitude is null
), site as (
    select gnaf.address_detail_pid,
           gnaf.address_site_pid
    from raw_gnaf_202408.address_detail as gnaf
    inner join missing on gnaf.address_detail_pid = missing.address_detail_pid
), coords as (
    select site.address_detail_pid,
           geo.latitude,
           geo.longitude
    from raw_gnaf_202408.address_site_geocode as geo
    inner join site on geo.address_site_pid = site.address_site_pid
    where geocode_type_code = 'PAPS'
)
update raw_gnaf_202408.address_default_geocode as def
    set latitude = coords.latitude,
        longitude = coords.longitude
from coords
where def.address_detail_pid = coords.address_detail_pid
;




