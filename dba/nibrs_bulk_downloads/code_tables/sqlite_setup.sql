--
-- Table loading
--

.mode csv
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

CREATE TABLE nibrs_criminal_act (
criminal_act_id smallint NOT NULL,
offense_id bigint NOT NULL
);

CREATE TABLE nibrs_weapon (
    weapon_id smallint NOT NULL REFERENCES nibrs_weapon_type(weapon_id),
    offense_id bigint NOT NULL REFERENCES nibrs_offense(offense_id),
    nibrs_weapon_id bigint NOT NULL PRIMARY KEY
);

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
