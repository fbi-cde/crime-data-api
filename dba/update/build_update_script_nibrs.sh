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
INSERT INTO nibrs_month (SELECT convert_to_integer(nibrs_month_id), convert_to_integer(agency_id), convert_to_integer(month_num), convert_to_integer(data_year), reported_status, to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), update_flag, orig_format, convert_to_integer(ff_line_number), data_home, ddocname, convert_to_integer(did) FROM nibrs_month_temp);

-- For some really messy relationships - we add data to mirrored tables, rather than the master data.
INSERT INTO nibrs_arrestee_new (SELECT convert_to_integer(arrestee_id), convert_to_integer(incident_id), convert_to_integer(arrestee_seq_num), arrest_num, to_timestamp_ucr(arrest_date), convert_to_integer(arrest_type_id), multiple_indicator, convert_to_integer(offense_type_id), convert_to_integer(age_id), convert_to_integer(age_num), sex_code, convert_to_integer(race_id), convert_to_integer(ethnicity_id), resident_code, under_18_disposition_code, clearance_ind, convert_to_integer(ff_line_number), convert_to_integer(age_range_low_num), convert_to_integer(age_range_high_num) FROM nibrs_arrestee_temp);
INSERT INTO nibrs_incident_new (SELECT convert_to_integer(agency_id), convert_to_integer(incident_id), convert_to_integer(nibrs_month_id), incident_number, cargo_theft_flag, to_timestamp_ucr(submission_date), to_timestamp_ucr(incident_date), report_date_flag, convert_to_integer(incident_hour), convert_to_integer(cleared_except_id), to_timestamp_ucr(cleared_except_date), convert_to_integer(incident_status), data_home, ddocname, orig_format, convert_to_integer(ff_line_number), convert_to_integer(did) FROM nibrs_incident_temp);
INSERT INTO nibrs_offense_new (SELECT convert_to_integer(offense_id), convert_to_integer(incident_id), convert_to_integer(offense_type_id), attempt_complete_flag, convert_to_integer(location_id), convert_to_integer(num_premises_entered), method_entry_code, convert_to_integer(ff_line_number) FROM nibrs_offense_temp);
INSERT INTO nibrs_offender_new (SELECT convert_to_integer(offender_id), convert_to_integer(incident_id), convert_to_integer(offender_seq_num), convert_to_integer(age_id), convert_to_integer(age_num), sex_code, convert_to_integer(race_id), convert_to_integer(ethnicity_id), convert_to_integer(ff_line_number), convert_to_integer(age_range_low_num), convert_to_integer(age_range_high_num) FROM nibrs_offender_temp);
INSERT INTO nibrs_property_new (SELECT convert_to_integer(property_id), convert_to_integer(incident_id), convert_to_integer(prop_loss_id), convert_to_integer(stolen_count), convert_to_integer(recovered_count), convert_to_integer(ff_line_number) FROM nibrs_property_temp);
INSERT INTO nibrs_victim_new (SELECT convert_to_integer(victim_id), convert_to_integer(incident_id), convert_to_integer(victim_seq_num), convert_to_integer(victim_type_id), convert_to_integer(assignment_type_id), convert_to_integer(activity_type_id), convert_to_integer(outside_agency_id), convert_to_integer(age_id), convert_to_integer(age_num), sex_code, convert_to_integer(race_id), convert_to_integer(ethnicity_id), resident_status_code, convert_to_integer(agency_data_year), convert_to_integer(ff_line_number), convert_to_integer(age_range_low_num), convert_to_integer(age_range_high_num) FROM nibrs_victim_temp);
INSERT INTO nibrs_arrestee_weapon (SELECT convert_to_integer(arrestee_id), convert_to_integer(weapon_id), convert_to_integer(nibrs_arrestee_weapon_id) FROM nibrs_arrestee_weapon_temp);
INSERT INTO nibrs_property_desc_new (SELECT convert_to_integer(property_id), convert_to_integer(prop_desc_id), convert_to_integer(property_value), to_timestamp_ucr(date_recovered), convert_to_integer(nibrs_prop_desc_id) FROM nibrs_property_desc_temp);

INSERT INTO nibrs_victim_offense (SELECT convert_to_integer(victim_id), convert_to_integer(offense_id) FROM nibrs_victim_offense_temp);
INSERT INTO nibrs_bias_motivation (SELECT convert_to_integer(bias_id), convert_to_integer(offense_id) FROM nibrs_bias_motivation_temp);
INSERT INTO nibrs_criminal_act (SELECT convert_to_integer(criminal_act_id), convert_to_integer(offense_id) FROM nibrs_criminal_act_temp);
INSERT INTO nibrs_suspected_drug (SELECT convert_to_integer(suspected_drug_type_id), convert_to_integer(property_id), convert_to_double(est_drug_qty), convert_to_integer(drug_measure_type_id), convert_to_integer(nibrs_suspected_drug_id) FROM nibrs_suspected_drug_temp);
INSERT INTO nibrs_suspect_using (SELECT convert_to_integer(suspect_using_id), convert_to_integer(offense_id) FROM nibrs_suspect_using_temp);
INSERT INTO nibrs_victim_circumstances (SELECT convert_to_integer(victim_id), convert_to_integer(circumstances_id), convert_to_integer(justifiable_force_id) FROM nibrs_victim_circumstances_temp);
INSERT INTO nibrs_victim_injury (SELECT convert_to_integer(victim_id), convert_to_integer(injury_id) FROM nibrs_victim_injury_temp);
INSERT INTO nibrs_victim_offender_rel (SELECT convert_to_integer(victim_id), convert_to_integer(offender_id), convert_to_integer(relationship_id), convert_to_integer(nibrs_victim_offender_id) FROM nibrs_victim_offender_rel_temp);
INSERT INTO nibrs_weapon (SELECT convert_to_integer(weapon_id), convert_to_integer(offense_id), convert_to_integer(nibrs_weapon_id) FROM nibrs_weapon_temp);

-------


-- ALTER TABLE nibrs_incident SET (autovacuum_enabled = false, toast.autovacuum_enabled = false);
-- ALTER TABLE nibrs_victim SET (autovacuum_enabled = false, toast.autovacuum_enabled = false);
-- ALTER TABLE nibrs_offender SET (autovacuum_enabled = false, toast.autovacuum_enabled = false);
-- ALTER TABLE nibrs_offense SET (autovacuum_enabled = false, toast.autovacuum_enabled = false);
-- ALTER TABLE nibrs_victim_offense SET (autovacuum_enabled = false, toast.autovacuum_enabled = false);


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

-- hc_*  - DONE!
INSERT INTO hc_quarter (SELECT convert_to_integer(agency_id), convert_to_integer(quarter_num), convert_to_integer(data_year), reported_status, convert_to_integer(reported_count), convert_to_integer(hc_quarter_id), update_flag, orig_format, convert_to_integer(ff_line_number), ddocname, convert_to_integer(did), data_home from hc_quarter_temp);
INSERT INTO hc_incident (SELECT convert_to_integer(incident_id), convert_to_integer(agency_id), incident_no, to_timestamp_ucr(incident_date), data_home, source_flag, ddocname, to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), convert_to_integer(victim_count), convert_to_integer(adult_victim_count), convert_to_integer(incident_status), convert_to_integer(juvenile_victim_count), convert_to_integer(offender_count), convert_to_integer(adult_offender_count), convert_to_integer(juvenile_offender_count), convert_to_integer(offender_race_id), convert_to_integer(offender_ethnicity_id), update_flag, convert_to_integer(hc_quarter_id), convert_to_integer(ff_line_number), orig_format, convert_to_integer(did), convert_to_integer(nibrs_incident_id) from hc_incident_temp);
INSERT INTO hc_offense (SELECT convert_to_integer(offense_id), convert_to_integer(incident_id), convert_to_integer(offense_type_id), convert_to_integer(victim_count), convert_to_integer(location_id), convert_to_integer(nibrs_offense_id) from hc_offense_temp);
INSERT INTO hc_victim (SELECT convert_to_integer(offense_id), convert_to_integer(victim_type_id) from hc_victim_temp);
INSERT INTO hc_bias_motivation (SELECT convert_to_integer(offense_id), convert_to_integer(bias_id) from hc_bias_motivation_temp);


-- ct_*
INSERT INTO ct_incident (SELECT convert_to_integer(incident_id), convert_to_integer(agency_id), convert_to_integer(data_year), incident_number, to_timestamp_ucr(incident_date), source_flag, ddocname, to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), report_date_flag, convert_to_integer(incident_hour), cleared_except_flag, update_flag, convert_to_integer(ct_month_id), convert_to_integer(ff_line_number), data_home, orig_format, unknown_offender, convert_to_integer(did), convert_to_integer(nibrs_incident_id) from ct_incident_temp);
INSERT INTO ct_victim (SELECT convert_to_integer(incident_id), convert_to_integer(victim_type_id) from ct_victim_temp);
INSERT INTO ct_offense (SELECT convert_to_integer(offense_id), convert_to_integer(incident_id), convert_to_integer(offense_type_id), convert_to_integer(location_id), ct_offense_flag from ct_offense_temp);
INSERT INTO ct_offender (SELECT convert_to_integer(offender_id), convert_to_integer(incident_id), convert_to_integer(age), sex_code, convert_to_integer(ethnicity_id), convert_to_integer(race_id) from ct_offender_temp);
INSERT INTO ct_property (SELECT convert_to_integer(property_id), convert_to_integer(prop_desc_id), convert_to_integer(incident_id), convert_to_integer(stolen_value), recovered_flag, to_timestamp_ucr(date_recovered), convert_to_integer(recovered_value) from ct_property_temp);
INSERT INTO ct_arrestee (SELECT convert_to_integer(arrestee_id), convert_to_integer(incident_id), convert_to_integer(age), sex_code, convert_to_integer(ethnicity_id), convert_to_integer(race_id) from ct_arrestee_temp);
INSERT INTO ct_weapon (SELECT convert_to_integer(incident_id), convert_to_integer(weapon_id), convert_to_integer(ct_weapon_id) from ct_weapon_temp);

-- arson_*
INSERT INTO arson_month (SELECT convert_to_integer(arson_month_id), convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(month_num), data_home, source_flag, reported_flag, ddocname, convert_to_integer(month_included_in), to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), orig_format, update_flag, convert_to_integer(did), convert_to_integer(ff_line_number) from arson_month_temp);
INSERT INTO arson_month_by_subcat (SELECT convert_to_integer(arson_month_id), convert_to_integer(subcategory_id), convert_to_integer(reported_count), convert_to_integer(reported_status), convert_to_integer(unfounded_count), convert_to_integer(unfounded_status), convert_to_integer(actual_count), convert_to_integer(actual_status), convert_to_integer(cleared_count), convert_to_integer(cleared_status), convert_to_integer(juvenile_cleared_count), convert_to_integer(juvenile_cleared_status), convert_to_integer(uninhabited_count), convert_to_integer(uninhabited_status), convert_to_integer(est_damage_value), convert_to_integer(est_damage_value_status) from arson_month_by_subcat_temp);


-- This script should load + merge one year of UCR NIBRS data in the 
-- form of multiple CSV|TSV files. 


-- Most of this stuff is optimized so that the queries run in a reasonable amount of time, 
-- processing the smallest slice of data possible.

-- Additionally, we use a series of UPDATES instead of a large UPDATE/INSERT because
-- it allows us to run an update, check the results, and verify before proceeding.
-- Also, a series of smaller queries is more likely to stay in RAM than a large one.

-- !!!!!!!!!!!!!! Grep/Replace _$YEAR with the new _{YEAR} !!!!!!!!!!!!!!!


\set ON_ERROR_STOP on;

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

-- FUN TRICK: Trick the partition trigger into creating a new partition with 
--   appropriate CHECK() statements, and all that jazz (so you can insert directly into the 
--   partition rather than through the trigger - which can be slower). 
INSERT INTO nibrs_victim_denorm (incident_id, victim_id, year, incident_date) VALUES (9999999999,999999999, '$YEAR',to_timestamp('01-01-$YEAR','MM-DD-YYYY'));
DELETE from nibrs_victim_denorm_$YEAR;
INSERT INTO nibrs_incident_denorm (incident_id, agency_id, year, incident_date) VALUES (9999999999,999999999, '$YEAR',to_timestamp('01-01-$YEAR','MM-DD-YYYY'));
DELETE from nibrs_incident_denorm_$YEAR;
INSERT INTO nibrs_offender_denorm (incident_id, offender_id, year, incident_date)  VALUES (9999999999,999999999, '$YEAR',to_timestamp('01-01-$YEAR','MM-DD-YYYY'));
DELETE from nibrs_offender_denorm_$YEAR;
INSERT INTO nibrs_offense_denorm (incident_id, offense_id, year, incident_date)  VALUES (9999999999,999999999, '$YEAR',to_timestamp('01-01-$YEAR','MM-DD-YYYY'));
DELETE from nibrs_offense_denorm_$YEAR;
INSERT INTO nibrs_arrestee_denorm (incident_id, arrestee_id, year, incident_date)  VALUES (9999999999,999999999, '$YEAR',to_timestamp('01-01-$YEAR','MM-DD-YYYY'));
DELETE from nibrs_arrestee_denorm_$YEAR;
INSERT INTO nibrs_property_denorm (incident_id, property_id, year, incident_date)  VALUES (9999999999,999999999, '$YEAR',to_timestamp('01-01-$YEAR','MM-DD-YYYY'));
DELETE from nibrs_property_denorm_$YEAR;

-- Give it a little more work mem to work with. Adjust this down if you get out of memory errors.
SET work_mem='2GB';

--
-- Begin Transformation queries.
-- Transform the newly uploaded data, 
-- and load it into our partitioned denormalized (and simplified) tables.
--

INSERT INTO nibrs_incident_denorm_$YEAR (incident_id, agency_id, state_id, ori, year, incident_date) SELECT nibrs_incident_new.incident_id, nibrs_incident_new.agency_id, ref_agency.state_id, ref_agency.ori, EXTRACT(YEAR FROM nibrs_incident_new.incident_date) as year, nibrs_incident_new.incident_date from nibrs_incident_new JOIN ref_agency ON (ref_agency.agency_id = nibrs_incident_new.agency_id) where nibrs_incident_new.incident_date >= to_timestamp('01-01-$YEAR', 'MM-DD-YYYY');
UPDATE nibrs_incident_denorm_$YEAR SET state_code = ref_state.state_code from ref_state where nibrs_incident_denorm_$YEAR.state_id = ref_state.state_id;

-- Insert directly into a single partition to bypass the partition trigger (faster).
-- DONE (~5 min per update)
INSERT INTO nibrs_victim_denorm_$YEAR (incident_id, agency_id, year, incident_date, victim_id, age_id, age_num, sex_code, race_id, victim_type_id,resident_status_code) SELECT nibrs_victim_new.incident_id, nibrs_incident_new.agency_id, EXTRACT(YEAR FROM nibrs_incident_new.incident_date) as year, nibrs_incident_new.incident_date, nibrs_victim_new.victim_id, nibrs_victim_new.age_id, nibrs_victim_new.age_num::numeric, nibrs_victim_new.sex_code,nibrs_victim_new.race_id, nibrs_victim_new.victim_type_id, nibrs_victim_new.resident_status_code from nibrs_victim_new LEFT JOIN nibrs_incident_new on nibrs_incident_new.incident_id = nibrs_victim_new.incident_id where nibrs_incident_new.incident_date >= to_timestamp('01-01-$YEAR', 'MM-DD-YYYY');
UPDATE nibrs_victim_denorm_$YEAR SET ori = ref_agency.ori from ref_agency where nibrs_victim_denorm_$YEAR.agency_id = ref_agency.agency_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET state_id = ref_agency.state_id, county_id = ref_agency_county.county_id from ref_agency JOIN ref_agency_county ON ref_agency.agency_id = ref_agency_county.agency_id where nibrs_victim_denorm_$YEAR.agency_id = ref_agency.agency_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET state_code = ref_state.state_code from ref_state where nibrs_victim_denorm_$YEAR.state_id = ref_state.state_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET race_code = ref_race.race_code from ref_race where nibrs_victim_denorm_$YEAR.race_id = ref_race.race_id and nibrs_victim_denorm_$YEAR.year = '$YEAR'; 
UPDATE nibrs_victim_denorm_$YEAR SET offense_id = nibrs_offense_new.offense_id, offense_type_id = nibrs_offense_new.offense_type_id, location_id = nibrs_offense_new.location_id from nibrs_offense_new  where nibrs_offense_new.incident_id = nibrs_victim_denorm_$YEAR.incident_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET offense_name = nibrs_offense_type.offense_name from nibrs_offense_type where nibrs_offense_type.offense_type_id = nibrs_victim_denorm_$YEAR.offense_type_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET circumstance_name = nibrs_circumstances.circumstances_name, ethnicity = nibrs_ethnicity.ethnicity_name, victim_type = nibrs_victim_type.victim_type_name from nibrs_victim_circumstances ON nibrs_victim_circumstances.victim_id = nibrs_victim_denorm_$YEAR.victim_id JOIN nibrs_circumstances ON nibrs_circumstances.circumstances_id = nibrs_victim_circumstances.circumstances_id JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_victim_new.ethnicity_id JOIN nibrs_victim_type ON nibrs_victim_new.victim_type_id = nibrs_victim_type.victim_type_id where nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET location_name = nibrs_location_type.location_name, location_code=nibrs_location_type.location_code from nibrs_location_type where nibrs_location_type.location_id = nibrs_victim_denorm_$YEAR.location_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET property_id = nibrs_property_new.property_id, property_loss_id=nibrs_property_new.prop_loss_id from nibrs_property_new  where nibrs_property_new.incident_id = nibrs_victim_denorm_$YEAR.incident_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET property_desc_id = nibrs_property_desc_new.prop_desc_id from nibrs_property_desc_new where nibrs_property_desc_new.property_id = nibrs_victim_denorm_$YEAR.property_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET prop_desc_name = nibrs_prop_desc_type.prop_desc_name from nibrs_prop_desc_type where nibrs_prop_desc_type.prop_desc_id = nibrs_victim_denorm_$YEAR.property_desc_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET bias_id = nibrs_bias_motivation.bias_id from nibrs_bias_motivation where nibrs_bias_motivation.offense_id = nibrs_victim_denorm_$YEAR.offense_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET bias_name = nibrs_bias_list.bias_name from nibrs_bias_list where nibrs_victim_denorm_$YEAR.bias_id = nibrs_bias_list.bias_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET offender_relationship = nibrs_relationship.relationship_name from nibrs_victim_offender_rel JOIN nibrs_relationship ON nibrs_relationship.relationship_id = nibrs_victim_offender_rel.relationship_id where nibrs_victim_denorm_$YEAR.victim_id = nibrs_victim_offender_rel.victim_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_victim_denorm_$YEAR SET ethnicity = nibrs_ethnicity.ethnicity_name from nibrs_victim_new JOIN nibrs_ethnicity ON (nibrs_victim_new.ethnicity_id = nibrs_ethnicity.ethnicity_id) WHERE nibrs_victim_new.victim_id = nibrs_victim_denorm_$YEAR.victim_id and nibrs_victim_denorm_$YEAR.year = '$YEAR';

-- denorm offender
INSERT INTO nibrs_offender_denorm_$YEAR (incident_id, agency_id, year, incident_date, offender_id, age_id, age_num, sex_code, race_id, ethnicity) SELECT nibrs_offender_new.incident_id, nibrs_incident_new.agency_id, EXTRACT(YEAR FROM nibrs_incident_new.incident_date) as year, nibrs_incident_new.incident_date, nibrs_offender_new.offender_id, nibrs_offender_new.age_id, nibrs_offender_new.age_num::numeric, nibrs_offender_new.sex_code,nibrs_offender_new.race_id, nibrs_ethnicity.ethnicity_name from nibrs_offender_new  LEFT JOIN nibrs_incident_new on nibrs_incident_new.incident_id = nibrs_offender_new.incident_id  LEFT JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_offender_new.ethnicity_id where nibrs_incident_new.incident_date >= to_timestamp('01-01-$YEAR', 'MM-DD-YYYY');
UPDATE nibrs_offender_denorm_$YEAR SET ori = ref_agency.ori from ref_agency where nibrs_offender_denorm_$YEAR.agency_id = ref_agency.agency_id and nibrs_offender_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offender_denorm_$YEAR SET state_id = ref_agency.state_id, county_id = ref_agency_county.county_id from ref_agency JOIN ref_agency_county ON ref_agency.agency_id = ref_agency_county.agency_id where nibrs_offender_denorm_$YEAR.agency_id = ref_agency.agency_id and nibrs_offender_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offender_denorm_$YEAR SET state_code = ref_state.state_code from ref_state where nibrs_offender_denorm_$YEAR.state_id = ref_state.state_id and nibrs_offender_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offender_denorm_$YEAR SET race_code = ref_race.race_code from ref_race where nibrs_offender_denorm_$YEAR.race_id = ref_race.race_id and nibrs_offender_denorm_$YEAR.year = '$YEAR'; 
UPDATE nibrs_offender_denorm_$YEAR SET offense_type_id = nibrs_offense_new.offense_type_id, location_id = nibrs_offense_new.location_id from nibrs_offense_new where nibrs_offense_new.incident_id = nibrs_offender_denorm_$YEAR.incident_id and nibrs_offender_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offender_denorm_$YEAR SET offense_name = nibrs_offense_type.offense_name from nibrs_offense_type where nibrs_offense_type.offense_type_id = nibrs_offender_denorm_$YEAR.offense_type_id and nibrs_offender_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offender_denorm_$YEAR SET location_name = nibrs_location_type.location_name, location_code=nibrs_location_type.location_code from nibrs_location_type where nibrs_location_type.location_id = nibrs_offender_denorm_$YEAR.location_id and nibrs_offender_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offender_denorm_$YEAR SET property_id = nibrs_property_new.property_id, property_loss_id=nibrs_property_new.prop_loss_id from nibrs_property_new where nibrs_property_new.incident_id = nibrs_offender_denorm_$YEAR.incident_id;
UPDATE nibrs_offender_denorm_$YEAR SET property_desc_id = nibrs_property_desc_new.prop_desc_id from nibrs_property_desc_new where nibrs_property_desc_new.property_id = nibrs_offender_denorm_$YEAR.property_id;
UPDATE nibrs_offender_denorm_$YEAR SET offense_id = nibrs_offense_new.offense_id from nibrs_offense_new where nibrs_offender_denorm_$YEAR.incident_id = nibrs_offense_new.incident_id and nibrs_offender_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offender_denorm_$YEAR SET bias_id = nibrs_bias_motivation.bias_id from nibrs_bias_motivation where nibrs_bias_motivation.offense_id = nibrs_offender_denorm_$YEAR.offense_id and nibrs_offender_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offender_denorm_$YEAR SET bias_name = nibrs_bias_list.bias_name from nibrs_bias_list where nibrs_offender_denorm_$YEAR.bias_id = nibrs_bias_list.bias_id and nibrs_offender_denorm_$YEAR.year = '$YEAR';

-- denorm offenses
INSERT INTO nibrs_offense_denorm_$YEAR (incident_id, agency_id, year, incident_date, offense_id, method_entry_code, num_premises_entered, location_id, offense_type_id, attempt_complete_flag) SELECT nibrs_offense_new.incident_id, nibrs_incident_new.agency_id, EXTRACT(YEAR FROM nibrs_incident_new.incident_date) as year, nibrs_incident_new.incident_date, nibrs_offense_new.offense_id, nibrs_offense_new.method_entry_code, nibrs_offense_new.num_premises_entered, nibrs_offense_new.location_id, nibrs_offense_new.offense_type_id, nibrs_offense_new.attempt_complete_flag from nibrs_offense_new  JOIN nibrs_incident_new on nibrs_incident_new.incident_id = nibrs_offense_new.incident_id where nibrs_incident_new.incident_date >= to_timestamp('01-01-$YEAR', 'MM-DD-YYYY');
UPDATE nibrs_offense_denorm_$YEAR SET state_id = ref_agency.state_id, county_id = ref_agency_county.county_id from ref_agency JOIN ref_agency_county ON ref_agency.agency_id = ref_agency_county.agency_id where nibrs_offense_denorm_$YEAR.agency_id = ref_agency.agency_id and nibrs_offense_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offense_denorm_$YEAR SET state_code = ref_state.state_code from ref_state where nibrs_offense_denorm_$YEAR.state_id = ref_state.state_id and nibrs_offense_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offense_denorm_$YEAR SET location_name = nibrs_location_type.location_name, location_code=nibrs_location_type.location_code from nibrs_location_type where nibrs_location_type.location_id = nibrs_offense_denorm_$YEAR.location_id and nibrs_offense_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offense_denorm_$YEAR SET offense_name = nibrs_offense_type.offense_name from nibrs_offense_type where nibrs_offense_type.offense_type_id = nibrs_offense_denorm_$YEAR.offense_type_id and nibrs_offense_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offense_denorm_$YEAR SET weapon_id = nibrs_weapon.weapon_id from nibrs_weapon where nibrs_weapon.offense_id = nibrs_offense_denorm_$YEAR.offense_id and nibrs_offense_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offense_denorm_$YEAR SET weapon_name = nibrs_weapon_type.weapon_name from nibrs_weapon_type where nibrs_weapon_type.weapon_id = nibrs_offense_denorm_$YEAR.weapon_id and nibrs_offense_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offense_denorm_$YEAR SET bias_name = nibrs_bias_list.bias_name, suspected_using = nibrs_using_list.suspect_using_name from nibrs_bias_motivation JOIN nibrs_bias_list ON (nibrs_bias_motivation.bias_id = nibrs_bias_list.bias_id) JOIN nibrs_suspect_using ON (nibrs_suspect_using.offense_id =  nibrs_bias_motivation.offense_id) JOIN nibrs_using_list ON (nibrs_using_list.suspect_using_id = nibrs_suspect_using.suspect_using_id) where nibrs_offense_denorm_$YEAR.offense_id = nibrs_bias_motivation.offense_id  and nibrs_offense_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_offense_denorm_$YEAR SET ori = ref_agency.ori from ref_agency where nibrs_offense_denorm_$YEAR.agency_id = ref_agency.agency_id and nibrs_offense_denorm_$YEAR.year = '$YEAR';


-- denorm arrestees 
INSERT INTO nibrs_arrestee_denorm_$YEAR (incident_id,arrest_type_id, agency_id, year, incident_date, arrestee_id, age_id, age_num, sex_code, race_id, arrest_date, resident_status, under_18_disposition_code, clearance_ind) SELECT nibrs_arrestee_new.incident_id, nibrs_arrestee_new.arrest_type_id, nibrs_incident_new.agency_id, EXTRACT(YEAR FROM nibrs_incident_new.incident_date) as year, nibrs_incident_new.incident_date, nibrs_arrestee_new.arrestee_id, nibrs_arrestee_new.age_id, nibrs_arrestee_new.age_num::numeric, nibrs_arrestee_new.sex_code,nibrs_arrestee_new.race_id, nibrs_arrestee_new.arrest_date, nibrs_arrestee_new.resident_code, nibrs_arrestee_new.under_18_disposition_code, nibrs_arrestee_new.clearance_ind from nibrs_arrestee_new JOIN nibrs_incident_new on nibrs_incident_new.incident_id = nibrs_arrestee_new.incident_id where nibrs_incident_new.incident_date >= to_timestamp('01-01-$YEAR', 'MM-DD-YYYY');
UPDATE nibrs_arrestee_denorm_$YEAR SET state_id = nibrs_incident_denorm_$YEAR.state_id, state_code=nibrs_incident_denorm_$YEAR.state_code from nibrs_incident_denorm_$YEAR where nibrs_arrestee_denorm_$YEAR.incident_id =  nibrs_incident_denorm_$YEAR.incident_id; 
UPDATE nibrs_arrestee_denorm_$YEAR SET race_code = ref_race.race_code from ref_race where nibrs_arrestee_denorm_$YEAR.race_id = ref_race.race_id and nibrs_arrestee_denorm_$YEAR.year = '$YEAR'; 
UPDATE nibrs_arrestee_denorm_$YEAR SET arrest_type_name = nibrs_arrest_type.arrest_type_name from nibrs_arrest_type where nibrs_arrestee_denorm_$YEAR.arrest_type_id = nibrs_arrest_type.arrest_type_id and nibrs_arrestee_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_arrestee_denorm_$YEAR SET arrest_type_code = nibrs_arrest_type.arrest_type_code, ethnicity = nibrs_ethnicity.ethnicity_name from nibrs_arrestee_new JOIN nibrs_arrest_type ON (nibrs_arrestee_new.arrest_type_id = nibrs_arrest_type.arrest_type_id) JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_arrestee_new.ethnicity_id where nibrs_arrestee_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_arrestee_denorm_$YEAR SET arrest_type_code = nibrs_arrest_type.arrest_type_code, ethnicity = nibrs_ethnicity.ethnicity_name from nibrs_arrestee_new JOIN nibrs_arrest_type ON (nibrs_arrestee_new.arrest_type_id = nibrs_arrest_type.arrest_type_id) JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_arrestee_new.ethnicity_id where nibrs_arrestee_denorm_$YEAR.arrestee_id = nibrs_arrestee_new.arrestee_id and nibrs_arrestee_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_arrestee_denorm_$YEAR SET ori = ref_agency.ori from ref_agency where nibrs_arrestee_denorm_$YEAR.agency_id = ref_agency.agency_id and nibrs_arrestee_denorm_$YEAR.year = '$YEAR';


-- denorm property
INSERT INTO nibrs_property_denorm_$YEAR (incident_id, agency_id, year, incident_date, property_id, stolen_count) SELECT nibrs_incident_new.incident_id, nibrs_incident_new.agency_id, EXTRACT(YEAR FROM nibrs_incident_new.incident_date) as year, nibrs_incident_new.incident_date, nibrs_property_new.property_id, nibrs_property_new.stolen_count from nibrs_property_new JOIN nibrs_incident_new on nibrs_incident_new.incident_id = nibrs_property_new.incident_id and nibrs_incident_new.incident_date >= to_timestamp('01-01-$YEAR', 'MM-DD-YYYY');
UPDATE nibrs_property_denorm_$YEAR SET state_id = ref_agency.state_id, ori = ref_agency.ori from ref_agency where nibrs_property_denorm_$YEAR.agency_id = ref_agency.agency_id and nibrs_property_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_property_denorm_$YEAR SET state_code = ref_state.state_code from ref_state where nibrs_property_denorm_$YEAR.state_id = ref_state.state_id and nibrs_property_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_property_denorm_$YEAR SET date_recovered = nibrs_property_desc_new.date_recovered, property_value = nibrs_property_desc_new.property_value, property_desc_id = nibrs_property_desc_new.prop_desc_id from nibrs_property_desc_new where nibrs_property_desc_new.property_id = nibrs_property_denorm_$YEAR.property_id and nibrs_property_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_property_denorm_$YEAR SET prop_desc_name = nibrs_prop_desc_type.prop_desc_name from nibrs_prop_desc_type where nibrs_prop_desc_type.prop_desc_id = nibrs_property_denorm_$YEAR.property_desc_id and nibrs_property_denorm_$YEAR.year = '$YEAR';
UPDATE nibrs_property_denorm_$YEAR SET est_drug_qty = nibrs_suspected_drug.est_drug_qty, drug_measure_code = nibrs_drug_measure_type.drug_measure_code, drug_measure_name = nibrs_drug_measure_type.drug_measure_name from nibrs_property_new JOIN nibrs_suspected_drug ON (nibrs_suspected_drug.property_id = nibrs_property_new.property_id) JOIN nibrs_drug_measure_type ON (nibrs_suspected_drug.drug_measure_type_id = nibrs_drug_measure_type.drug_measure_type_id) where nibrs_property_denorm_$YEAR.property_id = nibrs_property_new.property_id and nibrs_property_denorm_$YEAR.year = '$YEAR';


-----

-- Update NIBRS aggregations.

-- 

--------------
-- HATE CRIME
--------------
SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates Hate Crime stats.

drop materialized view  IF EXISTS hc_counts_states_new;
create materialized view hc_counts_states_new as select count(incident_id), bias_name, year, state_id 
from ( SELECT DISTINCT(hc_incident.incident_id), bias_name, state_id, EXTRACT(YEAR FROM hc_incident.incident_date) as year from hc_incident 
    LEFT OUTER JOIN hc_offense ON hc_incident.incident_id = hc_offense.incident_id 
    LEFT OUTER JOIN hc_bias_motivation ON hc_offense.offense_id = hc_bias_motivation.offense_id 
    LEFT OUTER JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = hc_offense.offense_type_id 
    LEFT OUTER JOIN nibrs_bias_list ON nibrs_bias_list.bias_id = hc_bias_motivation.bias_id 
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = hc_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, bias_name),
    (year, state_id, bias_name)
);

drop materialized view  IF EXISTS hc_counts_ori_new;
create materialized view hc_counts_ori_new as select count(incident_id), ori, bias_name, year  
from ( SELECT DISTINCT(hc_incident.incident_id), ref_agency.ori, bias_name, EXTRACT(YEAR FROM hc_incident.incident_date) as year from hc_incident 
    LEFT OUTER JOIN hc_offense ON hc_incident.incident_id = hc_offense.incident_id 
    LEFT OUTER JOIN hc_bias_motivation ON hc_offense.offense_id = hc_bias_motivation.offense_id 
    LEFT OUTER JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = hc_offense.offense_type_id 
    LEFT OUTER JOIN nibrs_bias_list ON nibrs_bias_list.bias_id = hc_bias_motivation.bias_id 
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = hc_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, bias_name)
);

drop materialized view  IF EXISTS offense_hc_counts_states_new;
create materialized view offense_hc_counts_states_new as select count(incident_id), offense_name, bias_name, year, state_id 
from ( SELECT DISTINCT(hc_incident.incident_id), bias_name, offense_name, state_id, EXTRACT(YEAR FROM hc_incident.incident_date) as year from hc_incident 
    LEFT OUTER JOIN hc_offense ON hc_incident.incident_id = hc_offense.incident_id 
    LEFT OUTER JOIN hc_bias_motivation ON hc_offense.offense_id = hc_bias_motivation.offense_id 
    LEFT OUTER JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = hc_offense.offense_type_id 
    LEFT OUTER JOIN nibrs_bias_list ON nibrs_bias_list.bias_id = hc_bias_motivation.bias_id 
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = hc_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, offense_name, bias_name),
    (year, state_id, offense_name, bias_name)
);

drop materialized view  IF EXISTS offense_hc_counts_ori_new;
create materialized view offense_hc_counts_ori_new as select count(incident_id), ori, offense_name, bias_name, year  
from ( SELECT DISTINCT(hc_incident.incident_id), ref_agency.ori, bias_name, offense_name, EXTRACT(YEAR FROM hc_incident.incident_date) as year from hc_incident 
    LEFT OUTER JOIN hc_offense ON hc_incident.incident_id = hc_offense.incident_id 
    LEFT OUTER JOIN hc_bias_motivation ON hc_offense.offense_id = hc_bias_motivation.offense_id 
    LEFT OUTER JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = hc_offense.offense_type_id 
    LEFT OUTER JOIN nibrs_bias_list ON nibrs_bias_list.bias_id = hc_bias_motivation.bias_id 
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = hc_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, offense_name, bias_name)
);




---------
-- CARGO THEFT
---------
SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates CT stats.
drop materialized view IF EXISTS ct_counts_states_new;
create materialized view ct_counts_states_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, state_id,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    state_id, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id

    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id

    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, prop_desc_name),
    (year, location_name),
    (year, victim_type_name),
    (year, offense_name),
    
    (year, state_id, prop_desc_name),
    (year, state_id, location_name),
    (year, state_id, victim_type_name),
    (year, state_id, offense_name)
);

drop materialized view IF EXISTS  ct_counts_ori_new;
create materialized view ct_counts_ori_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, ori,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    ref_agency.ori, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id

    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id

    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, prop_desc_name),
    (year, ori, location_name),
    (year, ori, victim_type_name),
    (year, ori, offense_name)
);

SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates CT stats.
create materialized view offense_ct_counts_states_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, state_id,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    state_id, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id

    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, offense_name, prop_desc_name),
    (year, offense_name, location_name),
    (year, offense_name, victim_type_name),

    (year, state_id, offense_name, prop_desc_name),
    (year, state_id, offense_name, location_name),
    (year, state_id, offense_name, victim_type_name)
);

create materialized view offense_ct_counts_ori_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, ori,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    ref_agency.ori, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id
    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, offense_name, prop_desc_name),
    (year, ori, offense_name, location_name),
    (year, ori, offense_name, victim_type_name)
);

--------------
-- OFFENDERS
--------------

DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    EXECUTE 'drop materialized view IF EXISTS offender_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offender_counts_' || i::TEXT || ' as select count(offender_id),ethnicity, prop_desc_name,offense_name, state_id, race_code,location_name, age_num, sex_code, ori  
    from ( 
        SELECT DISTINCT(offender_id), ethnicity, age_code, age_num,race_code,year,prop_desc_name,offense_name,location_name, sex_code, nibrs_offender_denorm_' || i::TEXT || '.state_id,ref_agency.ori from nibrs_offender_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_offender_denorm_' || i::TEXT || '.agency_id 
        where year::integer = ' || i || ' 
        ) as temp
    GROUP BY GROUPING SETS (
        (year, race_code),
        (year, sex_code),
        (year, age_num),
        (year, location_name), 
        (year, offense_name),
        (year, prop_desc_name),
        (year, ethnicity),

        (year, state_id, race_code),
        (year, state_id, sex_code),
        (year, state_id, age_num),
        (year, state_id, location_name), 
        (year, state_id, offense_name),
        (year, state_id, prop_desc_name),
        (year, state_id, ethnicity),

        (year, ori, race_code),
        (year, ori, sex_code),
        (year, ori, age_num),
        (year, ori, location_name), 
        (year, ori, offense_name),
        (year, ori, prop_desc_name),
        (year, ori, ethnicity)
    );';
   END LOOP;
END
$do$;

drop materialized view  IF EXISTS offender_counts_states_temp;
create materialized view offender_counts_states_temp as 
    SELECT *, $YEAR as year FROM offender_counts_$YEAR WHERE ori IS NULL UNION 
    SELECT *, 2015 as year FROM offender_counts_2015 WHERE ori IS NULL UNION 
    SELECT *, 2014 as year FROM offender_counts_2014 WHERE ori IS NULL UNION 
    SELECT *, 2013 as year FROM offender_counts_2013 WHERE ori IS NULL  UNION 
    SELECT *, 2012 as year FROM offender_counts_2012 WHERE ori IS NULL  UNION 
    SELECT *, 2011 as year FROM offender_counts_2011 WHERE ori IS NULL  UNION 
    SELECT *, 2010 as year FROM offender_counts_2010 WHERE ori IS NULL  UNION
    SELECT *, 2009 as year FROM offender_counts_2009 WHERE ori IS NULL  UNION 
    SELECT *, 2008 as year FROM offender_counts_2008 WHERE ori IS NULL  UNION 
    SELECT *, 2007 as year FROM offender_counts_2007 WHERE ori IS NULL  UNION
    SELECT *, 2006 as year FROM offender_counts_2006 WHERE ori IS NULL  UNION 
    SELECT *, 2005 as year FROM offender_counts_2005 WHERE ori IS NULL  UNION 
    SELECT *, 2004 as year FROM offender_counts_2004 WHERE ori IS NULL  UNION
    SELECT *, 2003 as year FROM offender_counts_2003 WHERE ori IS NULL  UNION 
    SELECT *, 2002 as year FROM offender_counts_2002 WHERE ori IS NULL  UNION 
    SELECT *, 2001 as year FROM offender_counts_2001 WHERE ori IS NULL  UNION
    SELECT *, 2000 as year FROM offender_counts_2000 WHERE ori IS NULL  UNION 
    SELECT *, 1999 as year FROM offender_counts_1999 WHERE ori IS NULL  UNION 
    SELECT *, 1998 as year FROM offender_counts_1998 WHERE ori IS NULL  UNION
    SELECT *, 1997 as year FROM offender_counts_1997 WHERE ori IS NULL  UNION 
    SELECT *, 1996 as year FROM offender_counts_1996 WHERE ori IS NULL  UNION 
    SELECT *, 1995 as year FROM offender_counts_1995 WHERE ori IS NULL  UNION
    SELECT *, 1994 as year FROM offender_counts_1994 WHERE ori IS NULL  UNION 
    SELECT *, 1993 as year FROM offender_counts_1993 WHERE ori IS NULL  UNION 
    SELECT *, 1992 as year FROM offender_counts_1992 WHERE ori IS NULL  UNION
    SELECT *, 1991 as year FROM offender_counts_1991 WHERE ori IS NULL ;

drop materialized view  IF EXISTS offender_counts_ori_temp;
create materialized view offender_counts_ori_temp as 
    SELECT *, $YEAR as year FROM offender_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *, 2015 as year FROM offender_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *, 2014 as year FROM offender_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *, 2013 as year FROM offender_counts_2013 WHERE ori IS NOT NULL  UNION
    SELECT *, 2012 as year FROM offender_counts_2012 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2011 as year FROM offender_counts_2011 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2010 as year FROM offender_counts_2010 WHERE ori IS NOT NULL  UNION
    SELECT *, 2009 as year FROM offender_counts_2009 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2008 as year FROM offender_counts_2008 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2007 as year FROM offender_counts_2007 WHERE ori IS NOT NULL  UNION
    SELECT *, 2006 as year FROM offender_counts_2006 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2005 as year FROM offender_counts_2005 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2004 as year FROM offender_counts_2004 WHERE ori IS NOT NULL  UNION
    SELECT *, 2003 as year FROM offender_counts_2003 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2002 as year FROM offender_counts_2002 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2001 as year FROM offender_counts_2001 WHERE ori IS NOT NULL  UNION
    SELECT *, 2000 as year FROM offender_counts_2000 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1999 as year FROM offender_counts_1999 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1998 as year FROM offender_counts_1998 WHERE ori IS NOT NULL  UNION
    SELECT *, 1997 as year FROM offender_counts_1997 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1996 as year FROM offender_counts_1996 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1995 as year FROM offender_counts_1995 WHERE ori IS NOT NULL  UNION
    SELECT *, 1994 as year FROM offender_counts_1994 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1993 as year FROM offender_counts_1993 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1992 as year FROM offender_counts_1992 WHERE ori IS NOT NULL  UNION
    SELECT *, 1991 as year FROM offender_counts_1991 WHERE ori IS NOT NULL ;

CREATE INDEX CONCURRENTLY offender_counts_state_year_id_idx ON offender_counts_states (state_id, year);
CREATE INDEX CONCURRENTLY offender_counts_ori_year_idx ON offender_counts_ori (ori, year);

--------------
-- OFFENDER - OFFENSES
--------------
DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view  IF EXISTS offense_offender_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offense_offender_counts_' || i::TEXT || ' as select count(offender_id), ori,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
    from (
        SELECT DISTINCT(offender_id), ref_agency.ori, ethnicity, age_num,race_code,year,offense_name, sex_code, nibrs_offender_denorm_' || i::TEXT || '.state_id from nibrs_offender_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_offender_denorm_' || i::TEXT || '.agency_id 
        where year::integer = ' || i || ' and nibrs_offender_denorm_' || i::TEXT || '.state_id is not null
    ) as temp 
    GROUP BY GROUPING SETS (
        (year, offense_name, race_code),
        (year, offense_name, sex_code),
        (year, offense_name, age_num),
        (year, offense_name, ethnicity),
        (year, state_id, offense_name, race_code),
        (year, state_id, offense_name, sex_code),
        (year, state_id, offense_name, age_num),
        (year, state_id, offense_name, ethnicity),
        (year, ori, offense_name, race_code),
        (year, ori, offense_name, sex_code),
        (year, ori, offense_name, age_num),
        (year, ori, offense_name, ethnicity)
    );';
   END LOOP;
END
$do$;

drop materialized view IF EXISTS  offense_offender_counts_states_temp;
create materialized view offense_offender_counts_states_temp as 
    SELECT *,$YEAR as year FROM offense_offender_counts_$YEAR WHERE ori IS NULL  UNION 
    SELECT *,2015 as year FROM offense_offender_counts_2015 WHERE ori IS NULL  UNION 
    SELECT *,2014 as year FROM offense_offender_counts_2014 WHERE ori IS NULL  UNION 
    SELECT *,2013 as year FROM offense_offender_counts_2013 WHERE ori IS NULL  UNION 
    SELECT *,2012 as year FROM offense_offender_counts_2012 WHERE ori IS NULL  UNION 
    SELECT *,2011 as year FROM offense_offender_counts_2011 WHERE ori IS NULL  UNION 
    SELECT *,2010 as year FROM offense_offender_counts_2010 WHERE ori IS NULL  UNION
    SELECT *,2009 as year FROM offense_offender_counts_2009 WHERE ori IS NULL  UNION 
    SELECT *,2008 as year FROM offense_offender_counts_2008 WHERE ori IS NULL  UNION 
    SELECT *,2007 as year FROM offense_offender_counts_2007 WHERE ori IS NULL  UNION
    SELECT *,2006 as year FROM offense_offender_counts_2006 WHERE ori IS NULL  UNION 
    SELECT *,2005 as year FROM offense_offender_counts_2005 WHERE ori IS NULL  UNION 
    SELECT *,2004 as year FROM offense_offender_counts_2004 WHERE ori IS NULL  UNION
    SELECT *,2003 as year FROM offense_offender_counts_2003 WHERE ori IS NULL  UNION 
    SELECT *,2002 as year FROM offense_offender_counts_2002 WHERE ori IS NULL  UNION 
    SELECT *,2001 as year FROM offense_offender_counts_2001 WHERE ori IS NULL  UNION
    SELECT *,2000 as year FROM offense_offender_counts_2000 WHERE ori IS NULL  UNION 
    SELECT *,1999 as year FROM offense_offender_counts_1999 WHERE ori IS NULL  UNION 
    SELECT *,1998 as year FROM offense_offender_counts_1998 WHERE ori IS NULL  UNION
    SELECT *,1997 as year FROM offense_offender_counts_1997 WHERE ori IS NULL  UNION 
    SELECT *,1996 as year FROM offense_offender_counts_1996 WHERE ori IS NULL  UNION 
    SELECT *,1995 as year FROM offense_offender_counts_1995 WHERE ori IS NULL  UNION
    SELECT *,1994 as year FROM offense_offender_counts_1994 WHERE ori IS NULL  UNION 
    SELECT *,1993 as year FROM offense_offender_counts_1993 WHERE ori IS NULL  UNION 
    SELECT *,1992 as year FROM offense_offender_counts_1992 WHERE ori IS NULL  UNION
    SELECT *,1991 as year FROM offense_offender_counts_1991 WHERE ori IS NULL ;


drop materialized view IF EXISTS  offense_offender_counts_ori_temp;
create materialized view offense_offender_counts_ori_temp as 
    SELECT *,$YEAR as year FROM offense_offender_counts_$YEAR WHERE ori IS NOT NULL  UNION 
    SELECT *,2015 as year FROM offense_offender_counts_2015 WHERE ori IS NOT NULL  UNION 
    SELECT *,2014 as year FROM offense_offender_counts_2014 WHERE ori IS NOT NULL  UNION 
    SELECT *,2013 as year FROM offense_offender_counts_2013 WHERE ori IS NOT NULL  UNION 
    SELECT *,2012 as year FROM offense_offender_counts_2012 WHERE ori IS NOT NULL  UNION 
    SELECT *,2011 as year FROM offense_offender_counts_2011 WHERE ori IS NOT NULL  UNION 
    SELECT *,2010 as year FROM offense_offender_counts_2010 WHERE ori IS NOT NULL  UNION
    SELECT *,2009 as year FROM offense_offender_counts_2009 WHERE ori IS NOT NULL  UNION 
    SELECT *,2008 as year FROM offense_offender_counts_2008 WHERE ori IS NOT NULL  UNION 
    SELECT *,2007 as year FROM offense_offender_counts_2007 WHERE ori IS NOT NULL  UNION
    SELECT *,2006 as year FROM offense_offender_counts_2006 WHERE ori IS NOT NULL  UNION 
    SELECT *,2005 as year FROM offense_offender_counts_2005 WHERE ori IS NOT NULL  UNION 
    SELECT *,2004 as year FROM offense_offender_counts_2004 WHERE ori IS NOT NULL  UNION
    SELECT *,2003 as year FROM offense_offender_counts_2003 WHERE ori IS NOT NULL  UNION 
    SELECT *,2002 as year FROM offense_offender_counts_2002 WHERE ori IS NOT NULL  UNION 
    SELECT *,2001 as year FROM offense_offender_counts_2001 WHERE ori IS NOT NULL  UNION
    SELECT *,2000 as year FROM offense_offender_counts_2000 WHERE ori IS NOT NULL  UNION 
    SELECT *,1999 as year FROM offense_offender_counts_1999 WHERE ori IS NOT NULL  UNION 
    SELECT *,1998 as year FROM offense_offender_counts_1998 WHERE ori IS NOT NULL  UNION
    SELECT *,1997 as year FROM offense_offender_counts_1997 WHERE ori IS NOT NULL  UNION 
    SELECT *,1996 as year FROM offense_offender_counts_1996 WHERE ori IS NOT NULL  UNION 
    SELECT *,1995 as year FROM offense_offender_counts_1995 WHERE ori IS NOT NULL  UNION
    SELECT *,1994 as year FROM offense_offender_counts_1994 WHERE ori IS NOT NULL  UNION 
    SELECT *,1993 as year FROM offense_offender_counts_1993 WHERE ori IS NOT NULL  UNION 
    SELECT *,1992 as year FROM offense_offender_counts_1992 WHERE ori IS NOT NULL  UNION
    SELECT *,1991 as year FROM offense_offender_counts_1991 WHERE ori IS NOT NULL ;

--------------
-- VICTIMS
--------------
DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    -- necessary when run on test DB slice
    EXECUTE 'CREATE TABLE IF NOT EXISTS nibrs_victim_denorm_' || i::TEXT || ' () INHERITS (nibrs_victim_denorm)';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view IF EXISTS victim_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view victim_counts_' || i::TEXT || ' as select count(victim_id), ori,resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code,location_name ,prop_desc_name
    from ( 
        SELECT DISTINCT(victim_id), ref_agency.ori, ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, nibrs_victim_denorm_' || i::TEXT || '.state_id,location_name,prop_desc_name 
        from nibrs_victim_denorm_' || i::TEXT || '  
        JOIN ref_agency ON ref_agency.agency_id = nibrs_victim_denorm_' || i::TEXT || '.agency_id
        where year::integer = ' || i || '  and nibrs_victim_denorm_' || i::TEXT || '.state_id is not null
        ) as temp
    GROUP BY GROUPING SETS (
        (year, race_code),
        (year, sex_code),
        (year, age_num),
        (year, location_name), 
        (year, offense_name),
        (year, prop_desc_name),
        (year, resident_status_code), 
        (year, offender_relationship),
        (year, circumstance_name),
        (year, ethnicity),
        (year, state_id, race_code),
        (year, state_id, sex_code),
        (year, state_id, age_num),
        (year, state_id, location_name), 
        (year, state_id, offense_name),
        (year, state_id, prop_desc_name),
        (year, state_id, resident_status_code), 
        (year, state_id, offender_relationship),
        (year, state_id, circumstance_name),
        (year, state_id, ethnicity),
        (year, ori, race_code),
        (year, ori, sex_code),
        (year, ori, age_num),
        (year, ori, location_name), 
        (year, ori, offense_name),
        (year, ori, prop_desc_name),
        (year, ori, resident_status_code), 
        (year, ori, offender_relationship),
        (year, ori, circumstance_name),
        (year, ori, ethnicity)
    );';
   END LOOP;
END
$do$;

create materialized view victim_counts_states_temp as 
    SELECT *, $YEAR as year FROM victim_counts_$YEAR WHERE ori IS NULL UNION  
    SELECT *, 2015 as year FROM victim_counts_2015 WHERE ori IS NULL UNION 
    SELECT *, 2014 as year FROM victim_counts_2014 WHERE ori IS NULL UNION 
    SELECT *, 2013 as year FROM victim_counts_2013 WHERE ori IS NULL UNION 
    SELECT *, 2012 as year FROM victim_counts_2012 WHERE ori IS NULL UNION 
    SELECT *, 2011 as year FROM victim_counts_2011 WHERE ori IS NULL UNION 
    SELECT *, 2010 as year FROM victim_counts_2010 WHERE ori IS NULL UNION 
    SELECT *, 2009 as year FROM victim_counts_2009 WHERE ori IS NULL UNION 
    SELECT *, 2008 as year FROM victim_counts_2008 WHERE ori IS NULL UNION 
    SELECT *, 2007 as year FROM victim_counts_2007 WHERE ori IS NULL UNION 
    SELECT *, 2006 as year FROM victim_counts_2006 WHERE ori IS NULL UNION 
    SELECT *, 2005 as year FROM victim_counts_2005 WHERE ori IS NULL UNION 
    SELECT *, 2004 as year FROM victim_counts_2004 WHERE ori IS NULL UNION 
    SELECT *, 2003 as year FROM victim_counts_2003 WHERE ori IS NULL UNION 
    SELECT *, 2002 as year FROM victim_counts_2002 WHERE ori IS NULL UNION 
    SELECT *, 2001 as year FROM victim_counts_2001 WHERE ori IS NULL UNION 
    SELECT *, 2000 as year FROM victim_counts_2000 WHERE ori IS NULL UNION 
    SELECT *, 1999 as year FROM victim_counts_1999 WHERE ori IS NULL UNION 
    SELECT *, 1998 as year FROM victim_counts_1998 WHERE ori IS NULL UNION 
    SELECT *, 1997 as year FROM victim_counts_1997 WHERE ori IS NULL UNION 
    SELECT *, 1996 as year FROM victim_counts_1996 WHERE ori IS NULL UNION 
    SELECT *, 1995 as year FROM victim_counts_1995 WHERE ori IS NULL UNION 
    SELECT *, 1994 as year FROM victim_counts_1994 WHERE ori IS NULL UNION 
    SELECT *, 1993 as year FROM victim_counts_1993 WHERE ori IS NULL UNION 
    SELECT *, 1992 as year FROM victim_counts_1992 WHERE ori IS NULL UNION 
    SELECT *, 1991 as year FROM victim_counts_1991 WHERE ori IS NULL;

create materialized view victim_counts_ori_temp as 
    SELECT *, $YEAR as year FROM victim_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *, 2015 as year FROM victim_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *, 2014 as year FROM victim_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *, 2013 as year FROM victim_counts_2013 WHERE ori IS NOT NULL UNION
    SELECT *, 2012 as year FROM victim_counts_2012 WHERE ori IS NOT NULL UNION 
    SELECT *, 2011 as year FROM victim_counts_2011 WHERE ori IS NOT NULL UNION 
    SELECT *, 2010 as year FROM victim_counts_2010 WHERE ori IS NOT NULL UNION
    SELECT *, 2009 as year FROM victim_counts_2009 WHERE ori IS NOT NULL UNION 
    SELECT *, 2008 as year FROM victim_counts_2008 WHERE ori IS NOT NULL UNION 
    SELECT *, 2007 as year FROM victim_counts_2007 WHERE ori IS NOT NULL UNION
    SELECT *, 2006 as year FROM victim_counts_2006 WHERE ori IS NOT NULL UNION 
    SELECT *, 2005 as year FROM victim_counts_2005 WHERE ori IS NOT NULL UNION 
    SELECT *, 2004 as year FROM victim_counts_2004 WHERE ori IS NOT NULL UNION
    SELECT *, 2003 as year FROM victim_counts_2003 WHERE ori IS NOT NULL UNION 
    SELECT *, 2002 as year FROM victim_counts_2002 WHERE ori IS NOT NULL UNION 
    SELECT *, 2001 as year FROM victim_counts_2001 WHERE ori IS NOT NULL UNION
    SELECT *, 2000 as year FROM victim_counts_2000 WHERE ori IS NOT NULL UNION 
    SELECT *, 1999 as year FROM victim_counts_1999 WHERE ori IS NOT NULL UNION 
    SELECT *, 1998 as year FROM victim_counts_1998 WHERE ori IS NOT NULL UNION
    SELECT *, 1997 as year FROM victim_counts_1997 WHERE ori IS NOT NULL UNION 
    SELECT *, 1996 as year FROM victim_counts_1996 WHERE ori IS NOT NULL UNION 
    SELECT *, 1995 as year FROM victim_counts_1995 WHERE ori IS NOT NULL UNION
    SELECT *, 1994 as year FROM victim_counts_1994 WHERE ori IS NOT NULL UNION 
    SELECT *, 1993 as year FROM victim_counts_1993 WHERE ori IS NOT NULL UNION 
    SELECT *, 1992 as year FROM victim_counts_1992 WHERE ori IS NOT NULL UNION
    SELECT *, 1991 as year FROM victim_counts_1991 WHERE ori IS NOT NULL;

--------------
-- VICTIMS - OFFENSES
--------------

DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view  IF EXISTS offense_victim_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offense_victim_counts_' || i::TEXT || ' as select count(victim_id), ori,resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
    from ( 
        SELECT DISTINCT(victim_id), ref_agency.ori, ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, nibrs_victim_denorm_' || i::TEXT || '.state_id from nibrs_victim_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_victim_denorm_' || i::TEXT || '.agency_id
        where year::integer = ' || i || '  and nibrs_victim_denorm_' || i::TEXT || '.state_id is not null
        ) as temp
    GROUP BY GROUPING SETS (
        (year, offense_name, race_code),
        (year, offense_name, sex_code),
        (year, offense_name, age_num),
        (year, offense_name, ethnicity),
        (year, offense_name, resident_status_code),
        (year, offense_name, offender_relationship),
        (year, offense_name, circumstance_name),
        (year, state_id, offense_name, race_code),
        (year, state_id, offense_name, sex_code),
        (year, state_id, offense_name, age_num),
        (year, state_id, offense_name, ethnicity),
        (year, state_id, offense_name, resident_status_code),
        (year, state_id, offense_name, offender_relationship),
        (year, state_id, offense_name, circumstance_name),
        (year, ori, offense_name, race_code),
        (year, ori, offense_name, sex_code),
        (year, ori, offense_name, age_num),
        (year, ori, offense_name, ethnicity),
        (year, ori, offense_name, resident_status_code),
        (year, ori, offense_name, offender_relationship),
        (year, ori, offense_name, circumstance_name)
    );';
   END LOOP;
END
$do$;

create materialized view offense_victim_counts_states_temp as 
SELECT *, $YEAR as year FROM offense_victim_counts_$YEAR WHERE ori IS NULL UNION 
SELECT *, 2015 as year FROM offense_victim_counts_2015 WHERE ori IS NULL UNION 
SELECT *, 2014 as year FROM offense_victim_counts_2014 WHERE ori IS NULL UNION 
SELECT *, 2013 as year FROM offense_victim_counts_2013 WHERE ori IS NULL UNION
SELECT *, 2012 as year FROM offense_victim_counts_2012 WHERE ori IS NULL UNION 
SELECT *, 2011 as year FROM offense_victim_counts_2011 WHERE ori IS NULL UNION 
SELECT *, 2010 as year FROM offense_victim_counts_2010 WHERE ori IS NULL UNION
SELECT *, 2009 as year FROM offense_victim_counts_2009 WHERE ori IS NULL UNION 
SELECT *, 2008 as year FROM offense_victim_counts_2008 WHERE ori IS NULL UNION 
SELECT *, 2007 as year FROM offense_victim_counts_2007 WHERE ori IS NULL UNION
SELECT *, 2006 as year FROM offense_victim_counts_2006 WHERE ori IS NULL UNION 
SELECT *, 2005 as year FROM offense_victim_counts_2005 WHERE ori IS NULL UNION 
SELECT *, 2004 as year FROM offense_victim_counts_2004 WHERE ori IS NULL UNION
SELECT *, 2003 as year FROM offense_victim_counts_2003 WHERE ori IS NULL UNION 
SELECT *, 2002 as year FROM offense_victim_counts_2002 WHERE ori IS NULL UNION 
SELECT *, 2001 as year FROM offense_victim_counts_2001 WHERE ori IS NULL UNION
SELECT *, 2000 as year FROM offense_victim_counts_2000 WHERE ori IS NULL UNION 
SELECT *, 1999 as year FROM offense_victim_counts_1999 WHERE ori IS NULL UNION 
SELECT *, 1998 as year FROM offense_victim_counts_1998 WHERE ori IS NULL UNION
SELECT *, 1997 as year FROM offense_victim_counts_1997 WHERE ori IS NULL UNION 
SELECT *, 1996 as year FROM offense_victim_counts_1996 WHERE ori IS NULL UNION 
SELECT *, 1995 as year FROM offense_victim_counts_1995 WHERE ori IS NULL UNION
SELECT *, 1994 as year FROM offense_victim_counts_1994 WHERE ori IS NULL UNION 
SELECT *, 1993 as year FROM offense_victim_counts_1993 WHERE ori IS NULL UNION 
SELECT *, 1992 as year FROM offense_victim_counts_1992 WHERE ori IS NULL UNION
SELECT *, 1991 as year FROM offense_victim_counts_1991 WHERE ori IS NULL;

create materialized view offense_victim_counts_ori_temp as 
    SELECT *, $YEAR as year FROM offense_victim_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *, 2015 as year FROM offense_victim_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *, 2014 as year FROM offense_victim_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *, 2013 as year FROM offense_victim_counts_2013 WHERE ori IS NOT NULL UNION
    SELECT *, 2012 as year FROM offense_victim_counts_2012 WHERE ori IS NOT NULL UNION 
    SELECT *, 2011 as year FROM offense_victim_counts_2011 WHERE ori IS NOT NULL UNION 
    SELECT *, 2010 as year FROM offense_victim_counts_2010 WHERE ori IS NOT NULL UNION
    SELECT *, 2009 as year FROM offense_victim_counts_2009 WHERE ori IS NOT NULL UNION 
    SELECT *, 2008 as year FROM offense_victim_counts_2008 WHERE ori IS NOT NULL UNION 
    SELECT *, 2007 as year FROM offense_victim_counts_2007 WHERE ori IS NOT NULL UNION
    SELECT *, 2006 as year FROM offense_victim_counts_2006 WHERE ori IS NOT NULL UNION 
    SELECT *, 2005 as year FROM offense_victim_counts_2005 WHERE ori IS NOT NULL UNION 
    SELECT *, 2004 as year FROM offense_victim_counts_2004 WHERE ori IS NOT NULL UNION
    SELECT *, 2003 as year FROM offense_victim_counts_2003 WHERE ori IS NOT NULL UNION 
    SELECT *, 2002 as year FROM offense_victim_counts_2002 WHERE ori IS NOT NULL UNION 
    SELECT *, 2001 as year FROM offense_victim_counts_2001 WHERE ori IS NOT NULL UNION
    SELECT *, 2000 as year FROM offense_victim_counts_2000 WHERE ori IS NOT NULL UNION 
    SELECT *, 1999 as year FROM offense_victim_counts_1999 WHERE ori IS NOT NULL UNION 
    SELECT *, 1998 as year FROM offense_victim_counts_1998 WHERE ori IS NOT NULL UNION
    SELECT *, 1997 as year FROM offense_victim_counts_1997 WHERE ori IS NOT NULL UNION 
    SELECT *, 1996 as year FROM offense_victim_counts_1996 WHERE ori IS NOT NULL UNION 
    SELECT *, 1995 as year FROM offense_victim_counts_1995 WHERE ori IS NOT NULL UNION
    SELECT *, 1994 as year FROM offense_victim_counts_1994 WHERE ori IS NOT NULL UNION 
    SELECT *, 1993 as year FROM offense_victim_counts_1993 WHERE ori IS NOT NULL UNION 
    SELECT *, 1992 as year FROM offense_victim_counts_1992 WHERE ori IS NOT NULL UNION
    SELECT *, 1991 as year FROM offense_victim_counts_1991 WHERE ori IS NOT NULL;

--------------
-- OFFENSES
--------------

DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    -- needed when run locally
    EXECUTE 'CREATE TABLE IF NOT EXISTS nibrs_offense_denorm_' || i::TEXT || ' () INHERITS (nibrs_offense_denorm)';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view IF EXISTS  offense_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offense_counts_' || i::TEXT || ' as select count(offense_id), ori, offense_name,weapon_name, method_entry_code, num_premises_entered,location_name, state_id 
    from ( 
        SELECT DISTINCT(offense_id), ref_agency.ori, offense_name, weapon_name, method_entry_code, num_premises_entered,location_name, nibrs_offense_denorm_' || i::TEXT || '.state_id, year from nibrs_offense_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_offense_denorm_' || i::TEXT || '.agency_id 
        where year::integer = ' || i || ' 
        ) as temp
    GROUP BY GROUPING SETS (
        (year, offense_name),
        (year, weapon_name),
        (year, method_entry_code),
        (year, num_premises_entered),
        (year, location_name),
        (year, state_id, offense_name),
        (year, state_id, weapon_name),
        (year, state_id, method_entry_code),
        (year, state_id, num_premises_entered),
        (year, state_id, location_name),
        (year, ori, offense_name),
        (year, ori, weapon_name),
        (year, ori, method_entry_code),
        (year, ori, num_premises_entered),
        (year, ori, location_name)
    );';
   END LOOP;
END
$do$;


create materialized view offense_counts_states_temp as 
    SELECT *,$YEAR as year  FROM offense_counts_$YEAR WHERE ori IS NULL UNION 
    SELECT *,2015 as year  FROM offense_counts_2015 WHERE ori IS NULL UNION 
    SELECT *,2014 as year  FROM offense_counts_2014 WHERE ori IS NULL UNION 
    SELECT *,2013 as year  FROM offense_counts_2013 WHERE ori IS NULL UNION 
    SELECT *,2012 as year  FROM offense_counts_2012 WHERE ori IS NULL UNION 
    SELECT *,2011 as year  FROM offense_counts_2011 WHERE ori IS NULL UNION 
    SELECT *,2010 as year  FROM offense_counts_2010 WHERE ori IS NULL UNION 
    SELECT *,2009 as year  FROM offense_counts_2009 WHERE ori IS NULL UNION 
    SELECT *,2008 as year  FROM offense_counts_2008 WHERE ori IS NULL UNION 
    SELECT *,2007 as year  FROM offense_counts_2007 WHERE ori IS NULL UNION 
    SELECT *,2006 as year  FROM offense_counts_2006 WHERE ori IS NULL UNION 
    SELECT *,2005 as year  FROM offense_counts_2005 WHERE ori IS NULL UNION 
    SELECT *,2004 as year  FROM offense_counts_2004 WHERE ori IS NULL UNION 
    SELECT *,2003 as year  FROM offense_counts_2003 WHERE ori IS NULL UNION 
    SELECT *,2002 as year  FROM offense_counts_2002 WHERE ori IS NULL UNION 
    SELECT *,2001 as year  FROM offense_counts_2001 WHERE ori IS NULL UNION 
    SELECT *,2000 as year  FROM offense_counts_2000 WHERE ori IS NULL UNION 
    SELECT *,1999 as year  FROM offense_counts_1999 WHERE ori IS NULL UNION 
    SELECT *,1998 as year  FROM offense_counts_1998 WHERE ori IS NULL UNION 
    SELECT *,1997 as year  FROM offense_counts_1997 WHERE ori IS NULL UNION 
    SELECT *,1996 as year  FROM offense_counts_1996 WHERE ori IS NULL UNION 
    SELECT *,1995 as year  FROM offense_counts_1995 WHERE ori IS NULL UNION 
    SELECT *,1994 as year  FROM offense_counts_1994 WHERE ori IS NULL UNION 
    SELECT *,1993 as year  FROM offense_counts_1993 WHERE ori IS NULL UNION 
    SELECT *,1992 as year  FROM offense_counts_1992 WHERE ori IS NULL UNION 
    SELECT *,1991 as year  FROM offense_counts_1991 WHERE ori IS NULL;

create materialized view offense_counts_ori_temp as 
    SELECT *,$YEAR as year  FROM offense_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *,2015 as year  FROM offense_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *,2014 as year  FROM offense_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *,2013 as year  FROM offense_counts_2013 WHERE ori IS NOT NULL UNION
    SELECT *,2012 as year  FROM offense_counts_2012 WHERE ori IS NOT NULL UNION 
    SELECT *,2011 as year  FROM offense_counts_2011 WHERE ori IS NOT NULL UNION 
    SELECT *,2010 as year  FROM offense_counts_2010 WHERE ori IS NOT NULL UNION
    SELECT *,2009 as year  FROM offense_counts_2009 WHERE ori IS NOT NULL UNION 
    SELECT *,2008 as year  FROM offense_counts_2008 WHERE ori IS NOT NULL UNION 
    SELECT *,2007 as year  FROM offense_counts_2007 WHERE ori IS NOT NULL UNION
    SELECT *,2006 as year  FROM offense_counts_2006 WHERE ori IS NOT NULL UNION 
    SELECT *,2005 as year  FROM offense_counts_2005 WHERE ori IS NOT NULL UNION 
    SELECT *,2004 as year  FROM offense_counts_2004 WHERE ori IS NOT NULL UNION
    SELECT *,2003 as year  FROM offense_counts_2003 WHERE ori IS NOT NULL UNION 
    SELECT *,2002 as year  FROM offense_counts_2002 WHERE ori IS NOT NULL UNION 
    SELECT *,2001 as year  FROM offense_counts_2001 WHERE ori IS NOT NULL UNION
    SELECT *,2000 as year  FROM offense_counts_2000 WHERE ori IS NOT NULL UNION 
    SELECT *,1999 as year  FROM offense_counts_1999 WHERE ori IS NOT NULL UNION 
    SELECT *,1998 as year  FROM offense_counts_1998 WHERE ori IS NOT NULL UNION
    SELECT *,1997 as year  FROM offense_counts_1997 WHERE ori IS NOT NULL UNION 
    SELECT *,1996 as year  FROM offense_counts_1996 WHERE ori IS NOT NULL UNION 
    SELECT *,1995 as year  FROM offense_counts_1995 WHERE ori IS NOT NULL UNION
    SELECT *,1994 as year  FROM offense_counts_1994 WHERE ori IS NOT NULL UNION 
    SELECT *,1993 as year  FROM offense_counts_1993 WHERE ori IS NOT NULL UNION 
    SELECT *,1992 as year  FROM offense_counts_1992 WHERE ori IS NOT NULL UNION
    SELECT *,1991 as year  FROM offense_counts_1991 WHERE ori IS NOT NULL;

--------------
-- OFFENSE - OFFENSES
--------------
DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view IF EXISTS  offense_offense_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offense_offense_counts_' || i::TEXT || ' as select count(offense_id), ori, offense_name,weapon_name, method_entry_code, num_premises_entered,location_name, state_id 
    from ( 
        SELECT DISTINCT(offense_id), ref_agency.ori, offense_name, weapon_name, method_entry_code, num_premises_entered,location_name, nibrs_offense_denorm_' || i::TEXT || '.state_id, year from nibrs_offense_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_offense_denorm_' || i::TEXT || '.agency_id 
        where year::integer = ' || i || ' 
        ) as temp
    GROUP BY GROUPING SETS (
        (year, offense_name, weapon_name),
        (year, offense_name, method_entry_code),
        (year, offense_name, num_premises_entered),
        (year, offense_name, location_name),
        (year, state_id, offense_name, weapon_name),
        (year, state_id, offense_name, method_entry_code),
        (year, state_id, offense_name, num_premises_entered),
        (year, state_id, offense_name, location_name),
        (year, ori, offense_name, weapon_name),
        (year, ori, offense_name, method_entry_code),
        (year, ori, offense_name, num_premises_entered),
        (year, ori, offense_name, location_name)
    );';
   END LOOP;
END
$do$;

create materialized view offense_offense_counts_states_temp as 
    SELECT *,$YEAR as year FROM offense_offense_counts_$YEAR WHERE ori IS NULL UNION 
    SELECT *,2015 as year FROM offense_offense_counts_2015 WHERE ori IS NULL UNION 
    SELECT *,2014 as year FROM offense_offense_counts_2014 WHERE ori IS NULL UNION 
    SELECT *,2013 as year  FROM offense_offense_counts_2013 WHERE ori IS NULL UNION 
    SELECT *,2012 as year  FROM offense_offense_counts_2012 WHERE ori IS NULL UNION 
    SELECT *,2011 as year  FROM offense_offense_counts_2011 WHERE ori IS NULL UNION 
    SELECT *,2010 as year  FROM offense_offense_counts_2010 WHERE ori IS NULL UNION 
    SELECT *,2009 as year  FROM offense_offense_counts_2009 WHERE ori IS NULL UNION 
    SELECT *,2008 as year  FROM offense_offense_counts_2008 WHERE ori IS NULL UNION 
    SELECT *,2007 as year  FROM offense_offense_counts_2007 WHERE ori IS NULL UNION 
    SELECT *,2006 as year  FROM offense_offense_counts_2006 WHERE ori IS NULL UNION 
    SELECT *,2005 as year  FROM offense_offense_counts_2005 WHERE ori IS NULL UNION 
    SELECT *,2004 as year  FROM offense_offense_counts_2004 WHERE ori IS NULL UNION 
    SELECT *,2003 as year  FROM offense_offense_counts_2003 WHERE ori IS NULL UNION 
    SELECT *,2002 as year  FROM offense_offense_counts_2002 WHERE ori IS NULL UNION 
    SELECT *,2001 as year  FROM offense_offense_counts_2001 WHERE ori IS NULL UNION 
    SELECT *,2000 as year  FROM offense_offense_counts_2000 WHERE ori IS NULL UNION 
    SELECT *,1999 as year  FROM offense_offense_counts_1999 WHERE ori IS NULL UNION 
    SELECT *,1998 as year  FROM offense_offense_counts_1998 WHERE ori IS NULL UNION 
    SELECT *,1997 as year  FROM offense_offense_counts_1997 WHERE ori IS NULL UNION 
    SELECT *,1996 as year  FROM offense_offense_counts_1996 WHERE ori IS NULL UNION 
    SELECT *,1995 as year  FROM offense_offense_counts_1995 WHERE ori IS NULL UNION 
    SELECT *,1994 as year  FROM offense_offense_counts_1994 WHERE ori IS NULL UNION 
    SELECT *,1993 as year  FROM offense_offense_counts_1993 WHERE ori IS NULL UNION 
    SELECT *,1992 as year  FROM offense_offense_counts_1992 WHERE ori IS NULL UNION 
    SELECT *,1991 as year  FROM offense_offense_counts_1991 WHERE ori IS NULL;



create materialized view offense_offense_counts_ori_temp as 
    SELECT *,$YEAR as year FROM offense_offense_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *,2015 as year FROM offense_offense_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *,2014 as year FROM offense_offense_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *,2013 as year  FROM offense_offense_counts_2013 WHERE ori IS NOT NULL UNION 
    SELECT *,2012 as year  FROM offense_offense_counts_2012 WHERE ori IS NOT NULL UNION 
    SELECT *,2011 as year  FROM offense_offense_counts_2011 WHERE ori IS NOT NULL UNION 
    SELECT *,2010 as year  FROM offense_offense_counts_2010 WHERE ori IS NOT NULL UNION 
    SELECT *,2009 as year  FROM offense_offense_counts_2009 WHERE ori IS NOT NULL UNION 
    SELECT *,2008 as year  FROM offense_offense_counts_2008 WHERE ori IS NOT NULL UNION 
    SELECT *,2007 as year  FROM offense_offense_counts_2007 WHERE ori IS NOT NULL UNION 
    SELECT *,2006 as year  FROM offense_offense_counts_2006 WHERE ori IS NOT NULL UNION 
    SELECT *,2005 as year  FROM offense_offense_counts_2005 WHERE ori IS NOT NULL UNION 
    SELECT *,2004 as year  FROM offense_offense_counts_2004 WHERE ori IS NOT NULL UNION 
    SELECT *,2003 as year  FROM offense_offense_counts_2003 WHERE ori IS NOT NULL UNION 
    SELECT *,2002 as year  FROM offense_offense_counts_2002 WHERE ori IS NOT NULL UNION 
    SELECT *,2001 as year  FROM offense_offense_counts_2001 WHERE ori IS NOT NULL UNION 
    SELECT *,2000 as year  FROM offense_offense_counts_2000 WHERE ori IS NOT NULL UNION 
    SELECT *,1999 as year  FROM offense_offense_counts_1999 WHERE ori IS NOT NULL UNION 
    SELECT *,1998 as year  FROM offense_offense_counts_1998 WHERE ori IS NOT NULL UNION 
    SELECT *,1997 as year  FROM offense_offense_counts_1997 WHERE ori IS NOT NULL UNION 
    SELECT *,1996 as year  FROM offense_offense_counts_1996 WHERE ori IS NOT NULL UNION 
    SELECT *,1995 as year  FROM offense_offense_counts_1995 WHERE ori IS NOT NULL UNION 
    SELECT *,1994 as year  FROM offense_offense_counts_1994 WHERE ori IS NOT NULL UNION 
    SELECT *,1993 as year  FROM offense_offense_counts_1993 WHERE ori IS NOT NULL UNION 
    SELECT *,1992 as year  FROM offense_offense_counts_1992 WHERE ori IS NOT NULL UNION 
    SELECT *,1991 as year  FROM offense_offense_counts_1991 WHERE ori IS NOT NULL;

"
