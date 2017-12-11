CREATE MATERIALIZED VIEW nibrs_state_denorm_offender_sex AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when sex_code = 'M' then count end), 0) as male_count,
coalesce(sum(case when sex_code = 'F' then count end), 0) as female_count,
coalesce(sum(case when sex_code = 'U' then count end), 0) as unknown_count
from public.nibrs_offender_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_offender_count AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
sum(count) as count
from public.nibrs_offender_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_offender_race AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when race_desc = 'Asian' then count end), 0) as asian,
coalesce(sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
coalesce(sum(case when race_desc = 'Black or African American' then count end), 0) as black,
coalesce(sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
coalesce(sum(case when race_desc = 'Unknown' then count end), 0) as unknown,
coalesce(sum(case when race_desc = 'White' then count end), 0) as white
from public.nibrs_offender_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_offender_ethnicity AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
coalesce(sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
coalesce(sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
coalesce(sum(case when ethnicity_name = 'Unknown' then count end), 0) as unknown
from public.nibrs_offender_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_offender_age AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
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
coalesce(sum(case when age_range = 'Unknown' then count end), 0) as unknown
from public.nibrs_offender_count group by state_id, state_abbr, offense_name, data_year;


CREATE MATERIALIZED VIEW nibrs_national_denorm_offender_sex AS
select
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when sex_code = 'M' then count end), 0) as male_count,
coalesce(sum(case when sex_code = 'F' then count end), 0) as female_count,
coalesce(sum(case when sex_code = 'U' then count end), 0) as unknown_count
from public.nibrs_offender_count group by offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_offender_count AS
select
offense_name as offense_name,
data_year as data_year,
sum(count) as count
from public.nibrs_offender_count group by offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_offender_race AS
select
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when race_desc = 'Asian' then count end), 0) as asian,
coalesce(sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
coalesce(sum(case when race_desc = 'Black or African American' then count end), 0) as black,
coalesce(sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
coalesce(sum(case when race_desc = 'Unknown' then count end), 0) as unknown,
coalesce(sum(case when race_desc = 'White' then count end), 0) as white
from public.nibrs_offender_count group by  offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_offender_ethnicity AS
select
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
coalesce(sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
coalesce(sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
coalesce(sum(case when ethnicity_name = 'Unknown' then count end), 0) as unknown
from public.nibrs_offender_count group by offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_offender_age AS
select
offense_name as offense_name,
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
coalesce(sum(case when age_range = 'Unknown' then count end), 0) as unknown
from public.nibrs_offender_count group by offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_offender_sex AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when sex_code = 'M' then count end), 0) as male_count,
coalesce(sum(case when sex_code = 'F' then count end), 0) as female_count,
coalesce(sum(case when sex_code = 'U' then count end), 0) as unknown_count
from public.nibrs_offender_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_offender_count AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
sum(count) as count
from public.nibrs_offender_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_offender_race AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when race_desc = 'Asian' then count end), 0) as asian,
coalesce(sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
coalesce(sum(case when race_desc = 'Black or African American' then count end), 0) as black,
coalesce(sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
coalesce(sum(case when race_desc = 'Unknown' then count end), 0) as unknown,
coalesce(sum(case when race_desc = 'White' then count end), 0) as white
from public.nibrs_offender_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_offender_ethnicity AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
coalesce(sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
coalesce(sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
coalesce(sum(case when ethnicity_name = 'Unknown' then count end), 0) as unknown
from public.nibrs_offender_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_offender_age AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
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
coalesce(sum(case when age_range = 'Unknown' then count end), 0) as unknown
from public.nibrs_offender_count group by agency_id, ori, offense_name, data_year;

REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_offender_age;
REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_offender_ethnicity;
REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_offender_race;
REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_offender_count;
REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_offender_sex;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_offender_age;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_offender_ethnicity;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_offender_race;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_offender_count;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_offender_sex;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_offender_age;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_offender_ethnicity;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_offender_race;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_offender_count;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_offender_sex;

UPDATE nibrs_offender_count
SET  state_abbr = TRIM(state_abbr),ori = TRIM(ori),
offense_name = TRIM(offense_name),sex_code = TRIM(sex_code),
age_range = TRIM(age_range),race_desc = TRIM(race_desc),ethnicity_name = TRIM(ethnicity_name)
