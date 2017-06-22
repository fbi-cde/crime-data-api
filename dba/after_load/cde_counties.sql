DROP TABLE IF EXISTS cde_counties_temp;
CREATE TABLE cde_counties_temp (
  county_id bigint PRIMARY KEY,
  fips character varying(5),
  county_name character varying(100),
  state_id smallint,
  state_name character varying(100),
  state_abbr character varying(2),
  current_year smallint,
  total_population bigint,
  total_agencies int,
  participating_agencies int,
  nibrs_participating_agencies int,
  covered_agencies int,
  participating_population bigint
);


INSERT INTO cde_counties_temp
SELECT
rc.county_id,
CASE WHEN rc.county_fips_code::int > 0 THEN LPAD(rs.state_fips_code, 2, '0') || LPAD(rc.county_fips_code, 3, '0') ELSE NULL END AS fips,
INITCAP(rc.county_name) AS county_name,
rs.state_id,
rs.state_name,
rs.state_postal_abbr AS state_abbr,
pc.year AS current_year,
pc.total_population,
pc.total_agencies,
pc.participating_agencies,
pc.nibrs_participating_agencies,
pc.covered_agencies,
pc.participating_population
FROM ref_county rc
JOIN ref_state rs ON rs.state_id=rc.state_id
LEFT OUTER JOIN (SELECT DISTINCT ON (county_id) county_id, year, total_population, total_agencies, participating_agencies, nibrs_participating_agencies, covered_agencies, participating_population from participation_rates pr ORDER by county_id, year DESC) pc ON pc.county_id=rc.county_id;

-- overrides
update cde_counties_temp
SET county_name='DeKalb'
WHERE fips IN ('01049', '13089');

update cde_counties_temp
SET county_name='DeSoto'
WHERE fips='12027';

DROP TABLE IF EXISTS cde_counties;
ALTER TABLE cde_counties_temp RENAME TO cde_counties;
