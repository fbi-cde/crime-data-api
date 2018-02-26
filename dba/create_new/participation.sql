CREATE MATERIALIZED VIEW participation_national AS
select data_year as data_year,
SUM(population) as POPULATION,
sum(  CASE  WHEN agency_data.agency_id IS NOT NULL THEN 1  ELSE 0 END) AS total_agency_count,
sum(  CASE  WHEN agency_data.agency_status = 'A' THEN 1  ELSE 0 END) AS active_agency_count,
sum(  CASE WHEN agency_data.covered_flag = 'Y' THEN 1  ELSE 0 END) AS covered_agency_count,
sum(  CASE WHEN agency_data.covered_flag = 'Y' THEN population  ELSE 0 END) AS population_covered,
sum(  CASE  WHEN agency_data.nibrs_start_date IS NOT NULL THEN 1  ELSE 0 END) AS agency_count_nibrs_submitting,
sum(  CASE  WHEN agency_data.nibrs_leoka_start_date IS NOT NULL THEN 1 ELSE 0 END) AS agency_count_leoka_submitting,
sum(  CASE WHEN agency_data.pe_reported_flag IS NOT NULL THEN 1 ELSE 0 END) AS agency_count_pe_submitting,
sum(  CASE WHEN (agency_data.reporting_type::text = 'S'::text) IS NOT NULL THEN 1  ELSE 0 END) AS agency_count_srs_submitting
from public.agency_data WHERE PUBLISHABLE_FLAG='Y' GROUP BY data_year;

CREATE MATERIALIZED VIEW participation_region AS
select data_year as data_year,
region_code as region_code,
region_name as region_name,
SUM(population) as POPULATION,
sum(  CASE  WHEN agency_data.agency_id IS NOT NULL THEN 1  ELSE 0 END) AS total_agency_count,
sum(  CASE  WHEN agency_data.agency_status = 'A' THEN 1  ELSE 0 END) AS active_agency_count,
sum(  CASE WHEN agency_data.covered_flag = 'Y' THEN 1  ELSE 0 END) AS covered_agency_count,
sum(  CASE WHEN agency_data.covered_flag = 'Y' THEN population  ELSE 0 END) AS population_covered,
sum(  CASE  WHEN agency_data.nibrs_start_date IS NOT NULL THEN 1  ELSE 0 END) AS agency_count_nibrs_submitting,
sum(  CASE  WHEN agency_data.nibrs_leoka_start_date IS NOT NULL THEN 1 ELSE 0 END) AS agency_count_leoka_submitting,
sum(  CASE WHEN agency_data.pe_reported_flag IS NOT NULL THEN 1 ELSE 0 END) AS agency_count_pe_submitting,
sum(  CASE WHEN (agency_data.reporting_type::text = 'S'::text) IS NOT NULL THEN 1  ELSE 0 END) AS agency_count_srs_submitting
from public.agency_data WHERE PUBLISHABLE_FLAG='Y' GROUP BY data_year,REGION_CODE,REGION_NAME;

CREATE MATERIALIZED VIEW participation_state AS
select data_year as data_year,
STATE_ID as STATE_ID,
STATE_ABBR as STATE_ABBR,
SUM(population) as POPULATION,
sum(  CASE  WHEN agency_data.agency_id IS NOT NULL THEN 1  ELSE 0 END) AS total_agency_count,
sum(  CASE  WHEN agency_data.agency_status = 'A' THEN 1  ELSE 0 END) AS active_agency_count,
sum(  CASE WHEN agency_data.covered_flag = 'Y' THEN 1  ELSE 0 END) AS covered_agency_count,
sum(  CASE WHEN agency_data.covered_flag = 'Y' THEN population  ELSE 0 END) AS population_covered,
sum(  CASE  WHEN agency_data.nibrs_start_date IS NOT NULL THEN 1  ELSE 0 END) AS agency_count_nibrs_submitting,
sum(  CASE  WHEN agency_data.nibrs_leoka_start_date IS NOT NULL THEN 1 ELSE 0 END) AS agency_count_leoka_submitting,
sum(  CASE WHEN agency_data.pe_reported_flag IS NOT NULL THEN 1 ELSE 0 END) AS agency_count_pe_submitting,
sum(  CASE WHEN (agency_data.reporting_type::text = 'S'::text) IS NOT NULL THEN 1  ELSE 0 END) AS agency_count_srs_submitting
from public.agency_data WHERE PUBLISHABLE_FLAG='Y' GROUP BY data_year,STATE_ID,STATE_ABBR;

CREATE MATERIALIZED VIEW participation_agency AS
select data_year as data_year,
STATE_ID as STATE_ID,
STATE_ABBR as STATE_ABBR,
ori as ori,
population as POPULATION,
COALESCE(  CASE  WHEN agency_data.agency_status = 'A' THEN true  ELSE false END) AS active,
COALESCE(  CASE WHEN agency_data.covered_flag = 'Y' THEN true  ELSE false END) AS covered,
COALESCE(  CASE  WHEN agency_data.nibrs_start_date IS NOT NULL THEN true  ELSE false END) AS nibrs_submittingg,
COALESCE(  CASE  WHEN agency_data.nibrs_start_date IS NOT NULL THEN nibrs_start_date  ELSE null END) AS nibrs_start_date,
COALESCE(  CASE  WHEN agency_data.nibrs_leoka_start_date IS NOT NULL THEN true ELSE false END) AS leoka_submitting,
COALESCE(  CASE  WHEN agency_data.nibrs_leoka_start_date IS NOT NULL THEN nibrs_leoka_start_date ELSE null END) AS nibrs_leoka_start_date,
COALESCE(  CASE WHEN agency_data.pe_reported_flag IS NOT NULL THEN pe_reported_flag ELSE null END) AS pe_reported_flag,
COALESCE(  CASE WHEN (agency_data.reporting_type::text = 'S'::text) IS NOT NULL THEN true  ELSE false END) AS srs_submitting
from public.agency_data WHERE PUBLISHABLE_FLAG='Y' GROUP BY data_year,STATE_ID,STATE_ABBR,ori,pe_reported_flag,reporting_type,population,agency_status,covered_flag,nibrs_start_date,nibrs_leoka_start_date;
