
--
-- Name: address_alias_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_alias
    ADD CONSTRAINT address_alias_pk PRIMARY KEY (address_alias_pid);


--
-- Name: address_alias_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_alias_type_aut
    ADD CONSTRAINT address_alias_type_aut_pk PRIMARY KEY (code);


--
-- Name: address_default_geocode_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_default_geocode
    ADD CONSTRAINT address_default_geocode_pk PRIMARY KEY (address_default_geocode_pid);


--
-- Name: address_detail_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_detail
    ADD CONSTRAINT address_detail_pk PRIMARY KEY (address_detail_pid);


--
-- Name: address_mesh_block_2011_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_mesh_block_2011
    ADD CONSTRAINT address_mesh_block_2011_pk PRIMARY KEY (address_mesh_block_2011_pid);


--
-- Name: address_mesh_block_2016_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY address_mesh_block_2016
    ADD CONSTRAINT address_mesh_block_2016_pk PRIMARY KEY (address_mesh_block_2016_pid);


--
-- Name: address_site_geocode_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_site_geocode
    ADD CONSTRAINT address_site_geocode_pk PRIMARY KEY (address_site_geocode_pid);


--
-- Name: address_site_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_site
    ADD CONSTRAINT address_site_pk PRIMARY KEY (address_site_pid);


--
-- Name: address_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_type_aut
    ADD CONSTRAINT address_type_aut_pk PRIMARY KEY (code);


--
-- Name: flat_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY flat_type_aut
    ADD CONSTRAINT flat_type_aut_pk PRIMARY KEY (code);


--
-- Name: geocode_reliability_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geocode_reliability_aut
    ADD CONSTRAINT geocode_reliability_aut_pk PRIMARY KEY (code);


--
-- Name: geocode_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geocode_type_aut
    ADD CONSTRAINT geocode_type_aut_pk PRIMARY KEY (code);


--
-- Name: geocoded_level_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geocoded_level_type_aut
    ADD CONSTRAINT geocoded_level_type_aut_pk PRIMARY KEY (code);


--
-- Name: level_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY level_type_aut
    ADD CONSTRAINT level_type_aut_pk PRIMARY KEY (code);


--
-- Name: locality_alias_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY locality_alias
    ADD CONSTRAINT locality_alias_pk PRIMARY KEY (locality_alias_pid);


--
-- Name: locality_alias_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY locality_alias_type_aut
    ADD CONSTRAINT locality_alias_type_aut_pk PRIMARY KEY (code);


--
-- Name: locality_class_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY locality_class_aut
    ADD CONSTRAINT locality_class_aut_pk PRIMARY KEY (code);


--
-- Name: locality_neighbour_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY locality_neighbour
    ADD CONSTRAINT locality_neighbour_pk PRIMARY KEY (locality_neighbour_pid);


--
-- Name: locality_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY locality
    ADD CONSTRAINT locality_pk PRIMARY KEY (locality_pid);


--
-- Name: locality_point_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY locality_point
    ADD CONSTRAINT locality_point_pk PRIMARY KEY (locality_point_pid);


--
-- Name: mb_2011_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mb_2011
    ADD CONSTRAINT mb_2011_pk PRIMARY KEY (mb_2011_pid);


--
-- Name: mb_2016_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY mb_2016
    ADD CONSTRAINT mb_2016_pk PRIMARY KEY (mb_2016_pid);


--
-- Name: mb_match_code_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mb_match_code_aut
    ADD CONSTRAINT mb_match_code_aut_pk PRIMARY KEY (code);


--
-- Name: primary_secondary_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY primary_secondary
    ADD CONSTRAINT primary_secondary_pk PRIMARY KEY (primary_secondary_pid);


--
-- Name: ps_join_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ps_join_type_aut
    ADD CONSTRAINT ps_join_type_aut_pk PRIMARY KEY (code);


--
-- Name: state_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY state
    ADD CONSTRAINT state_pk PRIMARY KEY (state_pid);


--
-- Name: street_class_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_class_aut
    ADD CONSTRAINT street_class_aut_pk PRIMARY KEY (code);


--
-- Name: street_locality_alias_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_locality_alias
    ADD CONSTRAINT street_locality_alias_pk PRIMARY KEY (street_locality_alias_pid);


--
-- Name: street_locality_alias_type__pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_locality_alias_type_aut
    ADD CONSTRAINT street_locality_alias_type__pk PRIMARY KEY (code);


--
-- Name: street_locality_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_locality
    ADD CONSTRAINT street_locality_pk PRIMARY KEY (street_locality_pid);


--
-- Name: street_locality_point_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_locality_point
    ADD CONSTRAINT street_locality_point_pk PRIMARY KEY (street_locality_point_pid);


--
-- Name: street_suffix_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_suffix_aut
    ADD CONSTRAINT street_suffix_aut_pk PRIMARY KEY (code);


--
-- Name: street_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_type_aut
    ADD CONSTRAINT street_type_aut_pk PRIMARY KEY (code);


--
-- Name: address_alias_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_alias
    ADD CONSTRAINT address_alias_fk1 FOREIGN KEY (alias_pid) REFERENCES address_detail(address_detail_pid);


--
-- Name: address_alias_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_alias
    ADD CONSTRAINT address_alias_fk2 FOREIGN KEY (alias_type_code) REFERENCES address_alias_type_aut(code);


--
-- Name: address_alias_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_alias
    ADD CONSTRAINT address_alias_fk3 FOREIGN KEY (principal_pid) REFERENCES address_detail(address_detail_pid);


--
-- Name: address_default_geocode_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_default_geocode
    ADD CONSTRAINT address_default_geocode_fk1 FOREIGN KEY (address_detail_pid) REFERENCES address_detail(address_detail_pid);


--
-- Name: address_default_geocode_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_default_geocode
    ADD CONSTRAINT address_default_geocode_fk2 FOREIGN KEY (geocode_type_code) REFERENCES geocode_type_aut(code);


--
-- Name: address_detail_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_detail
    ADD CONSTRAINT address_detail_fk1 FOREIGN KEY (address_site_pid) REFERENCES address_site(address_site_pid);


--
-- Name: address_detail_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_detail
    ADD CONSTRAINT address_detail_fk2 FOREIGN KEY (flat_type_code) REFERENCES flat_type_aut(code);


--
-- Name: address_detail_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_detail
    ADD CONSTRAINT address_detail_fk3 FOREIGN KEY (level_geocoded_code) REFERENCES geocoded_level_type_aut(code);


--
-- Name: address_detail_fk4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_detail
    ADD CONSTRAINT address_detail_fk4 FOREIGN KEY (level_type_code) REFERENCES level_type_aut(code);


--
-- Name: address_detail_fk5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_detail
    ADD CONSTRAINT address_detail_fk5 FOREIGN KEY (locality_pid) REFERENCES locality(locality_pid);


--
-- Name: address_detail_fk6; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_detail
    ADD CONSTRAINT address_detail_fk6 FOREIGN KEY (street_locality_pid) REFERENCES street_locality(street_locality_pid);


--
-- Name: address_mesh_block_2011_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2011
    ADD CONSTRAINT address_mesh_block_2011_fk1 FOREIGN KEY (address_detail_pid) REFERENCES address_detail(address_detail_pid);


--
-- Name: address_mesh_block_2011_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2011
    ADD CONSTRAINT address_mesh_block_2011_fk2 FOREIGN KEY (mb_2011_pid) REFERENCES mb_2011(mb_2011_pid);


--
-- Name: address_mesh_block_2011_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2011
    ADD CONSTRAINT address_mesh_block_2011_fk3 FOREIGN KEY (mb_match_code) REFERENCES mb_match_code_aut(code);


--
-- Name: address_mesh_block_2016_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2016
    ADD CONSTRAINT address_mesh_block_2016_fk1 FOREIGN KEY (address_detail_pid) REFERENCES address_detail(address_detail_pid);


--
-- Name: address_mesh_block_2016_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2016
    ADD CONSTRAINT address_mesh_block_2016_fk2 FOREIGN KEY (mb_2016_pid) REFERENCES mb_2016(mb_2016_pid);


--
-- Name: address_mesh_block_2016_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2016
    ADD CONSTRAINT address_mesh_block_2016_fk3 FOREIGN KEY (mb_match_code) REFERENCES mb_match_code_aut(code);


--
-- Name: address_site_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_site
    ADD CONSTRAINT address_site_fk1 FOREIGN KEY (address_type) REFERENCES address_type_aut(code);


--
-- Name: address_site_geocode_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_site_geocode
    ADD CONSTRAINT address_site_geocode_fk1 FOREIGN KEY (address_site_pid) REFERENCES address_site(address_site_pid);


--
-- Name: address_site_geocode_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_site_geocode
    ADD CONSTRAINT address_site_geocode_fk2 FOREIGN KEY (geocode_type_code) REFERENCES geocode_type_aut(code);


--
-- Name: address_site_geocode_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_site_geocode
    ADD CONSTRAINT address_site_geocode_fk3 FOREIGN KEY (reliability_code) REFERENCES geocode_reliability_aut(code);


--
-- Name: locality_alias_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality_alias
    ADD CONSTRAINT locality_alias_fk1 FOREIGN KEY (alias_type_code) REFERENCES locality_alias_type_aut(code);


--
-- Name: locality_alias_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality_alias
    ADD CONSTRAINT locality_alias_fk2 FOREIGN KEY (locality_pid) REFERENCES locality(locality_pid);


--
-- Name: locality_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality
    ADD CONSTRAINT locality_fk1 FOREIGN KEY (gnaf_reliability_code) REFERENCES geocode_reliability_aut(code);


--
-- Name: locality_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality
    ADD CONSTRAINT locality_fk2 FOREIGN KEY (locality_class_code) REFERENCES locality_class_aut(code);


--
-- Name: locality_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality
    ADD CONSTRAINT locality_fk3 FOREIGN KEY (state_pid) REFERENCES state(state_pid);


--
-- Name: locality_neighbour_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality_neighbour
    ADD CONSTRAINT locality_neighbour_fk1 FOREIGN KEY (locality_pid) REFERENCES locality(locality_pid);


--
-- Name: locality_neighbour_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality_neighbour
    ADD CONSTRAINT locality_neighbour_fk2 FOREIGN KEY (neighbour_locality_pid) REFERENCES locality(locality_pid);


--
-- Name: locality_point_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality_point
    ADD CONSTRAINT locality_point_fk1 FOREIGN KEY (locality_pid) REFERENCES locality(locality_pid);


--
-- Name: primary_secondary_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY primary_secondary
    ADD CONSTRAINT primary_secondary_fk1 FOREIGN KEY (primary_pid) REFERENCES address_detail(address_detail_pid);


--
-- Name: primary_secondary_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY primary_secondary
    ADD CONSTRAINT primary_secondary_fk2 FOREIGN KEY (ps_join_type_code) REFERENCES ps_join_type_aut(code);


--
-- Name: primary_secondary_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY primary_secondary
    ADD CONSTRAINT primary_secondary_fk3 FOREIGN KEY (secondary_pid) REFERENCES address_detail(address_detail_pid);


--
-- Name: street_locality_alias_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality_alias
    ADD CONSTRAINT street_locality_alias_fk1 FOREIGN KEY (alias_type_code) REFERENCES street_locality_alias_type_aut(code);


--
-- Name: street_locality_alias_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality_alias
    ADD CONSTRAINT street_locality_alias_fk2 FOREIGN KEY (street_locality_pid) REFERENCES street_locality(street_locality_pid);


--
-- Name: street_locality_alias_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality_alias
    ADD CONSTRAINT street_locality_alias_fk3 FOREIGN KEY (street_suffix_code) REFERENCES street_suffix_aut(code);


--
-- Name: street_locality_alias_fk4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality_alias
    ADD CONSTRAINT street_locality_alias_fk4 FOREIGN KEY (street_type_code) REFERENCES street_type_aut(code);


--
-- Name: street_locality_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality
    ADD CONSTRAINT street_locality_fk1 FOREIGN KEY (gnaf_reliability_code) REFERENCES geocode_reliability_aut(code);


--
-- Name: street_locality_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality
    ADD CONSTRAINT street_locality_fk2 FOREIGN KEY (locality_pid) REFERENCES locality(locality_pid);


--
-- Name: street_locality_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality
    ADD CONSTRAINT street_locality_fk3 FOREIGN KEY (street_class_code) REFERENCES street_class_aut(code);


--
-- Name: street_locality_fk4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality
    ADD CONSTRAINT street_locality_fk4 FOREIGN KEY (street_suffix_code) REFERENCES street_suffix_aut(code);


--
-- Name: street_locality_fk5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality
    ADD CONSTRAINT street_locality_fk5 FOREIGN KEY (street_type_code) REFERENCES street_type_aut(code);


--
-- Name: street_locality_point_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality_point
    ADD CONSTRAINT street_locality_point_fk1 FOREIGN KEY (street_locality_pid) REFERENCES street_locality(street_locality_pid);

