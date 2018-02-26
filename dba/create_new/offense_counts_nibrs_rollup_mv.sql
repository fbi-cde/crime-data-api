CREATE MATERIALIZED VIEW nibrs_national_denorm_offense_count AS
select
offense_name as offense_name,
data_year as data_year,
sum(incident_count) as incident_count,
sum(offense_count) as offense_count
from public.nibrs_offense_count group by offense_name, data_year;


CREATE MATERIALIZED VIEW nibrs_region_denorm_offense_count AS
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

--region
CREATE MATERIALIZED VIEW nibrs_state_denorm_offense_count AS
select  s.region_code as region_code,
r.region_name as region_name,
n.offense_name as offense_name,
n.data_year as data_year,
sum(n.incident_count) as incident_count,
sum(n.offense_count) as offense_count
from public.nibrs_offense_count n, public.state_lk s,public.region_lk r
where s.region_code = r.region_code
group by s.region_code,r.region_name, n.offense_name, n.data_year;;

UPDATE nibrs_offense_count
SET  state_abbr = TRIM(state_abbr),ori = TRIM(ori),
offense_name = TRIM(offense_name),
