
MYPWD="$(pwd)/data"
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
    extra1 text
);

-- Load CSV data into shell.
\COPY ref_agency_temp (agency_id, ori, legacy_ori, ucr_agency_name, ncic_agency_name, pub_agency_name, agency_type_id, special_mailing_group, special_mailing_address, tribe_id, city_id, state_id, campus_id, agency_status, judicial_dist_code, submitting_agency_id, fid_code, department_id, added_date, change_timestamp, change_user, legacy_notify_agency, dormant_year, population_family_id, field_office_id, extra1) FROM '$MYPWD/REF_A.csv' WITH DELIMITER '|';

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

"
