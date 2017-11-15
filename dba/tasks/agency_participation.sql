DROP TABLE IF EXISTS agency_participation CASCADE;
CREATE TABLE agency_participation AS
SELECT
ar.data_year AS year,
rs.state_name AS state_name,
rs.state_postal_abbr AS state_abbr,
ar.agency_id,
ra.ori as agency_ori,
ra.pub_agency_name as agency_name,
rap.population AS agency_population,
rpg.population_group_code AS population_group_code,
rpg.population_group_desc AS population_group,
CASE WHEN ar.months_reported = 12 THEN 1 ELSE 0 END AS reported,
COALESCE(ar.months_reported, 0) AS months_reported,
CASE WHEN nr.months_reported = 12 THEN 1 ELSE 0 END AS nibrs_reported,
COALESCE(nr.months_reported, 0) AS nibrs_months_reported,
CASE WHEN racbf.agency_id IS NOT NULL THEN 1 ELSE 0 END AS covered,
CASE WHEN ar.months_reported = 12 OR covered_ar.months_reported = 12 THEN 1 ELSE 0 END AS participated,
CASE WHEN nr.months_reported = 12 OR covered_nr.months_reported = 12 THEN 1 ELSE 0 END AS nibrs_participated
FROM temp_agency_reporting ar
JOIN ref_agency ra ON ra.agency_id=ar.agency_id
JOIN ref_state rs ON rs.state_id=ra.state_id
LEFT OUTER JOIN temp_agency_reporting_nibrs nr ON ar.agency_id=nr.agency_id AND ar.data_year=nr.data_year
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id=ar.agency_id AND rap.data_year=ar.data_year
LEFT OUTER JOIN ref_population_group rpg ON rpg.population_group_id = rap.population_group_id
LEFT OUTER JOIN ref_agency_covered_by_flat racbf ON racbf.agency_id=ar.agency_id AND racbf.data_year=ar.data_year
LEFT OUTER JOIN temp_agency_reporting covered_ar ON covered_ar.agency_id=racbf.covered_by_agency_id AND covered_ar.data_year=racbf.data_year
LEFT OUTER JOIN temp_agency_reporting_nibrs covered_nr ON covered_nr.agency_id=racbf.covered_by_agency_id AND covered_nr.data_year=racbf.data_year
ORDER by ar.data_year, rs.state_name, ra.pub_agency_name;

ALTER TABLE ONLY agency_participation
ADD CONSTRAINT agency_participation_pk PRIMARY KEY (year, agency_id);
