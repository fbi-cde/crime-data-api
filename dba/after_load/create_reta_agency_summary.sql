DROP TABLE IF EXISTS agency_reporting;

CREATE TABLE agency_reporting AS
SELECT rm.data_year,
rm.agency_id,
bool_and(CASE WHEN rm.reported_flag = 'Y' THEN TRUE ELSE FALSE END) AS reported
FROM reta_month rm
GROUP BY rm.data_year, rm.agency_id;

CREATE TABLE covering_counts AS
SELECT data_year, covered_by_agency_id, COUNT(agency_id) AS count
FROM ref_agency_covered_by_flat
GROUP BY covered_by_agency_id, data_year;

CREATE TABLE agency_sums (
 data_year smallint NOT NULL,
 agency_id bigint NOT NULL, 
 offense_id bigint NOT NULL,
 offense_code varchar(20),
 reported integer, 
 unfounded integer,
 actual integer,
 cleared integer,
 juvenile_cleared integer
);

DO
$do$
DECLARE
   arr integer[] := array[0, 11, 12, 20, 21, 22, 23, 24, 25, 30, 31, 32, 33, 34, 40, 41, 42, 43, 44, 45, 50, 51, 52, 53, 60, 70, 71, 72, 73, 80, 81, 82];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    RAISE NOTICE 'Executing Inserts for offense_subcat_id: %', i;
    SET work_mem='2GB';
    INSERT INTO agency_sums (data_year, agency_id, offense_id, offense_code, reported, unfounded, actual, cleared, juvenile_cleared)  
    SELECT rm.data_year,
    rm.agency_id,
    ros.offense_id,
    ro.offense_code,
    SUM(rmos.reported_count) AS reported,
    SUM(rmos.unfounded_count) AS unfounded,
    SUM(rmos.actual_count) AS actual,
    SUM(rmos.cleared_count) AS cleared,
    SUM(rmos.juvenile_cleared_count) AS juvenile_cleared 
    FROM (SELECT * from reta_month_offense_subcat where offense_subcat_id=i AND reta_month_offense_subcat.actual_status NOT IN (2, 3, 4)) rmos
    JOIN reta_offense_subcat ros ON (rmos.offense_subcat_id = ros.offense_subcat_id)
    JOIN reta_offense ro ON ro.offense_id=ros.offense_id
    JOIN reta_month rm ON (rmos.reta_month_id = rm.reta_month_id)
    JOIN agency_reporting ar ON ar.agency_id=rm.agency_id AND ar.data_year=rm.data_year
    WHERE ar.reported IS TRUE
    GROUP BY rm.data_year, rm.agency_id, ros.offense_id, ro.offense_code;
   END LOOP;
END
$do$;

ALTER TABLE agency_sums ADD COLUMN id SERIAL PRIMARY KEY;

drop materialized view agency_sums_view CASCADE;
create materialized view agency_sums_view as 
    SELECT 
    asums.id,
    asums.data_year as year,
    asums.agency_id,
    asums.offense_id,
    asums.offense_code,
    ro.offense_name,
    asums.reported,
    asums.unfounded,
    asums.actual,
    asums.cleared,
    asums.juvenile_cleared,
    ag.ori,
    ag.ucr_agency_name,
    ag.ncic_agency_name,
    ag.pub_agency_name,
    ros.offense_subcat_name,
    ros.offense_subcat_code,
    rs.state_postal_abbr,
    rc.county_name,
    rc.county_ansi_code,
    rc.county_fips_code,
    rc.legacy_county_code 
    from agency_sums asums 
    JOIN ref_agency ag ON (asums.agency_id = ag.agency_id)
    JOIN ref_agency_county rac ON (asums.agency_id = rac.agency_id)
    JOIN ref_county rc ON (rac.county_id = rc.county_id)
    JOIN reta_offense_subcat ros ON (asums.offense_id = ros.offense_subcat_id)
    JOIN reta_offense ro ON ro.offense_code=asums.offense_code
    JOIN ref_state rs ON (rs.state_id  = ag.state_id);

DROP SEQUENCE IF EXISTS retacubeseq CASCADE;
CREATE SEQUENCE retacubeseq;

DROP TABLE IF EXISTS reta_agency_offense_summary;
CREATE TABLE reta_agency_offense_summary AS
SELECT
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
FROM agency_reporting ar
JOIN ref_agency ra ON ra.agency_id=ar.agency_id
LEFT OUTER JOIN ref_state rs ON rs.state_id=ra.state_id
LEFT OUTER JOIN ref_agency_covered_by racb ON racb.agency_id=ar.agency_id AND racb.data_year=ar.data_year
LEFT OUTER JOIN covering_counts cvring ON cvring.covered_by_agency_id=ar.agency_id AND cvring.data_year=ar.data_year
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id=ar.agency_id AND rap.data_year=ar.data_year
LEFT OUTER JOIN ref_population_group rpg ON rpg.population_group_id=rap.population_group_id
LEFT OUTER JOIN agency_sums homicide ON homicide.agency_id=ar.agency_id AND homicide.data_year=ar.data_year AND homicide.offense_code='SUM_HOM'
LEFT OUTER JOIN agency_sums rape ON rape.agency_id=ar.agency_id AND rape.data_year=ar.data_year AND rape.offense_code='SUM_RPE';
