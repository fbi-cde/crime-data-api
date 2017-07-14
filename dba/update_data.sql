-- # Load in all new data into temporary tables.

-- # cf connect-to-service crime-data-api crime-data-upload-db <<EOF
-- # SET work_mem='3GB';

-- # \copy (SELECT incident_id as incident_key, ori, race_code, sex_code, age_num, location_name from nibrs_offender_denorm where year='$i' and state_code::integer=$k) To 'offender.csv' With CSV DELIMITER ',' HEADER;
-- # EOF



-- ISSUES:
-- REF_CP.csv - Seems malformed. Columns don't align, and there are weird values.
-- ASRS.csv - What table is this for ???
-- Cargo_M.csv - What is this for ????


-- Process.
-- (1) Remove last rows of file
-- (2) Get list of columns:
--           SELECT column_name || ',' FROM information_schema.columns WHERE table_schema='public' AND table_name='ref_agency_county';
-- (3) Build temp table statements.
-- (4) Merge or replace tables.
-- (5) Re-add all indexes (for replaced tables only).

-----------------------
-- Helper functions
-----------------------

CREATE OR REPLACE FUNCTION convert_to_integer(v_input text)
RETURNS INTEGER AS $$
DECLARE v_int_value INTEGER DEFAULT NULL;
BEGIN
    BEGIN
        IF (v_input = '') IS NOT FALSE THEN
            v_int_value := 0;
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
--- REFERENCE TABLE UPLOAD + REPLACEMENT.
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
INSERT INTO ref_agency_replace (SELECT convert_to_integer(agency_id), ori, legacy_ori, ucr_agency_name, ncic_agency_name, pub_agency_name, convert_to_integer(agency_type_id), special_mailing_group, special_mailing_address, convert_to_integer(tribe_id), convert_to_integer(city_id), convert_to_integer(state_id), convert_to_integer(campus_id), agency_status, judicial_dist_code, convert_to_integer(submitting_agency_id), fid_code, convert_to_integer(department_id), to_timestamp_ucr(added_date), to_timestamp_ucr1(change_timestamp), change_user, legacy_notify_agency, convert_to_integer(dormant_year), convert_to_integer(population_family_id), convert_to_integer(field_office_id) from ref_agency_new);


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
INSERT INTO ref_agency_county_replace (SELECT agency_id, county_id, convert_to_integer(metro_div_id), core_city_flag, convert_to_integer(data_year), convert_to_integer(population), convert_to_integer(census), legacy_county_code, legacy_msa_code, source_flag, to_timestamp_ucr1(change_timestamp), change_user from ref_agency_county_temp); 

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


---------------------------
--
-- 
-- REPLACE REF TABLES.
--
--
---------------------------

-- Replace table safely.
ALTER TABLE ref_agency RENAME TO ref_agency_old;
ALTER TABLE ref_agency_replace RENAME TO ref_agency;
DROP TABLE ref_agency_old;

ALTER TABLE ref_agency_county RENAME TO ref_agency_county_old;
ALTER TABLE ref_agency_county_replace RENAME TO ref_agency_county;
DROP TABLE ref_agency_county_old;

ALTER TABLE ref_agency_covered_by RENAME TO ref_agency_covered_by_old;
ALTER TABLE ref_agency_covered_by_replace RENAME TO ref_agency_covered_by;
DROP TABLE ref_agency_covered_by_old;

ALTER TABLE ref_county RENAME TO ref_county_old;
ALTER TABLE ref_county_replace RENAME TO ref_county;
DROP TABLE ref_county_old;

ALTER TABLE ref_country RENAME TO ref_country_old;
ALTER TABLE ref_country_replace RENAME TO ref_country;
DROP TABLE ref_country;

ALTER TABLE ref_county_population RENAME TO ref_county_population_old;
ALTER TABLE ref_county_population_replace RENAME TO ref_county_population;
DROP TABLE ref_county_population_old;

ALTER TABLE ref_agency_population RENAME TO ref_agency_population_old;
ALTER TABLE ref_agency_population_replace RENAME TO ref_agency_population;
DROP TABLE ref_agency_population_old;

ALTER TABLE ref_tribe_population RENAME TO ref_tribe_population_old;
ALTER TABLE ref_tribe_population_replace RENAME TO ref_tribe_population;
DROP TABLE ref_tribe_population_old;

---------------------------
-- 
-- 
-- REF TABLE INDEX BLOCK
-- 
-- 
---------------------------

--
-- Name: ref_agency_ori_key; Type: CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_ori_key UNIQUE (ori);


--
-- Name: ref_agency_pkey; Type: CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_pkey PRIMARY KEY (agency_id);


--
-- Name: agency_uni_campus_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX agency_uni_campus_ix ON ref_agency USING btree (campus_id);


--
-- Name: ra_state_id; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ra_state_id ON ref_agency USING btree (state_id);


--
-- Name: ref_agency_city_id_idx; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_city_id_idx ON ref_agency USING btree (city_id);


--
-- Name: ref_agency_city_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_city_ix ON ref_agency USING btree (city_id);


--
-- Name: ref_agency_department_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_department_ix ON ref_agency USING btree (department_id);


--
-- Name: ref_agency_field_office_idx; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_field_office_idx ON ref_agency USING btree (field_office_id);


--
-- Name: ref_agency_pop_family_idx; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_pop_family_idx ON ref_agency USING btree (population_family_id);


--
-- Name: ref_agency_short_ori_idx; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_short_ori_idx ON ref_agency USING btree ("substring"((legacy_ori)::text, 0, 7));


--
-- Name: ref_agency_state_id_idx; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_state_id_idx ON ref_agency USING btree (state_id);


--
-- Name: ref_agency_sub_agency_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_sub_agency_ix ON ref_agency USING btree (submitting_agency_id);


--
-- Name: ref_agency_tribe_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_tribe_ix ON ref_agency USING btree (tribe_id);


--
-- Name: ref_agency_type_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_type_ix ON ref_agency USING btree (agency_type_id);


--
-- Name: agency_state_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT agency_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);


--
-- Name: ref_agency_department_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_department_fk FOREIGN KEY (department_id) REFERENCES ref_department(department_id);


--
-- Name: ref_agency_field_office_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_field_office_fk FOREIGN KEY (field_office_id) REFERENCES ref_field_office(field_office_id);


--
-- Name: ref_agency_pop_family_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_pop_family_fk FOREIGN KEY (population_family_id) REFERENCES ref_population_family(population_family_id);


--
-- Name: ref_agency_sub_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_sub_agency_fk FOREIGN KEY (submitting_agency_id) REFERENCES ref_submitting_agency(agency_id);


--
-- Name: ref_agency_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_type_fk FOREIGN KEY (agency_type_id) REFERENCES ref_agency_type(agency_type_id);


--
-- Name: ref_agency_county_pkey; Type: CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency_county
    ADD CONSTRAINT ref_agency_county_pkey PRIMARY KEY (agency_id, county_id, metro_div_id, data_year);


--
-- Name: agency_county_county_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX agency_county_county_ix ON ref_agency_county USING btree (county_id);


--
-- Name: ref_agency_county_met_div_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_county_met_div_ix ON ref_agency_county USING btree (metro_div_id);


--
-- Name: agency_county_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency_county
    ADD CONSTRAINT agency_county_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: ref_agency_county_met_div_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency_county
    ADD CONSTRAINT ref_agency_county_met_div_fk FOREIGN KEY (metro_div_id) REFERENCES ref_metro_division(metro_div_id);


--
-- Name: ref_agency_covered_by_pkey; Type: CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency_covered_by
    ADD CONSTRAINT ref_agency_covered_by_pkey PRIMARY KEY (agency_id, data_year);


--
-- Name: ref_agency_cov_agency_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_agency_cov_agency_ix ON ref_agency_covered_by USING btree (covered_by_agency_id);


--
-- Name: ref_agency_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency_covered_by
    ADD CONSTRAINT ref_agency_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: ref_agency_cov_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_agency_covered_by
    ADD CONSTRAINT ref_agency_cov_agency_fk FOREIGN KEY (covered_by_agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: ref_county_pkey; Type: CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_county
    ADD CONSTRAINT ref_county_pkey PRIMARY KEY (county_id);


--
-- Name: ref_county_state_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_county_state_ix ON ref_county USING btree (state_id);


--
-- Name: ref_county_state_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_county
    ADD CONSTRAINT ref_county_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);


-- Name: ref_country_pkey; Type: CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_country
    ADD CONSTRAINT ref_country_pkey PRIMARY KEY (country_id);


--
-- Name: ref_country_continent_ix; Type: INDEX; Schema: public; Owner: colincraig
--

CREATE INDEX ref_country_continent_ix ON ref_country USING btree (continent_id);


--
-- Name: ref_country_continent_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_country
    ADD CONSTRAINT ref_country_continent_fk FOREIGN KEY (continent_id) REFERENCES ref_continent(continent_id);


--
-- Name: ref_county_population_pkey; Type: CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_county_population
    ADD CONSTRAINT ref_county_population_pkey PRIMARY KEY (county_id, data_year);


--
-- Name: ref_county_pop_county_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_county_population
    ADD CONSTRAINT ref_county_pop_county_fk FOREIGN KEY (county_id) REFERENCES ref_county(county_id);

--
-- Name: ref_tribe_population_pkey; Type: CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_tribe_population
    ADD CONSTRAINT ref_tribe_population_pkey PRIMARY KEY (tribe_id, data_year);


--
-- Name: ref_tribe_pop_tribe_fk; Type: FK CONSTRAINT; Schema: public; Owner: colincraig
--

ALTER TABLE ONLY ref_tribe_population
    ADD CONSTRAINT ref_tribe_pop_tribe_fk FOREIGN KEY (tribe_id) REFERENCES ref_tribe(tribe_id);



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

\COPY nibrs_offense_temp (offense_id, incident_id, offense_type_id, attempt_complete_flag, location_id, num_premises_entered, method_entry_code, ff_line_number) FROM 'NIBRS_OF.csv' WITH DELIMITER ',';

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

\COPY nibrs_offender_temp (offender_id, incident_id, offender_seq_num, age_id, age_num, sex_code, race_id, ethnicity_id, ff_line_number, age_range_low_num, age_range_high_num) FROM 'NIBRS_OFF.csv' WITH DELIMITER ',';

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
    total_reported_count text,
    total_unfounded_count text,
    total_actual_count text,
    total_cleared_count text,
    total_juvenile_cleared_count text,
    leoka_felony text,
    leoka_accident text,
    leoka_assault text,
    leoka_status text,
    update_flag text,
    did text,
    ff_line_number text
);


\COPY reta_month_temp (reta_month_id, agency_id, data_year, month_num, data_home, source_flag, reported_flag, ddocname, month_included_in, report_date, prepared_date, prepared_by_user, prepared_by_email, orig_format, total_reported_count, total_unfounded_count, total_actual_count, total_cleared_count, total_juvenile_cleared_count, leoka_felony, leoka_accident, leoka_assault, leoka_status, update_flag, did, ff_line_number) FROM 'RetAM.csv' WITH DELIMITER ',';

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
    data_home text
);

\COPY asr_month_temp (asr_month_id, agency_id, data_year, month_num, source_flag, reported_flag, orig_format, update_flag, ff_line_number, ddocname, did, data_home) FROM 'ASRM.csv' WITH DELIMITER ',';



-- asr_offense_subcat
DROP TABLE IF EXISTS asr_offense_subcat_temp;
CREATE TABLE asr_offense_subcat_temp (
    offense_subcat_id text,
    offense_id text,
    offense_subcat_name text,
    offense_subcat_code text,
    srs_offense_code text,
    master_offense_code text,
    total_flag text,
    adult_juv_flag text
);

\COPY asr_offense_subcat_temp (offense_subcat_id, offense_id, offense_subcat_name, offense_subcat_code, srs_offense_code, master_offense_code, total_flag, adult_juv_flag) FROM 'ASROS.csv' WITH DELIMITER ',';


-- ASRS.csv?????


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

\COPY hc_incident_temp (incident_id, agency_id, incident_no, incident_date, data_home, source_flag, ddocname, report_date, prepared_date, victim_count, adult_victim_count, incident_status, juvenile_victim_count, offender_count, adult_offender_count, juvenile_offender_count, offender_race_id, offender_ethnicity_id, update_flag, hc_quarter_id, ff_line_number, orig_format, did, nibrs_incident_id) FROM 'HC_I.csv' WITH DELIMITER ',';


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

\COPY hc_offense_temp (offense_id, incident_id, offense_type_id, victim_count, location_id, nibrs_offense_id) FROM 'HC_O.csv' WITH DELIMITER ',';

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

\COPY ct_offense_temp (incident_id, victim_type_id) FROM 'Cargo_V.csv' WITH DELIMITER ',';


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
    ff_line_number text
);

\COPY arson_month_temp (arson_month_id, agency_id, data_year, month_num, data_home, source_flag, reported_flag, ddocname, month_included_in, report_date, prepared_date, orig_format, update_flag, did, ff_line_number) FROM 'Arson_M.csv' WITH DELIMITER ',';


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

\COPY arson_month_by_subcat_temp (arson_month_id, subcategory_id, reported_count, reported_status, unfounded_count, unfounded_status, actual_count, actual_status, cleared_count, cleared_status, juvenile_cleared_count, juvenile_cleared_status, uninhabited_count, uninhabited_status, est_damage_value, est_damage_value_status) FROM 'Arson_MOS.csv' WITH DELIMITER ',';


-----------------------------
--
--
-- DATA MERGE BLOCK - Merges the new data with existing tables.
--
--
------------------------------

-- Save this task for last. Be sure everything lines up.
INSERT INTO nibrs_incident (SELECT convert_to_integer(agency_id), convert_to_integer(incident_id), convert_to_integer(nibrs_month_id), convert_to_integer(incident_number), cargo_theft_flag, to_timestamp_ucr(submission_date), to_timestamp_ucr(incident_date), report_date_flag, convert_to_integer(incident_hour), convert_to_integer(cleared_except_id), to_timestamp_ucr(cleared_except_date), convert_to_integer(incident_status), data_home, ddocname, orig_format, convert_to_integer(ff_line_number), convert_to_integer(did) FROM nibrs_incident_temp);
INSERT INTO nibrs_month (SELECT convert_to_integer(nibrs_month_id), convert_to_integer(agency_id), convert_to_integer(month_num), convert_to_integer(data_year), reported_status, to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), update_flag, orig_format, convert_to_integer(ff_line_number), data_home, ddocname, convert_to_integer(did) FROM nibrs_month_temp);
INSERT INTO nibrs_arrestee (SELECT convert_to_integer(arrestee_id), convert_to_integer(incident_id), convert_to_integer(arrestee_seq_num), arrest_num, to_timestamp_ucr(arrest_date), convert_to_integer(arrest_type_id), multiple_indicator, convert_to_integer(offense_type_id), convert_to_integer(age_id), convert_to_integer(age_num), sex_code, convert_to_integer(race_id), convert_to_integer(ethnicity_id), resident_code, under_18_disposition_code, clearance_ind, convert_to_integer(ff_line_number), convert_to_integer(age_range_low_num), convert_to_integer(age_range_high_num) FROM nibrs_arrestee_temp);
INSERT INTO nibrs_arrestee_weapon (SELECT convert_to_integer(arrestee_id), convert_to_integer(weapon_id), convert_to_integer(nibrs_arrestee_weapon_id) FROM nibrs_arrestee_weapon_temp);
INSERT INTO nibrs_bias_motivation (SELECT convert_to_integer(bias_id), convert_to_integer(offense_id) FROM nibrs_bias_motivation_temp);
INSERT INTO nibrs_criminal_act (SELECT convert_to_integer(criminal_act_id), convert_to_integer(offense_id) FROM nibrs_criminal_act_temp);
INSERT INTO nibrs_offense (SELECT convert_to_integer(offense_id), convert_to_integer(incident_id), convert_to_integer(offense_type_id), attempt_complete_flag, convert_to_integer(location_id), convert_to_integer(num_premises_entered), method_entry_code, convert_to_integer(ff_line_number) FROM nibrs_offense_temp);
INSERT INTO nibrs_offender (SELECT convert_to_integer(offender_id), convert_to_integer(incident_id), convert_to_integer(offender_seq_num), convert_to_integer(age_id), convert_to_integer(age_num), sex_code, convert_to_integer(race_id), convert_to_integer(ethnicity_id), convert_to_integer(ff_line_number), convert_to_integer(age_range_low_num), convert_to_integer(age_range_high_num) FROM nibrs_offender_temp);
INSERT INTO nibrs_property (SELECT convert_to_integer(property_id), convert_to_integer(incident_id), convert_to_integer(prop_loss_id), convert_to_integer(stolen_count), convert_to_integer(recovered_count), convert_to_integer(ff_line_number) FROM nibrs_property_temp);
INSERT INTO nibrs_property_desc (SELECT convert_to_integer(property_id), convert_to_integer(prop_desc_id), convert_to_integer(property_value), to_timestamp_ucr(date_recovered), convert_to_integer(nibrs_prop_desc_id) FROM nibrs_property_desc_temp);
INSERT INTO nibrs_suspected_drug (SELECT convert_to_integer(suspected_drug_type_id), convert_to_integer(property_id), convert_to_double(est_drug_qty), convert_to_integer(drug_measure_type_id), convert_to_integer(nibrs_suspected_drug_id) FROM nibrs_suspected_drug_temp);
INSERT INTO nibrs_suspect_using (SELECT convert_to_integer(suspect_using_id), convert_to_integer(offense_id) FROM nibrs_suspect_using_temp);
INSERT INTO nibrs_victim (SELECT convert_to_integer(victim_id), convert_to_integer(incident_id), convert_to_integer(victim_seq_num), convert_to_integer(victim_type_id), convert_to_integer(assignment_type_id), convert_to_integer(activity_type_id), convert_to_integer(outside_agency_id), convert_to_integer(age_id), convert_to_integer(age_num), sex_code, convert_to_integer(race_id), convert_to_integer(ethnicity_id), resident_status_code, convert_to_integer(agency_data_year), convert_to_integer(ff_line_number), convert_to_integer(age_range_low_num), convert_to_integer(age_range_high_num) FROM nibrs_victim_temp);
INSERT INTO nibrs_victim_circumstances (SELECT convert_to_integer(victim_id), convert_to_integer(circumstances_id), convert_to_integer(justifiable_force_id) FROM nibrs_victim_circumstances_temp);
INSERT INTO nibrs_victim_injury (SELECT convert_to_integer(victim_id), convert_to_integer(injury_id) FROM nibrs_victim_injury_temp);
INSERT INTO nibrs_victim_offense (SELECT convert_to_integer(victim_id), convert_to_integer(offense_id) FROM nibrs_victim_offense_temp);
INSERT INTO nibrs_victim_offender_rel (SELECT convert_to_integer(victim_id), convert_to_integer(offender_id), convert_to_integer(relationship_id), convert_to_integer(nibrs_victim_offender_id) FROM nibrs_victim_offender_rel);
INSERT INTO nibrs_weapon (SELECT convert_to_integer(weapon_id), convert_to_integer(offense_id), convert_to_integer(nibrs_weapon_id) FROM nibrs_weapon_temp);
INSERT INTO reta_month (SELECT convert_to_integer(reta_month_id), convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(month_num), data_home, source_flag, reported_flag, ddocname, convert_to_integer(month_included_in), to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), prepared_by_user, prepared_by_email, orig_format, convert_to_integer(total_reported_count), convert_to_integer(total_unfounded_count), convert_to_integer(total_actual_count), convert_to_integer(total_cleared_count), convert_to_integer(total_juvenile_cleared_count), convert_to_integer(leoka_felony), convert_to_integer(leoka_accident), convert_to_integer(leoka_assault), convert_to_integer(leoka_status), update_flag, convert_to_integer(did), convert_to_integer(ff_line_number) FROM reta_month_temp);
INSERT INTO reta_month_offense_subcat (SELECT convert_to_integer(reta_month_id), convert_to_integer(offense_subcat_id), convert_to_integer(reported_count), convert_to_integer(reported_status), convert_to_integer(unfounded_count), convert_to_integer(unfounded_status), convert_to_integer(actual_count), convert_to_integer(actual_status), convert_to_integer(cleared_count), convert_to_integer(cleared_status), convert_to_integer(juvenile_cleared_count), convert_to_integer(juvenile_cleared_status) FROM reta_month_offense_subcat_temp);
INSERT INTO asr_month (SELECT convert_to_integer(asr_month_id), convert_to_integer(agency_id), convert_to_integer(data_year), convert_to_integer(month_num), source_flag, reported_flag, orig_format, update_flag, convert_to_integer(ff_line_number), ddocname, convert_to_integer(did), data_home FROM asr_month_temp);
INSERT INTO asr_offense_subcat (SELECT convert_to_integer(offense_subcat_id), convert_to_integer(offense_id), offense_subcat_name, offense_subcat_code, srs_offense_code, convert_to_integer(master_offense_code), total_flag, adult_juv_flag FROM asr_offense_subcat_temp);

-- TODO: (Don't forget to replace temp table fields with text)
-- hc_*
INSERT INTO hc_incident (SELECT convert_to_integer(incident_id), convert_to_integer(agency_id), incident_no, to_timestamp_ucr(incident_date), data_home, source_flag, ddocname, to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), convert_to_integer(victim_count), convert_to_integer(adult_victim_count), convert_to_integer(incident_status), convert_to_integer(juvenile_victim_count), convert_to_integer(offender_count), convert_to_integer(adult_offender_count), convert_to_integer(juvenile_offender_count), convert_to_integer(offender_race_id), convert_to_integer(offender_ethnicity_id), update_flag, convert_to_integer(hc_quarter_id), convert_to_integer(ff_line_number), orig_format, convert_to_integer(did), convert_to_integer(nibrs_incident_id) from hc_incident_temp);
INSERT INTO hc_bias_motivation (SELECT convert_to_integer(offense_id), convert_to_integer(bias_id) from hc_bias_motivation_temp);
INSERT INTO hc_offense (SELECT convert_to_integer(offense_id), convert_to_integer(incident_id), convert_to_integer(offense_type_id), convert_to_integer(victim_count), convert_to_integer(location_id), convert_to_integer(nibrs_offense_id) from hc_offense_temp);
INSERT INTO hc_victim (SELECT convert_to_integer(offense_id), convert_to_integer(victim_type_id) from hc_victim_temp);

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

