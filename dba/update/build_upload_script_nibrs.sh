
MYPWD="$(pwd)/data"
YEAR=$1


echo "--------------------------
-- 
-- 
--  UPLOAD NIBRS TABLES.
-- 
-- 
---------------------------


-- nibrs_incident (This one could take awhile - grab some popcorn)
DROP TABLE IF EXISTS nibrs_incident_temp;
CREATE TABLE nibrs_incident_temp (
    agency_id text,
    incident_id text,
    nibrs_month_id text,
    incident_numb` text,
    cargo_theft_flag text,
    submission_date text,
    incident_date text,
    report_date_flag text,
    incident_hour text,
    cleared_except_id text,
    cleared_except_date text,
    incident_status text,
    data_home text,
    ddocname text,
    orig_format text,
    ff_line_number text,
    did text
);

\COPY nibrs_incident_temp (agency_id, incident_id, nibrs_month_id, incident_number, cargo_theft_flag, submission_date, incident_date, report_date_flag, incident_hour, cleared_except_id, cleared_except_date, incident_status, data_home, ddocname, orig_format, ff_line_number, did) FROM '$MYPWD/NIBRS_I.csv' WITH DELIMITER ',';


CREATE TABLE nibrs_incident_new (
    agency_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    nibrs_month_id bigint NOT NULL,
    incident_number character varying(15),
    cargo_theft_flag character(1),
    submission_date timestamp without time zone,
    incident_date timestamp without time zone,
    report_date_flag character(1),
    incident_hour smallint,
    cleared_except_id smallint NOT NULL,
    cleared_except_date timestamp without time zone,
    incident_status smallint,
    data_home character(1),
    ddocname character varying(100),
    orig_format character(1),
    ff_line_number bigint,
    did bigint
);




-- nibrs_month
DROP TABLE IF EXISTS nibrs_month_temp;
CREATE TABLE nibrs_month_temp (
    nibrs_month_id text,
    agency_id text,
    month_num text,
    data_year text,
    reported_status text,
    report_date text,
    prepared_date text,
    update_flag text,
    orig_format text,
    ff_line_number text,
    data_home text,
    ddocname text,
    did text
);

\COPY nibrs_month_temp (nibrs_month_id, agency_id, month_num, data_year, reported_status, report_date, prepared_date, update_flag, orig_format, ff_line_number, data_home, ddocname, did) FROM '$MYPWD/NIBRS_M.csv' WITH DELIMITER ',';


-- nibrs_arrestee
DROP TABLE IF EXISTS nibrs_arrestee_temp;
CREATE TABLE nibrs_arrestee_temp (
    arrestee_id text,
    incident_id text,
    arrestee_seq_num text,
    arrest_num text,
    arrest_date text,
    arrest_type_id text,
    multiple_indicator text,
    offense_type_id text,
    age_id text,
    age_num text,
    sex_code text,
    race_id text,
    ethnicity_id text,
    resident_code text,
    under_18_disposition_code text,
    clearance_ind text,
    ff_line_number text,
    age_range_low_num text,
    age_range_high_num text
);

\COPY nibrs_arrestee_temp (arrestee_id, incident_id, arrestee_seq_num, arrest_num, arrest_date, arrest_type_id, multiple_indicator, offense_type_id, age_id, age_num, sex_code, race_id, ethnicity_id, resident_code, under_18_disposition_code, clearance_ind, ff_line_number, age_range_low_num, age_range_high_num) FROM '$MYPWD/NIBRS_A.csv' WITH DELIMITER ',';

CREATE TABLE nibrs_arrestee_new (
    arrestee_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    arrestee_seq_num bigint,
    arrest_num character varying(12),
    arrest_date timestamp without time zone,
    arrest_type_id smallint,
    multiple_indicator character(1),
    offense_type_id bigint NOT NULL,
    age_id smallint NOT NULL,
    age_num smallint,
    sex_code character(1),
    race_id smallint NOT NULL,
    ethnicity_id smallint,
    resident_code character(1),
    under_18_disposition_code character(1),
    clearance_ind character(1),
    ff_line_number bigint,
    age_range_low_num smallint,
    age_range_high_num smallint
);


-- nibrs_arrestee_weapon
DROP TABLE IF EXISTS nibrs_arrestee_weapon_temp;
CREATE TABLE nibrs_arrestee_weapon_temp (
    arrestee_id text,
    weapon_id text,
    nibrs_arrestee_weapon_id text
);

\COPY nibrs_arrestee_weapon_temp (arrestee_id, weapon_id, nibrs_arrestee_weapon_id) FROM '$MYPWD/NIBRS_AW.csv' WITH DELIMITER ',';

-- nibrs_bias_motivation
DROP TABLE IF EXISTS nibrs_bias_motivation_temp;
CREATE TABLE nibrs_bias_motivation_temp (
    bias_id text,
    offense_id text
);

\COPY nibrs_bias_motivation_temp (bias_id, offense_id) FROM '$MYPWD/NIBRS_BM.csv' WITH DELIMITER ',';


-- nibrs_criminal_act
DROP TABLE IF EXISTS nibrs_criminal_act_temp;
CREATE TABLE nibrs_criminal_act_temp (
    criminal_act_id text,
    offense_id text
);

\COPY nibrs_criminal_act_temp (criminal_act_id, offense_id) FROM '$MYPWD/NIBRS_CA.csv' WITH DELIMITER ',';

-- nibrs_offense
DROP TABLE IF EXISTS nibrs_offense_temp;
CREATE TABLE nibrs_offense_temp (
    offense_id text,
    incident_id text,
    offense_type_id text,
    attempt_complete_flag text,
    location_id text,
    num_premises_entered text,
    method_entry_code text,
    ff_line_number text
);

\COPY nibrs_offense_temp (offense_id, incident_id, offense_type_id, attempt_complete_flag, location_id, num_premises_entered, method_entry_code, ff_line_number) FROM '$MYPWD/NIBRS_OFF.csv' WITH DELIMITER ',';

CREATE TABLE nibrs_offense_new (
    offense_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    offense_type_id bigint NOT NULL,
    attempt_complete_flag character(1),
    location_id bigint NOT NULL,
    num_premises_entered smallint,
    method_entry_code character(1),
    ff_line_number bigint
);

DROP TABLE IF EXISTS nibrs_offender_temp;
CREATE TABLE nibrs_offender_temp (
    offender_id text,
    incident_id text,
    offender_seq_num text,
    age_id text,
    age_num text,
    sex_code text,
    race_id text,
    ethnicity_id text,
    ff_line_number text,
    age_range_low_num text,
    age_range_high_num text
);

\COPY nibrs_offender_temp (offender_id, incident_id, offender_seq_num, age_id, age_num, sex_code, race_id, ethnicity_id, ff_line_number, age_range_low_num, age_range_high_num) FROM '$MYPWD/NIBRS_OF.csv' WITH DELIMITER ',';


CREATE TABLE nibrs_offender_new (
    offender_id bigint NOT NULL,
    incident_id bigint NOT NULL,
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


-- nibrs_property
DROP TABLE IF EXISTS nibrs_property_temp;
CREATE TABLE nibrs_property_temp (
    property_id text,
    incident_id text,
    prop_loss_id text,
    stolen_count text,
    recovered_count text,
    ff_line_number text
);

\COPY nibrs_property_temp (property_id, incident_id, prop_loss_id, stolen_count, recovered_count, ff_line_number) FROM '$MYPWD/NIBRS_P.csv' WITH DELIMITER ',';


CREATE TABLE nibrs_property_new (
    property_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    prop_loss_id smallint NOT NULL,
    stolen_count smallint,
    recovered_count smallint,
    ff_line_number bigint
);

-- nibrs_property_desc
DROP TABLE IF EXISTS nibrs_property_desc_temp;
CREATE TABLE nibrs_property_desc_temp (
    property_id text,
    prop_desc_id text,
    property_value text,
    date_recovered text,
    nibrs_prop_desc_id text
);

\COPY nibrs_property_desc_temp (property_id, prop_desc_id, property_value, date_recovered, nibrs_prop_desc_id) FROM '$MYPWD/NIBRS_PD.csv' WITH DELIMITER ',';

DROP TABLE IF EXISTS nibrs_property_desc_new;
CREATE TABLE nibrs_property_desc_new (
    property_id bigint,
    prop_desc_id bigint,
    property_value int,
    date_recovered timestamp,
    nibrs_prop_desc_id int
);


-- nibrs_suspected_drug
DROP TABLE IF EXISTS nibrs_suspected_drug_temp;
CREATE TABLE nibrs_suspected_drug_temp (
    suspected_drug_type_id text,
    property_id text,
    est_drug_qty text,
    drug_measure_type_id text,
    nibrs_suspected_drug_id text
);

\COPY nibrs_suspected_drug_temp (suspected_drug_type_id, property_id, est_drug_qty, drug_measure_type_id, nibrs_suspected_drug_id) FROM '$MYPWD/NIBRS_SD.csv' WITH DELIMITER ',';


-- nibrs_suspect_using
DROP TABLE IF EXISTS nibrs_suspect_using_temp;
CREATE TABLE nibrs_suspect_using_temp (
    suspect_using_id text,
    offense_id text
);

\COPY nibrs_suspect_using_temp (suspect_using_id, offense_id) FROM '$MYPWD/NIBRS_SU.csv' WITH DELIMITER ',';

-- nibrs_victim
DROP TABLE IF EXISTS nibrs_victim_temp;
CREATE TABLE nibrs_victim_temp (
    victim_id text,
    incident_id text,
    victim_seq_num text,
    victim_type_id text,
    assignment_type_id text,
    activity_type_id text,
    outside_agency_id text,
    age_id text,
    age_num text,
    sex_code text,
    race_id text,
    ethnicity_id text,
    resident_status_code text,
    agency_data_year text,
    ff_line_number text,
    age_range_low_num text,
    age_range_high_num text
);

\COPY nibrs_victim_temp (victim_id, incident_id, victim_seq_num, victim_type_id, assignment_type_id, activity_type_id, outside_agency_id, age_id, age_num, sex_code, race_id, ethnicity_id, resident_status_code, agency_data_year, ff_line_number, age_range_low_num, age_range_high_num) FROM '$MYPWD/NIBRS_V.csv' WITH DELIMITER ',';

CREATE TABLE nibrs_victim_new (
    victim_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    victim_seq_num smallint,
    victim_type_id smallint NOT NULL,
    assignment_type_id smallint,
    activity_type_id smallint,
    outside_agency_id bigint,
    age_id smallint,
    age_num smallint,
    sex_code character(1),
    race_id smallint,
    ethnicity_id smallint,
    resident_status_code character(1),
    agency_data_year smallint,
    ff_line_number bigint,
    age_range_low_num smallint,
    age_range_high_num smallint
);

-- nibrs_victim_circumstances
DROP TABLE IF EXISTS nibrs_victim_circumstances_temp;
CREATE TABLE nibrs_victim_circumstances_temp (
    victim_id text,
    circumstances_id text,
    justifiable_force_id text
);

\COPY nibrs_victim_circumstances_temp (victim_id, circumstances_id, justifiable_force_id) FROM '$MYPWD/NIBRS_VC.csv' WITH DELIMITER ',';


-- nibrs_victim_injury
DROP TABLE IF EXISTS nibrs_victim_injury_temp;
CREATE TABLE nibrs_victim_injury_temp (
    victim_id text,
    injury_id text
);

\COPY nibrs_victim_injury_temp (victim_id, injury_id) FROM '$MYPWD/NIBRS_VI.csv' WITH DELIMITER ',';


-- nibrs_victim_offense
DROP TABLE IF EXISTS nibrs_victim_offense_temp;
CREATE TABLE nibrs_victim_offense_temp (
    victim_id text,
    offense_id text
);

\COPY nibrs_victim_offense_temp (victim_id, offense_id) FROM '$MYPWD/NIBRS_VO.csv' WITH DELIMITER ',';

-- nibrs_victim_offender_rel
DROP TABLE IF EXISTS nibrs_victim_offender_rel_temp;
CREATE TABLE nibrs_victim_offender_rel_temp (
    victim_id text,
    offender_id text,
    relationship_id text,
    nibrs_victim_offender_id text
);

\COPY nibrs_victim_offender_rel_temp (victim_id, offender_id, relationship_id, nibrs_victim_offender_id) FROM '$MYPWD/NIBRS_VOR.csv' WITH DELIMITER ',';

-- nibrs_weapon
DROP TABLE IF EXISTS nibrs_weapon_temp;
CREATE TABLE nibrs_weapon_temp (
    weapon_id text,
    offense_id text,
    nibrs_weapon_id text
);

\COPY nibrs_weapon_temp (weapon_id, offense_id, nibrs_weapon_id) FROM '$MYPWD/NIBRS_W.csv' WITH DELIMITER ',';
"