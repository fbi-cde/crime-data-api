ALTER TABLE ONLY nibrs_activity_type
    ADD CONSTRAINT nibrs_activity_type_pkey PRIMARY KEY (activity_type_id);

ALTER TABLE ONLY nibrs_age
    ADD CONSTRAINT nibrs_age_pkey PRIMARY KEY (age_id);

ALTER TABLE ONLY nibrs_arrest_type
    ADD CONSTRAINT nibrs_arrest_type_pkey PRIMARY KEY (arrest_type_id);

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_pkey PRIMARY KEY (arrestee_id);

ALTER TABLE ONLY nibrs_arrestee_weapon
    ADD CONSTRAINT nibrs_arrestee_weapon_pkey PRIMARY KEY (nibrs_arrestee_weapon_id);

ALTER TABLE ONLY nibrs_assignment_type
    ADD CONSTRAINT nibrs_assignment_type_pkey PRIMARY KEY (assignment_type_id);

ALTER TABLE ONLY nibrs_bias_list
    ADD CONSTRAINT nibrs_bias_list_pkey PRIMARY KEY (bias_id);

ALTER TABLE ONLY nibrs_bias_motivation
    ADD CONSTRAINT nibrs_bias_motivation_pkey PRIMARY KEY (bias_id, offense_id);

ALTER TABLE ONLY nibrs_circumstances
    ADD CONSTRAINT nibrs_circumstances_pkey PRIMARY KEY (circumstances_id);

ALTER TABLE ONLY nibrs_cleared_except
    ADD CONSTRAINT nibrs_cleared_except_pkey PRIMARY KEY (cleared_except_id);

ALTER TABLE ONLY nibrs_criminal_act
    ADD CONSTRAINT nibrs_criminal_act_pkey PRIMARY KEY (criminal_act_id, offense_id);

ALTER TABLE ONLY nibrs_criminal_act_type
    ADD CONSTRAINT nibrs_criminal_act_type_pkey PRIMARY KEY (criminal_act_id);

ALTER TABLE ONLY nibrs_drug_measure_type
    ADD CONSTRAINT nibrs_drug_measure_type_pkey PRIMARY KEY (drug_measure_type_id);

ALTER TABLE ONLY nibrs_ethnicity
    ADD CONSTRAINT nibrs_ethnicity_pkey PRIMARY KEY (ethnicity_id);

ALTER TABLE ONLY nibrs_incident
    ADD CONSTRAINT nibrs_incident_pkey PRIMARY KEY (incident_id);

ALTER TABLE ONLY nibrs_injury
    ADD CONSTRAINT nibrs_injury_pkey PRIMARY KEY (injury_id);

ALTER TABLE ONLY nibrs_justifiable_force
    ADD CONSTRAINT nibrs_justifiable_force_pkey PRIMARY KEY (justifiable_force_id);

ALTER TABLE ONLY nibrs_location_type
    ADD CONSTRAINT nibrs_location_type_pkey PRIMARY KEY (location_id);

ALTER TABLE ONLY nibrs_month
    ADD CONSTRAINT nibrs_month_pkey PRIMARY KEY (nibrs_month_id);

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_pkey PRIMARY KEY (offender_id);

ALTER TABLE ONLY nibrs_offense
    ADD CONSTRAINT nibrs_offense_pkey PRIMARY KEY (offense_id);

ALTER TABLE ONLY nibrs_offense_type
    ADD CONSTRAINT nibrs_offense_type_pkey PRIMARY KEY (offense_type_id);

ALTER TABLE ONLY nibrs_prop_desc_type
    ADD CONSTRAINT nibrs_prop_desc_type_pkey PRIMARY KEY (prop_desc_id);

ALTER TABLE ONLY nibrs_prop_loss_type
    ADD CONSTRAINT nibrs_prop_loss_type_pkey PRIMARY KEY (prop_loss_id);

ALTER TABLE ONLY nibrs_property_desc
    ADD CONSTRAINT nibrs_property_desc_pkey PRIMARY KEY (nibrs_prop_desc_id);

ALTER TABLE ONLY nibrs_property
    ADD CONSTRAINT nibrs_property_pkey PRIMARY KEY (property_id);

ALTER TABLE ONLY nibrs_relationship
    ADD CONSTRAINT nibrs_relationship_pkey PRIMARY KEY (relationship_id);

ALTER TABLE ONLY nibrs_suspect_using
    ADD CONSTRAINT nibrs_suspect_using_pkey PRIMARY KEY (suspect_using_id, offense_id);

ALTER TABLE ONLY nibrs_suspected_drug
    ADD CONSTRAINT nibrs_suspected_drug_pkey PRIMARY KEY (nibrs_suspected_drug_id);

ALTER TABLE ONLY nibrs_suspected_drug_type
    ADD CONSTRAINT nibrs_suspected_drug_type_pkey PRIMARY KEY (suspected_drug_type_id);

ALTER TABLE ONLY nibrs_using_list
    ADD CONSTRAINT nibrs_using_list_pkey PRIMARY KEY (suspect_using_id);

ALTER TABLE ONLY nibrs_victim_circumstances
    ADD CONSTRAINT nibrs_victim_circumstances_pkey PRIMARY KEY (victim_id, circumstances_id);

ALTER TABLE ONLY nibrs_victim_injury
    ADD CONSTRAINT nibrs_victim_injury_pkey PRIMARY KEY (victim_id, injury_id);

ALTER TABLE ONLY nibrs_victim_offender_rel
    ADD CONSTRAINT nibrs_victim_offender_rel_pkey PRIMARY KEY (nibrs_victim_offender_id);

ALTER TABLE ONLY nibrs_victim_offense
    ADD CONSTRAINT nibrs_victim_offense_pkey PRIMARY KEY (victim_id, offense_id);

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_pkey PRIMARY KEY (victim_id);

ALTER TABLE ONLY nibrs_victim_type
    ADD CONSTRAINT nibrs_victim_type_pkey PRIMARY KEY (victim_type_id);

ALTER TABLE ONLY nibrs_weapon
    ADD CONSTRAINT nibrs_weapon_pkey PRIMARY KEY (nibrs_weapon_id);

ALTER TABLE ONLY nibrs_weapon_type
    ADD CONSTRAINT nibrs_weapon_type_pkey PRIMARY KEY (weapon_id);

ALTER TABLE ONLY ref_race
    ADD CONSTRAINT ref_race_pkey PRIMARY KEY (race_id);

ALTER TABLE ONLY ref_state
    ADD CONSTRAINT ref_state_pkey PRIMARY KEY (state_id);


--
-- Other indices
--

CREATE INDEX ni_incnum_agency ON nibrs_incident USING btree (agency_id, incident_number);

CREATE INDEX nibrs_arr_weapon_arrestee_id ON nibrs_arrestee_weapon USING btree (arrestee_id);
CREATE INDEX nibrs_arrest_weap_type_ix ON nibrs_arrestee_weapon USING btree (weapon_id);

CREATE INDEX nibrs_arrestee_age_id_idx ON nibrs_arrestee USING btree (age_id);
CREATE INDEX nibrs_arrestee_age_ix ON nibrs_arrestee USING btree (age_id);
CREATE INDEX nibrs_arrestee_arrest_type_id_idx ON nibrs_arrestee USING btree (arrest_type_id);
CREATE INDEX nibrs_arrestee_arrest_type_ix ON nibrs_arrestee USING btree (arrest_type_id);
CREATE INDEX nibrs_arrestee_ethnicity_id_idx ON nibrs_arrestee USING btree (ethnicity_id);
CREATE INDEX nibrs_arrestee_ethnicity_ix ON nibrs_arrestee USING btree (ethnicity_id);
CREATE INDEX nibrs_arrestee_inc_id ON nibrs_arrestee USING btree (incident_id);
CREATE INDEX nibrs_arrestee_nibrs_race_ix ON nibrs_arrestee USING btree (race_id);
CREATE INDEX nibrs_arrestee_offense_type_id_idx ON nibrs_arrestee USING btree (offense_type_id);
CREATE INDEX nibrs_arrestee_offense_type_ix ON nibrs_arrestee USING btree (offense_type_id);
CREATE INDEX nibrs_arrestee_race_id_idx ON nibrs_arrestee USING btree (race_id);
CREATE INDEX nibrs_arrestee_weapon_arrestee_id_idx ON nibrs_arrestee_weapon USING btree (arrestee_id);
CREATE INDEX nibrs_arrestee_weapon_weapon_id_idx ON nibrs_arrestee_weapon USING btree (weapon_id);

CREATE INDEX nibrs_bias_motiv_off_id ON nibrs_bias_motivation USING btree (offense_id);

CREATE INDEX nibrs_criminal_act_off_id ON nibrs_criminal_act USING btree (offense_id);

CREATE INDEX nibrs_incident_agency_id_idx ON nibrs_incident USING btree (agency_id);
CREATE INDEX nibrs_incident_clear_ex_ix ON nibrs_incident USING btree (cleared_except_id);
CREATE INDEX nibrs_incident_cleared_except_id_idx ON nibrs_incident USING btree (cleared_except_id);
CREATE INDEX nibrs_incident_incid_agency ON nibrs_incident USING btree (agency_id, incident_id);
CREATE INDEX nibrs_incident_index1 ON nibrs_incident USING btree (nibrs_month_id);
CREATE INDEX nibrs_incident_index2 ON nibrs_incident USING btree (incident_number);
CREATE INDEX nibrs_incident_status_idx ON nibrs_incident USING btree (incident_status);

CREATE INDEX nibrs_month_agency_id_idx ON nibrs_month USING btree (agency_id);
CREATE UNIQUE INDEX nibrs_month_un ON nibrs_month USING btree (agency_id, month_num, data_year);

CREATE INDEX nibrs_offender_age_id_idx ON nibrs_offender USING btree (age_id);
CREATE INDEX nibrs_offender_age_ix ON nibrs_offender USING btree (age_id);
CREATE INDEX nibrs_offender_ethnicity_id_idx ON nibrs_offender USING btree (ethnicity_id);
CREATE INDEX nibrs_offender_ethnicity_ix ON nibrs_offender USING btree (ethnicity_id);

CREATE INDEX nibrs_offender_inc_id ON nibrs_offender USING btree (incident_id);
CREATE INDEX nibrs_offender_race_id_idx ON nibrs_offender USING btree (race_id);
CREATE INDEX nibrs_offender_race_ix ON nibrs_offender USING btree (race_id);

CREATE INDEX nibrs_offense_loc_type_ix ON nibrs_offense USING btree (location_id);
CREATE INDEX nibrs_offense_location_id_idx ON nibrs_offense USING btree (location_id);
CREATE INDEX nibrs_offense_off_type_ix ON nibrs_offense USING btree (offense_type_id);
CREATE INDEX nibrs_offense_offense_type_id_idx ON nibrs_offense USING btree (offense_type_id);
CREATE INDEX nibrs_offense_x1 ON nibrs_offense USING btree (incident_id);

CREATE INDEX nibrs_prop_desc_date_rec_ix ON nibrs_property_desc USING btree (date_recovered);
CREATE INDEX nibrs_property_desc_desc_id_in ON nibrs_property_desc USING btree (prop_desc_id);
CREATE INDEX nibrs_property_desc_prop_desc_id_idx ON nibrs_property_desc USING btree (prop_desc_id);
CREATE INDEX nibrs_property_desc_property_id_idx ON nibrs_property_desc USING btree (property_id);

CREATE INDEX nibrs_property_loss_type_ix ON nibrs_property USING btree (prop_loss_id);
CREATE INDEX nibrs_property_prop_loss_id_idx ON nibrs_property USING btree (prop_loss_id);
CREATE INDEX nibrs_property_property_id_in ON nibrs_property_desc USING btree (property_id);
CREATE INDEX nibrs_property_x1 ON nibrs_property USING btree (incident_id);

CREATE INDEX nibrs_susp_drug_meas_type_ix ON nibrs_suspected_drug USING btree (drug_measure_type_id);
CREATE INDEX nibrs_susp_drug_prop_id ON nibrs_suspected_drug USING btree (property_id);
CREATE INDEX nibrs_susp_drug_type_ix ON nibrs_suspected_drug USING btree (suspected_drug_type_id);

CREATE INDEX nibrs_suspect_using_code_idx ON nibrs_using_list USING btree (suspect_using_code);

CREATE INDEX nibrs_suspect_using_off_id ON nibrs_suspect_using USING btree (offense_id);

CREATE INDEX nibrs_vic_circ_nibrs_circ_ix ON nibrs_victim_circumstances USING btree (circumstances_id);
CREATE INDEX nibrs_victim_circ_just_hom_ix ON nibrs_victim_circumstances USING btree (justifiable_force_id);

CREATE INDEX nibrs_vic_injury_nibrs_inj_ix ON nibrs_victim_injury USING btree (injury_id);

CREATE INDEX nibrs_victims_vic_type_ix ON nibrs_victim USING btree (victim_type_id);
CREATE INDEX nibrs_victim_x1 ON nibrs_victim USING btree (incident_id);
CREATE INDEX nibrs_victim_act_type_ix ON nibrs_victim USING btree (activity_type_id);
CREATE INDEX nibrs_victim_age_id_idx ON nibrs_victim USING btree (age_id);
CREATE INDEX nibrs_victim_assign_type_ix ON nibrs_victim USING btree (assignment_type_id);
CREATE INDEX nibrs_victim_ethnicity_id_idx ON nibrs_victim USING btree (ethnicity_id);

CREATE INDEX nibrs_victim_injury_injury_id_idx ON nibrs_victim_injury USING btree (injury_id);

CREATE INDEX nibrs_victim_off_rel_rel_ix ON nibrs_victim_offender_rel USING btree (relationship_id);
CREATE INDEX nibrs_victim_offender_rel_off ON nibrs_victim_offender_rel USING btree (offender_id);
CREATE INDEX nibrs_victim_offender_rel_vic ON nibrs_victim_offender_rel USING btree (victim_id);

CREATE INDEX nibrs_victim_offense_off_id ON nibrs_victim_offense USING btree (offense_id);
CREATE INDEX nibrs_victim_offense_vic_id ON nibrs_victim_offense USING btree (victim_id);

CREATE INDEX nibrs_victim_race_id_idx ON nibrs_victim USING btree (race_id);

CREATE INDEX nibrs_victim_victim_type_id_idx ON nibrs_victim USING btree (victim_type_id);

CREATE INDEX nibrs_weap_weap_type_ix ON nibrs_weapon USING btree (weapon_id);
CREATE INDEX nibrs_weapon_off_id ON nibrs_weapon USING btree (offense_id);


CREATE UNIQUE INDEX ref_race_code ON ref_race USING btree (race_code);
CREATE INDEX ref_race_sort_order ON ref_race USING btree (sort_order);

CREATE INDEX ref_state_lower_idx ON ref_state USING btree (lower((state_abbr)::text));

--
-- Foreign Keys
--
ALTER TABLE ONLY nibrs_arrestee_weapon
    ADD CONSTRAINT nibrs_arrest_weap_arrest_fk FOREIGN KEY (arrestee_id) REFERENCES nibrs_arrestee(arrestee_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_arrestee_weapon
    ADD CONSTRAINT nibrs_arrest_weap_type_fk FOREIGN KEY (weapon_id) REFERENCES nibrs_weapon_type(weapon_id);

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_arrest_type_fk FOREIGN KEY (arrest_type_id) REFERENCES nibrs_arrest_type(arrest_type_id);

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_inc_fk FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_offense_type_fk FOREIGN KEY (offense_type_id) REFERENCES nibrs_offense_type(offense_type_id);

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);

ALTER TABLE ONLY nibrs_bias_motivation
    ADD CONSTRAINT nibrs_bias_mot_list_fk FOREIGN KEY (bias_id) REFERENCES nibrs_bias_list(bias_id);

ALTER TABLE ONLY nibrs_bias_motivation
    ADD CONSTRAINT nibrs_bias_mot_offense_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_criminal_act
    ADD CONSTRAINT nibrs_criminal_act_offense_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_criminal_act
    ADD CONSTRAINT nibrs_criminal_act_type_fk FOREIGN KEY (criminal_act_id) REFERENCES nibrs_criminal_act_type(criminal_act_id);

ALTER TABLE ONLY nibrs_incident
    ADD CONSTRAINT nibrs_incident_clear_ex_fk FOREIGN KEY (cleared_except_id) REFERENCES nibrs_cleared_except(cleared_except_id);

ALTER TABLE ONLY nibrs_incident
    ADD CONSTRAINT nibrs_incident_month_fk FOREIGN KEY (nibrs_month_id) REFERENCES nibrs_month(nibrs_month_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_nibrs_inci_fk1 FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);

ALTER TABLE ONLY nibrs_offense
    ADD CONSTRAINT nibrs_offense_inc_fk1 FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_offense
    ADD CONSTRAINT nibrs_offense_loc_type_fk FOREIGN KEY (location_id) REFERENCES nibrs_location_type(location_id);

ALTER TABLE ONLY nibrs_offense
    ADD CONSTRAINT nibrs_offense_off_type_fk FOREIGN KEY (offense_type_id) REFERENCES nibrs_offense_type(offense_type_id);

ALTER TABLE ONLY nibrs_property_desc
    ADD CONSTRAINT nibrs_prop_desc_prop_fk FOREIGN KEY (property_id) REFERENCES nibrs_property(property_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_property_desc
    ADD CONSTRAINT nibrs_prop_desc_type_fk FOREIGN KEY (prop_desc_id) REFERENCES nibrs_prop_desc_type(prop_desc_id);

ALTER TABLE ONLY nibrs_property
    ADD CONSTRAINT nibrs_property_inc_fk FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_property
    ADD CONSTRAINT nibrs_property_loss_type_fk FOREIGN KEY (prop_loss_id) REFERENCES nibrs_prop_loss_type(prop_loss_id);

ALTER TABLE ONLY nibrs_suspected_drug
    ADD CONSTRAINT nibrs_susp_drug_meas_type_fk FOREIGN KEY (drug_measure_type_id) REFERENCES nibrs_drug_measure_type(drug_measure_type_id);

ALTER TABLE ONLY nibrs_suspected_drug
    ADD CONSTRAINT nibrs_susp_drug_prop_fk FOREIGN KEY (property_id) REFERENCES nibrs_property(property_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_suspected_drug
    ADD CONSTRAINT nibrs_susp_drug_type_fk FOREIGN KEY (suspected_drug_type_id) REFERENCES nibrs_suspected_drug_type(suspected_drug_type_id);

ALTER TABLE ONLY nibrs_suspect_using
    ADD CONSTRAINT nibrs_suspect_using_list_fk FOREIGN KEY (suspect_using_id) REFERENCES nibrs_using_list(suspect_using_id);

ALTER TABLE ONLY nibrs_suspect_using
    ADD CONSTRAINT nibrs_suspect_using_off_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_victim_circumstances
    ADD CONSTRAINT nibrs_vic_circ_nibrs_circ_fk FOREIGN KEY (circumstances_id) REFERENCES nibrs_circumstances(circumstances_id);

ALTER TABLE ONLY nibrs_victim_circumstances
    ADD CONSTRAINT nibrs_vic_circ_nibrs_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_victim_injury
    ADD CONSTRAINT nibrs_vic_injury_nibrs_inj_fk FOREIGN KEY (injury_id) REFERENCES nibrs_injury(injury_id);

ALTER TABLE ONLY nibrs_victim_injury
    ADD CONSTRAINT nibrs_vic_injury_nibrs_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_victim_offense
    ADD CONSTRAINT nibrs_vic_off_nibrs_off_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_victim_offense
    ADD CONSTRAINT nibrs_vic_off_nibrs_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_act_type_fk FOREIGN KEY (activity_type_id) REFERENCES nibrs_activity_type(activity_type_id);

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_assign_type_fk FOREIGN KEY (assignment_type_id) REFERENCES nibrs_assignment_type(assignment_type_id);

ALTER TABLE ONLY nibrs_victim_circumstances
    ADD CONSTRAINT nibrs_victim_circ_just_hom_fk FOREIGN KEY (justifiable_force_id) REFERENCES nibrs_justifiable_force(justifiable_force_id);

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_inc_fk FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_victim_offender_rel
    ADD CONSTRAINT nibrs_victim_off_rel_off_fk FOREIGN KEY (offender_id) REFERENCES nibrs_offender(offender_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_victim_offender_rel
    ADD CONSTRAINT nibrs_victim_off_rel_rel_fk FOREIGN KEY (relationship_id) REFERENCES nibrs_relationship(relationship_id);

ALTER TABLE ONLY nibrs_victim_offender_rel
    ADD CONSTRAINT nibrs_victim_off_rel_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victims_vic_type_fk FOREIGN KEY (victim_type_id) REFERENCES nibrs_victim_type(victim_type_id);

ALTER TABLE ONLY nibrs_weapon
    ADD CONSTRAINT nibrs_weap_off_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

ALTER TABLE ONLY nibrs_weapon
    ADD CONSTRAINT nibrs_weap_weap_type_fk FOREIGN KEY (weapon_id) REFERENCES nibrs_weapon_type(weapon_id);
