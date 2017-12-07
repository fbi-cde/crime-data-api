-- This is not a standard UCR table but one derived from the reta_month/nibrs_month
CREATE TABLE agency_participation (
    year smallint NOT NULL,
    state_name character varying(100),
    state_abbr character varying(2),
    agency_id bigint NOT NULL REFERENCES cde_agencies(agency_id),
    agency_ori character(9),
    agency_name character varying(100),
    agency_population bigint,
    population_group_code character varying(2),
    population_group character varying(150),
    reported integer,
    months_reported integer,
    nibrs_reported integer,
    nibrs_months_reported integer,
    covered integer,
    participated integer,
    nibrs_participated integer
);

CREATE TABLE cde_agencies (
    agency_id bigint NOT NULL PRIMARY KEY,
    ori character(9) NOT NULL,
    legacy_ori character(9) NOT NULL,
    agency_name text,
    short_name text,
    agency_type_id smallint NOT NULL,
    agency_type_name text,
    tribe_id bigint,
    campus_id bigint,
    city_id bigint,
    city_name text,
    state_id smallint NOT NULL REFERENCES ref_state(state_id),
    state_abbr character(2) NOT NULL,
    primary_county_id bigint,
    primary_county text,
    primary_county_fips character varying(5),
    agency_status character(1),
    submitting_agency_id bigint,
    submitting_sai character varying(9),
    submitting_name text,
    submitting_state_abbr character varying(2),
    start_year smallint,
    dormant_year smallint,
    current_year smallint,
    revised_rape_start smallint,
    current_nibrs_start_year smallint,
    population bigint,
    population_group_code character varying(2),
    population_group_desc text,
    population_source_flag character varying(1),
    suburban_area_flag character varying(1),
    core_city_flag character varying(1),
    months_reported smallint,
    nibrs_months_reported smallint,
    past_10_years_reported smallint,
    covered_by_id bigint,
    covered_by_ori character(9),
    covered_by_name character varying(100),
    staffing_year smallint,
    total_officers integer,
    total_civilians integer,
    icpsr_zip character(5),
    icpsr_lat numeric,
    icpsr_lng numeric
);

CREATE TABLE nibrs_activity_type (
activity_type_id smallint NOT NULL PRIMARY KEY,
activity_type_code character(2),
activity_type_name character varying(100)
);

CREATE TABLE nibrs_age (
age_id smallint NOT NULL PRIMARY KEY,
age_code character(2),
age_name character varying(100)
);

CREATE TABLE nibrs_arrest_type (
arrest_type_id smallint NOT NULL PRIMARY KEY,
arrest_type_code character(1),
arrest_type_name character varying(100)
);

CREATE TABLE nibrs_assignment_type (
assignment_type_id smallint NOT NULL PRIMARY KEY,
assignment_type_code character(1),
assignment_type_name character varying(100)
);

CREATE TABLE nibrs_bias_list (
bias_id smallint NOT NULL PRIMARY KEY,
bias_code character(2),
bias_name character varying(100)
);

CREATE TABLE nibrs_location_type (
    location_id bigint NOT NULL PRIMARY KEY,
    location_code character(2),
    location_name character varying(100)
);

CREATE TABLE nibrs_offense_type (
    offense_type_id bigint NOT NULL PRIMARY KEY,
    offense_code character varying(5),
    offense_name character varying(100),
    crime_against character varying(100),
    ct_flag character(1),
    hc_flag character(1),
    hc_code character varying(5),
    offense_category_name character varying(100)
);

CREATE TABLE nibrs_prop_desc_type (
    prop_desc_id smallint NOT NULL PRIMARY KEY,
    prop_desc_code character(2),
    prop_desc_name character varying(100)
);

CREATE TABLE nibrs_victim_type (
    victim_type_id smallint NOT NULL PRIMARY KEY,
    victim_type_code character(1),
    victim_type_name character varying(100)
);

CREATE TABLE nibrs_circumstances (
    circumstances_id smallint NOT NULL PRIMARY KEY,
    circumstances_type character(1),
    circumstances_code smallint,
    circumstances_name character varying(100)
);

CREATE TABLE nibrs_cleared_except (
    cleared_except_id smallint NOT NULL PRIMARY KEY,
    cleared_except_code character(1),
    cleared_except_name character varying(100)
);

CREATE TABLE nibrs_criminal_act (
    criminal_act_id smallint NOT NULL PRIMARY KEY,
    offense_id bigint NOT NULL
);

CREATE TABLE nibrs_criminal_act_type (
    criminal_act_id smallint NOT NULL PRIMARY KEY,
    criminal_act_code character(1),
    criminal_act_name character varying(100)
);

CREATE TABLE nibrs_drug_measure_type (
    drug_measure_type_id smallint NOT NULL PRIMARY KEY,
    drug_measure_code character(2),
    drug_measure_name character varying(100)
);

CREATE TABLE nibrs_ethnicity (
    ethnicity_id smallint NOT NULL PRIMARY KEY,
    ethnicity_code character(1),
    ethnicity_name character varying(100),
    hc_flag character varying(1)
);

CREATE TABLE nibrs_injury (
injury_id smallint NOT NULL PRIMARY KEY,
injury_code character(1),
injury_name character varying(100)
);

CREATE TABLE nibrs_justifiable_force (
justifiable_force_id smallint NOT NULL PRIMARY KEY,
justifiable_force_code character(1),
justifiable_force_name character varying(100)
);

CREATE TABLE nibrs_prop_loss_type (
prop_loss_id smallint NOT NULL PRIMARY KEY,
prop_loss_name character varying(100)
);

CREATE TABLE nibrs_relationship (
relationship_id smallint NOT NULL PRIMARY KEY,
relationship_code character(2),
relationship_name character varying(100)
);

CREATE TABLE nibrs_suspected_drug_type (
suspected_drug_type_id smallint NOT NULL PRIMARY KEY,
suspected_drug_code character(1),
suspected_drug_name character varying(100)
);

CREATE TABLE nibrs_using_list (
suspect_using_id smallint NOT NULL PRIMARY KEY,
suspect_using_code character(1),
suspect_using_name character varying(100)
);


CREATE TABLE nibrs_weapon_type (
weapon_id smallint NOT NULL PRIMARY KEY,
weapon_code character varying(3),
weapon_name character varying(100),
shr_flag character(1)
);

CREATE TABLE ref_race (
race_id smallint NOT NULL PRIMARY KEY,
race_code character varying(2) NOT NULL,
race_desc character varying(100) NOT NULL,
sort_order smallint,
start_year smallint,
end_year smallint,
notes character varying(1000)
);

CREATE TABLE ref_state (
state_id smallint NOT NULL PRIMARY KEY,
division_id smallint NOT NULL,
state_name character varying(100),
state_code character varying(2),
state_abbr character varying(2),
state_postal_abbr character varying(2),
state_fips_code character varying(2),
state_pub_freq_months smallint
);

--
-- Main NIBRS tables
--

CREATE TABLE nibrs_arrestee (
arrestee_id bigint NOT NULL PRIMARY KEY,
incident_id bigint NOT NULL REFERENCES nibrs_incident(incident_id),
arrestee_seq_num bigint,
arrest_num character varying(12),
arrest_date timestamp without time zone,
arrest_type_id smallint REFERENCES nibrs_arrest_type(arrest_type_id),
multiple_indicator character(1),
offense_type_id bigint NOT NULL REFERENCES nibrs_offense_type(offense_type_id),
age_id smallint NOT NULL REFERENCES nibrs_age(age_id),
age_num smallint,
sex_code character(1),
race_id smallint NOT NULL REFERENCES ref_race(race_id),
ethnicity_id smallint REFERENCES nibrs_ethnicity(ethnicity_id),
resident_code character(1),
under_18_disposition_code character(1),
clearance_ind character(1),
ff_line_number bigint,
age_range_low_num smallint,
age_range_high_num smallint
);

CREATE TABLE nibrs_arrestee_weapon (
arrestee_id bigint NOT NULL REFERENCES nibrs_arrestee(arrestee_id),
weapon_id smallint NOT NULL REFERENCES nibrs_weapon_type(weapon_id),
nibrs_arrestee_weapon_id bigint NOT NULL PRIMARY KEY
);

CREATE TABLE nibrs_bias_motivation (
bias_id smallint NOT NULL REFERENCES nibrs_bias_list(bias_id),
offense_id bigint NOT NULL REFERENCES nibrs_offense(offense_id)
);

CREATE TABLE nibrs_month (
nibrs_month_id bigint NOT NULL PRIMARY KEY,
agency_id bigint NOT NULL REFERENCES cde_agencies(agency_id),
month_num smallint NOT NULL,
data_year smallint NOT NULL,
reported_status character varying(1),
report_date timestamp without time zone,
prepared_date timestamp without time zone,
update_flag character(1),
orig_format character(1),
ff_line_number bigint,
data_home character varying(1),
ddocname character varying(50),
did bigint
);

CREATE TABLE nibrs_incident (
    agency_id bigint NOT NULL REFERENCES cde_agencies(agency_id),
    incident_id bigint PRIMARY KEY,
    nibrs_month_id bigint NOT NULL REFERENCES nibrs_month(nibrs_month_id),
    incident_number character varying(15),
    cargo_theft_flag character varying(1),
    submission_date timestamp without time zone,
    incident_date timestamp without time zone,
    report_date_flag character varying(1),
    incident_hour smallint,
    cleared_except_id smallint NOT NULL REFERENCES nibrs_cleared_except(cleared_except_id),
    cleared_except_date timestamp without time zone,
    incident_status smallint,
    data_home character(1),
    ddocname character varying(100),
    orig_format character(1),
    ff_line_number bigint,
    did bigint
);

CREATE TABLE nibrs_offender (
offender_id bigint NOT NULL PRIMARY KEY,
incident_id bigint NOT NULL REFERENCES nibrs_incident(incident_id),
offender_seq_num smallint,
age_id smallint,
age_num smallint,
sex_code character(1),
race_id smallint,
ethnicity_id smallint,
ff_line_number bigint,
age_range_low_num smallint,
age_range_high_num smallint
);

CREATE TABLE nibrs_offense (
offense_id bigint NOT NULL PRIMARY KEY,
incident_id bigint NOT NULL REFERENCES nibrs_incident(incident_id),
offense_type_id bigint NOT NULL REFERENCES nibrs_offense_type(offense_type_id),
attempt_complete_flag character(1),
location_id bigint NOT NULL REFERENCES nibrs_location_type(location_id),
num_premises_entered smallint,
method_entry_code character(1),
ff_line_number bigint
);

CREATE TABLE nibrs_property (
    property_id bigint NOT NULL PRIMARY KEY,
    incident_id bigint NOT NULL REFERENCES nibrs_incident(incident_id),
    prop_loss_id smallint NOT NULL REFERENCES nibrs_prop_loss_type(prop_loss_id),
    stolen_count smallint,
    recovered_count smallint,
    ff_line_number bigint
);

CREATE TABLE nibrs_property_desc (
    property_id bigint NOT NULL REFERENCES nibrs_property(property_id),
    prop_desc_id smallint NOT NULL REFERENCES nibrs_prop_desc_type(prop_desc_id),
    property_value bigint,
    date_recovered timestamp without time zone,
    nibrs_prop_desc_id bigint NOT NULL PRIMARY KEY
);

CREATE TABLE nibrs_suspect_using (
    suspect_using_id smallint NOT NULL REFERENCES nibrs_using_list(suspect_using_id),
    offense_id bigint NOT NULL REFERENCES nibrs_offense(offense_id)
);

CREATE TABLE nibrs_suspected_drug (
    suspected_drug_type_id smallint NOT NULL REFERENCES nibrs_suspected_drug_type(suspected_drug_type_id),
    property_id bigint NOT NULL REFERENCES nibrs_property(property_id),
    est_drug_qty double precision,
    drug_measure_type_id smallint REFERENCES nibrs_drug_measure_type(drug_measure_type_id),
    nibrs_suspected_drug_id bigint NOT NULL PRIMARY KEY
);

CREATE TABLE nibrs_victim (
    victim_id bigint NOT NULL PRIMARY KEY,
    incident_id bigint NOT NULL REFERENCES nibrs_incident(incident_id),
    victim_seq_num smallint,
    victim_type_id smallint NOT NULL REFERENCES nibrs_victim_type(victim_type_id),
    assignment_type_id smallint REFERENCES nibrs_assignment_type(assignment_type_id),
    activity_type_id smallint REFERENCES nibrs_activity_type(activity_type_id),
    outside_agency_id bigint,
    age_id smallint REFERENCES nibrs_age(age_id),
    age_num smallint,
    sex_code character(1),
    race_id smallint REFERENCES ref_race(race_id),
    ethnicity_id smallint REFERENCES nibrs_ethnicity(ethnicity_id),
    resident_status_code character(1),
    agency_data_year smallint,
    ff_line_number bigint,
    age_range_low_num smallint,
    age_range_high_num smallint
);

CREATE TABLE nibrs_victim_circumstances (
    victim_id bigint NOT NULL REFERENCES nibrs_victim(victim_id),
    circumstances_id smallint NOT NULL REFERENCES nibrs_circumstances(circumstances_id),
    justifiable_force_id smallint REFERENCES nibrs_justifiable_force(justifiable_force_id)
);

CREATE TABLE nibrs_victim_injury (
    victim_id bigint NOT NULL REFERENCES nibrs_victim(victim_id),
    injury_id smallint NOT NULL REFERENCES nibrs_injury(injury_id)
);

CREATE TABLE nibrs_victim_offender_rel (
    victim_id bigint NOT NULL REFERENCES nibrs_victim(victim_id),
    offender_id bigint NOT NULL REFERENCES nibrs_offender(offender_id),
    relationship_id smallint NOT NULL REFERENCES nibrs_relationship(relationship_id),
    nibrs_victim_offender_id bigint NOT NULL PRIMARY KEY
);

CREATE TABLE nibrs_victim_offense (
    victim_id bigint NOT NULL REFERENCES nibrs_victim(victim_id),
    offense_id bigint NOT NULL REFERENCES nibrs_offense(offense_id)
);

CREATE TABLE nibrs_weapon (
    weapon_id smallint NOT NULL REFERENCES nibrs_weapon_type(weapon_id),
    offense_id bigint NOT NULL REFERENCES nibrs_offense(offense_id),
    nibrs_weapon_id bigint NOT NULL PRIMARY KEY
);

--
-- Table loading
--

.mode csv
.import 'agency_participation.csv' agency_participation
.import 'cde_agencies.csv' cde_agencies
.import 'nibrs_age.csv' nibrs_age
.import 'nibrs_arrest_type.csv' nibrs_arrest_type
.import 'nibrs_assignment_type.csv' nibrs_assignment_type
.import 'nibrs_bias_list.csv' nibrs_bias_list
.import 'nibrs_circumstances.csv' nibrs_circumstances
.import 'nibrs_cleared_except.csv' nibrs_cleared_except
.import 'nibrs_criminal_act_type.csv' nibrs_criminal_act_type
.import 'nibrs_drug_measure_type.csv' nibrs_drug_measure_type
.import 'nibrs_ethnicity.csv' nibrs_ethnicity
.import 'nibrs_injury.csv' nibrs_injury
.import 'nibrs_justifiable_force.csv' nibrs_justifiable_force
.import 'nibrs_location_type.csv' nibrs_location_type
.import 'nibrs_offense_type.csv' nibrs_offense_type
.import 'nibrs_prop_desc_type.csv' nibrs_prop_desc_type
.import 'nibrs_prop_loss_type.csv' nibrs_prop_loss_type
.import 'nibrs_relationship.csv' nibrs_relationship
.import 'nibrs_suspected_drug_type.csv' nibrs_suspected_drug_type
.import 'nibrs_using_list.csv' nibrs_using_list
.import 'nibrs_victim_type.csv' nibrs_victim_type
.import 'nibrs_weapon_type.csv' nibrs_weapon_type
.import 'ref_race.csv' ref_race
.import 'ref_state.csv' ref_state
.import 'nibrs_arrestee.csv' nibrs_arrestee
.import 'nibrs_arrestee_weapon.csv' nibrs_arrestee_weapon
.import 'nibrs_bias_motivation.csv' nibrs_bias_motivation
.import 'nibrs_month.csv' nibrs_month
.import 'nibrs_incident.csv' nibrs_incident
.import 'nibrs_offender.csv' nibrs_offender
.import 'nibrs_offense.csv' nibrs_offense
.import 'nibrs_property.csv' nibrs_property
.import 'nibrs_property_desc.csv' nibrs_property_desc
.import 'nibrs_suspect_using.csv' nibrs_suspect_using
.import 'nibrs_suspected_drug.csv' nibrs_suspected_drug
.import 'nibrs_victim.csv' nibrs_victim
.import 'nibrs_victim_circumstances.csv' nibrs_victim_circumstances
.import 'nibrs_victim_injury.csv' nibrs_victim_injury
.import 'nibrs_victim_offender_rel.csv' nibrs_victim_offender_rel
.import 'nibrs_victim_offense.csv' nibrs_victim_offense
.import 'nibrs_weapon.csv' nibrs_weapon

--
-- Indexes
--
-- ALTER TABLE ONLY nibrs_assignment_type
--     ADD CONSTRAINT nibrs_assignment_type_pkey PRIMARY KEY (assignment_type_id);

-- ALTER TABLE ONLY nibrs_bias_list
--     ADD CONSTRAINT nibrs_bias_list_pkey PRIMARY KEY (bias_id);

-- ALTER TABLE ONLY nibrs_bias_motivation
--     ADD CONSTRAINT nibrs_bias_motivation_pkey PRIMARY KEY (bias_id, offense_id);

-- ALTER TABLE ONLY nibrs_circumstances
--     ADD CONSTRAINT nibrs_circumstances_pkey PRIMARY KEY (circumstances_id);

-- ALTER TABLE ONLY nibrs_cleared_except
--     ADD CONSTRAINT nibrs_cleared_except_pkey PRIMARY KEY (cleared_except_id);

-- ALTER TABLE ONLY nibrs_criminal_act
--     ADD CONSTRAINT nibrs_criminal_act_pkey PRIMARY KEY (criminal_act_id, offense_id);

-- ALTER TABLE ONLY nibrs_criminal_act_type
--     ADD CONSTRAINT nibrs_criminal_act_type_pkey PRIMARY KEY (criminal_act_id);

-- ALTER TABLE ONLY nibrs_drug_measure_type
--     ADD CONSTRAINT nibrs_drug_measure_type_pkey PRIMARY KEY (drug_measure_type_id);

-- ALTER TABLE ONLY nibrs_ethnicity
--     ADD CONSTRAINT nibrs_ethnicity_pkey PRIMARY KEY (ethnicity_id);

-- ALTER TABLE ONLY nibrs_incident
--     ADD CONSTRAINT nibrs_incident_pkey PRIMARY KEY (incident_id);

-- ALTER TABLE ONLY nibrs_injury
--     ADD CONSTRAINT nibrs_injury_pkey PRIMARY KEY (injury_id);

-- ALTER TABLE ONLY nibrs_justifiable_force
--     ADD CONSTRAINT nibrs_justifiable_force_pkey PRIMARY KEY (justifiable_force_id);

-- ALTER TABLE ONLY nibrs_location_type
--     ADD CONSTRAINT nibrs_location_type_pkey PRIMARY KEY (location_id);

-- ALTER TABLE ONLY nibrs_month
--     ADD CONSTRAINT nibrs_month_pkey PRIMARY KEY (nibrs_month_id);

-- ALTER TABLE ONLY nibrs_offender
--     ADD CONSTRAINT nibrs_offender_pkey PRIMARY KEY (offender_id);

-- ALTER TABLE ONLY nibrs_offense
--     ADD CONSTRAINT nibrs_offense_pkey PRIMARY KEY (offense_id);

-- ALTER TABLE ONLY nibrs_offense_type
--     ADD CONSTRAINT nibrs_offense_type_pkey PRIMARY KEY (offense_type_id);

-- ALTER TABLE ONLY nibrs_prop_desc_type
--     ADD CONSTRAINT nibrs_prop_desc_type_pkey PRIMARY KEY (prop_desc_id);

-- ALTER TABLE ONLY nibrs_prop_loss_type
--     ADD CONSTRAINT nibrs_prop_loss_type_pkey PRIMARY KEY (prop_loss_id);

-- ALTER TABLE ONLY nibrs_property_desc
--     ADD CONSTRAINT nibrs_property_desc_pkey PRIMARY KEY (nibrs_prop_desc_id);

-- ALTER TABLE ONLY nibrs_property
--     ADD CONSTRAINT nibrs_property_pkey PRIMARY KEY (property_id);

-- ALTER TABLE ONLY nibrs_relationship
--     ADD CONSTRAINT nibrs_relationship_pkey PRIMARY KEY (relationship_id);

-- ALTER TABLE ONLY nibrs_suspect_using
--     ADD CONSTRAINT nibrs_suspect_using_pkey PRIMARY KEY (suspect_using_id, offense_id);

-- ALTER TABLE ONLY nibrs_suspected_drug
--     ADD CONSTRAINT nibrs_suspected_drug_pkey PRIMARY KEY (nibrs_suspected_drug_id);

-- ALTER TABLE ONLY nibrs_suspected_drug_type
--     ADD CONSTRAINT nibrs_suspected_drug_type_pkey PRIMARY KEY (suspected_drug_type_id);

-- ALTER TABLE ONLY nibrs_using_list
--     ADD CONSTRAINT nibrs_using_list_pkey PRIMARY KEY (suspect_using_id);

-- ALTER TABLE ONLY nibrs_victim_circumstances
--     ADD CONSTRAINT nibrs_victim_circumstances_pkey PRIMARY KEY (victim_id, circumstances_id);

-- ALTER TABLE ONLY nibrs_victim_injury
--     ADD CONSTRAINT nibrs_victim_injury_pkey PRIMARY KEY (victim_id, injury_id);

-- ALTER TABLE ONLY nibrs_victim_offender_rel
--     ADD CONSTRAINT nibrs_victim_offender_rel_pkey PRIMARY KEY (nibrs_victim_offender_id);

-- ALTER TABLE ONLY nibrs_victim_offense
--     ADD CONSTRAINT nibrs_victim_offense_pkey PRIMARY KEY (victim_id, offense_id);

-- ALTER TABLE ONLY nibrs_victim
--     ADD CONSTRAINT nibrs_victim_pkey PRIMARY KEY (victim_id);

-- ALTER TABLE ONLY nibrs_victim_type
--     ADD CONSTRAINT nibrs_victim_type_pkey PRIMARY KEY (victim_type_id);

-- ALTER TABLE ONLY nibrs_weapon
--     ADD CONSTRAINT nibrs_weapon_pkey PRIMARY KEY (nibrs_weapon_id);

-- ALTER TABLE ONLY nibrs_weapon_type
--     ADD CONSTRAINT nibrs_weapon_type_pkey PRIMARY KEY (weapon_id);

-- ALTER TABLE ONLY ref_race
--     ADD CONSTRAINT ref_race_pkey PRIMARY KEY (race_id);

-- ALTER TABLE ONLY ref_state
--     ADD CONSTRAINT ref_state_pkey PRIMARY KEY (state_id);


--
-- Other indices
--

CREATE INDEX ni_incnum_agency ON nibrs_incident (agency_id, incident_number);

CREATE INDEX nibrs_arr_weapon_arrestee_id ON nibrs_arrestee_weapon (arrestee_id);
CREATE INDEX nibrs_arrest_weap_type_ix ON nibrs_arrestee_weapon (weapon_id);

CREATE INDEX nibrs_arrestee_age_id_idx ON nibrs_arrestee (age_id);
CREATE INDEX nibrs_arrestee_age_ix ON nibrs_arrestee (age_id);
CREATE INDEX nibrs_arrestee_arrest_type_id_idx ON nibrs_arrestee (arrest_type_id);
CREATE INDEX nibrs_arrestee_arrest_type_ix ON nibrs_arrestee (arrest_type_id);
CREATE INDEX nibrs_arrestee_ethnicity_id_idx ON nibrs_arrestee (ethnicity_id);
CREATE INDEX nibrs_arrestee_ethnicity_ix ON nibrs_arrestee (ethnicity_id);
CREATE INDEX nibrs_arrestee_inc_id ON nibrs_arrestee (incident_id);
CREATE INDEX nibrs_arrestee_nibrs_race_ix ON nibrs_arrestee (race_id);
CREATE INDEX nibrs_arrestee_offense_type_id_idx ON nibrs_arrestee (offense_type_id);
CREATE INDEX nibrs_arrestee_offense_type_ix ON nibrs_arrestee (offense_type_id);
CREATE INDEX nibrs_arrestee_race_id_idx ON nibrs_arrestee (race_id);
CREATE INDEX nibrs_arrestee_weapon_arrestee_id_idx ON nibrs_arrestee_weapon (arrestee_id);
CREATE INDEX nibrs_arrestee_weapon_weapon_id_idx ON nibrs_arrestee_weapon (weapon_id);

CREATE INDEX nibrs_bias_motiv_off_id ON nibrs_bias_motivation (offense_id);

CREATE INDEX nibrs_criminal_act_off_id ON nibrs_criminal_act (offense_id);

CREATE INDEX nibrs_incident_agency_id_idx ON nibrs_incident (agency_id);
CREATE INDEX nibrs_incident_clear_ex_ix ON nibrs_incident (cleared_except_id);
CREATE INDEX nibrs_incident_cleared_except_id_idx ON nibrs_incident (cleared_except_id);
CREATE INDEX nibrs_incident_incid_agency ON nibrs_incident (agency_id, incident_id);
CREATE INDEX nibrs_incident_index1 ON nibrs_incident (nibrs_month_id);
CREATE INDEX nibrs_incident_index2 ON nibrs_incident (incident_number);
CREATE INDEX nibrs_incident_status_idx ON nibrs_incident (incident_status);

CREATE INDEX nibrs_month_agency_id_idx ON nibrs_month (agency_id);
CREATE UNIQUE INDEX nibrs_month_un ON nibrs_month (agency_id, month_num, data_year);

CREATE INDEX nibrs_offender_age_id_idx ON nibrs_offender (age_id);
CREATE INDEX nibrs_offender_age_ix ON nibrs_offender (age_id);
CREATE INDEX nibrs_offender_ethnicity_id_idx ON nibrs_offender (ethnicity_id);
CREATE INDEX nibrs_offender_ethnicity_ix ON nibrs_offender (ethnicity_id);

CREATE INDEX nibrs_offender_inc_id ON nibrs_offender (incident_id);
CREATE INDEX nibrs_offender_race_id_idx ON nibrs_offender (race_id);
CREATE INDEX nibrs_offender_race_ix ON nibrs_offender (race_id);

CREATE INDEX nibrs_offense_loc_type_ix ON nibrs_offense (location_id);
CREATE INDEX nibrs_offense_location_id_idx ON nibrs_offense (location_id);
CREATE INDEX nibrs_offense_off_type_ix ON nibrs_offense (offense_type_id);
CREATE INDEX nibrs_offense_offense_type_id_idx ON nibrs_offense (offense_type_id);
CREATE INDEX nibrs_offense_x1 ON nibrs_offense (incident_id);

CREATE INDEX nibrs_prop_desc_date_rec_ix ON nibrs_property_desc (date_recovered);
CREATE INDEX nibrs_property_desc_desc_id_in ON nibrs_property_desc (prop_desc_id);
CREATE INDEX nibrs_property_desc_prop_desc_id_idx ON nibrs_property_desc (prop_desc_id);
CREATE INDEX nibrs_property_desc_property_id_idx ON nibrs_property_desc (property_id);

CREATE INDEX nibrs_property_loss_type_ix ON nibrs_property (prop_loss_id);
CREATE INDEX nibrs_property_prop_loss_id_idx ON nibrs_property (prop_loss_id);
CREATE INDEX nibrs_property_property_id_in ON nibrs_property_desc (property_id);
CREATE INDEX nibrs_property_x1 ON nibrs_property (incident_id);

CREATE INDEX nibrs_susp_drug_meas_type_ix ON nibrs_suspected_drug (drug_measure_type_id);
CREATE INDEX nibrs_susp_drug_prop_id ON nibrs_suspected_drug (property_id);
CREATE INDEX nibrs_susp_drug_type_ix ON nibrs_suspected_drug (suspected_drug_type_id);

CREATE INDEX nibrs_suspect_using_code_idx ON nibrs_using_list (suspect_using_code);

CREATE INDEX nibrs_suspect_using_off_id ON nibrs_suspect_using (offense_id);

CREATE INDEX nibrs_vic_circ_nibrs_circ_ix ON nibrs_victim_circumstances (circumstances_id);
CREATE INDEX nibrs_victim_circ_just_hom_ix ON nibrs_victim_circumstances (justifiable_force_id);

CREATE INDEX nibrs_vic_injury_nibrs_inj_ix ON nibrs_victim_injury (injury_id);

CREATE INDEX nibrs_victims_vic_type_ix ON nibrs_victim (victim_type_id);
CREATE INDEX nibrs_victim_x1 ON nibrs_victim (incident_id);
CREATE INDEX nibrs_victim_act_type_ix ON nibrs_victim (activity_type_id);
CREATE INDEX nibrs_victim_age_id_idx ON nibrs_victim (age_id);
CREATE INDEX nibrs_victim_assign_type_ix ON nibrs_victim (assignment_type_id);
CREATE INDEX nibrs_victim_ethnicity_id_idx ON nibrs_victim (ethnicity_id);

CREATE INDEX nibrs_victim_injury_injury_id_idx ON nibrs_victim_injury (injury_id);

CREATE INDEX nibrs_victim_off_rel_rel_ix ON nibrs_victim_offender_rel (relationship_id);
CREATE INDEX nibrs_victim_offender_rel_off ON nibrs_victim_offender_rel (offender_id);
CREATE INDEX nibrs_victim_offender_rel_vic ON nibrs_victim_offender_rel (victim_id);

CREATE INDEX nibrs_victim_offense_off_id ON nibrs_victim_offense (offense_id);
CREATE INDEX nibrs_victim_offense_vic_id ON nibrs_victim_offense (victim_id);

CREATE INDEX nibrs_victim_race_id_idx ON nibrs_victim (race_id);

CREATE INDEX nibrs_victim_victim_type_id_idx ON nibrs_victim (victim_type_id);

CREATE INDEX nibrs_weap_weap_type_ix ON nibrs_weapon (weapon_id);
CREATE INDEX nibrs_weapon_off_id ON nibrs_weapon (offense_id);


CREATE UNIQUE INDEX ref_race_code ON ref_race (race_code);
CREATE INDEX ref_race_sort_order ON ref_race (sort_order);


-- Foreign Keys
--

-- ALTER TABLE ONLY cde_agencies
--     ADD CONSTRAINT agencies_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);


-- ALTER TABLE ONLY nibrs_arrestee_weapon
--     ADD CONSTRAINT nibrs_arrest_weap_arrest_fk FOREIGN KEY (arrestee_id) REFERENCES nibrs_arrestee(arrestee_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_arrestee_weapon
--     ADD CONSTRAINT nibrs_arrest_weap_type_fk FOREIGN KEY (weapon_id) REFERENCES nibrs_weapon_type(weapon_id);

-- ALTER TABLE ONLY nibrs_arrestee
--     ADD CONSTRAINT nibrs_arrestee_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);

-- ALTER TABLE ONLY nibrs_arrestee
--     ADD CONSTRAINT nibrs_arrestee_arrest_type_fk FOREIGN KEY (arrest_type_id) REFERENCES nibrs_arrest_type(arrest_type_id);

-- ALTER TABLE ONLY nibrs_arrestee
--     ADD CONSTRAINT nibrs_arrestee_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);

-- ALTER TABLE ONLY nibrs_arrestee
--     ADD CONSTRAINT nibrs_arrestee_inc_fk FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_arrestee
--     ADD CONSTRAINT nibrs_arrestee_offense_type_fk FOREIGN KEY (offense_type_id) REFERENCES nibrs_offense_type(offense_type_id);

-- ALTER TABLE ONLY nibrs_arrestee
--     ADD CONSTRAINT nibrs_arrestee_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);

-- ALTER TABLE ONLY nibrs_bias_motivation
--     ADD CONSTRAINT nibrs_bias_mot_list_fk FOREIGN KEY (bias_id) REFERENCES nibrs_bias_list(bias_id);

-- ALTER TABLE ONLY nibrs_bias_motivation
--     ADD CONSTRAINT nibrs_bias_mot_offense_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_criminal_act
--     ADD CONSTRAINT nibrs_criminal_act_offense_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_criminal_act
--     ADD CONSTRAINT nibrs_criminal_act_type_fk FOREIGN KEY (criminal_act_id) REFERENCES nibrs_criminal_act_type(criminal_act_id);

-- ALTER TABLE ONLY nibrs_incident
--     ADD CONSTRAINT nibrs_incident_clear_ex_fk FOREIGN KEY (cleared_except_id) REFERENCES nibrs_cleared_except(cleared_except_id);

-- ALTER TABLE ONLY nibrs_incident
--     ADD CONSTRAINT nibrs_incident_month_fk FOREIGN KEY (nibrs_month_id) REFERENCES nibrs_month(nibrs_month_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_offender
--     ADD CONSTRAINT nibrs_offender_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);

-- ALTER TABLE ONLY nibrs_offender
--     ADD CONSTRAINT nibrs_offender_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);

-- ALTER TABLE ONLY nibrs_offender
--     ADD CONSTRAINT nibrs_offender_nibrs_inci_fk1 FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_offender
--     ADD CONSTRAINT nibrs_offender_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);

-- ALTER TABLE ONLY nibrs_offense
--     ADD CONSTRAINT nibrs_offense_inc_fk1 FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_offense
--     ADD CONSTRAINT nibrs_offense_loc_type_fk FOREIGN KEY (location_id) REFERENCES nibrs_location_type(location_id);

-- ALTER TABLE ONLY nibrs_offense
--     ADD CONSTRAINT nibrs_offense_off_type_fk FOREIGN KEY (offense_type_id) REFERENCES nibrs_offense_type(offense_type_id);

-- ALTER TABLE ONLY nibrs_property_desc
--     ADD CONSTRAINT nibrs_prop_desc_prop_fk FOREIGN KEY (property_id) REFERENCES nibrs_property(property_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_property_desc
--     ADD CONSTRAINT nibrs_prop_desc_type_fk FOREIGN KEY (prop_desc_id) REFERENCES nibrs_prop_desc_type(prop_desc_id);

-- ALTER TABLE ONLY nibrs_property
--     ADD CONSTRAINT nibrs_property_inc_fk FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_property
--     ADD CONSTRAINT nibrs_property_loss_type_fk FOREIGN KEY (prop_loss_id) REFERENCES nibrs_prop_loss_type(prop_loss_id);

-- ALTER TABLE ONLY nibrs_suspected_drug
--     ADD CONSTRAINT nibrs_susp_drug_meas_type_fk FOREIGN KEY (drug_measure_type_id) REFERENCES nibrs_drug_measure_type(drug_measure_type_id);

-- ALTER TABLE ONLY nibrs_suspected_drug
--     ADD CONSTRAINT nibrs_susp_drug_prop_fk FOREIGN KEY (property_id) REFERENCES nibrs_property(property_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_suspected_drug
--     ADD CONSTRAINT nibrs_susp_drug_type_fk FOREIGN KEY (suspected_drug_type_id) REFERENCES nibrs_suspected_drug_type(suspected_drug_type_id);

-- ALTER TABLE ONLY nibrs_suspect_using
--     ADD CONSTRAINT nibrs_suspect_using_list_fk FOREIGN KEY (suspect_using_id) REFERENCES nibrs_using_list(suspect_using_id);

-- ALTER TABLE ONLY nibrs_suspect_using
--     ADD CONSTRAINT nibrs_suspect_using_off_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_victim_circumstances
--     ADD CONSTRAINT nibrs_vic_circ_nibrs_circ_fk FOREIGN KEY (circumstances_id) REFERENCES nibrs_circumstances(circumstances_id);

-- ALTER TABLE ONLY nibrs_victim_circumstances
--     ADD CONSTRAINT nibrs_vic_circ_nibrs_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_victim_injury
--     ADD CONSTRAINT nibrs_vic_injury_nibrs_inj_fk FOREIGN KEY (injury_id) REFERENCES nibrs_injury(injury_id);

-- ALTER TABLE ONLY nibrs_victim_injury
--     ADD CONSTRAINT nibrs_vic_injury_nibrs_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_victim_offense
--     ADD CONSTRAINT nibrs_vic_off_nibrs_off_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_victim_offense
--     ADD CONSTRAINT nibrs_vic_off_nibrs_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_victim
--     ADD CONSTRAINT nibrs_victim_act_type_fk FOREIGN KEY (activity_type_id) REFERENCES nibrs_activity_type(activity_type_id);

-- ALTER TABLE ONLY nibrs_victim
--     ADD CONSTRAINT nibrs_victim_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);

-- ALTER TABLE ONLY nibrs_victim
--     ADD CONSTRAINT nibrs_victim_assign_type_fk FOREIGN KEY (assignment_type_id) REFERENCES nibrs_assignment_type(assignment_type_id);

-- ALTER TABLE ONLY nibrs_victim_circumstances
--     ADD CONSTRAINT nibrs_victim_circ_just_hom_fk FOREIGN KEY (justifiable_force_id) REFERENCES nibrs_justifiable_force(justifiable_force_id);

-- ALTER TABLE ONLY nibrs_victim
--     ADD CONSTRAINT nibrs_victim_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);

-- ALTER TABLE ONLY nibrs_victim
--     ADD CONSTRAINT nibrs_victim_inc_fk FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_victim_offender_rel
--     ADD CONSTRAINT nibrs_victim_off_rel_off_fk FOREIGN KEY (offender_id) REFERENCES nibrs_offender(offender_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_victim_offender_rel
--     ADD CONSTRAINT nibrs_victim_off_rel_rel_fk FOREIGN KEY (relationship_id) REFERENCES nibrs_relationship(relationship_id);

-- ALTER TABLE ONLY nibrs_victim_offender_rel
--     ADD CONSTRAINT nibrs_victim_off_rel_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_victim
--     ADD CONSTRAINT nibrs_victim_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);

-- ALTER TABLE ONLY nibrs_victim
--     ADD CONSTRAINT nibrs_victims_vic_type_fk FOREIGN KEY (victim_type_id) REFERENCES nibrs_victim_type(victim_type_id);

-- ALTER TABLE ONLY nibrs_weapon
--     ADD CONSTRAINT nibrs_weap_off_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;

-- ALTER TABLE ONLY nibrs_weapon
--     ADD CONSTRAINT nibrs_weap_weap_type_fk FOREIGN KEY (weapon_id) REFERENCES nibrs_weapon_type(weapon_id);

--
-- PostgreSQL database dump complete
--

