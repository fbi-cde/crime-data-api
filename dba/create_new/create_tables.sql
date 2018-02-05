CREATE TABLE public.region_lk
(
  region_code smallint PRIMARY KEY,
  region_name character varying(50),
  region_desc character varying(100)
);

CREATE TABLE state_lk (
state_id int PRIMARY KEY,
STATE_ABBR character(2),
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

CREATE TABLE asr_data (
  DATA_YEAR int,
  AGENCY_ID int,
  OFFENSE_SUBCAT_ID int,
  OFFENSE_SUBCAT_NAME varchar(100),
  M_AGE_UNDER_10_ARR_CNT int,
  M_AGE_10_TO_12_ARR_CNT int,
  M_AGE_13_TO_14_ARR_CNT int,
  M_AGE_15_ARR_CNT int,
  M_AGE_16_ARR_CNT int,
  M_AGE_17_ARR_CNT int,
  M_AGE_18_ARR_CNT int,
  M_AGE_19_ARR_CNT int,
  M_AGE_20_ARR_CNT int,
  M_AGE_21_ARR_CNT int,
  M_AGE_22_ARR_CNT int,
  M_AGE_23_ARR_CNT int,
  M_AGE_24_ARR_CNT int,
  M_AGE_25_TO_29_ARR_CNT int,
  M_AGE_30_TO_34_ARR_CNT int,
  M_AGE_35_TO_39_ARR_CNT int,
  M_AGE_40_TO_44_ARR_CNT int,
  M_AGE_45_TO_49_ARR_CNT int,
  M_AGE_50_TO_54_ARR_CNT int,
  M_AGE_55_TO_59_ARR_CNT int,
  M_AGE_60_TO_64_ARR_CNT int,
  M_AGE_OVER_64_ARR_CNT int,
  F_AGE_UNDER_10_ARR_CNT int,
  F_AGE_10_TO_12_ARR_CNT int,
  F_AGE_13_TO_14_ARR_CNT int,
  F_AGE_15_ARR_CNT int,
  F_AGE_16_ARR_CNT int,
  F_AGE_17_ARR_CNT int,
  F_AGE_18_ARR_CNT int,
  F_AGE_19_ARR_CNT int,
  F_AGE_20_ARR_CNT int,
  F_AGE_21_ARR_CNT int,
  F_AGE_22_ARR_CNT int,
  F_AGE_23_ARR_CNT int,
  F_AGE_24_ARR_CNT int,
  F_AGE_25_TO_29_ARR_CNT int,
  F_AGE_30_TO_34_ARR_CNT int,
  F_AGE_35_TO_39_ARR_CNT int,
  F_AGE_40_TO_44_ARR_CNT int,
  F_AGE_45_TO_49_ARR_CNT int,
  F_AGE_50_TO_54_ARR_CNT int,
  F_AGE_55_TO_59_ARR_CNT int,
  F_AGE_60_TO_64_ARR_CNT int,
  F_AGE_OVER_64_ARR_CNT int,
  ETH_HIS_LAT_ARR_CNT int,
  ETH_NOT_HIS_LAT_ARR_CNT int,
  ETH_UNK_ARR_CNT int,
  ETH_HIS_LAT_YTH_ARR_CNT int,
  ETH_NOT_HIS_LAT_YTH_ARR_CNT int,
  ETH_UNK_YTH_ARR_CNT int,
  RACE_UNKNOWN_ARR_CNT int,
  RACE_WHITE_ARR_CNT int,
  RACE_BLACK_ARR_CNT int,
  RACE_AMIAN_ARR_CNT int,
  RACE_ASIAN_ARR_CNT int,
  RACE_ANHOPI_ARR_CNT int,
  RACE_CHINESE_ARR_CNT int,
  RACE_JAPANESE_ARR_CNT int,
  RACE_NHOPI_ARR_CNT int,
  RACE_OTHER_ARR_CNT int,
  RACE_MULTIPLE_ARR_CNT int,
  RACE_NOT_SPECIFIED_ARR_CNT int,
  RACE_UNKNOWN_YTH_ARR_CNT int,
  RACE_WHITE_YTH_ARR_CNT int,
  RACE_BLACK_YTH_ARR_CNT int,
  RACE_AMIAN_YTH_ARR_CNT int,
  RACE_ASIAN_YTH_ARR_CNT int,
  RACE_ANHOPI_YTH_ARR_CNT int,
  RACE_CHINESE_YTH_ARR_CNT int,
  RACE_JAPANESE_YTH_ARR_CNT int,
  RACE_NHOPI_YTH_ARR_CNT int,
  RACE_OTHER_YTH_ARR_CNT int,
  RACE_MULTIPLE_YTH_ARR_CNT int,
  RACE_NOT_SPECIFIED_YTH_ARR_CNT int
);
