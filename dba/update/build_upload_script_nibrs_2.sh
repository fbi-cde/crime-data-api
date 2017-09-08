MYPWD="$(pwd)/data"
YEAR=$1

echo "

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