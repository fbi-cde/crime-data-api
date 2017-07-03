DROP TABLE IF EXISTS cde_states_temp;
CREATE TABLE cde_states_temp (
  state_id int PRIMARY KEY,
  state_name text,
  state_abbr character varying(2),
  current_year smallint,
  total_population bigint,
  total_agencies int,
  participating_agencies int,
  participation_pct numeric(5,2),
  nibrs_participating_agencies int,
  nibrs_participation_pct numeric(5,2),
  covered_agencies int,
  covered_pct numeric(5,2),
  participating_population bigint,
  participating_population_pct numeric(5,2),
  nibrs_participating_population bigint,
  nibrs_population_pct numeric,
  police_officers integer,
  civilian_employees integer
);


WITH pe_staffing AS (SELECT state_id, COALESCE(SUM(ped.male_officer)+SUM(ped.female_officer)) AS total_officers, COALESCE(SUM(ped.male_civilian)+SUM(ped.female_civilian)) AS total_civilians
                     FROM pe_employee_data ped
                     JOIN ref_agency ra ON ra.agency_id = ped.agency_id
                     WHERE ped.reported_flag='Y' AND ped.data_year=(SELECT MAX(current_year) from cde_agencies) GROUP BY ra.state_id)
INSERT INTO cde_states_temp
SELECT
rs.state_id,
rs.state_name,
rs.state_postal_abbr AS state_abbr,
ps.year AS current_year,
ps.total_population,
ps.total_agencies,
ps.participating_agencies,
CASE WHEN ps.total_agencies > 0 THEN CAST(100*ps.participating_agencies AS numeric)/ps.total_agencies ELSE 0 END AS participation_pct,
ps.nibrs_participating_agencies,
CASE WHEN ps.total_agencies > 0 THEN CAST(100*ps.nibrs_participating_agencies AS numeric)/ps.total_agencies ELSE 0 END AS nibrs_participation_pct,
ps.covered_agencies,
CASE WHEN ps.total_agencies > 0 THEN CAST(100*ps.covered_agencies AS numeric)/ps.total_agencies ELSE 0 END AS covered_pct,
ps.participating_population,
CASE WHEN ps.total_population > 0 THEN CAST(100*ps.participating_population AS numeric)/ps.total_population ELSE 0 END as participating_population_pct,
ps.nibrs_participating_population,
CASE WHEN ps.total_population > 0 THEN CAST(100*ps.nibrs_participating_population AS numeric)/ps.total_population ELSE 0 END as nibrs_participating_population_pct,
pe.total_officers,
pe.total_civilians
FROM ref_state rs
LEFT OUTER JOIN (SELECT DISTINCT ON (state_id) state_id, year, total_population, total_agencies, participating_agencies, nibrs_participating_agencies, covered_agencies, participating_population, nibrs_participating_population FROM participation_rates pr WHERE state_id IS NOT NULL AND county_id IS NULL ORDER by state_id, year DESC) ps ON ps.state_id = rs.state_id
LEFT OUTER JOIN pe_staffing pe ON pe.state_id = rs.state_id;
DROP TABLE IF EXISTS cde_states;
ALTER TABLE cde_states_temp RENAME TO cde_states;
