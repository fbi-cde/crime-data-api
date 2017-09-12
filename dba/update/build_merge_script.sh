echo "

\set ON_ERROR_STOP on;
-----------------------------
--
--
-- DATA MERGE BLOCK - Merges the new data with existing tables.
--
--
------------------------------


-- Save this task for last. Be sure everything lines up.

-- DONE!
UPDATE nibrs_incident_new SET incident_number = '';
CREATE TABLE nibrs_month_new AS (SELECT convert_to_integer(nibrs_month_id) as nibrs_month_id, convert_to_integer(agency_id) as agency_id, convert_to_integer(month_num) as month_num, convert_to_integer(data_year) as data_year, reported_status as reported_status, to_timestamp_ucr(report_date) as report_date, to_timestamp_ucr(prepared_date) as prepared_date, update_flag as update_flag, orig_format as orig_format, convert_to_integer(ff_line_number) as ff_line_number, data_home as data_home, ddocname as ddocname, convert_to_integer(did) as did FROM nibrs_month_temp);

-- For some really messy relationships - we add data to mirrored tables, rather than the master data.
DELETE from nibrs_arrestee_new;
INSERT INTO nibrs_arrestee_new (SELECT convert_to_integer(arrestee_id), convert_to_integer(incident_id), convert_to_integer(arrestee_seq_num), arrest_num, to_timestamp_ucr(arrest_date), convert_to_integer(arrest_type_id), multiple_indicator, convert_to_integer(offense_type_id), convert_to_integer(age_id), convert_to_integer(age_num), sex_code, convert_to_integer(race_id), convert_to_integer(ethnicity_id), resident_code, under_18_disposition_code, clearance_ind, convert_to_integer(ff_line_number), convert_to_integer(age_range_low_num), convert_to_integer(age_range_high_num) FROM nibrs_arrestee_temp);
DELETE from nibrs_incident_new;
INSERT INTO nibrs_incident_new (SELECT convert_to_integer(agency_id), convert_to_integer(incident_id), convert_to_integer(nibrs_month_id), incident_number, cargo_theft_flag, to_timestamp_ucr(submission_date), to_timestamp_ucr(incident_date), report_date_flag, convert_to_integer(incident_hour), convert_to_integer(cleared_except_id), to_timestamp_ucr(cleared_except_date), convert_to_integer(incident_status), data_home, ddocname, orig_format, convert_to_integer(ff_line_number), convert_to_integer(did) FROM nibrs_incident_temp);
DELETE from nibrs_offense_new;
INSERT INTO nibrs_offense_new (SELECT convert_to_integer(offense_id), convert_to_integer(incident_id), convert_to_integer(offense_type_id), attempt_complete_flag, convert_to_integer(location_id), convert_to_integer(num_premises_entered), method_entry_code, convert_to_integer(ff_line_number) FROM nibrs_offense_temp);
DELETE from nibrs_offender_new;
INSERT INTO nibrs_offender_new (SELECT convert_to_integer(offender_id), convert_to_integer(incident_id), convert_to_integer(offender_seq_num), convert_to_integer(age_id), convert_to_integer(age_num), sex_code, convert_to_integer(race_id), convert_to_integer(ethnicity_id), convert_to_integer(ff_line_number), convert_to_integer(age_range_low_num), convert_to_integer(age_range_high_num) FROM nibrs_offender_temp);
DELETE from nibrs_property_new;
INSERT INTO nibrs_property_new (SELECT convert_to_integer(property_id), convert_to_integer(incident_id), convert_to_integer(prop_loss_id), convert_to_integer(stolen_count), convert_to_integer(recovered_count), convert_to_integer(ff_line_number) FROM nibrs_property_temp);
DELETE from nibrs_victim_new;
INSERT INTO nibrs_victim_new (SELECT convert_to_integer(victim_id), convert_to_integer(incident_id), convert_to_integer(victim_seq_num), convert_to_integer(victim_type_id), convert_to_integer(assignment_type_id), convert_to_integer(activity_type_id), convert_to_integer(outside_agency_id), convert_to_integer(age_id), convert_to_integer(age_num), sex_code, convert_to_integer(race_id), convert_to_integer(ethnicity_id), resident_status_code, convert_to_integer(agency_data_year), convert_to_integer(ff_line_number), convert_to_integer(age_range_low_num), convert_to_integer(age_range_high_num) FROM nibrs_victim_temp);
DELETE from nibrs_property_desc_new;
INSERT INTO nibrs_property_desc_new (SELECT convert_to_integer(property_id), convert_to_integer(prop_desc_id), convert_to_integer(property_value), to_timestamp_ucr(date_recovered), convert_to_integer(nibrs_prop_desc_id) FROM nibrs_property_desc_temp);

DROP TABLE IF EXISTS  nibrs_victim_offense_new;
CREATE TABLE nibrs_victim_offense_new AS (SELECT convert_to_integer(victim_id) as victim_id, convert_to_integer(offense_id) as offense_id FROM nibrs_victim_offense_temp);
DROP TABLE IF EXISTS  nibrs_bias_motivation_new;
CREATE TABLE nibrs_bias_motivation_new AS (SELECT convert_to_integer(bias_id) as bias_id, convert_to_integer(offense_id) as offense_id FROM nibrs_bias_motivation_temp);
DROP TABLE IF EXISTS  nibrs_criminal_act_new;
CREATE TABLE nibrs_criminal_act_new AS (SELECT convert_to_integer(criminal_act_id) as criminal_act_id, convert_to_integer(offense_id) as offense_id FROM nibrs_criminal_act_temp);
DROP TABLE IF EXISTS nibrs_suspected_drug_new;
CREATE TABLE nibrs_suspected_drug_new AS (SELECT convert_to_integer(suspected_drug_type_id) as suspected_drug_type_id, convert_to_integer(property_id) as property_id, convert_to_double(est_drug_qty) as est_drug_qty, convert_to_integer(drug_measure_type_id) as drug_measure_type_id, convert_to_integer(nibrs_suspected_drug_id) as nibrs_suspected_drug_id FROM nibrs_suspected_drug_temp);
DROP TABLE IF EXISTS nibrs_suspect_using_new;
CREATE TABLE nibrs_suspect_using_new AS (SELECT convert_to_integer(suspect_using_id) as suspect_using_id, convert_to_integer(offense_id) as offense_id FROM nibrs_suspect_using_temp);
DROP TABLE IF EXISTS nibrs_arrestee_weapon_new;
CREATE TABLE nibrs_arrestee_weapon_new AS (SELECT convert_to_integer(arrestee_id) as arrestee_id, convert_to_integer(weapon_id) as weapon_id, convert_to_integer(nibrs_arrestee_weapon_id) as nibrs_arrestee_weapon_id FROM nibrs_arrestee_weapon_temp);
DROP TABLE IF EXISTS nibrs_victim_circumstances_new
CREATE TABLE nibrs_victim_circumstances_new AS (SELECT convert_to_integer(victim_id) as victim_id, convert_to_integer(circumstances_id) as circumstances_id, convert_to_integer(justifiable_force_id) as justifiable_force_id FROM nibrs_victim_circumstances_temp);
DROP TABLE IF EXISTS nibrs_victim_injury_new;
CREATE TABLE nibrs_victim_injury_new AS (SELECT convert_to_integer(victim_id) as victim_id, convert_to_integer(injury_id) as injury_id FROM nibrs_victim_injury_temp);
DROP TABLE IF EXISTS nibrs_victim_offender_rel_new;
CREATE TABLE nibrs_victim_offender_rel_new AS (SELECT convert_to_integer(victim_id) as victim_id, convert_to_integer(offender_id) as offender_id, convert_to_integer(relationship_id) as relationship_id, convert_to_integer(nibrs_victim_offender_id) as nibrs_victim_offender_id FROM nibrs_victim_offender_rel_temp);
DROP TABLE IF EXISTS nibrs_weapon_new;
CREATE TABLE nibrs_weapon_new AS (SELECT convert_to_integer(weapon_id), convert_to_integer(offense_id), convert_to_integer(nibrs_weapon_id) FROM nibrs_weapon_temp);


CREATE TABLE reta_month_offense_subcat_new (
    reta_month_id bigint NOT NULL,
    offense_subcat_id bigint NOT NULL,
    reported_count integer,
    reported_status smallint,
    unfounded_count integer,
    unfounded_status smallint,
    actual_count integer,
    actual_status smallint,
    cleared_count integer,
    cleared_status smallint,
    juvenile_cleared_count integer,
    juvenile_cleared_status smallint
);

CREATE TABLE reta_month_new (
    reta_month_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    month_num smallint NOT NULL,
    data_home character(1) NOT NULL,
    source_flag character(1) NOT NULL,
    reported_flag character(1) NOT NULL,
    ddocname character varying(100),
    month_included_in smallint,
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    prepared_by_user character varying(100),
    prepared_by_email character varying(200),
    orig_format character(1) NOT NULL,
    total_reported_count integer,
    total_unfounded_count integer,
    total_actual_count integer,
    total_cleared_count integer,
    total_juvenile_cleared_count integer,
    leoka_felony smallint,
    leoka_accident smallint,
    leoka_assault integer,
    leoka_status smallint,
    update_flag character(1),
    did bigint,
    ff_line_number bigint
);

-- Insert into copy tables (for way faster selects.)
INSERT INTO reta_month_new (reta_month_id, agency_id, data_year, month_num, data_home, source_flag, reported_flag, ddocname, month_included_in,report_date,prepared_date,prepared_by_user,prepared_by_email,orig_format, leoka_felony, leoka_accident, leoka_assault, leoka_status, update_flag, did,ff_line_number) (SELECT convert_to_integer(reta_month_id), convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(month_num), data_home, source_flag, reported_flag, ddocname, convert_to_integer(month_included_in), to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), prepared_by_user, prepared_by_email, orig_format, convert_to_integer(leoka_felony), convert_to_integer(leoka_accident), convert_to_integer(leoka_assault), convert_to_integer(leoka_status), update_flag::text, convert_to_integer(did), convert_to_integer(ff_line_number) FROM reta_month_temp);
INSERT INTO reta_month_offense_subcat_new (SELECT convert_to_integer(reta_month_id), convert_to_integer(offense_subcat_id), convert_to_integer(reported_count), convert_to_integer(reported_status), convert_to_integer(unfounded_count), convert_to_integer(unfounded_status), convert_to_integer(actual_count), convert_to_integer(actual_status), convert_to_integer(cleared_count), convert_to_integer(cleared_status), convert_to_integer(juvenile_cleared_count), convert_to_integer(juvenile_cleared_status) FROM reta_month_offense_subcat_temp);
ALTER TABLE ONLY reta_month_offense_subcat_new
    ADD CONSTRAINT reta_month_offense_subcat_new_pkey PRIMARY KEY (offense_subcat_id, reta_month_id);
CREATE INDEX reta_month_offense_subcat_reta_month_id_new_idx ON reta_month_offense_subcat_new USING btree (reta_month_id);

ALTER TABLE ONLY reta_month_new
    ADD CONSTRAINT reta_month_new_pkey PRIMARY KEY (reta_month_id);
CREATE INDEX reta_month_agency_id_new_idx ON reta_month_new USING btree (agency_id);
CREATE INDEX reta_month_data_year_new_idx ON reta_month_new USING btree (data_year);

INSERT INTO asr_month (SELECT convert_to_integer(asr_month_id), convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(month_num), source_flag, reported_flag, orig_format, update_flag, convert_to_integer(ff_line_number), ddocname, convert_to_integer(did), data_home FROM asr_month_temp);
INSERT INTO asr_offense_subcat (SELECT convert_to_integer(offense_subcat_id) ,    convert_to_integer(offense_id) ,    offense_subcat_name ,    offense_subcat_code ,    srs_offense_code ,    convert_to_integer(master_offense_code) ,    total_flag ,    adult_juv_flag  FROM asr_offense_subcat_temp);
INSERT INTO asr_age_sex_subcat (SELECT convert_to_integer(asr_month_id), convert_to_integer(offense_subcat_id), convert_to_integer(age_range_id),  convert_to_integer(arrest_count) ,    convert_to_integer(arrest_status) , active_flag ,    to_timestamp_ucr(prepared_date) ,    to_timestamp_ucr(report_date) ,   convert_to_integer(ff_line_number)   FROM asr_age_sex_subcat_temp);
INSERT INTO asr_race_offense_subcat (SELECT convert_to_integer(asr_month_id), convert_to_integer(offense_subcat_id), convert_to_integer(race_id),  juvenile_flag, convert_to_integer(arrest_count), convert_to_integer(arrest_status), active_flag, to_timestamp_ucr(prepared_date), to_timestamp_ucr(report_date), convert_to_integer(ff_line_number) FROM asr_race_offense_subcat_temp);

-- arson_*
INSERT INTO arson_month (SELECT convert_to_integer(arson_month_id), convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(month_num), data_home, source_flag, reported_flag, ddocname, convert_to_integer(month_included_in), to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), orig_format, update_flag, convert_to_integer(did), convert_to_integer(ff_line_number) from arson_month_temp);
INSERT INTO arson_month_by_subcat (SELECT convert_to_integer(arson_month_id), convert_to_integer(subcategory_id), convert_to_integer(reported_count), convert_to_integer(reported_status), convert_to_integer(unfounded_count), convert_to_integer(unfounded_status), convert_to_integer(actual_count), convert_to_integer(actual_status), convert_to_integer(cleared_count), convert_to_integer(cleared_status), convert_to_integer(juvenile_cleared_count), convert_to_integer(juvenile_cleared_status), convert_to_integer(uninhabited_count), convert_to_integer(uninhabited_status), convert_to_integer(est_damage_value), convert_to_integer(est_damage_value_status) from arson_month_by_subcat_temp);


-- Add some basic indexes to speed up selection + joining for transformation queries.

-- nibrs_incident
ALTER TABLE ONLY nibrs_incident_new
    ADD CONSTRAINT nibrs_incident_pkey_new PRIMARY KEY (incident_id);

CREATE INDEX nibrs_incident_agency_id_new_idx ON nibrs_incident_new USING btree (agency_id);
CREATE INDEX nibrs_incident_idx1_new ON nibrs_incident_new USING btree (agency_id, incident_date);

-- nibrs_victim
ALTER TABLE ONLY nibrs_victim_new
    ADD CONSTRAINT nibrs_victim_pkey_new PRIMARY KEY (victim_id);
CREATE INDEX nibrs_victim_idx1_new ON nibrs_victim_new USING btree (victim_id, incident_id);

-- nibrs_offender
ALTER TABLE ONLY nibrs_offender_new
    ADD CONSTRAINT nibrs_offender_pkey_new PRIMARY KEY (offender_id);
CREATE INDEX nibrs_offender_idx1_new ON nibrs_offender_new USING btree (offender_id, incident_id);

-- nibrs_offense
ALTER TABLE ONLY nibrs_offense_new
    ADD CONSTRAINT nibrs_offense_pkey_new PRIMARY KEY (offense_id);
CREATE INDEX nibrs_offense_idx1_new ON nibrs_offense_new USING btree (offense_id, incident_id);

-- nibrs_arrestee
ALTER TABLE ONLY nibrs_arrestee_new
    ADD CONSTRAINT nibrs_arrestee_pkey_new PRIMARY KEY (arrestee_id);
CREATE INDEX nibrs_arrestee_idx1_new ON nibrs_arrestee_new USING btree (arrestee_id, incident_id);

-- nibrs_property
ALTER TABLE ONLY nibrs_property_new
    ADD CONSTRAINT nibrs_prop_pkey_new PRIMARY KEY (property_id);
CREATE INDEX nibrs_property_idx1_new ON nibrs_property_new USING btree (property_id, incident_id);

-- nibrs_property_desc
CREATE INDEX nibrs_property_desc_idx1_new ON nibrs_property_desc_new USING btree (property_id, prop_desc_id);
"