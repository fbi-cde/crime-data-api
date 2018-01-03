CREATE MATERIALIZED VIEW shr_state_homicide_victim_count AS
select  state_id as state_id,
state_abbr as state_abbr,
data_year as data_year,
sum(count) as count
from public.shr_expanded_homicide_victim_count group by state_id, state_abbr, data_year;

CREATE MATERIALIZED VIEW shr_national_homicide_victim_count AS
select
data_year as data_year,
sum(count) as count
from public.shr_expanded_homicide_victim_count group by data_year;


CREATE MATERIALIZED VIEW shr_state_homicide_victim_sex AS
select  state_id as state_id,
state_abbr as state_abbr,
data_year as data_year,
coalesce(sum(case when sex_code = 'M' then count end), 0) as male_count,
coalesce(sum(case when sex_code = 'F' then count end), 0) as female_count,
coalesce(sum(case when sex_code = 'U' then count end), 0) as unknown_count,
coalesce(sum(case when sex_code = 'NR' or sex_code = 'nr' then count end), 0) as not_reported
from public.shr_expanded_homicide_victim_count group by state_id, state_abbr, data_year;

CREATE MATERIALIZED VIEW shr_national_homicide_victim_sex AS
select
data_year as data_year,
coalesce(sum(case when sex_code = 'M' then count end), 0) as male_count,
coalesce(sum(case when sex_code = 'F' then count end), 0) as female_count,
coalesce(sum(case when sex_code = 'U' then count end), 0) as unknown_count,
coalesce(sum(case when sex_code = 'NR' or sex_code = 'nr' then count end), 0) as not_reported
from public.shr_expanded_homicide_victim_count group by data_year;

CREATE MATERIALIZED VIEW shr_state_homicide_victim_race AS
select  state_id as state_id,
state_abbr as state_abbr,
data_year as data_year,
coalesce(sum(case when race_desc = 'Asian' then count end), 0) as asian,
coalesce(sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
coalesce(sum(case when race_desc = 'Black or African American' then count end), 0) as black,
coalesce(sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
coalesce(sum(case when race_desc = 'Unknown' or race_desc = 'UNKNOW' then count end), 0) as unknown,
coalesce(sum(case when race_desc = 'White' then count end), 0) as white,
coalesce(sum(case when race_desc = 'NR' or race_desc = 'nr' then count end), 0) as not_reported
from public.shr_expanded_homicide_victim_count group by state_id, state_abbr, data_year;

CREATE MATERIALIZED VIEW shr_national_homicide_victim_race AS
select data_year as data_year,
coalesce(sum(case when race_desc = 'Asian' then count end), 0) as asian,
coalesce(sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
coalesce(sum(case when race_desc = 'Black or African American' then count end), 0) as black,
coalesce(sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
coalesce(sum(case when race_desc = 'Unknown' or race_desc = 'UNKNOW' then count end), 0) as unknown,
coalesce(sum(case when race_desc = 'White' then count end), 0) as white,
coalesce(sum(case when race_desc = 'NR' or race_desc = 'nr' then count end), 0) as not_reported
from public.shr_expanded_homicide_victim_count group by  data_year;

CREATE MATERIALIZED VIEW shr_state_homicide_victim_age AS
select  state_id as state_id,
state_abbr as state_abbr,
data_year as data_year,
coalesce(sum(case when age_range = '0-9' then count end), 0) as range_0_9,
coalesce(sum(case when age_range = '10-19' then count end), 0) as range_10_19,
coalesce(sum(case when age_range = '20-29' then count end), 0) as range_20_29,
coalesce(sum(case when age_range = '30-39' then count end), 0) as range_30_39,
coalesce(sum(case when age_range = '40-49' then count end), 0) as range_40_49,
coalesce(sum(case when age_range = '50-59' then count end), 0) as range_50_59,
coalesce(sum(case when age_range = '60-69' then count end), 0) as range_60_69,
coalesce(sum(case when age_range = '70-79' then count end), 0) as range_70_79,
coalesce(sum(case when age_range = '80-89' then count end), 0) as range_80_89,
coalesce(sum(case when age_range = '90-99' then count end), 0) as range_90_99,
coalesce(sum(case when age_range = 'UNKNOWN' or age_range = 'Unknown' then count end), 0) as unknown,
coalesce(sum(case when age_range = 'NR' or age_range = 'nr' then count end), 0) as not_reported
from public.shr_expanded_homicide_victim_count group by state_id, state_abbr, data_year;

CREATE MATERIALIZED VIEW shr_national_homicide_victim_age AS
select
data_year as data_year,
coalesce(sum(case when age_range = '0-9' then count end), 0) as range_0_9,
coalesce(sum(case when age_range = '10-19' then count end), 0) as range_10_19,
coalesce(sum(case when age_range = '20-29' then count end), 0) as range_20_29,
coalesce(sum(case when age_range = '30-39' then count end), 0) as range_30_39,
coalesce(sum(case when age_range = '40-49' then count end), 0) as range_40_49,
coalesce(sum(case when age_range = '50-59' then count end), 0) as range_50_59,
coalesce(sum(case when age_range = '60-69' then count end), 0) as range_60_69,
coalesce(sum(case when age_range = '70-79' then count end), 0) as range_70_79,
coalesce(sum(case when age_range = '80-89' then count end), 0) as range_80_89,
coalesce(sum(case when age_range = '90-99' then count end), 0) as range_90_99,
coalesce(sum(case when age_range = 'UNKNOWN' or age_range = 'Unknown' then count end), 0) as unknown,
coalesce(sum(case when age_range = 'NR' or age_range = 'nr' then count end), 0) as not_reported
from public.shr_expanded_homicide_victim_count group by data_year;


CREATE MATERIALIZED VIEW shr_state_homicide_victim_ethnicity AS
select  state_id as state_id,
state_abbr as state_abbr,
data_year as data_year,
coalesce(sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
coalesce(sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
coalesce(sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
coalesce(sum(case when ethnicity_name = 'Unknown' or ethnicity_name = 'UNKNOW'then count end), 0) as unknown,
coalesce(sum(case when ethnicity_name = 'NR' or ethnicity_name = 'nr' then count end), 0) as not_reported
from public.shr_expanded_homicide_victim_count group by state_id, state_abbr, data_year;

CREATE MATERIALIZED VIEW shr_national_homicide_victim_ethnicity AS
select data_year as data_year,
coalesce(sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
coalesce(sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
coalesce(sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
coalesce(sum(case when ethnicity_name = 'Unknown' or ethnicity_name = 'UNKNOW' then count end), 0) as unknown,
coalesce(sum(case when ethnicity_name = 'NR' or ethnicity_name = 'nr' then count end), 0) as not_reported
from public.shr_expanded_homicide_victim_count group by  data_year;

REFRESH MATERIALIZED VIEW shr_national_homicide_victim_ethnicity;
REFRESH MATERIALIZED VIEW shr_state_homicide_victim_ethnicity;
REFRESH MATERIALIZED VIEW shr_national_homicide_victim_age;
REFRESH MATERIALIZED VIEW shr_state_homicide_victim_age;
REFRESH MATERIALIZED VIEW shr_national_homicide_victim_race;
REFRESH MATERIALIZED VIEW shr_state_homicide_victim_race;
REFRESH MATERIALIZED VIEW shr_national_homicide_victim_sex;
REFRESH MATERIALIZED VIEW shr_state_homicide_victim_sex;
refresh MATERLIZED VIEW shr_national_homicide_victim_count;
refresh MATERLIZED VIEW shr_state_homicide_victim_count;
