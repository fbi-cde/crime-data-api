MYPWD="$(pwd)/data"
YEAR=$1

echo """
--------------------------
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
    incident_number text,
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
"""