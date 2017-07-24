-- Process.
-- (1) Build temp table statements.
-- (2) Merge or replace tables.
-- (3) Re-add all indexes (for replaced tables only).

-----------------------
-- Helper functions
-----------------------

CREATE OR REPLACE FUNCTION convert_to_integer(v_input text)
RETURNS INTEGER AS $$
DECLARE v_int_value INTEGER DEFAULT NULL;
BEGIN
    BEGIN
        IF (v_input = '') IS NOT FALSE THEN
            v_int_value := NULL;
        ELSE
            v_int_value := v_input::BIGINT;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Invalid integer value: "%".  Returning NULL.', v_input;
        RETURN NULL;
    END;
RETURN v_int_value;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION to_timestamp_ucr1(v_input text)
RETURNS timestamp without time zone AS $$
DECLARE v_int_value timestamp without time zone DEFAULT NULL;
BEGIN
    BEGIN
        IF (v_input = '') IS NOT FALSE THEN
            v_int_value := NULL;
        ELSE
            v_int_value := to_timestamp(v_input,'DD-Mon-YYHH24:MI:SS');
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Invalid integer value: "%".  Returning NULL.', v_input;
        RETURN NULL;
    END;
RETURN v_int_value;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION to_timestamp_ucr(v_input text)
RETURNS timestamp without time zone AS $$
DECLARE v_int_value timestamp without time zone DEFAULT NULL;
BEGIN
    BEGIN
        IF (v_input = '') IS NOT FALSE THEN
            v_int_value := NULL;
        ELSE
            v_int_value := v_input::timestamp without time zone;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Invalid integer value: "%".  Returning NULL.', v_input;
        RETURN NULL;
    END;
RETURN v_int_value;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION convert_to_double(v_input text)
RETURNS double precision AS $$
DECLARE v_d_value double precision DEFAULT NULL;
BEGIN
    BEGIN
        IF (v_input = '') IS NOT FALSE THEN
            v_d_value := 0.0;
        ELSE
            v_d_value := v_input::double precision;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Invalid double value: "%".  Returning NULL.', v_input;
        RETURN NULL;
    END;
RETURN v_d_value;
END;
$$ LANGUAGE plpgsql;


--------------------------
-- Start data upload
--------------------------


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
\COPY ref_agency_temp (agency_id, ori, legacy_ori, ucr_agency_name, ncic_agency_name, pub_agency_name, agency_type_id, special_mailing_group, special_mailing_address, tribe_id, city_id, state_id, campus_id, agency_status, judicial_dist_code, submitting_agency_id, fid_code, department_id, added_date, change_timestamp, change_user, legacy_notify_agency, dormant_year, population_family_id, field_office_id, extra) FROM 'REF_A.csv' WITH DELIMITER '|';

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
\COPY ref_agency_county_temp (agency_id,county_id, metro_div_id, core_city_flag, data_year, population, census, legacy_county_code, legacy_msa_code, source_flag, change_timestamp, change_user) FROM 'REF_AC.csv' WITH DELIMITER '|';

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
\COPY ref_agency_covered_by_temp (agency_id,data_year, covered_by_agency_id) FROM 'REF_ACB.csv' WITH DELIMITER '|';

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

\COPY ref_county_temp (county_id, state_id, county_name, county_ansi_code, county_fips_code, legacy_county_code, comments) FROM 'REF_C.csv' WITH DELIMITER '|';

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

\COPY ref_country_temp (country_id, continent_id, country_desc) FROM 'REF_CY.csv' WITH DELIMITER '|';

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

\COPY ref_county_population_temp (county_id, data_year, population, source_flag, extra, change_timestamp, change_user, reporting_population) FROM 'REF_CP.csv' WITH DELIMITER '|';

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

\COPY ref_agency_population_temp (agency_id, data_year, population_group_id, population, source_flag, change_timestamp, change_user, city_sequence, suburban_area_flag) FROM 'REF_AP.csv' WITH DELIMITER '|';


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

\COPY ref_tribe_population_temp (tribe_id, data_year, population, source_flag, census, change_timestamp, change_user, reporting_population) FROM 'REF_TP.csv' WITH DELIMITER '|';

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

\COPY nibrs_incident_temp (agency_id, incident_id, nibrs_month_id, incident_number, cargo_theft_flag, submission_date, incident_date, report_date_flag, incident_hour, cleared_except_id, cleared_except_date, incident_status, data_home, ddocname, orig_format, ff_line_number, did) FROM 'NIBRS_I.csv' WITH DELIMITER ',';


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

\COPY nibrs_month_temp (nibrs_month_id, agency_id, month_num, data_year, reported_status, report_date, prepared_date, update_flag, orig_format, ff_line_number, data_home, ddocname, did) FROM 'NIBRS_M.csv' WITH DELIMITER ',';


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

\COPY nibrs_arrestee_temp (arrestee_id, incident_id, arrestee_seq_num, arrest_num, arrest_date, arrest_type_id, multiple_indicator, offense_type_id, age_id, age_num, sex_code, race_id, ethnicity_id, resident_code, under_18_disposition_code, clearance_ind, ff_line_number, age_range_low_num, age_range_high_num) FROM 'NIBRS_A.csv' WITH DELIMITER ',';

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

\COPY nibrs_arrestee_weapon_temp (arrestee_id, weapon_id, nibrs_arrestee_weapon_id) FROM 'NIBRS_AW.csv' WITH DELIMITER ',';

-- nibrs_bias_motivation
DROP TABLE IF EXISTS nibrs_bias_motivation_temp;
CREATE TABLE nibrs_bias_motivation_temp (
    bias_id text,
    offense_id text
);

\COPY nibrs_bias_motivation_temp (bias_id, offense_id) FROM 'NIBRS_BM.csv' WITH DELIMITER ',';


-- nibrs_criminal_act
DROP TABLE IF EXISTS nibrs_criminal_act_temp;
CREATE TABLE nibrs_criminal_act_temp (
    criminal_act_id text,
    offense_id text
);

\COPY nibrs_criminal_act_temp (criminal_act_id, offense_id) FROM 'NIBRS_CA.csv' WITH DELIMITER ',';

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

\COPY nibrs_offense_temp (offense_id, incident_id, offense_type_id, attempt_complete_flag, location_id, num_premises_entered, method_entry_code, ff_line_number) FROM 'NIBRS_OFF.csv' WITH DELIMITER ',';

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

\COPY nibrs_offender_temp (offender_id, incident_id, offender_seq_num, age_id, age_num, sex_code, race_id, ethnicity_id, ff_line_number, age_range_low_num, age_range_high_num) FROM 'NIBRS_OF.csv' WITH DELIMITER ',';


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

\COPY nibrs_property_temp (property_id, incident_id, prop_loss_id, stolen_count, recovered_count, ff_line_number) FROM 'NIBRS_P.csv' WITH DELIMITER ',';


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

\COPY nibrs_property_desc_temp (property_id, prop_desc_id, property_value, date_recovered, nibrs_prop_desc_id) FROM 'NIBRS_PD.csv' WITH DELIMITER ',';

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

\COPY nibrs_suspected_drug_temp (suspected_drug_type_id, property_id, est_drug_qty, drug_measure_type_id, nibrs_suspected_drug_id) FROM 'NIBRS_SD.csv' WITH DELIMITER ',';


-- nibrs_suspect_using
DROP TABLE IF EXISTS nibrs_suspect_using_temp;
CREATE TABLE nibrs_suspect_using_temp (
    suspect_using_id text,
    offense_id text
);

\COPY nibrs_suspect_using_temp (suspect_using_id, offense_id) FROM 'NIBRS_SU.csv' WITH DELIMITER ',';

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

\COPY nibrs_victim_temp (victim_id, incident_id, victim_seq_num, victim_type_id, assignment_type_id, activity_type_id, outside_agency_id, age_id, age_num, sex_code, race_id, ethnicity_id, resident_status_code, agency_data_year, ff_line_number, age_range_low_num, age_range_high_num) FROM 'NIBRS_V.csv' WITH DELIMITER ',';

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

\COPY nibrs_victim_circumstances_temp (victim_id, circumstances_id, justifiable_force_id) FROM 'NIBRS_VC.csv' WITH DELIMITER ',';


-- nibrs_victim_injury
DROP TABLE IF EXISTS nibrs_victim_injury_temp;
CREATE TABLE nibrs_victim_injury_temp (
    victim_id text,
    injury_id text
);

\COPY nibrs_victim_injury_temp (victim_id, injury_id) FROM 'NIBRS_VI.csv' WITH DELIMITER ',';


-- nibrs_victim_offense
DROP TABLE IF EXISTS nibrs_victim_offense_temp;
CREATE TABLE nibrs_victim_offense_temp (
    victim_id text,
    offense_id text
);

\COPY nibrs_victim_offense_temp (victim_id, offense_id) FROM 'NIBRS_VO.csv' WITH DELIMITER ',';

-- nibrs_victim_offender_rel
DROP TABLE IF EXISTS nibrs_victim_offender_rel_temp;
CREATE TABLE nibrs_victim_offender_rel_temp (
    victim_id text,
    offender_id text,
    relationship_id text,
    nibrs_victim_offender_id text
);

\COPY nibrs_victim_offender_rel_temp (victim_id, offender_id, relationship_id, nibrs_victim_offender_id) FROM 'NIBRS_VOR.csv' WITH DELIMITER ',';

-- nibrs_weapon
DROP TABLE IF EXISTS nibrs_weapon_temp;
CREATE TABLE nibrs_weapon_temp (
    weapon_id text,
    offense_id text,
    nibrs_weapon_id text
);

\COPY nibrs_weapon_temp (weapon_id, offense_id, nibrs_weapon_id) FROM 'NIBRS_W.csv' WITH DELIMITER ',';


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
\COPY reta_month_temp (reta_month_id, agency_id, data_year, month_num, data_home, source_flag, reported_flag, ddocname, month_included_in, report_date, prepared_date, prepared_by_user, prepared_by_email, orig_format, leoka_felony, leoka_accident, leoka_assault, leoka_status, update_flag, did, ff_line_number, extra) FROM 'RetAM.csv' WITH DELIMITER ',';

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
\COPY reta_month_offense_subcat_temp (reta_month_id, offense_subcat_id, reported_count, reported_status, unfounded_count, unfounded_status, actual_count, actual_status, cleared_count, cleared_status, juvenile_cleared_count, juvenile_cleared_status) FROM 'RetAMOS.csv' WITH DELIMITER ',';

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

\COPY asr_month_temp (asr_month_id, agency_id, data_year, month_num, source_flag, reported_flag, orig_format, update_flag, ff_line_number, ddocname, did, data_home, extra) FROM 'ASRM.csv' WITH DELIMITER ',';



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


\COPY asr_race_offense_subcat_temp (asr_month_id , offense_subcat_id ,    race_id ,    juvenile_flag ,    arrest_count ,    arrest_status ,    active_flag ,    prepared_date ,    report_date ,    ff_line_number ,    asr_month_id_1,    agency_id,    data_year,    month_num,    source_flag,    reported_flag,    orig_format,    update_flag,    ff_line_number_1,    ddocname,    did,    data_home,    month_pub_status) FROM 'ASROS.csv' WITH DELIMITER ',';


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


\COPY asr_age_sex_subcat_temp (asr_month_id ,    offense_subcat_id ,    age_range_id ,    arrest_count ,    arrest_status ,    active_flag ,    prepared_date ,    report_date ,    ff_line_number ,    asr_month_id_1,    agency_id,    data_year,    month_num,    source_flag,    reported_flag,    orig_format,    update_flag,    ff_line_number_1,    ddocname,    did,    data_home,    month_pub_status) FROM 'ASRS.csv' WITH DELIMITER ',';




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

\COPY hc_incident_temp (incident_id, agency_id, incident_no, incident_date, data_home, source_flag, ddocname, report_date, prepared_date, victim_count, adult_victim_count, incident_status, juvenile_victim_count, offender_count, adult_offender_count, juvenile_offender_count, offender_race_id, offender_ethnicity_id, update_flag, hc_quarter_id, ff_line_number, orig_format, did, nibrs_incident_id) FROM 'Hate_I.csv' WITH DELIMITER ',';

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


\COPY hc_quarter_temp (agency_id, quarter_num, data_year, reported_status, reported_count, hc_quarter_id, update_flag, orig_format, ff_line_number, ddocname, did, data_home, quarter_pub_status) FROM 'Hate_Q.csv' WITH DELIMITER ',';


-- hc_bias_motivation
DROP TABLE IF EXISTS hc_bias_motivation_temp;
CREATE TABLE hc_bias_motivation_temp (
    offense_id text,
    bias_id text
);

\COPY hc_bias_motivation_temp (offense_id, bias_id) FROM 'Hate_BM.csv' WITH DELIMITER ',';

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

\COPY hc_offense_temp (offense_id, incident_id, offense_type_id, victim_count, location_id, nibrs_offense_id) FROM 'Hate_O.csv' WITH DELIMITER ',';

-- hc_victim
DROP TABLE IF EXISTS hc_victim_temp;
CREATE TABLE hc_victim_temp (
    offense_id text,
    victim_type_id text
);

\COPY hc_victim_temp (offense_id, victim_type_id) FROM 'Hate_V.csv' WITH DELIMITER ',';


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

\COPY ct_incident_temp (incident_id, agency_id, data_year, incident_number, incident_date, source_flag, ddocname, report_date, prepared_date, report_date_flag, incident_hour, cleared_except_flag, update_flag, ct_month_id, ff_line_number, data_home, orig_format, unknown_offender, did, nibrs_incident_id) FROM 'Cargo_I.csv' WITH DELIMITER ',';

-- ct_victim
DROP TABLE IF EXISTS ct_victim_temp;
CREATE TABLE ct_victim_temp (
    incident_id text,
    victim_type_id text
);

\COPY ct_victim_temp (incident_id, victim_type_id) FROM 'Cargo_V.csv' WITH DELIMITER ',';


-- ct_offense
DROP TABLE IF EXISTS ct_offense_temp;
CREATE TABLE ct_offense_temp (
    offense_id text,
    incident_id text,
    offense_type_id text,
    location_id text,
    ct_offense_flag text
);

\COPY ct_offense_temp (offense_id, incident_id, offense_type_id, location_id, ct_offense_flag) FROM 'Cargo_OO.csv' WITH DELIMITER ',';


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

\COPY ct_offender_temp (offender_id, incident_id, age, sex_code, ethnicity_id, race_id) FROM 'Cargo_O.csv' WITH DELIMITER ',';

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

\COPY ct_arrestee_temp (arrestee_id, incident_id, age, sex_code, ethnicity_id, race_id) FROM 'Cargo_A.csv' WITH DELIMITER ',';

-- ct_weapon
DROP TABLE IF EXISTS ct_weapon_temp;
CREATE TABLE ct_weapon_temp (
    incident_id text,
    weapon_id text,
    ct_weapon_id text
);

\COPY ct_weapon_temp (incident_id, weapon_id, ct_weapon_id) FROM 'Cargo_W.csv' WITH DELIMITER ',';

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

\COPY ct_property_temp (property_id, prop_desc_id, incident_id, stolen_value, recovered_flag, date_recovered, recovered_value) FROM 'Cargo_P.csv' WITH DELIMITER ',';




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

\COPY arson_month_temp (arson_month_id, agency_id, data_year, month_num, data_home, source_flag, reported_flag, ddocname, month_included_in, report_date, prepared_date, orig_format, update_flag, did, ff_line_number, extra) FROM 'ArsonM.csv' WITH DELIMITER ',';


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

\COPY arson_month_by_subcat_temp (arson_month_id, subcategory_id, reported_count, reported_status, unfounded_count, unfounded_status, actual_count, actual_status, cleared_count, cleared_status, juvenile_cleared_count, juvenile_cleared_status, uninhabited_count, uninhabited_status, est_damage_value, est_damage_value_status) FROM 'ArsonMOS.csv' WITH DELIMITER ',';


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

INSERT INTO reta_month (SELECT convert_to_integer(reta_month_id), convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(month_num), data_home, source_flag, reported_flag, ddocname, convert_to_integer(month_included_in), to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), prepared_by_user, prepared_by_email, orig_format, convert_to_integer(leoka_felony), convert_to_integer(leoka_accident), convert_to_integer(leoka_assault), convert_to_integer(leoka_status), update_flag, convert_to_integer(did), convert_to_integer(ff_line_number) FROM reta_month_temp);
INSERT INTO reta_month_offense_subcat (SELECT convert_to_integer(reta_month_id), convert_to_integer(offense_subcat_id), convert_to_integer(reported_count), convert_to_integer(reported_status), convert_to_integer(unfounded_count), convert_to_integer(unfounded_status), convert_to_integer(actual_count), convert_to_integer(actual_status), convert_to_integer(cleared_count), convert_to_integer(cleared_status), convert_to_integer(juvenile_cleared_count), convert_to_integer(juvenile_cleared_status) FROM reta_month_offense_subcat_temp);
INSERT INTO asr_month (SELECT convert_to_integer(asr_month_id), convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(month_num), source_flag, reported_flag, orig_format, update_flag, convert_to_integer(ff_line_number), ddocname, convert_to_integer(did), data_home FROM asr_month_temp);
INSERT INTO asr_offense_subcat (SELECT convert_to_integer(asr_month_id) ,    convert_to_integer(offense_subcat_id) ,    convert_to_integer(race_id) ,    juvenile_flag ,    convert_to_integer(arrest_count) ,    convert_to_integer(arrest_status) ,    active_flag ,    to_timestamp_ucr(prepared_date) ,    to_timestamp_ucr(report_date) ,   convert_to_integer(ff_line_number) FROM asr_offense_subcat_temp);
INSERT INTO asr_age_sex_subcat (SELECT convert_to_integer(asr_month_id), convert_to_integer(offense_subcat_id), convert_to_integer(age_range_id),  convert_to_integer(arrest_count) ,    convert_to_integer(arrest_status) , active_flag ,    to_timestamp_ucr(prepared_date) ,    to_timestamp_ucr(report_date) ,   convert_to_integer(ff_line_number)   FROM asr_age_sex_subcat_temp);


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

