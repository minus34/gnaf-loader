--
 DROP TABLE IF EXISTS testing.weather_stations;
-- CREATE TABLE testing.weather_stations
-- (
--     sort_order integer,
--     wmo integer,
--     name_x text,
--     history_product text,
--     local_date_time text,
--     local_date_time_full text,
--     aifstime_utc text,
--     lat double precision,
--     lon double precision,
--     apparent_t double precision,
--     cloud text,
--     cloud_base_m double precision,
--     cloud_oktas double precision,
--     cloud_type text,
--     cloud_type_id double precision,
--     delta_t double precision,
--     gust_kmh double precision,
--     gust_kt double precision,
--     air_temp double precision,
--     dewpt double precision,
--     press double precision,
--     press_msl double precision,
--     press_qnh double precision,
--     press_tend text,
--     rain_trace text,
--     rel_hum double precision,
--     sea_state text,
--     swell_dir_worded text,
--     swell_height double precision,
--     swell_period double precision,
--     vis_km text,
--     weather text,
--     wind_dir text,
--     wind_spd_kmh double precision,
--     wind_spd_kt double precision,
--     name_y text,
--     latitude double precision,
--     longitude double precision,
--     state text,
--     altitude double precision,
--     geom geometry(Point,4283),
--     CONSTRAINT weather_stations_pkey PRIMARY KEY (wmo)
-- );
-- ALTER TABLE testing.weather_stations OWNER to postgres;
--
-- CREATE INDEX sidx_weather_stations_geom ON testing.weather_stations USING gist (geom);
-- ALTER TABLE testing.weather_stations CLUSTER ON sidx_weather_stations_geom;

select *
from testing.weather_stations;



DROP TABLE IF EXISTS testing.weather_voronoi;
CREATE TABLE testing.weather_voronoi as
select (st_dump(ST_VoronoiPolygons(st_collect(geom), 0.0, ST_MakeEnvelope(112.0, -45.0, 165.0, 5.0, 4283)))).geom as geom
-- select ST_VoronoiPolygons(st_collect(geometry), 0.0, ST_MakeEnvelope(90.0, -50.0, 180.0, 0.0, 4283)) as geom
from testing.weather_stations
where air_temp is not null
;







select wmo, count(*)
from testing.weather_stations
group by wmo
having count(*) > 1


with qa as (
    select extract(epoch from now() - utc_time) as time_diff_s,
           *
    from testing.weather_stations
)
select utc_time,
       time_diff_s,
       count(*) as cnt
from qa
group by utc_time,
         time_diff_s
order by utc_time desc,
         time_diff_s
;



where wmo = 94564;
