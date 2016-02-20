--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: raw_admin_bdys; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA raw_admin_bdys;


ALTER SCHEMA raw_admin_bdys OWNER TO postgres;

SET search_path = raw_admin_bdys, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: aus_comm_electoral; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_comm_electoral (
    gid integer NOT NULL,
    ce_pid character varying(15),
    dt_create date,
    dt_retire date,
    name character varying(50),
    dt_gazetd date,
    state_pid character varying(15),
    redistyear integer
);


ALTER TABLE aus_comm_electoral OWNER TO postgres;

--
-- Name: aus_comm_electoral_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_comm_electoral_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_comm_electoral_gid_seq OWNER TO postgres;

--
-- Name: aus_comm_electoral_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_comm_electoral_gid_seq OWNED BY aus_comm_electoral.gid;


--
-- Name: aus_comm_electoral_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_comm_electoral_polygon (
    gid integer NOT NULL,
    ce_ply_pid character varying(15),
    dt_create date,
    dt_retire date,
    ce_pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_comm_electoral_polygon OWNER TO postgres;

--
-- Name: aus_comm_electoral_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_comm_electoral_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_comm_electoral_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_comm_electoral_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_comm_electoral_polygon_gid_seq OWNED BY aus_comm_electoral_polygon.gid;


--
-- Name: aus_gccsa_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_gccsa_2011 (
    gid integer NOT NULL,
    gcc_11pid character varying(15),
    dt_create date,
    dt_retire date,
    gcc_11code character varying(5),
    gcc_11name character varying(50),
    state_pid character varying(15),
    area_sqm numeric
);


ALTER TABLE aus_gccsa_2011 OWNER TO postgres;

--
-- Name: aus_gccsa_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_gccsa_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_gccsa_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_gccsa_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_gccsa_2011_gid_seq OWNED BY aus_gccsa_2011.gid;


--
-- Name: aus_gccsa_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_gccsa_2011_polygon (
    gid integer NOT NULL,
    gcc_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    gcc_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_gccsa_2011_polygon OWNER TO postgres;

--
-- Name: aus_gccsa_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_gccsa_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_gccsa_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_gccsa_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_gccsa_2011_polygon_gid_seq OWNED BY aus_gccsa_2011_polygon.gid;


--
-- Name: aus_iare_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_iare_2011 (
    gid integer NOT NULL,
    iare_11pid character varying(15),
    dt_create date,
    dt_retire date,
    iare_11cod character varying(6),
    iare_11nam character varying(50),
    ireg_11pid character varying(15),
    ireg_11cod integer,
    ireg_11nam character varying(50),
    state_pid character varying(15),
    area_sqkm double precision
);


ALTER TABLE aus_iare_2011 OWNER TO postgres;

--
-- Name: aus_iare_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_iare_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_iare_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_iare_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_iare_2011_gid_seq OWNED BY aus_iare_2011.gid;


--
-- Name: aus_iare_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_iare_2011_polygon (
    gid integer NOT NULL,
    iar_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    iare_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_iare_2011_polygon OWNER TO postgres;

--
-- Name: aus_iare_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_iare_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_iare_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_iare_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_iare_2011_polygon_gid_seq OWNED BY aus_iare_2011_polygon.gid;


--
-- Name: aus_iloc_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_iloc_2011 (
    gid integer NOT NULL,
    iloc_11pid character varying(15),
    dt_create date,
    dt_retire date,
    iloc_11cod integer,
    iloc_11nam character varying(50),
    iare_11pid character varying(15),
    iare_11cod character varying(6),
    iare_11nam character varying(50),
    ireg_11pid character varying(15),
    ireg_11cod integer,
    ireg_11nam character varying(50),
    state_pid character varying(15),
    area_sqkm double precision
);


ALTER TABLE aus_iloc_2011 OWNER TO postgres;

--
-- Name: aus_iloc_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_iloc_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_iloc_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_iloc_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_iloc_2011_gid_seq OWNED BY aus_iloc_2011.gid;


--
-- Name: aus_iloc_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_iloc_2011_polygon (
    gid integer NOT NULL,
    ilo_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    iloc_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_iloc_2011_polygon OWNER TO postgres;

--
-- Name: aus_iloc_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_iloc_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_iloc_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_iloc_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_iloc_2011_polygon_gid_seq OWNED BY aus_iloc_2011_polygon.gid;


--
-- Name: aus_ireg_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_ireg_2011 (
    gid integer NOT NULL,
    ireg_11pid character varying(15),
    dt_create date,
    dt_retire date,
    ireg_11cod integer,
    ireg_11nam character varying(50),
    state_pid character varying(15),
    area_sqkm double precision
);


ALTER TABLE aus_ireg_2011 OWNER TO postgres;

--
-- Name: aus_ireg_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_ireg_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_ireg_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_ireg_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_ireg_2011_gid_seq OWNED BY aus_ireg_2011.gid;


--
-- Name: aus_ireg_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_ireg_2011_polygon (
    gid integer NOT NULL,
    ire_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    ireg_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_ireg_2011_polygon OWNER TO postgres;

--
-- Name: aus_ireg_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_ireg_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_ireg_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_ireg_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_ireg_2011_polygon_gid_seq OWNED BY aus_ireg_2011_polygon.gid;


--
-- Name: aus_lga; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_lga (
    gid integer NOT NULL,
    lga_pid character varying(15),
    dt_create date,
    dt_retire date,
    lga_name character varying(100),
    abb_name character varying(100),
    dt_gazetd date,
    state_pid character varying(15)
);


ALTER TABLE aus_lga OWNER TO postgres;

--
-- Name: aus_lga_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_lga_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_lga_gid_seq OWNER TO postgres;

--
-- Name: aus_lga_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_lga_gid_seq OWNED BY aus_lga.gid;


--
-- Name: aus_lga_locality; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_lga_locality (
    gid integer NOT NULL,
    lg_loc_pid character varying(20),
    dt_create date,
    dt_retire date,
    lga_pid character varying(15),
    loc_pid character varying(15)
);


ALTER TABLE aus_lga_locality OWNER TO postgres;

--
-- Name: aus_lga_locality_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_lga_locality_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_lga_locality_gid_seq OWNER TO postgres;

--
-- Name: aus_lga_locality_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_lga_locality_gid_seq OWNED BY aus_lga_locality.gid;


--
-- Name: aus_lga_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_lga_polygon (
    gid integer NOT NULL,
    lg_ply_pid character varying(15),
    dt_create date,
    dt_retire date,
    lga_pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_lga_polygon OWNER TO postgres;

--
-- Name: aus_lga_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_lga_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_lga_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_lga_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_lga_polygon_gid_seq OWNED BY aus_lga_polygon.gid;


--
-- Name: aus_locality; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_locality (
    gid integer NOT NULL,
    loc_pid character varying(15),
    dt_create date,
    dt_retire date,
    name character varying(100),
    postcode character varying(4),
    prim_pcode character varying(4),
    loccl_code character varying(1),
    dt_gazetd date,
    state_pid character varying(15)
);


ALTER TABLE aus_locality OWNER TO postgres;

--
-- Name: aus_locality_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_locality_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_locality_gid_seq OWNER TO postgres;

--
-- Name: aus_locality_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_locality_gid_seq OWNED BY aus_locality.gid;


--
-- Name: aus_locality_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_locality_polygon (
    gid integer NOT NULL,
    lc_ply_pid character varying(15),
    dt_create date,
    dt_retire date,
    loc_pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_locality_polygon OWNER TO postgres;

--
-- Name: aus_locality_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_locality_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_locality_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_locality_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_locality_polygon_gid_seq OWNED BY aus_locality_polygon.gid;


--
-- Name: aus_locality_town; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_locality_town (
    gid integer NOT NULL,
    locality_t character varying(15),
    date_creat date,
    date_retir date,
    locality_p character varying(15),
    town_pid character varying(15)
);


ALTER TABLE aus_locality_town OWNER TO postgres;

--
-- Name: aus_locality_town_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_locality_town_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_locality_town_gid_seq OWNER TO postgres;

--
-- Name: aus_locality_town_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_locality_town_gid_seq OWNED BY aus_locality_town.gid;


--
-- Name: aus_mb_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_mb_2011 (
    gid integer NOT NULL,
    mb_11pid character varying(15),
    dt_create date,
    dt_retire date,
    sa1_11pid character varying(15),
    mb_cat_cd character varying(10),
    mb_11code character varying(15),
    sa1_11main double precision,
    sa1_11_7cd integer,
    sa2_11main integer,
    sa2_11_5cd integer,
    sa2_11name character varying(50),
    sa3_11code integer,
    sa3_11name character varying(50),
    sa4_11code integer,
    sa4_11name character varying(50),
    gcc_11code character varying(5),
    gcc_11name character varying(50),
    state_pid character varying(15),
    area_sqm numeric,
    mb11_pop integer,
    mb11_dwell integer
);


ALTER TABLE aus_mb_2011 OWNER TO postgres;

--
-- Name: aus_mb_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_mb_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_mb_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_mb_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_mb_2011_gid_seq OWNED BY aus_mb_2011.gid;


--
-- Name: aus_mb_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_mb_2011_polygon (
    gid integer NOT NULL,
    mb_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    mb_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_mb_2011_polygon OWNER TO postgres;

--
-- Name: aus_mb_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_mb_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_mb_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_mb_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_mb_2011_polygon_gid_seq OWNED BY aus_mb_2011_polygon.gid;


--
-- Name: aus_remoteness_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_remoteness_2011 (
    gid integer NOT NULL,
    rem11_pid character varying(15),
    dt_create date,
    dt_retire date,
    rem11_ccd character varying(15),
    rem11_code integer,
    state_pid character varying(15),
    areasqkm double precision
);


ALTER TABLE aus_remoteness_2011 OWNER TO postgres;

--
-- Name: aus_remoteness_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_remoteness_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_remoteness_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_remoteness_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_remoteness_2011_gid_seq OWNED BY aus_remoteness_2011.gid;


--
-- Name: aus_remoteness_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_remoteness_2011_polygon (
    gid integer NOT NULL,
    rem11_ppid character varying(15),
    dt_create date,
    dt_retire date,
    rem11_pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_remoteness_2011_polygon OWNER TO postgres;

--
-- Name: aus_remoteness_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_remoteness_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_remoteness_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_remoteness_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_remoteness_2011_polygon_gid_seq OWNED BY aus_remoteness_2011_polygon.gid;


--
-- Name: aus_sa1_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sa1_2011 (
    gid integer NOT NULL,
    sa1_11pid character varying(15),
    dt_create date,
    dt_retire date,
    sa2_11pid character varying(15),
    sa1_11main double precision,
    sa1_11_7cd integer,
    sa2_11main integer,
    sa2_11_5cd integer,
    sa2_11name character varying(50),
    sa3_11code integer,
    sa3_11name character varying(50),
    sa4_11code integer,
    sa4_11name character varying(50),
    gcc_11code character varying(5),
    gcc_11name character varying(50),
    state_pid character varying(15),
    area_sqm numeric
);


ALTER TABLE aus_sa1_2011 OWNER TO postgres;

--
-- Name: aus_sa1_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sa1_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sa1_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_sa1_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sa1_2011_gid_seq OWNED BY aus_sa1_2011.gid;


--
-- Name: aus_sa1_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sa1_2011_polygon (
    gid integer NOT NULL,
    sa1_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    sa1_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_sa1_2011_polygon OWNER TO postgres;

--
-- Name: aus_sa1_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sa1_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sa1_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_sa1_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sa1_2011_polygon_gid_seq OWNED BY aus_sa1_2011_polygon.gid;


--
-- Name: aus_sa2_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sa2_2011 (
    gid integer NOT NULL,
    sa2_11pid character varying(15),
    dt_create date,
    dt_retire date,
    sa3_11pid character varying(15),
    sa2_11main integer,
    sa2_11_5cd integer,
    sa2_11name character varying(50),
    sa3_11code integer,
    sa3_11name character varying(50),
    sa4_11code integer,
    sa4_11name character varying(50),
    gcc_11code character varying(5),
    gcc_11name character varying(50),
    state_pid character varying(15),
    area_sqm numeric
);


ALTER TABLE aus_sa2_2011 OWNER TO postgres;

--
-- Name: aus_sa2_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sa2_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sa2_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_sa2_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sa2_2011_gid_seq OWNED BY aus_sa2_2011.gid;


--
-- Name: aus_sa2_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sa2_2011_polygon (
    gid integer NOT NULL,
    sa2_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    sa2_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_sa2_2011_polygon OWNER TO postgres;

--
-- Name: aus_sa2_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sa2_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sa2_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_sa2_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sa2_2011_polygon_gid_seq OWNED BY aus_sa2_2011_polygon.gid;


--
-- Name: aus_sa3_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sa3_2011 (
    gid integer NOT NULL,
    sa3_11pid character varying(15),
    dt_create date,
    dt_retire date,
    sa4_11pid character varying(15),
    sa3_11code integer,
    sa3_11name character varying(50),
    sa4_11code integer,
    sa4_11name character varying(50),
    gcc_11code character varying(5),
    gcc_11name character varying(50),
    state_pid character varying(15),
    area_sqm numeric
);


ALTER TABLE aus_sa3_2011 OWNER TO postgres;

--
-- Name: aus_sa3_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sa3_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sa3_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_sa3_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sa3_2011_gid_seq OWNED BY aus_sa3_2011.gid;


--
-- Name: aus_sa3_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sa3_2011_polygon (
    gid integer NOT NULL,
    sa3_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    sa3_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_sa3_2011_polygon OWNER TO postgres;

--
-- Name: aus_sa3_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sa3_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sa3_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_sa3_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sa3_2011_polygon_gid_seq OWNED BY aus_sa3_2011_polygon.gid;


--
-- Name: aus_sa4_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sa4_2011 (
    gid integer NOT NULL,
    sa4_11pid character varying(15),
    dt_create date,
    dt_retire date,
    gcc_11pid character varying(15),
    sa4_11code integer,
    sa4_11name character varying(50),
    gcc_11code character varying(5),
    gcc_11name character varying(50),
    state_pid character varying(15),
    area_sqm numeric
);


ALTER TABLE aus_sa4_2011 OWNER TO postgres;

--
-- Name: aus_sa4_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sa4_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sa4_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_sa4_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sa4_2011_gid_seq OWNED BY aus_sa4_2011.gid;


--
-- Name: aus_sa4_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sa4_2011_polygon (
    gid integer NOT NULL,
    sa4_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    sa4_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_sa4_2011_polygon OWNER TO postgres;

--
-- Name: aus_sa4_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sa4_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sa4_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_sa4_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sa4_2011_polygon_gid_seq OWNED BY aus_sa4_2011_polygon.gid;


--
-- Name: aus_seifa_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_seifa_2011 (
    gid integer NOT NULL,
    seifa11pid character varying(15),
    dt_create date,
    dt_retire date,
    sa1_11pid character varying(15),
    pop integer,
    irsad_scr integer,
    irsad_a_rk integer,
    irsad_a_dc character varying(2),
    irsad_a_pc character varying(3),
    irsad_s_rk integer,
    irsad_s_dc character varying(2),
    irsad_s_pc character varying(3),
    irsd_scr integer,
    irsd_a_rk integer,
    irsd_a_dc character varying(2),
    irsd_a_pc character varying(3),
    irsd_s_rk integer,
    irsd_s_dc character varying(2),
    irsd_s_pc character varying(3),
    ier_scr integer,
    ier_a_rk integer,
    ier_a_dc character varying(2),
    ier_a_pc character varying(3),
    ier_s_rk integer,
    ier_s_dc character varying(2),
    ier_s_pc character varying(3),
    ieo_scr integer,
    ieo_a_rk integer,
    ieo_a_dc character varying(2),
    ieo_a_pc character varying(3),
    ieo_s_rk integer,
    ieo_s_dc character varying(2),
    ieo_s_pc character varying(3)
);


ALTER TABLE aus_seifa_2011 OWNER TO postgres;

--
-- Name: aus_seifa_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_seifa_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_seifa_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_seifa_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_seifa_2011_gid_seq OWNED BY aus_seifa_2011.gid;


--
-- Name: aus_sos_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sos_2011 (
    gid integer NOT NULL,
    sos_11pid character varying(15),
    dt_create date,
    dt_retire date,
    sos_11code integer,
    sos_11name character varying(50),
    state_pid character varying(15),
    area_sqkm double precision
);


ALTER TABLE aus_sos_2011 OWNER TO postgres;

--
-- Name: aus_sos_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sos_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sos_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_sos_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sos_2011_gid_seq OWNED BY aus_sos_2011.gid;


--
-- Name: aus_sos_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sos_2011_polygon (
    gid integer NOT NULL,
    sos_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    sos_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_sos_2011_polygon OWNER TO postgres;

--
-- Name: aus_sos_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sos_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sos_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_sos_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sos_2011_polygon_gid_seq OWNED BY aus_sos_2011_polygon.gid;


--
-- Name: aus_sosr_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sosr_2011 (
    gid integer NOT NULL,
    ssr_11pid character varying(15),
    dt_create date,
    dt_retire date,
    ssr_11code integer,
    ssr_11name character varying(50),
    sos_11code integer,
    sos_11name character varying(50),
    state_pid character varying(15),
    area_sqkm double precision
);


ALTER TABLE aus_sosr_2011 OWNER TO postgres;

--
-- Name: aus_sosr_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sosr_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sosr_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_sosr_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sosr_2011_gid_seq OWNED BY aus_sosr_2011.gid;


--
-- Name: aus_sosr_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sosr_2011_polygon (
    gid integer NOT NULL,
    ssr_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    ssr_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_sosr_2011_polygon OWNER TO postgres;

--
-- Name: aus_sosr_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sosr_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sosr_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_sosr_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sosr_2011_polygon_gid_seq OWNED BY aus_sosr_2011_polygon.gid;


--
-- Name: aus_state; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_state (
    gid integer NOT NULL,
    state_pid character varying(15),
    dt_create date,
    dt_retire date,
    state_name character varying(50),
    st_abbrev character varying(3)
);


ALTER TABLE aus_state OWNER TO postgres;

--
-- Name: aus_state_electoral; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_state_electoral (
    gid integer NOT NULL,
    se_pid character varying(15),
    dt_create date,
    dt_retire date,
    name character varying(50),
    dt_gazetd date,
    eff_start date,
    eff_end date,
    state_pid character varying(15),
    secl_code character varying(10)
);


ALTER TABLE aus_state_electoral OWNER TO postgres;

--
-- Name: aus_state_electoral_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_state_electoral_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_state_electoral_gid_seq OWNER TO postgres;

--
-- Name: aus_state_electoral_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_state_electoral_gid_seq OWNED BY aus_state_electoral.gid;


--
-- Name: aus_state_electoral_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_state_electoral_polygon (
    gid integer NOT NULL,
    se_ply_pid character varying(15),
    dt_create date,
    dt_retire date,
    se_pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_state_electoral_polygon OWNER TO postgres;

--
-- Name: aus_state_electoral_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_state_electoral_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_state_electoral_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_state_electoral_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_state_electoral_polygon_gid_seq OWNED BY aus_state_electoral_polygon.gid;


--
-- Name: aus_state_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_state_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_state_gid_seq OWNER TO postgres;

--
-- Name: aus_state_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_state_gid_seq OWNED BY aus_state.gid;


--
-- Name: aus_state_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_state_polygon (
    gid integer NOT NULL,
    st_ply_pid character varying(15),
    dt_create date,
    dt_retire date,
    state_pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_state_polygon OWNER TO postgres;

--
-- Name: aus_state_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_state_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_state_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_state_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_state_polygon_gid_seq OWNED BY aus_state_polygon.gid;


--
-- Name: aus_sua_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sua_2011 (
    gid integer NOT NULL,
    sua_11pid character varying(15),
    dt_create date,
    dt_retire date,
    sua_11code integer,
    sua_11name character varying(50),
    area_sqkm double precision
);


ALTER TABLE aus_sua_2011 OWNER TO postgres;

--
-- Name: aus_sua_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sua_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sua_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_sua_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sua_2011_gid_seq OWNED BY aus_sua_2011.gid;


--
-- Name: aus_sua_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_sua_2011_polygon (
    gid integer NOT NULL,
    sua_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    sua_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_sua_2011_polygon OWNER TO postgres;

--
-- Name: aus_sua_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_sua_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_sua_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_sua_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_sua_2011_polygon_gid_seq OWNED BY aus_sua_2011_polygon.gid;


--
-- Name: aus_town; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_town (
    gid integer NOT NULL,
    town_pid character varying(15),
    date_creat date,
    date_retir date,
    town_class character varying(1),
    town_name character varying(50),
    population character varying(15),
    state_pid character varying(15)
);


ALTER TABLE aus_town OWNER TO postgres;

--
-- Name: aus_town_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_town_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_town_gid_seq OWNER TO postgres;

--
-- Name: aus_town_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_town_gid_seq OWNED BY aus_town.gid;


--
-- Name: aus_town_point; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_town_point (
    gid integer NOT NULL,
    town_point character varying(15),
    date_creat date,
    date_retir date,
    town_pid character varying(15)
);


ALTER TABLE aus_town_point OWNER TO postgres;

--
-- Name: aus_town_point_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_town_point_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_town_point_gid_seq OWNER TO postgres;

--
-- Name: aus_town_point_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_town_point_gid_seq OWNED BY aus_town_point.gid;


--
-- Name: aus_ucl_2011; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_ucl_2011 (
    gid integer NOT NULL,
    ucl_11pid character varying(15),
    dt_create date,
    dt_retire date,
    ucl_11code integer,
    ucl_11name character varying(50),
    ssr_11code integer,
    ssr_11name character varying(50),
    sos_11code integer,
    sos_11name character varying(50),
    state_pid character varying(15),
    area_sqkm double precision
);


ALTER TABLE aus_ucl_2011 OWNER TO postgres;

--
-- Name: aus_ucl_2011_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_ucl_2011_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_ucl_2011_gid_seq OWNER TO postgres;

--
-- Name: aus_ucl_2011_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_ucl_2011_gid_seq OWNED BY aus_ucl_2011.gid;


--
-- Name: aus_ucl_2011_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_ucl_2011_polygon (
    gid integer NOT NULL,
    ucl_11ppid character varying(15),
    dt_create date,
    dt_retire date,
    ucl_11pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_ucl_2011_polygon OWNER TO postgres;

--
-- Name: aus_ucl_2011_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_ucl_2011_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_ucl_2011_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_ucl_2011_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_ucl_2011_polygon_gid_seq OWNED BY aus_ucl_2011_polygon.gid;


--
-- Name: aus_ward; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_ward (
    gid integer NOT NULL,
    ward_pid character varying(15),
    dt_create date,
    dt_retire date,
    name character varying(100),
    dt_gazetd date,
    lga_pid character varying(15),
    state_pid character varying(15)
);


ALTER TABLE aus_ward OWNER TO postgres;

--
-- Name: aus_ward_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_ward_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_ward_gid_seq OWNER TO postgres;

--
-- Name: aus_ward_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_ward_gid_seq OWNED BY aus_ward.gid;


--
-- Name: aus_ward_polygon; Type: TABLE; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

CREATE TABLE aus_ward_polygon (
    gid integer NOT NULL,
    wd_ply_pid character varying(15),
    dt_create date,
    dt_retire date,
    ward_pid character varying(15),
    geom public.geometry(MultiPolygon,4283)
);


ALTER TABLE aus_ward_polygon OWNER TO postgres;

--
-- Name: aus_ward_polygon_gid_seq; Type: SEQUENCE; Schema: raw_admin_bdys; Owner: postgres
--

CREATE SEQUENCE aus_ward_polygon_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aus_ward_polygon_gid_seq OWNER TO postgres;

--
-- Name: aus_ward_polygon_gid_seq; Type: SEQUENCE OWNED BY; Schema: raw_admin_bdys; Owner: postgres
--

ALTER SEQUENCE aus_ward_polygon_gid_seq OWNED BY aus_ward_polygon.gid;


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_comm_electoral ALTER COLUMN gid SET DEFAULT nextval('aus_comm_electoral_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_comm_electoral_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_comm_electoral_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_gccsa_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_gccsa_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_gccsa_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_gccsa_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_iare_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_iare_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_iare_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_iare_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_iloc_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_iloc_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_iloc_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_iloc_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_ireg_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_ireg_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_ireg_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_ireg_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_lga ALTER COLUMN gid SET DEFAULT nextval('aus_lga_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_lga_locality ALTER COLUMN gid SET DEFAULT nextval('aus_lga_locality_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_lga_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_lga_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_locality ALTER COLUMN gid SET DEFAULT nextval('aus_locality_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_locality_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_locality_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_locality_town ALTER COLUMN gid SET DEFAULT nextval('aus_locality_town_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_mb_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_mb_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_mb_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_mb_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_remoteness_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_remoteness_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_remoteness_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_remoteness_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sa1_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sa1_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sa1_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sa1_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sa2_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sa2_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sa2_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sa2_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sa3_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sa3_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sa3_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sa3_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sa4_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sa4_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sa4_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sa4_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_seifa_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_seifa_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sos_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sos_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sos_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sos_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sosr_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sosr_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sosr_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sosr_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_state ALTER COLUMN gid SET DEFAULT nextval('aus_state_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_state_electoral ALTER COLUMN gid SET DEFAULT nextval('aus_state_electoral_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_state_electoral_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_state_electoral_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_state_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_state_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sua_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_sua_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_sua_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_sua_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_town ALTER COLUMN gid SET DEFAULT nextval('aus_town_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_town_point ALTER COLUMN gid SET DEFAULT nextval('aus_town_point_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_ucl_2011 ALTER COLUMN gid SET DEFAULT nextval('aus_ucl_2011_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_ucl_2011_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_ucl_2011_polygon_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_ward ALTER COLUMN gid SET DEFAULT nextval('aus_ward_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: raw_admin_bdys; Owner: postgres
--

ALTER TABLE ONLY aus_ward_polygon ALTER COLUMN gid SET DEFAULT nextval('aus_ward_polygon_gid_seq'::regclass);


--
-- Name: aus_comm_electoral_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_comm_electoral
    ADD CONSTRAINT aus_comm_electoral_pkey PRIMARY KEY (gid);


--
-- Name: aus_comm_electoral_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_comm_electoral_polygon
    ADD CONSTRAINT aus_comm_electoral_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_gccsa_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_gccsa_2011
    ADD CONSTRAINT aus_gccsa_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_gccsa_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_gccsa_2011_polygon
    ADD CONSTRAINT aus_gccsa_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_iare_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_iare_2011
    ADD CONSTRAINT aus_iare_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_iare_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_iare_2011_polygon
    ADD CONSTRAINT aus_iare_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_iloc_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_iloc_2011
    ADD CONSTRAINT aus_iloc_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_iloc_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_iloc_2011_polygon
    ADD CONSTRAINT aus_iloc_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_ireg_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_ireg_2011
    ADD CONSTRAINT aus_ireg_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_ireg_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_ireg_2011_polygon
    ADD CONSTRAINT aus_ireg_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_lga_locality_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_lga_locality
    ADD CONSTRAINT aus_lga_locality_pkey PRIMARY KEY (gid);


--
-- Name: aus_lga_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_lga
    ADD CONSTRAINT aus_lga_pkey PRIMARY KEY (gid);


--
-- Name: aus_lga_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_lga_polygon
    ADD CONSTRAINT aus_lga_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_locality_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_locality
    ADD CONSTRAINT aus_locality_pkey PRIMARY KEY (gid);


--
-- Name: aus_locality_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_locality_polygon
    ADD CONSTRAINT aus_locality_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_locality_town_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_locality_town
    ADD CONSTRAINT aus_locality_town_pkey PRIMARY KEY (gid);


--
-- Name: aus_mb_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_mb_2011
    ADD CONSTRAINT aus_mb_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_mb_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_mb_2011_polygon
    ADD CONSTRAINT aus_mb_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_remoteness_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_remoteness_2011
    ADD CONSTRAINT aus_remoteness_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_remoteness_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_remoteness_2011_polygon
    ADD CONSTRAINT aus_remoteness_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_sa1_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sa1_2011
    ADD CONSTRAINT aus_sa1_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_sa1_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sa1_2011_polygon
    ADD CONSTRAINT aus_sa1_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_sa2_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sa2_2011
    ADD CONSTRAINT aus_sa2_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_sa2_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sa2_2011_polygon
    ADD CONSTRAINT aus_sa2_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_sa3_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sa3_2011
    ADD CONSTRAINT aus_sa3_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_sa3_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sa3_2011_polygon
    ADD CONSTRAINT aus_sa3_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_sa4_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sa4_2011
    ADD CONSTRAINT aus_sa4_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_sa4_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sa4_2011_polygon
    ADD CONSTRAINT aus_sa4_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_seifa_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_seifa_2011
    ADD CONSTRAINT aus_seifa_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_sos_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sos_2011
    ADD CONSTRAINT aus_sos_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_sos_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sos_2011_polygon
    ADD CONSTRAINT aus_sos_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_sosr_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sosr_2011
    ADD CONSTRAINT aus_sosr_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_sosr_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sosr_2011_polygon
    ADD CONSTRAINT aus_sosr_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_state_electoral_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_state_electoral
    ADD CONSTRAINT aus_state_electoral_pkey PRIMARY KEY (gid);


--
-- Name: aus_state_electoral_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_state_electoral_polygon
    ADD CONSTRAINT aus_state_electoral_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_state_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_state
    ADD CONSTRAINT aus_state_pkey PRIMARY KEY (gid);


--
-- Name: aus_state_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_state_polygon
    ADD CONSTRAINT aus_state_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_sua_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sua_2011
    ADD CONSTRAINT aus_sua_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_sua_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_sua_2011_polygon
    ADD CONSTRAINT aus_sua_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_town_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_town
    ADD CONSTRAINT aus_town_pkey PRIMARY KEY (gid);


--
-- Name: aus_town_point_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_town_point
    ADD CONSTRAINT aus_town_point_pkey PRIMARY KEY (gid);


--
-- Name: aus_ucl_2011_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_ucl_2011
    ADD CONSTRAINT aus_ucl_2011_pkey PRIMARY KEY (gid);


--
-- Name: aus_ucl_2011_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_ucl_2011_polygon
    ADD CONSTRAINT aus_ucl_2011_polygon_pkey PRIMARY KEY (gid);


--
-- Name: aus_ward_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_ward
    ADD CONSTRAINT aus_ward_pkey PRIMARY KEY (gid);


--
-- Name: aus_ward_polygon_pkey; Type: CONSTRAINT; Schema: raw_admin_bdys; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aus_ward_polygon
    ADD CONSTRAINT aus_ward_polygon_pkey PRIMARY KEY (gid);


--
-- PostgreSQL database dump complete
--

