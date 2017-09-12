
MYPWD="$(pwd)/data"
YEAR=$1


echo "-- Process.
-- (1) Build temp table statements.
-- (2) Merge or replace tables.
-- (3) Re-add all indexes (for replaced tables only).


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
    extra1 text
);

-- Load CSV data into shell.
\COPY ref_agency_temp (agency_id, ori, legacy_ori, ucr_agency_name, ncic_agency_name, pub_agency_name, agency_type_id, special_mailing_group, special_mailing_address, tribe_id, city_id, state_id, campus_id, agency_status, judicial_dist_code, submitting_agency_id, fid_code, department_id, added_date, change_timestamp, change_user, legacy_notify_agency, dormant_year, population_family_id, field_office_id, extra1) FROM '$MYPWD/REFA.csv' WITH DELIMITER '|';

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
\COPY ref_agency_county_temp (agency_id,county_id, metro_div_id, core_city_flag, data_year, population, census, legacy_county_code, legacy_msa_code, source_flag, change_timestamp, change_user) FROM '$MYPWD/REFAC.csv' WITH DELIMITER '|';

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
\COPY ref_agency_covered_by_temp (agency_id,data_year, covered_by_agency_id) FROM '$MYPWD/REFACB.csv' WITH DELIMITER '|';

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

\COPY ref_county_temp (county_id, state_id, county_name, county_ansi_code, county_fips_code, legacy_county_code, comments) FROM '$MYPWD/REFC.csv' WITH DELIMITER '|';

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

\COPY ref_country_temp (country_id, continent_id, country_desc) FROM '$MYPWD/REFCY.csv' WITH DELIMITER '|';

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

\COPY ref_county_population_temp (county_id, data_year, population, source_flag, extra, change_timestamp, change_user, reporting_population) FROM '$MYPWD/REFCP.csv' WITH DELIMITER '|';

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

\COPY ref_agency_population_temp (agency_id, data_year, population_group_id, population, source_flag, change_timestamp, change_user, city_sequence, suburban_area_flag) FROM '$MYPWD/REFAP.csv' WITH DELIMITER '|';


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

\COPY ref_tribe_population_temp (tribe_id, data_year, population, source_flag, census, change_timestamp, change_user, reporting_population) FROM '$MYPWD/REFTP.csv' WITH DELIMITER '|';

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
    ff_line_number text
);


\COPY asr_race_offense_subcat_temp (asr_month_id , offense_subcat_id ,    race_id ,    juvenile_flag ,    arrest_count ,    arrest_status ,    active_flag ,    prepared_date ,    report_date ,    ff_line_number) FROM '$MYPWD/ASROS.csv' WITH DELIMITER ',';


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
    ff_line_number text
);


\COPY asr_age_sex_subcat_temp (asr_month_id ,    offense_subcat_id ,    age_range_id ,    arrest_count ,    arrest_status ,    active_flag ,    prepared_date ,    report_date ,    ff_line_number ) FROM '$MYPWD/ASRS.csv' WITH DELIMITER ',';



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

\COPY arson_month_by_subcat_temp (arson_month_id, subcategory_id, reported_count, reported_status, unfounded_count, unfounded_status, actual_count, actual_status, cleared_count, cleared_status, juvenile_cleared_count, juvenile_cleared_status, uninhabited_count, uninhabited_status, est_damage_value, est_damage_value_status) FROM '$MYPWD/ArsonMBS.csv' WITH DELIMITER ',';

------------------------------
--
-- Additional datasets (leoka, pe)
--
------------------------------

-- leoka data
DROP TABLE IF EXISTS lkasum_month_temp;
CREATE TABLE lkasum_month_temp (
    lkasum_month_id text,
    agency_id text,
    data_year text,
    month_num text,
    data_home text,
    source_flag text,
    report_date text, 
    prepared_date text,
    reported_flag text,
    ddocname text,
    leoka_felony text,
    leoka_accident text,
    orig_format text,
    update_flag text,
    did text,
    ff_line_number text,
    extra1 text,
    extra2 text
);

\COPY lkasum_month_temp (lkasum_month_id, agency_id, data_year, month_num, data_home, source_flag, report_date, prepared_date, reported_flag, ddocname, leoka_felony, leoka_accident, orig_format, update_flag, did, ff_line_number, extra1, extra2) FROM '$MYPWD/LKAM.csv' WITH DELIMITER ',';

-- PE data
DROP TABLE IF EXISTS pe_employee_data_temp;
CREATE TABLE pe_employee_data_temp (
    agency_id text,--bigint NOT NULL,
    data_year text,--smallint NOT NULL,
    reported_flag text,
    male_officer text,--bigint,
    male_civilian text,--bigint,
    male_total text,--bigint,
    female_officer text,--bigint,
    female_civilian text,--bigint,
    female_total text, --bigint,
    officer_rate text, --bigint,
    employee_rate text, --bigint,
    data_home character(1),
    ddocname character varying(100),
    did text, --bigint,
    ff_line_number text, --bigint,
    orig_format character(1),
    pe_employee_id text, --bigint NOT NULL
    extra text
);

\COPY pe_employee_data_temp (agency_id,  data_year, reported_flag, male_officer, male_civilian, male_total, female_officer, female_civilian, female_total, officer_rate, employee_rate, data_home, ddocname, did, ff_line_number, orig_format, pe_employee_id, extra) FROM '$MYPWD/PE.csv' WITH DELIMITER ',';



"
