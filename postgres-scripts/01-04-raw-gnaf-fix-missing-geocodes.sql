-- workaround for missing default coordinates - 202111 release issue
with missing as (
    select address_detail_pid
    from raw_gnaf_202111.address_default_geocode
    where latitude is null or longitude is null
), site as (
    select gnaf.address_detail_pid,
           gnaf.address_site_pid
    from raw_gnaf_202111.address_detail as gnaf
    inner join missing on gnaf.address_detail_pid = missing.address_detail_pid
), coords as (
    select site.address_detail_pid,
           geo.latitude,
           geo.longitude
    from raw_gnaf_202111.address_site_geocode as geo
    inner join site on geo.address_site_pid = site.address_site_pid
    where geocode_type_code = 'PAPS'
)
update raw_gnaf_202111.address_default_geocode as def
    set latitude = coords.latitude,
        longitude = coords.longitude
from coords
where def.address_detail_pid = coords.address_detail_pid
;
