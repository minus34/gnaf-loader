--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: address_alias; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_alias (
    address_alias_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    principal_pid character varying(15) NOT NULL,
    alias_pid character varying(15) NOT NULL,
    alias_type_code character varying(10) NOT NULL,
    alias_comment character varying(200)
);


ALTER TABLE address_alias OWNER TO postgres;

--
-- Name: address_alias_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_alias_type_aut (
    code character varying(10) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(30)
);


ALTER TABLE address_alias_type_aut OWNER TO postgres;

--
-- Name: address_default_geocode; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_default_geocode (
    address_default_geocode_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    address_detail_pid character varying(15) NOT NULL,
    geocode_type_code character varying(4) NOT NULL,
    longitude numeric(11,8),
    latitude numeric(10,8)
);


ALTER TABLE address_default_geocode OWNER TO postgres;

--
-- Name: address_detail; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_detail (
    address_detail_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_last_modified date,
    date_retired date,
    building_name character varying(45),
    lot_number_prefix character varying(2),
    lot_number character varying(5),
    lot_number_suffix character varying(2),
    flat_type_code character varying(7),
    flat_number_prefix character varying(2),
    flat_number numeric(5,0),
    flat_number_suffix character varying(2),
    level_type_code character varying(4),
    level_number_prefix character varying(2),
    level_number numeric(3,0),
    level_number_suffix character varying(2),
    number_first_prefix character varying(3),
    number_first numeric(6,0),
    number_first_suffix character varying(2),
    number_last_prefix character varying(3),
    number_last numeric(6,0),
    number_last_suffix character varying(2),
    street_locality_pid character varying(15),
    location_description character varying(45),
    locality_pid character varying(15) NOT NULL,
    alias_principal character(1),
    postcode character varying(4),
    private_street character varying(75),
    legal_parcel_id character varying(20),
    confidence numeric(1,0),
    address_site_pid character varying(15) NOT NULL,
    level_geocoded_code numeric(2,0) NOT NULL,
    property_pid character varying(15),
    gnaf_property_pid character varying(15),
    primary_secondary character varying(1)
);


ALTER TABLE address_detail OWNER TO postgres;

--
-- Name: address_mesh_block_2016; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE address_mesh_block_2016 (
    address_mesh_block_2016_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    address_detail_pid character varying(15) NOT NULL,
    mb_match_code character varying(15) NOT NULL,
    mb_2016_pid character varying(15) NOT NULL
);


ALTER TABLE address_mesh_block_2016 OWNER TO postgres;

--
-- Name: address_mesh_block_2011; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_mesh_block_2011 (
    address_mesh_block_2011_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    address_detail_pid character varying(15) NOT NULL,
    mb_match_code character varying(15) NOT NULL,
    mb_2011_pid character varying(15) NOT NULL
);


ALTER TABLE address_mesh_block_2011 OWNER TO postgres;

--
-- Name: address_site; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_site (
    address_site_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    address_type character varying(8),
    address_site_name character varying(45)
);


ALTER TABLE address_site OWNER TO postgres;

--
-- Name: address_site_geocode; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_site_geocode (
    address_site_geocode_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    address_site_pid character varying(15),
    geocode_site_name character varying(46),
    geocode_site_description character varying(45),
    geocode_type_code character varying(4),
    reliability_code numeric(1,0) NOT NULL,
    boundary_extent numeric(7,0),
    planimetric_accuracy numeric(12,0),
    elevation numeric(7,0),
    longitude numeric(11,8),
    latitude numeric(10,8)
);


ALTER TABLE address_site_geocode OWNER TO postgres;

--
-- Name: address_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_type_aut (
    code character varying(8) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(30)
);


ALTER TABLE address_type_aut OWNER TO postgres;

--
-- Name: flat_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE flat_type_aut (
    code character varying(7) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(30)
);


ALTER TABLE flat_type_aut OWNER TO postgres;

--
-- Name: geocode_reliability_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geocode_reliability_aut (
    code numeric(1,0) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(100)
);


ALTER TABLE geocode_reliability_aut OWNER TO postgres;

--
-- Name: geocode_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geocode_type_aut (
    code character varying(4) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(250)
);


ALTER TABLE geocode_type_aut OWNER TO postgres;

--
-- Name: geocoded_level_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geocoded_level_type_aut (
    code numeric(2,0) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(70)
);


ALTER TABLE geocoded_level_type_aut OWNER TO postgres;

--
-- Name: level_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE level_type_aut (
    code character varying(4) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(30)
);


ALTER TABLE level_type_aut OWNER TO postgres;

--
-- Name: locality; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE locality (
    locality_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    locality_name character varying(100) NOT NULL,
    primary_postcode character varying(4),
    locality_class_code character(1) NOT NULL,
    state_pid character varying(15) NOT NULL,
    gnaf_locality_pid character varying(15),
    gnaf_reliability_code numeric(1,0) NOT NULL
);


ALTER TABLE locality OWNER TO postgres;

--
-- Name: locality_alias; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE locality_alias (
    locality_alias_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    locality_pid character varying(15) NOT NULL,
    name character varying(100) NOT NULL,
    postcode character varying(4),
    alias_type_code character varying(10) NOT NULL,
    state_pid character varying(15) NOT NULL
);


ALTER TABLE locality_alias OWNER TO postgres;

--
-- Name: locality_alias_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE locality_alias_type_aut (
    code character varying(10) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(100)
);


ALTER TABLE locality_alias_type_aut OWNER TO postgres;

--
-- Name: locality_class_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE locality_class_aut (
    code character(1) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(200)
);


ALTER TABLE locality_class_aut OWNER TO postgres;

--
-- Name: locality_neighbour; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE locality_neighbour (
    locality_neighbour_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    locality_pid character varying(15) NOT NULL,
    neighbour_locality_pid character varying(15) NOT NULL
);


ALTER TABLE locality_neighbour OWNER TO postgres;

--
-- Name: locality_point; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE locality_point (
    locality_point_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    locality_pid character varying(15) NOT NULL,
    planimetric_accuracy numeric(12,0),
    longitude numeric(11,8),
    latitude numeric(10,8)
);


ALTER TABLE locality_point OWNER TO postgres;

--
-- Name: mb_2016; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE mb_2016 (
    mb_2016_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    mb_2016_code character varying(15) NOT NULL
);


ALTER TABLE mb_2016 OWNER TO postgres;


--
-- Name: mb_2011; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mb_2011 (
    mb_2011_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    mb_2011_code character varying(15) NOT NULL
);


ALTER TABLE mb_2011 OWNER TO postgres;

--
-- Name: mb_match_code_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mb_match_code_aut (
    code character varying(15) NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(250)
);


ALTER TABLE mb_match_code_aut OWNER TO postgres;

--
-- Name: primary_secondary; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE primary_secondary (
    primary_secondary_pid character varying(15) NOT NULL,
    primary_pid character varying(15) NOT NULL,
    secondary_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    ps_join_type_code numeric(2,0) NOT NULL,
    ps_join_comment character varying(500)
);


ALTER TABLE primary_secondary OWNER TO postgres;

--
-- Name: ps_join_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ps_join_type_aut (
    code numeric(2,0) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(500)
);


ALTER TABLE ps_join_type_aut OWNER TO postgres;

--
-- Name: state; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE state (
    state_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    state_name character varying(50) NOT NULL,
    state_abbreviation character varying(3) NOT NULL
);


ALTER TABLE state OWNER TO postgres;

--
-- Name: street_class_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE street_class_aut (
    code character(1) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(200)
);


ALTER TABLE street_class_aut OWNER TO postgres;

--
-- Name: street_locality; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE street_locality (
    street_locality_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    street_class_code character(1) NOT NULL,
    street_name character varying(100) NOT NULL,
    street_type_code character varying(15),
    street_suffix_code character varying(15),
    locality_pid character varying(15) NOT NULL,
    gnaf_street_pid character varying(15),
    gnaf_street_confidence numeric(1,0),
    gnaf_reliability_code numeric(1,0) NOT NULL
);


ALTER TABLE street_locality OWNER TO postgres;

--
-- Name: street_locality_alias; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE street_locality_alias (
    street_locality_alias_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    street_locality_pid character varying(15) NOT NULL,
    street_name character varying(100) NOT NULL,
    street_type_code character varying(15),
    street_suffix_code character varying(15),
    alias_type_code character varying(10) NOT NULL
);


ALTER TABLE street_locality_alias OWNER TO postgres;

--
-- Name: street_locality_alias_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE street_locality_alias_type_aut (
    code character varying(10) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(15)
);


ALTER TABLE street_locality_alias_type_aut OWNER TO postgres;

--
-- Name: street_locality_point; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE street_locality_point (
    street_locality_point_pid character varying(15) NOT NULL,
    date_created date NOT NULL,
    date_retired date,
    street_locality_pid character varying(15) NOT NULL,
    boundary_extent numeric(7,0),
    planimetric_accuracy numeric(12,0),
    longitude numeric(11,8),
    latitude numeric(10,8)
);


ALTER TABLE street_locality_point OWNER TO postgres;

--
-- Name: street_suffix_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE street_suffix_aut (
    code character varying(15) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(30)
);


ALTER TABLE street_suffix_aut OWNER TO postgres;

--
-- Name: street_type_aut; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE street_type_aut (
    code character varying(15) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(15)
);


ALTER TABLE street_type_aut OWNER TO postgres;


REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;
