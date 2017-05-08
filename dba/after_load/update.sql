
SET work_mem='3GB';
SET synchronous_commit TO OFF;

DROP SEQUENCE IF EXISTS retacubeseq CASCADE;
CREATE SEQUENCE retacubeseq;

DROP TABLE IF EXISTS reta_agency_offense_summary;
CREATE TABLE reta_agency_offense_summary AS SELECT 
NEXTVAL('retacubeseq') AS reta_agency_summary_id,
ar.data_year AS year,
rs.state_postal_abbr,
rs.state_name,
ra.agency_id,
ra.ori AS agency_ori,
ra.pub_agency_name AS agency_name,
ar.reported AS reported,
CASE WHEN racb.agency_id IS NOT NULL THEN TRUE ELSE FALSE END AS covered,
cvring.count AS covering_count,
rap.population AS agency_population,
rpg.population_group_code AS population_group_code,
rpg.population_group_desc AS population_group,
homicide.reported AS homicide_reported,
homicide.actual AS homicide_actual,
homicide.cleared AS homicide_cleared,
homicide.juvenile_cleared AS homicide_juvenile_cleared,
rape.reported AS rape_reported,
rape.actual AS rape_actual,
rape.cleared AS rape_cleared,
rape.juvenile_cleared AS rape_juvenile_cleared
FROM   agency_reporting ar
JOIN ref_agency ra ON ra.agency_id=ar.agency_id
LEFT OUTER JOIN ref_state rs ON rs.state_id=ra.state_id
LEFT OUTER JOIN ref_agency_covered_by racb ON racb.agency_id=ar.agency_id AND racb.data_year=ar.data_year
LEFT OUTER JOIN covering_counts cvring ON cvring.covered_by_agency_id=ar.agency_id AND cvring.data_year=ar.data_year
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id=ar.agency_id AND rap.data_year=ar.data_year
LEFT OUTER JOIN ref_population_group rpg ON rpg.population_group_id=rap.population_group_id
LEFT JOIN (
    SELECT 
      year,
      agency_id,
      sum(agency_sums_view.reported) AS reported,
      sum(agency_sums_view.actual) AS actual,
      sum(agency_sums_view.cleared) AS cleared,
      sum(agency_sums_view.juvenile_cleared) AS juvenile_cleared 
      FROM  agency_sums_view
      WHERE offense_code = 'SUM_HOM'
      GROUP  BY (year, agency_id)
    ) homicide ON homicide.agency_id=ar.agency_id AND homicide.year=ar.data_year 
LEFT JOIN (
    SELECT 
      year,
      agency_id,
      sum(agency_sums_view.reported) AS reported,
      sum(agency_sums_view.actual) AS actual,
      sum(agency_sums_view.cleared) AS cleared,
      sum(agency_sums_view.juvenile_cleared) AS juvenile_cleared 
      FROM  agency_sums_view
      WHERE offense_code = 'SUM_RPE'
      GROUP BY (year, agency_id)
    ) rape ON rape.agency_id=ar.agency_id AND rape.year=ar.data_year;