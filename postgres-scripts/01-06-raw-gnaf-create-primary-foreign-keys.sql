
--
-- Name: address_alias_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_alias
    ADD CONSTRAINT address_alias_pk PRIMARY KEY (address_alias_pid);


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
-- Name: address_mesh_block_2021_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY address_mesh_block_2021
    ADD CONSTRAINT address_mesh_block_2021_pk PRIMARY KEY (address_mesh_block_2021_pid);


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
-- Name: locality_alias_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY locality_alias
    ADD CONSTRAINT locality_alias_pk PRIMARY KEY (locality_alias_pid);


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
-- Name: mb_2021_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY mb_2021
    ADD CONSTRAINT mb_2021_pk PRIMARY KEY (mb_2021_pid);


--
-- Name: mb_2016_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY mb_2016
    ADD CONSTRAINT mb_2016_pk PRIMARY KEY (mb_2016_pid);


--
-- Name: primary_secondary_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY primary_secondary
    ADD CONSTRAINT primary_secondary_pk PRIMARY KEY (primary_secondary_pid);


--
-- Name: state_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY state
    ADD CONSTRAINT state_pk PRIMARY KEY (state_pid);


--
-- Name: street_locality_alias_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY street_locality_alias
    ADD CONSTRAINT street_locality_alias_pk PRIMARY KEY (street_locality_alias_pid);


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
-- Name: address_feature_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY address_feature
    ADD CONSTRAINT address_feature_pk PRIMARY KEY (address_feature_id);


--
-- Name: address_alias_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_alias
    ADD CONSTRAINT address_alias_fk1 FOREIGN KEY (alias_pid) REFERENCES address_detail(address_detail_pid);


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
-- Name: address_detail_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_detail
    ADD CONSTRAINT address_detail_fk1 FOREIGN KEY (address_site_pid) REFERENCES address_site(address_site_pid);


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
-- Name: address_mesh_block_2021_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2021
    ADD CONSTRAINT address_mesh_block_2021_fk1 FOREIGN KEY (address_detail_pid) REFERENCES address_detail(address_detail_pid);


--
-- Name: address_mesh_block_2021_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_mesh_block_2021
    ADD CONSTRAINT address_mesh_block_2021_fk2 FOREIGN KEY (mb_2021_pid) REFERENCES mb_2021(mb_2021_pid);


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
-- Name: address_site_geocode_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_site_geocode
    ADD CONSTRAINT address_site_geocode_fk1 FOREIGN KEY (address_site_pid) REFERENCES address_site(address_site_pid);


--
-- Name: locality_alias_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY locality_alias
    ADD CONSTRAINT locality_alias_fk2 FOREIGN KEY (locality_pid) REFERENCES locality(locality_pid);


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
-- Name: primary_secondary_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY primary_secondary
    ADD CONSTRAINT primary_secondary_fk3 FOREIGN KEY (secondary_pid) REFERENCES address_detail(address_detail_pid);


--
-- Name: street_locality_alias_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality_alias
    ADD CONSTRAINT street_locality_alias_fk2 FOREIGN KEY (street_locality_pid) REFERENCES street_locality(street_locality_pid);


--
-- Name: street_locality_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality
    ADD CONSTRAINT street_locality_fk2 FOREIGN KEY (locality_pid) REFERENCES locality(locality_pid);


--
-- Name: street_locality_point_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY street_locality_point
    ADD CONSTRAINT street_locality_point_fk1 FOREIGN KEY (street_locality_pid) REFERENCES street_locality(street_locality_pid);


--
-- Name: address_alias_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_feature
    ADD CONSTRAINT address_feature_fk1 FOREIGN KEY (address_detail_pid) REFERENCES address_detail(address_detail_pid);
