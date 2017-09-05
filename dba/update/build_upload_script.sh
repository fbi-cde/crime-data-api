
MYPWD=$2
YEAR=$1


echo "-- Process.
-- (1) Build temp table statements.
-- (2) Merge or replace tables.
-- (3) Re-add all indexes (for replaced tables only).


--------------------------
-- Start data upload
--------------------------

\set ON_ERROR_STOP on;

----------------------
---
---
--- MERGE NEW REF DATA WITH EXISTING REF DATA.
--- 
---
----------------------

-- create shell table that contains CSV data.
DROP TABLE IF EXISTS ref_agency_temp;
CREATE TABLE ref_agency_temp (
    agency_id text,
    ori text,
    legacy_ori text,
    ucr_agency_name text,
    ncic_agency_name text,
    pub_agency_name text,
    agency_type_id text,
    special_mailing_group text,
    special_mailing_address text,
    tribe_id text,
    city_id text,
    state_id text,
    campus_id text,
    agency_status text,
    judicial_dist_code text,
    submitting_agency_id text,
    fid_code text,
    department_id text,
    added_date text,
    change_timestamp text,
    change_user text,
    legacy_notify_agency text,
    dormant_year text,
    population_family_id text,
    field_office_id text,
    extra text
);

-- Load CSV data into shell.
\COPY ref_agency_temp (agency_id, ori, legacy_ori, ucr_agency_name, ncic_agency_name, pub_agency_name, agency_type_id, special_mailing_group, special_mailing_address, tribe_id, city_id, state_id, campus_id, agency_status, judicial_dist_code, submitting_agency_id, fid_code, department_id, added_date, change_timestamp, change_user, legacy_notify_agency, dormant_year, population_family_id, field_office_id, extra) FROM '$MYPWD/REF_A.csv' WITH DELIMITER '|';

-- Load/convert data from shell into 
DROP TABLE IF EXISTS ref_agency_replace;
CREATE TABLE ref_agency_replace (
    agency_id bigint NOT NULL,
    ori character(9) NOT NULL,
    legacy_ori character(9) NOT NULL,
    ucr_agency_name character varying(100),
    ncic_agency_name character varying(100),
    pub_agency_name character varying(100),
    agency_type_id smallint NOT NULL,
    special_mailing_group character(1),
    special_mailing_address character(1),
    tribe_id bigint,
    city_id bigint,
    state_id smallint NOT NULL,
    campus_id bigint,
    agency_status character(1) NOT NULL,
    judicial_dist_code character varying(4),
    submitting_agency_id bigint,
    fid_code character(2),
    department_id smallint,
    added_date timestamp without time zone,
    change_timestamp timestamp without time zone,
    change_user character varying(100),
    legacy_notify_agency character(1),
    dormant_year smallint,
    population_family_id smallint DEFAULT 0 NOT NULL,
    field_office_id bigint
);

-- Insert into replacement table.
INSERT INTO ref_agency_replace (SELECT convert_to_integer(agency_id), ori, legacy_ori, ucr_agency_name, ncic_agency_name, pub_agency_name, convert_to_integer(agency_type_id), special_mailing_group, special_mailing_address, convert_to_integer(tribe_id), convert_to_integer(city_id), convert_to_integer(state_id), convert_to_integer(campus_id), agency_status, judicial_dist_code, convert_to_integer(submitting_agency_id), fid_code, convert_to_integer(department_id), to_timestamp_ucr(added_date), to_timestamp_ucr1(change_timestamp), change_user, legacy_notify_agency, convert_to_integer(dormant_year), convert_to_integer(population_family_id), convert_to_integer(field_office_id) from ref_agency_temp);
INSERT INTO ref_agency SELECT * from ref_agency_replace where not exists (select * from ref_agency where ref_agency.agency_id = ref_agency_replace.agency_id);

-- Create temp shell.
DROP TABLE IF EXISTS ref_agency_county_temp;
CREATE TABLE ref_agency_county_temp (
    agency_id text,
    county_id text,
    metro_div_id text,
    core_city_flag text,
    data_year text,
    population text,
    census text,
    legacy_county_code text,
    legacy_msa_code text,
    source_flag text,
    change_timestamp text,
    change_user text
);

-- insert into shell from csv.
\COPY ref_agency_county_temp (agency_id,county_id, metro_div_id, core_city_flag, data_year, population, census, legacy_county_code, legacy_msa_code, source_flag, change_timestamp, change_user) FROM '$MYPWD/REF_AC.csv' WITH DELIMITER '|';

-- replacement table.
DROP TABLE IF EXISTS ref_agency_county_replace;
CREATE TABLE ref_agency_county_replace (
    agency_id bigint NOT NULL,
    county_id bigint NOT NULL,
    metro_div_id bigint NOT NULL,
    core_city_flag character(1),
    data_year smallint NOT NULL,
    population bigint,
    census bigint,
    legacy_county_code character varying(20),
    legacy_msa_code character varying(20),
    source_flag character(1),
    change_timestamp timestamp without time zone,
    change_user character varying(100)
);

-- insert into replacement.
INSERT INTO ref_agency_county_replace (SELECT convert_to_integer(agency_id), convert_to_integer(county_id), convert_to_integer(metro_div_id), core_city_flag, convert_to_integer(data_year), convert_to_integer(population), convert_to_integer(census), legacy_county_code, legacy_msa_code, source_flag, to_timestamp_ucr1(change_timestamp), change_user from ref_agency_county_temp); 

INSERT INTO ref_agency_county SELECT * from ref_agency_county_replace where not exists (select * from ref_agency_county where ref_agency_county.agency_id = ref_agency_county_replace.agency_id and ref_agency_county_replace.county_id = ref_agency_county.county_id);

-- Shell for ref_agency_covered_by.
DROP TABLE IF EXISTS ref_agency_covered_by_temp;
CREATE TABLE ref_agency_covered_by_temp (
    agency_id text,
    data_year text,
    covered_by_agency_id text
);

-- insert into shell from csv.
\COPY ref_agency_covered_by_temp (agency_id,data_year, covered_by_agency_id) FROM '$MYPWD/REF_ACB.csv' WITH DELIMITER '|';

DROP TABLE IF EXISTS ref_agency_covered_by_replace;
CREATE TABLE ref_agency_covered_by_replace (
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    covered_by_agency_id bigint NOT NULL
);

INSERT INTO ref_agency_covered_by_replace (SELECT convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(covered_by_agency_id) FROM ref_agency_covered_by_temp);
INSERT INTO ref_agency_covered_by SELECT * from ref_agency_covered_by_replace where not exists (select * from ref_agency_covered_by where ref_agency_covered_by.agency_id = ref_agency_covered_by_replace.agency_id and ref_agency_covered_by_replace.data_year = ref_agency_covered_by.data_year);

-- ref_county
DROP TABLE IF EXISTS ref_county_temp;
CREATE TABLE ref_county_temp (
    county_id text,
    state_id text,
    county_name text,
    county_ansi_code text,
    county_fips_code text,
    legacy_county_code text,
    comments text
);

\COPY ref_county_temp (county_id, state_id, county_name, county_ansi_code, county_fips_code, legacy_county_code, comments) FROM '$MYPWD/REF_C.csv' WITH DELIMITER '|';

DROP TABLE IF EXISTS ref_county_replace;
CREATE TABLE ref_county_replace (
    county_id bigint NOT NULL,
    state_id smallint NOT NULL,
    county_name character varying(100),
    county_ansi_code character varying(5),
    county_fips_code character varying(5),
    legacy_county_code character varying(5),
    comments character varying(1000)
);

INSERT INTO ref_county_replace (SELECT convert_to_integer(county_id), convert_to_integer(state_id), county_name, county_ansi_code, county_fips_code, legacy_county_code, comments from ref_county_temp);
INSERT INTO ref_county SELECT * from ref_county_replace where not exists (select * from ref_county where ref_county_replace.county_id = ref_county.county_id);

-- ref_country
DROP TABLE IF EXISTS ref_country_temp;
CREATE TABLE ref_country_temp (
    country_id text,
    continent_id text,
    country_desc text
);

\COPY ref_country_temp (country_id, continent_id, country_desc) FROM '$MYPWD/REF_CY.csv' WITH DELIMITER '|';

DROP TABLE IF EXISTS ref_country_replace;
CREATE TABLE ref_country_replace (
    country_id smallint NOT NULL,
    continent_id smallint NOT NULL,
    country_desc character varying(50)
);

INSERT INTO ref_country_replace (SELECT convert_to_integer(country_id), convert_to_integer(continent_id), country_desc from ref_country_temp);
INSERT INTO ref_country SELECT * from ref_country_replace where not exists (select * from ref_country where ref_country_replace.country_id = ref_country.country_id);

-- ref_county_population

DROP TABLE IF EXISTS ref_county_population_temp;
CREATE TABLE ref_county_population_temp (
    county_id text,
    data_year text,
    population text,
    source_flag text,
    extra text,
    change_timestamp text,
    change_user text,
    reporting_population text
);

\COPY ref_county_population_temp (county_id, data_year, population, source_flag, extra, change_timestamp, change_user, reporting_population) FROM '$MYPWD/REF_CP.csv' WITH DELIMITER '|';

DROP TABLE IF EXISTS ref_county_population_replace;
CREATE TABLE ref_county_population_replace (
    county_id bigint NOT NULL,
    data_year smallint NOT NULL,
    population bigint,
    source_flag character(1) NOT NULL,
    change_timestamp timestamp without time zone,
    change_user character varying(100),
    reporting_population bigint
);

INSERT INTO ref_county_population_replace (SELECT convert_to_integer(county_id), convert_to_integer(data_year), convert_to_integer(population), source_flag, to_timestamp_ucr1(change_timestamp), change_user, convert_to_integer(reporting_population) FROM ref_county_population_temp);
INSERT INTO ref_county_population SELECT * from ref_county_population_replace where not exists (select * from ref_county_population where ref_county_population_replace.county_id = ref_county_population.county_id and ref_county_population_replace.data_year = ref_county_population.data_year);



-- ref_agency_population
DROP TABLE IF EXISTS ref_agency_population_temp;
CREATE TABLE ref_agency_population_temp (
    agency_id text,
    data_year text,
    population_group_id text,
    population text,
    source_flag text,
    change_timestamp text,
    change_user text,
    city_sequence text,
    suburban_area_flag text
);

\COPY ref_agency_population_temp (agency_id, data_year, population_group_id, population, source_flag, change_timestamp, change_user, city_sequence, suburban_area_flag) FROM '$MYPWD/REF_AP.csv' WITH DELIMITER '|';


DROP TABLE IF EXISTS ref_agency_population_replace;
CREATE TABLE ref_agency_population_replace (
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    population_group_id bigint NOT NULL,
    population bigint,
    source_flag character(1) NOT NULL,
    change_timestamp timestamp without time zone,
    change_user character varying(100),
    city_sequence bigint,
    suburban_area_flag character(1)
);

INSERT INTO ref_agency_population_replace (SELECT convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(population_group_id), convert_to_integer(population), source_flag, to_timestamp_ucr1(change_timestamp), change_user, convert_to_integer(city_sequence), suburban_area_flag FROM ref_agency_population_temp);
INSERT INTO ref_agency_population SELECT * from ref_agency_population_replace where not exists (select * from ref_agency_population where ref_agency_population_replace.agency_id = ref_agency_population.agency_id and ref_agency_population_replace.data_year = ref_agency_population.data_year);

-- ref_tribe_population
DROP TABLE IF EXISTS ref_tribe_population_temp;
CREATE TABLE ref_tribe_population_temp (
    tribe_id text,
    data_year text,
    population text,
    source_flag text,
    census text,
    change_timestamp text,
    change_user text,
    reporting_population text
);

\COPY ref_tribe_population_temp (tribe_id, data_year, population, source_flag, census, change_timestamp, change_user, reporting_population) FROM '$MYPWD/REF_TP.csv' WITH DELIMITER '|';

DROP TABLE IF EXISTS ref_tribe_population_replace;
CREATE TABLE ref_tribe_population_replace (
    tribe_id bigint NOT NULL,
    data_year smallint NOT NULL,
    population bigint,
    source_flag character(1) NOT NULL,
    census bigint,
    change_timestamp timestamp without time zone,
    change_user character varying(100),
    reporting_population bigint
);

INSERT INTO ref_tribe_population_replace (SELECT convert_to_integer(tribe_id), convert_to_integer(data_year), convert_to_integer(population), source_flag, convert_to_integer(census), to_timestamp_ucr1(change_timestamp), change_user, convert_to_integer(reporting_population) FROM ref_tribe_population_temp);
INSERT INTO ref_tribe_population SELECT * from ref_tribe_population_replace where not exists (select * from ref_tribe_population where ref_tribe_population_replace.tribe_id = ref_tribe_population.tribe_id and ref_tribe_population_replace.data_year = ref_tribe_population.data_year);


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


-----------------------------
-- 
-- 
-- UPLOAD RETA tables.
-- 
-- 
-----------------------------

-- reta_month_temp
DROP TABLE IF EXISTS reta_month_temp;
CREATE TABLE reta_month_temp (
    reta_month_id text,
    agency_id text,
    data_year text,
    month_num text,
    data_home text,
    source_flag text,
    reported_flag text,
    ddocname text,
    month_included_in text,
    report_date text,
    prepared_date text,
    prepared_by_user text,
    prepared_by_email text,
    orig_format text,
    leoka_felony text,
    leoka_accident text,
    leoka_assault text,
    leoka_status text,
    update_flag text,
    did text,
    ff_line_number text,
    extra text
);

--RETA_MONTH_ID   AGENCY_ID   DATA_YEAR   MONTH_NUM   DATA_HOME   SOURCE_FLAG REPORTED_FLAG   DDOCNAME    MONTH_INCLUDED_IN   REPORT_DATE PREPARED_DATE   PREPARED_BY_USER    PREPARED_BY_EMAIL   ORIG_FORMAT LEOKA_FELONY    LEOKA_ACCIDENT  LEOKA_ASSAULT   LEOKA_STATUS    UPDATE_FLAG DID FF_LINE_NUMBER  MONTH_PUB_STATUS
\COPY reta_month_temp (reta_month_id, agency_id, data_year, month_num, data_home, source_flag, reported_flag, ddocname, month_included_in, report_date, prepared_date, prepared_by_user, prepared_by_email, orig_format, leoka_felony, leoka_accident, leoka_assault, leoka_status, update_flag, did, ff_line_number, extra) FROM '$MYPWD/RetAM.csv' WITH DELIMITER ',';

-- reta_month_offense_subcat
DROP TABLE IF EXISTS reta_month_offense_subcat_temp;
CREATE TABLE reta_month_offense_subcat_temp (
    reta_month_id text,
    offense_subcat_id text,
    reported_count text,
    reported_status text,
    unfounded_count text,
    unfounded_status text,
    actual_count text,
    actual_status text,
    cleared_count text,
    cleared_status text,
    juvenile_cleared_count text,
    juvenile_cleared_status text
);

-- RETA_MONTH_ID   OFFENSE_SUBCAT_ID   REPORTED_COUNT  REPORTED_STATUS UNFOUNDED_COUNT UNFOUNDED_STATUS    ACTUAL_COUNT    ACTUAL_STATUS   CLEARED_COUNT   CLEARED_STATUS  JUVENILE_CLEARED_COUNT  JUVENILE_CLEARED_STATUS
\COPY reta_month_offense_subcat_temp (reta_month_id, offense_subcat_id, reported_count, reported_status, unfounded_count, unfounded_status, actual_count, actual_status, cleared_count, cleared_status, juvenile_cleared_count, juvenile_cleared_status) FROM '$MYPWD/RetAMOS.csv' WITH DELIMITER ',';

-----------------------------
-- 
-- 
-- ASR tables upload.
-- 
-- 
-----------------------------

-- asr_month
DROP TABLE IF EXISTS asr_month_temp;
CREATE TABLE asr_month_temp (
    asr_month_id text,
    agency_id text,
    data_year text,
    month_num text,
    source_flag text,
    reported_flag text,
    orig_format text,
    update_flag text,
    ff_line_number text,
    ddocname text,
    did text,
    data_home text,
    extra text
);

\COPY asr_month_temp (asr_month_id, agency_id, data_year, month_num, source_flag, reported_flag, orig_format, update_flag, ff_line_number, ddocname, did, data_home, extra) FROM '$MYPWD/ASRM.csv' WITH DELIMITER ',';



-- asr_offense_subcat
DROP TABLE IF EXISTS asr_race_offense_subcat_temp;
CREATE TABLE asr_race_offense_subcat_temp (
    asr_month_id text,
    offense_subcat_id text,
    race_id text,
    juvenile_flag text,
    arrest_count text,
    arrest_status text,
    active_flag text,
    prepared_date text,
    report_date text,
    ff_line_number text,
    asr_month_id_1 text,
    agency_id text,
    data_year text,
    month_num text,
    source_flag text,
    reported_flag text,
    orig_format text,
    update_flag text,
    ff_line_number_1 text,
    ddocname text,
    did text,
    data_home text,
    month_pub_status text
);


\COPY asr_race_offense_subcat_temp (asr_month_id , offense_subcat_id ,    race_id ,    juvenile_flag ,    arrest_count ,    arrest_status ,    active_flag ,    prepared_date ,    report_date ,    ff_line_number ,    asr_month_id_1,    agency_id,    data_year,    month_num,    source_flag,    reported_flag,    orig_format,    update_flag,    ff_line_number_1,    ddocname,    did,    data_home,    month_pub_status) FROM '$MYPWD/ASROS.csv' WITH DELIMITER ',';


-- ASRS.csv?????
-- ASR_AGE_SEX_SUBCAT
DROP TABLE IF EXISTS asr_age_sex_subcat_temp;
CREATE TABLE asr_age_sex_subcat_temp (
    asr_month_id text,
    offense_subcat_id text,
    age_range_id text,
    arrest_count text,
    arrest_status text,
    active_flag text,
    prepared_date text,
    report_date text,
    ff_line_number text,
    asr_month_id_1 text,
    agency_id text,
    data_year text,
    month_num text,
    source_flag text,
    reported_flag text,
    orig_format text,
    update_flag text,
    ff_line_number_1 text,
    ddocname text,
    did text,
    data_home text,
    month_pub_status text
);


\COPY asr_age_sex_subcat_temp (asr_month_id ,    offense_subcat_id ,    age_range_id ,    arrest_count ,    arrest_status ,    active_flag ,    prepared_date ,    report_date ,    ff_line_number ,    asr_month_id_1,    agency_id,    data_year,    month_num,    source_flag,    reported_flag,    orig_format,    update_flag,    ff_line_number_1,    ddocname,    did,    data_home,    month_pub_status) FROM '$MYPWD/ASRS.csv' WITH DELIMITER ',';




-----------------------------
-- 
-- 
-- Hate Crime tables upload.
-- 
-- 
-----------------------------

-- hc_incident
DROP TABLE IF EXISTS hc_incident_temp;
CREATE TABLE hc_incident_temp (
    incident_id text,
    agency_id text,
    incident_no text,
    incident_date text,
    data_home text,
    source_flag text,
    ddocname text,
    report_date text,
    prepared_date text,
    victim_count text,
    adult_victim_count text,
    incident_status text,
    juvenile_victim_count text,
    offender_count text,
    adult_offender_count text,
    juvenile_offender_count text,
    offender_race_id text,
    offender_ethnicity_id text,
    update_flag text,
    hc_quarter_id text,
    ff_line_number text,
    orig_format text,
    did text,
    nibrs_incident_id text
);

\COPY hc_incident_temp (incident_id, agency_id, incident_no, incident_date, data_home, source_flag, ddocname, report_date, prepared_date, victim_count, adult_victim_count, incident_status, juvenile_victim_count, offender_count, adult_offender_count, juvenile_offender_count, offender_race_id, offender_ethnicity_id, update_flag, hc_quarter_id, ff_line_number, orig_format, did, nibrs_incident_id) FROM '$MYPWD/Hate_I.csv' WITH DELIMITER ',';

-- hc_quarter
DROP TABLE IF EXISTS hc_quarter_temp;
CREATE TABLE hc_quarter_temp (
    agency_id text,
    quarter_num text,
    data_year text,
    reported_status text,
    reported_count text,
    hc_quarter_id text,
    update_flag text,
    orig_format text,
    ff_line_number text,
    ddocname text,
    did text,
    data_home text,
    quarter_pub_status text
);


\COPY hc_quarter_temp (agency_id, quarter_num, data_year, reported_status, reported_count, hc_quarter_id, update_flag, orig_format, ff_line_number, ddocname, did, data_home, quarter_pub_status) FROM '$MYPWD/Hate_Q.csv' WITH DELIMITER ',';


-- hc_bias_motivation
DROP TABLE IF EXISTS hc_bias_motivation_temp;
CREATE TABLE hc_bias_motivation_temp (
    offense_id text,
    bias_id text
);

\COPY hc_bias_motivation_temp (offense_id, bias_id) FROM '$MYPWD/Hate_BM.csv' WITH DELIMITER ',';

-- hc_offense
DROP TABLE IF EXISTS hc_offense_temp;
CREATE TABLE hc_offense_temp (
    offense_id text,
    incident_id text,
    offense_type_id text,
    victim_count text,
    location_id text,
    nibrs_offense_id text
);

\COPY hc_offense_temp (offense_id, incident_id, offense_type_id, victim_count, location_id, nibrs_offense_id) FROM '$MYPWD/Hate_O.csv' WITH DELIMITER ',';

-- hc_victim
DROP TABLE IF EXISTS hc_victim_temp;
CREATE TABLE hc_victim_temp (
    offense_id text,
    victim_type_id text
);

\COPY hc_victim_temp (offense_id, victim_type_id) FROM '$MYPWD/Hate_V.csv' WITH DELIMITER ',';


-----------------------------
-- 
-- 
-- Cargo Theft tables upload.
-- 
-- 
-----------------------------

-- ct_incident
DROP TABLE IF EXISTS ct_incident_temp;
CREATE TABLE ct_incident_temp (
    incident_id text,
    agency_id text,
    data_year text,
    incident_number text,
    incident_date text,
    source_flag text,
    ddocname text,
    report_date text,
    prepared_date text,
    report_date_flag text,
    incident_hour text,
    cleared_except_flag text,
    update_flag text,
    ct_month_id text,
    ff_line_number text,
    data_home text,
    orig_format text,
    unknown_offender text,
    did text,
    nibrs_incident_id text
);

\COPY ct_incident_temp (incident_id, agency_id, data_year, incident_number, incident_date, source_flag, ddocname, report_date, prepared_date, report_date_flag, incident_hour, cleared_except_flag, update_flag, ct_month_id, ff_line_number, data_home, orig_format, unknown_offender, did, nibrs_incident_id) FROM '$MYPWD/Cargo_I.csv' WITH DELIMITER ',';

-- ct_victim
DROP TABLE IF EXISTS ct_victim_temp;
CREATE TABLE ct_victim_temp (
    incident_id text,
    victim_type_id text
);

\COPY ct_victim_temp (incident_id, victim_type_id) FROM '$MYPWD/Cargo_V.csv' WITH DELIMITER ',';


-- ct_offense
DROP TABLE IF EXISTS ct_offense_temp;
CREATE TABLE ct_offense_temp (
    offense_id text,
    incident_id text,
    offense_type_id text,
    location_id text,
    ct_offense_flag text
);

\COPY ct_offense_temp (offense_id, incident_id, offense_type_id, location_id, ct_offense_flag) FROM '$MYPWD/Cargo_OO.csv' WITH DELIMITER ',';


-- ct_offender
DROP TABLE IF EXISTS ct_offender_temp;
CREATE TABLE ct_offender_temp (
    offender_id text,
    incident_id text,
    age text,
    sex_code text,
    ethnicity_id text,
    race_id text
);

\COPY ct_offender_temp (offender_id, incident_id, age, sex_code, ethnicity_id, race_id) FROM '$MYPWD/Cargo_O.csv' WITH DELIMITER ',';

-- ct_arrestee_temp
DROP TABLE IF EXISTS ct_arrestee_temp;
CREATE TABLE ct_arrestee_temp (
    arrestee_id text,
    incident_id text,
    age text,
    sex_code text,
    ethnicity_id text,
    race_id text
);

\COPY ct_arrestee_temp (arrestee_id, incident_id, age, sex_code, ethnicity_id, race_id) FROM '$MYPWD/Cargo_A.csv' WITH DELIMITER ',';

-- ct_weapon
DROP TABLE IF EXISTS ct_weapon_temp;
CREATE TABLE ct_weapon_temp (
    incident_id text,
    weapon_id text,
    ct_weapon_id text
);

\COPY ct_weapon_temp (incident_id, weapon_id, ct_weapon_id) FROM '$MYPWD/Cargo_W.csv' WITH DELIMITER ',';

-- ct_property
DROP TABLE IF EXISTS ct_property_temp;
CREATE TABLE ct_property_temp (
    property_id text,
    prop_desc_id text,
    incident_id text,
    stolen_value text,
    recovered_flag text,
    date_recovered text,
    recovered_value text
);

\COPY ct_property_temp (property_id, prop_desc_id, incident_id, stolen_value, recovered_flag, date_recovered, recovered_value) FROM '$MYPWD/Cargo_P.csv' WITH DELIMITER ',';




-----------------------------
-- 
-- 
-- Arson tables upload.
-- 
-- 
-----------------------------

-- arson_month
DROP TABLE IF EXISTS arson_month_temp;
CREATE TABLE arson_month_temp (
    arson_month_id text,
    agency_id text,
    data_year text,
    month_num text,
    data_home text,
    source_flag text,
    reported_flag text,
    ddocname text,
    month_included_in text,
    report_date text,
    prepared_date text,
    orig_format text,
    update_flag text,
    did text,
    ff_line_number text,
    extra text
);

\COPY arson_month_temp (arson_month_id, agency_id, data_year, month_num, data_home, source_flag, reported_flag, ddocname, month_included_in, report_date, prepared_date, orig_format, update_flag, did, ff_line_number, extra) FROM '$MYPWD/ArsonM.csv' WITH DELIMITER ',';


-- arson_month_by_subcat
DROP TABLE IF EXISTS arson_month_by_subcat_temp;
CREATE TABLE arson_month_by_subcat_temp (
    arson_month_id text,
    subcategory_id text,
    reported_count text,
    reported_status text,
    unfounded_count text,
    unfounded_status text,
    actual_count text,
    actual_status text,
    cleared_count text,
    cleared_status text,
    juvenile_cleared_count text,
    juvenile_cleared_status text,
    uninhabited_count text,
    uninhabited_status text,
    est_damage_value text,
    est_damage_value_status text
);

\COPY arson_month_by_subcat_temp (arson_month_id, subcategory_id, reported_count, reported_status, unfounded_count, unfounded_status, actual_count, actual_status, cleared_count, cleared_status, juvenile_cleared_count, juvenile_cleared_status, uninhabited_count, uninhabited_status, est_damage_value, est_damage_value_status) FROM '$MYPWD/ArsonMOS.csv' WITH DELIMITER ',';


-----------------------------
--
--
-- DATA MERGE BLOCK - Merges the new data with existing tables.
--
--
------------------------------

INSERT INTO ref_agency_old SELECT * from ref_agency where not exists (select * from ref_agency_old where ref_agency_old.agency_id = ref_agency.agency_id);




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

--
-- Not ready (drop FK's)

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
"
