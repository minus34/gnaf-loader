DROP TABLE IF EXISTS govhack2016.aec_senate_results;

CREATE TABLE govhack2016.aec_senate_results
(
  state character varying(3),
  division_id smallint,
  division_name character varying(50),
  ticket character varying (2),
  ballot_position smallint,
  candidate_id integer,
  candidate_name character varying(255),
  party_name character varying(255),
  party_ab character varying(4),
  elected character(1),
  historic_elected character(1),
  ordinary_votes integer,
  absent_votes integer,
  provisional_votes integer,
  prepoll_votes integer,
  postal_votes integer,
  total_votes integer
)
WITH (OIDS=FALSE);
ALTER TABLE govhack2016.aec_senate_results OWNER TO postgres;

COPY govhack2016.aec_senate_results FROM '/Users/hugh/minus34/govhack2016/SenateFirstPrefsByDivisionByVoteTypeDownload-20499.csv' CSV HEADER;


-- aggregate voting data by division
DROP TABLE IF EXISTS govhack2016.nationalist_party_voting;
SELECT t.*, n.nationalist_party_votes, (COALESCE(n.nationalist_party_votes,0)::float / t.total_votes::float * 100.0)::numeric(3,1) AS percent
  INTO govhack2016.nationalist_party_voting
  FROM (
    SELECT state, division_id, division_name, SUM(total_votes) AS total_votes
      FROM govhack2016.aec_senate_results
    GROUP BY state, division_id, division_name
  ) as t
  LEFT OUTER JOIN (
    SELECT division_id, SUM(total_votes) AS nationalist_party_votes
      FROM govhack2016.aec_senate_results
      WHERE party_name IN ('Pauline Hanson''s One Nation', 'Australia First Party', 'Australian Liberty Alliance')
      GROUP BY state, division_id
  ) AS n
  ON t.division_id = n.division_id;

select * from govhack2016.nationalist_party_voting where percent = 0;

-- 
-- -- get counts of islamic people
-- --create table
-- DROP TABLE IF EXISTS govhack2016.sa1_islam_points;
-- CREATE TABLE govhack2016.sa1_islam_points
-- (
--   gid integer NOT NULL DEFAULT nextval('sa1_islam_points_gid_seq'::regclass),
--   region_id character varying(11) NOT NULL,
--   geom geometry(Point, 4283),
--   CONSTRAINT sa1_islam_points_pkey PRIMARY KEY (gid)
-- ) WITH (OIDS=FALSE);
-- ALTER TABLE govhack2016.sa1_islam_points OWNER TO postgres;
-- 
-- INSERT INTO govhack2016.sa1_islam_points (region_id, geom)
-- SELECT region_id, ST_Transform(geom, 4283) FROM public.sa1_islam_points;
-- 
-- CREATE INDEX sa1_islam_points_geom_gist ON govhack2016.sa1_islam_points USING gist (geom);
-- ALTER TABLE govhack2016.sa1_islam_points CLUSTER ON sa1_islam_points_geom_gist;
-- 
-- -- get data
-- DROP TABLE IF EXISTS govhack2016.commonwealth_electorates_islam;
-- SELECT bdy.state, bdy.name AS division_name, Count(*) AS islamic_australians
--   INTO govhack2016.commonwealth_electorates_islam
--   FROM govhack2016.sa1_islam_points AS pnt
--   INNER JOIN admin_bdys.commonwealth_electorates_analysis AS bdy
--   ON ST_Intersects(pnt.geom, bdy.geom)
--   GROUP BY bdy.state, bdy.name;
-- 
-- 
-- -- get counts of all people -FAIL METHOD!!!!!!
-- --create table
-- DROP TABLE IF EXISTS govhack2016.sa1_points;
-- CREATE TABLE govhack2016.sa1_points
-- (
--   gid integer NOT NULL DEFAULT nextval('sa1_points_gid_seq'::regclass),
--   region_id character varying(11) NOT NULL,
--   geom geometry(Point, 4283),
--   CONSTRAINT sa1_points_pkey PRIMARY KEY (gid)
-- ) WITH (OIDS=FALSE);
-- ALTER TABLE govhack2016.sa1_points OWNER TO postgres;
-- 
-- INSERT INTO govhack2016.sa1_points (region_id, geom)
-- SELECT region_id, ST_Transform(geom, 4283) FROM public.sa1_points;
-- 
-- CREATE INDEX sa1_points_geom_gist ON govhack2016.sa1_points USING gist (geom);
-- ALTER TABLE govhack2016.sa1_points CLUSTER ON sa1_points_geom_gist;
-- 
-- -- get data
-- DROP TABLE IF EXISTS govhack2016.commonwealth_electorates_pop;
-- SELECT bdy.state, bdy.name AS division_name, Count(*) AS population
--   INTO govhack2016.commonwealth_electorates_pop
--   FROM govhack2016.sa1_points AS pnt
--   INNER JOIN admin_bdys.commonwealth_electorates_analysis AS bdy
--   ON ST_Intersects(pnt.geom, bdy.geom)
--   GROUP BY bdy.state, bdy.name;


-- -- 
-- -- -- get counts of all people using meshblocks
-- -- --create table
-- -- DROP TABLE IF EXISTS govhack2016.mb_points;
-- -- CREATE TABLE govhack2016.mb_points
-- -- (
-- --   gid integer NOT NULL DEFAULT nextval('mb_points_gid_seq'::regclass),
-- --   region_id character varying(11) NOT NULL,
-- --   geom geometry(Point, 4283),
-- --   CONSTRAINT mb_points_pkey PRIMARY KEY (gid)
-- -- ) WITH (OIDS=FALSE);
-- -- ALTER TABLE govhack2016.mb_points OWNER TO postgres;
-- -- 
-- -- INSERT INTO govhack2016.mb_points (region_id, geom)
-- -- SELECT mb_code11, ST_Centroid(geom) FROM public.mb_2011_aus;
-- -- 
-- -- CREATE INDEX mb_points_geom_gist ON govhack2016.mb_points USING gist (geom);
-- -- ALTER TABLE govhack2016.mb_points CLUSTER ON mb_points_geom_gist;
-- 
-- -- get data
-- DROP TABLE IF EXISTS govhack2016.commonwealth_electorates_pop;
-- SELECT bdy.state, bdy.name AS division_name, Count(*) AS population
--   INTO govhack2016.commonwealth_electorates_pop
--   FROM public.mb_random_points AS pnt
--   INNER JOIN admin_bdys.commonwealth_electorates_analysis AS bdy
--   ON ST_Intersects(pnt.geom, bdy.geom)
--   GROUP BY bdy.state, bdy.name;





-- create comparison table
DROP TABLE IF EXISTS govhack2016.commonwealth_electorates_pe;
SELECT t.*, i.islamic_australians, p.population, (i.islamic_australians::float / p.population::float * 100.0)::numeric(3,1) AS pop_percent
  INTO govhack2016.commonwealth_electorates_pe
  FROM govhack2016.nationalist_party_voting AS t
  RIGHT OUTER JOIN govhack2016.commonwealth_electorates_islam AS i ON t.state = i.state AND upper(t.division_name) = upper(i.division_name) 
  RIGHT OUTER JOIN govhack2016.commonwealth_electorates_pop AS p ON t.state = p.state AND upper(t.division_name) = upper(p.division_name);

-- Add geometry
ALTER TABLE govhack2016.commonwealth_electorates_pe ADD COLUMN geom geometry(MultiPolygon, 4283);

-- create temp tables of thinned bdys
DROP TABLE IF EXISTS temp_bdys;
SELECT state, name, (ST_Dump(ST_MakeValid(ST_Multi(ST_SnapToGrid(ST_Simplify(geom, 0.001), 0.001))))).geom AS geom
  INTO TEMPORARY temp_bdys
  FROM admin_bdys.commonwealth_electorates;

DELETE FROM temp_bdys WHERE ST_GeometryType(geom) <> 'ST_Polygon'; -- 13

DROP TABLE IF EXISTS temp_bdys2;
SELECT state, name, ST_Multi(ST_Union(geom)) AS geom
  INTO TEMPORARY temp_bdys2
  FROM temp_bdys
  GROUP BY state, name;

UPDATE govhack2016.commonwealth_electorates_pe AS p
  SET geom = g.geom
  FROM temp_bdys2 AS g
  WHERE p.state = g.state AND upper(p.division_name) = g.name;

CREATE INDEX commonwealth_electorates_pe_geom_gist ON govhack2016.commonwealth_electorates_pe USING gist (geom);
ALTER TABLE govhack2016.commonwealth_electorates_pe CLUSTER ON commonwealth_electorates_pe_geom_gist;

DROP TABLE temp_bdys;
DROP TABLE temp_bdys2;

COPY (
  SELECT state, division_id, division_name, total_votes, nationalist_party_votes, 
         percent, islamic_australians, population, pop_percent, ST_AsGeoJSON(geom, 3)
    FROM govhack2016.commonwealth_electorates_pe
  ) TO '/Users/hugh/GitHub/please-explain/ce.csv' CSV;

COPY (
  SELECT division_name || ', ' || state AS name, percent, pop_percent, (nationalist_party_votes::float/islamic_australians::float)::numeric(5,1) AS ratio, ST_AsGeoJSON(geom, 3)
    FROM govhack2016.commonwealth_electorates_pe
  ) TO '/Users/hugh/GitHub/please-explain/ce.csv' CSV;




select division_name || ', ' || state AS name, total_votes, nationalist_party_votes, 
         percent, islamic_australians, population, pop_percent,
         (nationalist_party_votes::float/islamic_australians::float)::numeric(5,1) AS n_i_ratio, (percent/pop_percent)::numeric(5,1) AS percent_ratio
  from govhack2016.commonwealth_electorates_pe
  WHERE percent > 0.0
  order by percent desc;

select corr(percent, pop_percent), covar_pop(percent, pop_percent)
  FROM govhack2016.commonwealth_electorates_pe
  WHERE percent > 0.0;



