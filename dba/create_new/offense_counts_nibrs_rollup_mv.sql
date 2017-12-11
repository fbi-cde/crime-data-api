CREATE MATERIALIZED VIEW nibrs_national_denorm_offense_count AS
select
offense_name as offense_name,
data_year as data_year,
sum(incident_count) as incident_count,
sum(offense_count) as offense_count
from public.nibrs_offense_count group by offense_name, data_year;


CREATE MATERIALIZED VIEW nibrs_state_denorm_offense_count AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
sum(incident_count) as incident_count,
sum(offense_count) as offense_count
from public.nibrs_offense_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_offense_count AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
sum(incident_count) as incident_count,
sum(offense_count) as offense_count
from public.nibrs_offense_count group by agency_id, ori, offense_name, data_year;

REFRESH MATERIALIZED VIEW nibrs_agency_denorm_offense_count;
REFRESH MATERIALIZED VIEW nibrs_state_denorm_offense_count;
REFRESH MATERIALIZED VIEW nibrs_national_denorm_offense_count;
