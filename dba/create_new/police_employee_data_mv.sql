CREATE MATERIALIZED VIEW police_employment_nation AS
SELECT
  data_year as data_year,
  SUM(population) as population,
  SUM(male_officer) as male_officer_ct,
  SUM(male_civilian) as male_civilian_ct,
  SUM(male_total) as male_total_ct,
  SUM(female_officer) as female_officer_ct,
  SUM(female_civilian) as female_civilian_ct,
  SUM(female_total) as female_total_ct,
  SUM(male_officer)+SUM(female_officer) as officer_ct,
  SUM(male_civilian)+SUM(female_civilian) as civilian_ct,
  SUM(male_total)+SUM(female_total) as total_pe_ct,
  ROUND(((SUM(male_total)+SUM(female_total))*1.0 / SUM(population))*1000,2) as pe_ct_per_1000
FROM public.agency_data
GROUP BY data_year
ORDER BY data_year;

CREATE MATERIALIZED VIEW police_employment_region AS
SELECT
  region_code as region_code,
  region_name as region_name,
  data_year as data_year,
  SUM(population) as population,
  SUM(male_officer) as male_officer_ct,
  SUM(male_civilian) as male_civilian_ct,
  SUM(male_total) as male_total_ct,
  SUM(female_officer) as female_officer_ct,
  SUM(female_civilian) as female_civilian_ct,
  SUM(female_total) as female_total_ct,
  SUM(male_officer)+SUM(female_officer) as officer_ct,
  SUM(male_civilian)+SUM(female_civilian) as civilian_ct,
  SUM(male_total)+SUM(female_total) as total_pe_ct,
  ROUND(((SUM(male_total)+SUM(female_total))*1.0 / NULLIF(SUM(population),0))*1000,2) as pe_ct_per_1000
FROM public.agency_data
GROUP BY region_code, region_name, data_year
ORDER BY data_year, region_code;

CREATE MATERIALIZED VIEW police_employment_state AS
SELECT
  state_id as state_id,
  state_name as state_name,
  state_abbr as state_abbr,
  data_year as data_year,
  SUM(population) as population,
  SUM(male_officer) as male_officer_ct,
  SUM(male_civilian) as male_civilian_ct,
  SUM(male_total) as male_total_ct,
  SUM(female_officer) as female_officer_ct,
  SUM(female_civilian) as female_civilian_ct,
  SUM(female_total) as female_total_ct,
  SUM(male_officer)+SUM(female_officer) as officer_ct,
  SUM(male_civilian)+SUM(female_civilian) as civilian_ct,
  SUM(male_total)+SUM(female_total) as total_pe_ct,
  ROUND(((SUM(male_total)+SUM(female_total))*1.0 / NULLIF(SUM(population),0))*1000,2) as pe_ct_per_1000
FROM public.agency_data
GROUP BY state_id, state_name, state_abbr, data_year
ORDER BY data_year, state_abbr;

CREATE MATERIALIZED VIEW police_employment_agency AS
SELECT
  ori as ori,
  ncic_agency_name as ncic_agency_name,
  ncic_agency_name as agency_name_edit,
  agency_type_name as agency_type_name,
  state_abbr as state_abbr,
  data_year as data_year,
  population as population,
  male_officer as male_officer_ct,
  male_civilian as male_civilian_ct,
  male_total as male_total_ct,
  female_officer as female_officer_ct,
  female_civilian as female_civilian_ct,
  female_total as female_total_ct,
  male_officer+female_officer as officer_ct,
  male_civilian+female_civilian as civilian_ct,
  male_total+female_total as total_pe_ct,
  ROUND(((male_total+female_total)*1.0 / NULLIF(population,0))*1000,2) as pe_ct_per_1000
FROM public.agency_data
ORDER BY data_year, ori;
