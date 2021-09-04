
--
-- Name: address_alias_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_alias_type_aut
    ADD CONSTRAINT address_alias_type_aut_pk PRIMARY KEY (code);


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
-- Name: mb_match_code_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mb_match_code_aut
    ADD CONSTRAINT mb_match_code_aut_pk PRIMARY KEY (code);


--
-- Name: ps_join_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ps_join_type_aut
    ADD CONSTRAINT ps_join_type_aut_pk PRIMARY KEY (code);


--
-- Name: street_class_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_class_aut
    ADD CONSTRAINT street_class_aut_pk PRIMARY KEY (code);


--
-- Name: street_locality_alias_type__pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_locality_alias_type_aut
    ADD CONSTRAINT street_locality_alias_type_pk PRIMARY KEY (code);


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
-- Name: address_change_type_aut_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY address_change_type_aut
    ADD CONSTRAINT address_change_type_aut_pk PRIMARY KEY (code);


--
-- Name: address_alias_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_alias
    ADD CONSTRAINT address_alias_fk2 FOREIGN KEY (alias_type_code) REFERENCES address_alias_type_aut(code);


--
-- Name: address_default_geocode_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_default_geocode
    ADD CONSTRAINT address_default_geocode_fk2 FOREIGN KEY (geocode_type_code) REFERENCES geocode_type_aut(code);


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
-- Name: address_mesh_block_2011_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2011
    ADD CONSTRAINT address_mesh_block_2011_fk3 FOREIGN KEY (mb_match_code) REFERENCES mb_match_code_aut(code);


--
-- Name: address_mesh_block_2021_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2021
    ADD CONSTRAINT address_mesh_block_2021_fk3 FOREIGN KEY (mb_match_code) REFERENCES mb_match_code_aut(code);


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
-- Name: primary_secondary_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY primary_secondary
    ADD CONSTRAINT primary_secondary_fk2 FOREIGN KEY (ps_join_type_code) REFERENCES ps_join_type_aut(code);


--
-- Name: street_locality_alias_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality_alias
    ADD CONSTRAINT street_locality_alias_fk1 FOREIGN KEY (alias_type_code) REFERENCES street_locality_alias_type_aut(code);


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
-- Name: address_feature_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_feature
    ADD CONSTRAINT address_feature_fk2 FOREIGN KEY (address_change_type_code) REFERENCES address_change_type_aut(code);
