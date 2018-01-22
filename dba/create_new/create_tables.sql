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

CREATE TABLE public.leoka_assault_data
(
  DATA_YEAR INT,
  AGENCY_ID INT,
  ORI VARCHAR(25),
  MONTH_NUM INT,
  LKASUM_MOTH_ID INT,
  MONTH_PUB_STATUS INT,
  STATE_ID INT,
  STATE_ABBR VARCHAR(2),
  DIVISION_CODE INT,
  DIVISION_NAME VARCHAR(100),
  REGION_CODE INT,
  REGION_NAME VARCHAR(100),
  ACTIVITY_ID INT,
  ACTIVITY_NAME VARCHAR(100),
  TWO_OFFICER_VEHICLE_ACTUAL INT,
  ONE_OFFICER_VEHICLE_ACTUAL INT,
  ONE_OFFICER_ASSISTED_ACTUAL INT,
  DET_SPE_ASS_ALONE_ACTUAL INT,
  DET_SPE_ASS_ASSISTED_ACTUAL INT,
  OTHER_ALONE_ACTUAL INT,
  OTHER_ASSISTED_ACTUAL INT,
  FIREARM_ACTUAL INT,
  KNIFE_ACTUAL INT,
  HANDS_FISTS_FEET_ACTUAL INT,
  OTHER_ACTUAL INT,
  CLEARED_COUNT INT
);

CREATE TABLE public.police_empoloyement_data
(
  DATA_YEAR	smallint,
  AGENCY_ID int,
  ORI varchar(25),
  STATE_ID	smallint,
  STATE_ABBR character(2),
  REGION_CODE	smallint,
  REGION_NAME varchar(100),
	POPULATION int,
  pe_reported_flag	character(1),
  male_officer int,c
  male_civilian int,
  male_total int,
  female_officer int,
  female_civilian int,
  female_total int,
  officer_rate int,
  employee_rate int,
)
