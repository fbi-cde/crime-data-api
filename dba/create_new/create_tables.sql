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

CREATE TABLE public.leoka_assault_activity_assignemnt_data
(
  DATA_YEAR INT,
  AGENCY_ID INT,
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

CREATE TABLE public.leoka_assault_time_injury_data
(
  DATA_YEAR INT,
  AGENCY_ID INT,
  TIME_0001_0200_CNT INT,
  TIME_0201_0400_CNT INT,
  TIME_0401_0600_CNT INT,
  TIME_0601_0800_CNT INT,
  TIME_0801_1000_CNT INT,
  TIME_1001_1200_CNT INT,
  TIME_1201_1400_CNT INT,
  TIME_1401_1600_CNT INT,
  TIME_1601_1800_CNT INT,
  TIME_1801_2000_CNT INT,
  TIME_2001_2200_CNT INT,
  TIME_2201_0000_CNT INT,
  FIREARM_INJURY_CNT INT,
  FIREARM_NO_INJURY_CNT INT,
  KNIFE_INJURY_CNT INT,
  KNIFE_NO_INJURY_CNT INT,
  HANDS_FISTS_FEET_INJURY_CNT INT,
  HANDS_FISTS_FEET_NO_INJURY_CNT INT,
  OTHER_INJURY_CNT INT,
  OTHER_NO_INJURY_CNT INT,
  LEOKA_FELONY_KILLED INT,
  LEOKA_ACCIDENT_KILLED INT
);

CREATE TABLE public.agency_data
(
  YEARLY_AGENCY_ID int,
  AGENCY_ID int,
  DATA_YEAR int,
  ORI varchar(25),
  LEGACY_ORI varchar(25),
  COVERED_BY_LEGACY_ORI varchar(25),
  DIRECT_CONTRIBUTOR_FLAG varchar(1),
  DORMANT_FLAG varchar(1),
  DORMANT_YEAR int,
  REPORTING_TYPE varchar(1),
  UCR_AGENCY_NAME varchar(100),
  NCIC_AGENCY_NAME varchar(100),
  PUB_AGENCY_NAME varchar(100),
  PUB_AGENCY_UNIT varchar(100),
  AGENCY_STATUS varchar(1),
  STATE_ID int,
  STATE_NAME varchar(100),
  STATE_ABBR varchar(2),
  STATE_POSTAL_ABBR varchar(2),
  DIVISION_CODE int,
  DIVISION_NAME varchar(100),
  REGION_CODE int,
  REGION_NAME varchar(100),
  REGION_DESC varchar(100),
  AGENCY_TYPE_NAME varchar(100),
  POPULATION int,
  SUBMITTING_AGENCY_ID int,
  SAI varchar(25),
  SUBMITTING_AGENCY_NAME varchar(200),
  SUBURBAN_AREA_FLAG varchar(1),
  POPULATION_GROUP_ID int,
  POPULATION_GROUP_CODE varchar(2),
  POPULATION_GROUP_DESC varchar(100),
  PARENT_POP_GROUP_CODE int,
  PARENT_POP_GROUP_DESC varchar(100),
  MIP_FLAG varchar(1),
  POP_SORT_ORDER int,
  SUMMARY_RAPE_DEF varchar(1),
  PE_REPORTED_FLAG varchar(1),
  PE_OFFICER_COUNT int,
  PE_CIVILIAN_COUNT int,
  NIBRS_CERT_DATE date,
  NIBRS_START_DATE date,
  NIBRS_LEOKA_START_DATE date,
  NIBRS_CT_START_DATE date,
  NIBRS_MULTI_BIAS_START_DATE date,
  NIBRS_OFF_ETH_START_DATE date,
  COVERED_FLAG varchar(1),
  COUNTY_NAME varchar(100),
  MSA_NAME varchar(100),
  MALE_OFFICER int,
  MALE_CIVILIAN int,
  MALE_TOTAL int,
  FEMALE_OFFICER int,
  FEMALE_CIVILIAN int,
  FEMALE_TOTAL int,
  OFFICER_RATE int,
  EMPLOYEE_RATE int
);
