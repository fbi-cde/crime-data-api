CREATE TABLE state_lk (
state_id int PRIMARY KEY,
STATE_ABBR character(4),
STATE_NAME varchar(50),
STATE_FIPS_CODE int
);

CREATE TABLE public.region_lk
(
  region_code smallint PRIMARY KEY,
  region_name character varying(50),
  region_desc character varying(100)
)

CREATE TABLE region_state_lk (
state_id int REFERENCES state_lk(state_id),
region_code smallint REFERENCES region_lk(region_code)
);
