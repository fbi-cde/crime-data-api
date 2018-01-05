-- This file just loads the data specific to this download and needs
-- to be run in the directory of every year you want to load.

ALTER TABLE nibrs_arrestee DISABLE TRIGGER ALL;
ALTER TABLE nibrs_arrestee_weapon DISABLE TRIGGER ALL;
ALTER TABLE nibrs_bias_motivation DISABLE TRIGGER ALL;
ALTER TABLE nibrs_month DISABLE TRIGGER ALL;
ALTER TABLE nibrs_incident DISABLE TRIGGER ALL;
ALTER TABLE nibrs_offender DISABLE TRIGGER ALL;
ALTER TABLE nibrs_offense DISABLE TRIGGER ALL;
ALTER TABLE nibrs_property DISABLE TRIGGER ALL;
ALTER TABLE nibrs_property_desc DISABLE TRIGGER ALL;
ALTER TABLE nibrs_suspect_using DISABLE TRIGGER ALL;
ALTER TABLE nibrs_suspected_drug DISABLE TRIGGER ALL;
ALTER TABLE nibrs_victim DISABLE TRIGGER ALL;
ALTER TABLE nibrs_victim_circumstances DISABLE TRIGGER ALL;
ALTER TABLE nibrs_victim_injury DISABLE TRIGGER ALL;
ALTER TABLE nibrs_victim_offender_rel DISABLE TRIGGER ALL;
ALTER TABLE nibrs_victim_offense DISABLE TRIGGER ALL;
ALTER TABLE nibrs_weapon DISABLE TRIGGER ALL;

\COPY nibrs_arrestee FROM 'nibrs_arrestee.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_arrestee_weapon FROM 'nibrs_arrestee_weapon.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_bias_motivation FROM 'nibrs_bias_motivation.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_month FROM 'nibrs_month.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_incident FROM 'nibrs_incident.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_offender FROM 'nibrs_offender.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_offense FROM 'nibrs_offense.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_property FROM 'nibrs_property.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_property_desc FROM 'nibrs_property_desc.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_suspect_using FROM 'nibrs_suspect_using.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_suspected_drug FROM 'nibrs_suspected_drug.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_victim FROM 'nibrs_victim.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_victim_circumstances FROM 'nibrs_victim_circumstances.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_victim_injury FROM 'nibrs_victim_injury.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_victim_offender_rel FROM 'nibrs_victim_offender_rel.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_victim_offense FROM 'nibrs_victim_offense.csv' DELIMITER ',' HEADER CSV;
\COPY nibrs_weapon FROM 'nibrs_weapon.csv' DELIMITER ',' HEADER CSV;
\COPY agency_participation FROM 'agency_participation.csv' DELIMITER ',' HEADER CSV;

--- Need to do something special for agencies because will have many
--- of same agencies from year to year

CREATE TABLE cde_agencies_temp (
    agency_id bigint NOT NULL,
    ori character(9) NOT NULL,
    legacy_ori character(9) NOT NULL,
    agency_name text,
    short_name text,
    agency_type_id smallint NOT NULL,
    agency_type_name text,
    tribe_id bigint,
    campus_id bigint,
    city_id bigint,
    city_name text,
    state_id smallint NOT NULL,
    state_abbr character(2) NOT NULL,
    primary_county_id bigint,
    primary_county text,
    primary_county_fips character varying(5),
    agency_status character(1),
    submitting_agency_id bigint,
    submitting_sai character varying(9),
    submitting_name text,
    submitting_state_abbr character varying(2),
    start_year smallint,
    dormant_year smallint,
    current_year smallint,
    revised_rape_start smallint,
    current_nibrs_start_year smallint,
    population bigint,
    population_group_code character varying(2),
    population_group_desc text,
    population_source_flag character varying(1),
    suburban_area_flag character varying(1),
    core_city_flag character varying(1),
    months_reported smallint,
    nibrs_months_reported smallint,
    past_10_years_reported smallint,
    covered_by_id bigint,
    covered_by_ori character(9),
    covered_by_name character varying(100),
    staffing_year smallint,
    total_officers integer,
    total_civilians integer,
    icpsr_zip character(5),
    icpsr_lat numeric,
    icpsr_lng numeric
);

\COPY cde_agencies_temp FROM 'cde_agencies.csv' DELIMITER ',' HEADER CSV;

INSERT INTO cde_agencies
SELECT * from cde_agencies_temp
ON CONFLICT DO NOTHING;

DROP TABLE cde_agencies_temp;

---
ALTER TABLE nibrs_arrestee ENABLE TRIGGER ALL;
ALTER TABLE nibrs_arrestee_weapon ENABLE TRIGGER ALL;
ALTER TABLE nibrs_bias_motivation ENABLE TRIGGER ALL;
ALTER TABLE nibrs_month ENABLE TRIGGER ALL;
ALTER TABLE nibrs_incident ENABLE TRIGGER ALL;
ALTER TABLE nibrs_offender ENABLE TRIGGER ALL;
ALTER TABLE nibrs_offense ENABLE TRIGGER ALL;
ALTER TABLE nibrs_property ENABLE TRIGGER ALL;
ALTER TABLE nibrs_property_desc ENABLE TRIGGER ALL;
ALTER TABLE nibrs_suspect_using ENABLE TRIGGER ALL;
ALTER TABLE nibrs_suspected_drug ENABLE TRIGGER ALL;
ALTER TABLE nibrs_victim ENABLE TRIGGER ALL;
ALTER TABLE nibrs_victim_circumstances ENABLE TRIGGER ALL;
ALTER TABLE nibrs_victim_injury ENABLE TRIGGER ALL;
ALTER TABLE nibrs_victim_offender_rel ENABLE TRIGGER ALL;
ALTER TABLE nibrs_victim_offense ENABLE TRIGGER ALL;
ALTER TABLE nibrs_weapon ENABLE TRIGGER ALL;
