CREATE TABLE public.region_lk
(
  region_code smallint PRIMARY KEY,
  region_name character varying(50),
  region_desc character varying(100)
);

CREATE TABLE state_lk (
state_id int PRIMARY KEY,
STATE_ABBR character(4),
STATE_NAME varchar(50),
STATE_FIPS_CODE int,
region_code smallint REFERENCES region_lk(region_code)
);


CREATE TABLE nibrs_victim_count (
    data_year int,
    state_id int,
    state_abbr character(2),
    agency_id int,
    ori varchar(50),
    offense_name varchar(50),
    victim_type_name varchar(50),
    sex_code character(1),
    age_range varchar(50),
    race_desc varchar(50),
    ethnicity_name varchar(50),
    location varchar(100),
    count int
);


CREATE TABLE nibrs_offender_count (
    data_year int,
    state_id int,
    state_abbr character(2),
    agency_id int,
    ori varchar(50),
    offense_name varchar(50),
    sex_code character(1),
    race_desc varchar(50),
    ethnicity_name varchar(50),
    age_range varchar(50),
    count int
);


CREATE TABLE nibrs_victim_to_offender_relationship_count (
    data_year int,
    state_id int,
    state_abbr character(2),
    agency_id int,
    ori varchar(50),
    offense_name varchar(50),
    relationship varchar(50),
    count int
);

CREATE TABLE nibrs_offense_count (
    data_year int,
    state_id int,
    state_abbr character(2),
    agency_id int,
    ori varchar(50),
    offense_name varchar(50),
    incident_count int,
    offense_count int
);
