CREATE MATERIALIZED VIEW police_employment_nation AS
  SELECT
    data_year as data_year,
    SUM(CASE WHEN month_num = 12 THEN population ELSE 0 END) as population,
    SUM(male_officer) as male_officer_ct,
    SUM(male_civilian) as male_civilian_ct,
    SUM(male_total) as male_total_ct,
    SUM(female_officer) as female_officer_ct,
    SUM(female_civilian) as female_civilian_ct,
    SUM(female_total) as female_total_ct,
    SUM(male_officer)+SUM(female_officer) as officer_ct,
    SUM(male_civilian)+SUM(female_civilian) as civilian_ct,
    SUM(male_total)+SUM(female_total) as total_pe_ct,
    ROUND(((SUM(male_total)+SUM(female_total))*1.0 / SUM(CASE WHEN month_num = 12 THEN population ELSE 0 END))*1000,2) as pe_ct_per_1000
  FROM public.summarized_data
  GROUP BY data_year;

CREATE MATERIALIZED VIEW police_employment_region AS
  SELECT
    region_code as region_code,
    region_name as region_name,
    data_year as data_year,
    SUM(CASE WHEN month_num = 12 THEN population ELSE 0 END) as population,
    SUM(male_officer) as male_officer_ct,
    SUM(male_civilian) as male_civilian_ct,
    SUM(male_total) as male_total_ct,
    SUM(female_officer) as female_officer_ct,
    SUM(female_civilian) as female_civilian_ct,
    SUM(female_total) as female_total_ct,
    SUM(male_officer)+SUM(female_officer) as officer_ct,
    SUM(male_civilian)+SUM(female_civilian) as civilian_ct,
    SUM(male_total)+SUM(female_total) as total_pe_ct,
    ROUND(((SUM(male_total)+SUM(female_total))*1.0 / NULLIF(SUM(CASE WHEN month_num = 12 THEN population ELSE 0 END),0))*1000,2) as pe_ct_per_1000
  FROM public.summarized_data
  GROUP BY region_code, region_name, data_year;

CREATE MATERIALIZED VIEW police_employment_state AS
  SELECT
    state_id as state_id,
    state_name as state_name,
    state_abbr as state_abbr,
    data_year as data_year,
    SUM(CASE WHEN month_num = 12 THEN population ELSE 0 END) as population,
    SUM(male_officer) as male_officer_ct,
    SUM(male_civilian) as male_civilian_ct,
    SUM(male_total) as male_total_ct,
    SUM(female_officer) as female_officer_ct,
    SUM(female_civilian) as female_civilian_ct,
    SUM(female_total) as female_total_ct,
    SUM(male_officer)+SUM(female_officer) as officer_ct,
    SUM(male_civilian)+SUM(female_civilian) as civilian_ct,
    SUM(male_total)+SUM(female_total) as total_pe_ct,
    ROUND(((SUM(male_total)+SUM(female_total))*1.0 / NULLIF(SUM(CASE WHEN month_num = 12 THEN population ELSE 0 END),0))*1000,2) as pe_ct_per_1000
  FROM public.summarized_data
  GROUP BY state_id, state_name, state_abbr, data_year;

CREATE MATERIALIZED VIEW police_employment_agency AS
  SELECT
    ori as ori,
    ncic_agency_name as ncic_agency_name,
    agency_name_edit as agency_name_edit,
    agency_type_name as agency_type_name,
    state_abbr as state_abbr,
    data_year as data_year,
    SUM(CASE WHEN month_num = 12 THEN population ELSE 0 END) as population,
    SUM(male_officer) as male_officer_ct,
    SUM(male_civilian) as male_civilian_ct,
    SUM(male_total) as male_total_ct,
    SUM(female_officer) as female_officer_ct,
    SUM(female_civilian) as female_civilian_ct,
    SUM(female_total) as female_total_ct,
    SUM(male_officer)+SUM(female_officer) as officer_ct,
    SUM(male_civilian)+SUM(female_civilian) as civilian_ct,
    SUM(male_total)+SUM(female_total) as total_pe_ct,
    ROUND(((SUM(male_total)+SUM(female_total))*1.0 / NULLIF(SUM(CASE WHEN month_num = 12 THEN population ELSE 0 END),0))*1000,2) as pe_ct_per_1000
  FROM public.summarized_data
GROUP BY ori, ncic_agency_name, agency_name_edit, agency_type_name, state_abbr, data_year;
