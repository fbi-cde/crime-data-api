-- These:

-- echo -n "Create flat ref_agency_covered_by table..."
SET work_mem='4096MB'; -- Go Super Saiyan.

DROP TABLE IF EXISTS flat_covered_by_temp CASCADE;

CREATE TABLE flat_covered_by_temp
(
  data_year smallint NOT NULL,
  agency_id bigint NOT NULL,
  covered_by_agency_id bigint NOT NULL,
  PRIMARY KEY(data_year, agency_id)
);

WITH RECURSIVE flatcover(data_year, agency_id, covered_by_agency_id, root_agency_id) AS (
SELECT DISTINCT data_year, agency_id, 0::bigint AS covered_by_agency_id, agency_id AS root_agency_id
FROM ref_agency_county WHERE ref_agency_county.agency_id NOT IN (select agency_id from ref_agency_covered_by WHERE data_year=ref_agency_county.data_year)
UNION ALL
SELECT u.data_year, u.agency_id, u.covered_by_agency_id, f.root_agency_id
FROM flatcover f
INNER JOIN ref_agency_covered_by u ON f.agency_id=u.covered_by_agency_id AND f.data_year=u.data_year
)
INSERT INTO flat_covered_by_temp(data_year, agency_id, covered_by_agency_id)
SELECT data_year, agency_id, root_agency_id AS covered_by_agency_id FROM flatcover WHERE agency_id <> root_agency_id;

DROP TABLE IF EXISTS ref_agency_covered_by_flat CASCADE;
ALTER TABLE flat_covered_by_temp RENAME TO ref_agency_covered_by_flat;

ALTER TABLE ONLY ref_agency_covered_by_flat
ADD CONSTRAINT flat_covered_by_agency_id_fk FOREIGN KEY (agency_id) REFERENCES cde_agencies(agency_id);

ALTER TABLE ONLY ref_agency_covered_by_flat
ADD CONSTRAINT flat_covered_by_agency_id_covering_fk FOREIGN KEY (covered_by_agency_id) REFERENCES cde_agencies(agency_id);


-- echo -n "Create participation views..."
SET work_mem='4096MB'; -- Go Super Saiyan.

-- first create reporting code
DROP TABLE IF EXISTS agency_reporting CASCADE;
CREATE TABLE agency_reporting AS
SELECT
data_year,
agency_id,
SUM(CASE WHEN reported_flag = 'Y' THEN 1 ELSE 0 END)::int AS months_reported
FROM reta_month
GROUP by data_year, agency_id;

DROP TABLE IF EXISTS agency_reporting_nibrs CASCADE;
CREATE TABLE agency_reporting_nibrs AS
SELECT
data_year,
agency_id,
SUM(CASE WHEN reported_status IN ('I', 'Z') THEN 1 ELSE 0 END)::int AS months_reported
FROM nibrs_month
GROUP by data_year, agency_id;

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
FROM agency_reporting ar
JOIN ref_agency ra ON ra.agency_id=ar.agency_id
JOIN ref_state rs ON rs.state_id=ra.state_id
LEFT OUTER JOIN agency_reporting_nibrs nr ON ar.agency_id=nr.agency_id AND ar.data_year=nr.data_year
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id=ar.agency_id AND rap.data_year=ar.data_year
LEFT OUTER JOIN ref_population_group rpg ON rpg.population_group_id = rap.population_group_id
LEFT OUTER JOIN ref_agency_covered_by_flat racbf ON racbf.agency_id=ar.agency_id AND racbf.data_year=ar.data_year
LEFT OUTER JOIN agency_reporting covered_ar ON covered_ar.agency_id=racbf.covered_by_agency_id AND covered_ar.data_year=racbf.data_year
LEFT OUTER JOIN agency_reporting covered_nr ON covered_nr.agency_id=racbf.covered_by_agency_id AND covered_nr.data_year=racbf.data_year
ORDER by ar.data_year, rs.state_name, ra.pub_agency_name;

ALTER TABLE ONLY agency_participation
ADD CONSTRAINT agency_participation_pk PRIMARY KEY (year, agency_id);

DROP TABLE agency_reporting;
DROP TABLE agency_reporting_nibrs;

DROP TABLE IF EXISTS participation_rates_temp CASCADE;
CREATE TABLE participation_rates_temp
(
    participation_id serial PRIMARY KEY,
    year smallint NOT NULL,
    state_id bigint,
    state_name varchar(255),
    county_id bigint,
    county_name varchar(255),
    total_agencies int,
    participating_agencies int,
    participation_rate float,
    nibrs_participating_agencies int,
    nibrs_participation_rate float,
    covered_agencies int,
    covered_rate float,
    total_population bigint,
    participating_population bigint,
    nibrs_participating_population bigint
);

ALTER TABLE ONLY participation_rates_temp
ADD CONSTRAINT participation_rates_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);

ALTER TABLE ONLY participation_rates_temp
ADD CONSTRAINT participation_rates_county_fk FOREIGN KEY (county_id) REFERENCES ref_county(county_id);

INSERT INTO participation_rates_temp(year, state_id, state_name, total_agencies, participating_agencies, participation_rate, nibrs_participating_agencies, nibrs_participation_rate, covered_agencies, covered_rate, participating_population, nibrs_participating_population)
SELECT
c.year,
a.state_id,
rs.state_name,
COUNT(a.ori) AS total_agencies,
SUM(c.participated) AS participating_agencies,
CAST(SUM(c.participated) AS float)/COUNT(a.ORI) AS participation_rate,
SUM(c.nibrs_participated) AS nibrs_participating_agencies,
CAST(SUM(c.nibrs_participated) AS float)/COUNT(a.ORI) AS nibrs_participation_rate,
COUNT(racb.agency_id) AS covered_agencies,
CAST(COUNT(racb.agency_id) AS float)/COUNT(a.ORI) AS covered_rate,
0 AS participating_population,
0 as nibrs_participating_population
FROM agency_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
JOIN ref_state rs ON a.state_id = rs.state_id
LEFT OUTER JOIN ref_agency_covered_by racb ON racb.agency_id=c.agency_id AND racb.data_year=c.year
GROUP BY c.year, a.state_id, rs.state_name;

-- If an agency spans multiple counties, it will be counted once in
-- the total/reporting agencies counts for each county. Its population
-- is apportioned individually though, so its full population won't be
-- duplicated for each county
INSERT INTO participation_rates_temp(year, county_id, county_name, total_agencies, participating_agencies, participation_rate, nibrs_participating_agencies, nibrs_participation_rate, total_population, participating_population, nibrs_participating_population, covered_agencies, covered_rate)
SELECT
c.year,
rc.county_id,
rc.county_name,
COUNT(a.ori) AS total_agencies,
SUM(c.participated) AS participating_agencies,
CAST(SUM(c.participated) AS float)/COUNT(a.ori) AS participation_rate,
SUM(c.nibrs_participated) AS nibrs_participating_agencies,
CAST(SUM(c.nibrs_participated) AS float)/COUNT(a.ori) AS nibrs_participation_rate,
SUM(rac.population) AS total_population,
SUM(CASE WHEN c.participated = 1 THEN rac.population ELSE 0 END) AS participating_population,
SUM(CASE WHEN c.nibrs_participated = 1 THEN rac.population ELSE 0 END) AS nibrs_participating_population,
COUNT(racb.agency_id) AS covered_agencies,
CAST(COUNT(racb.agency_id) AS float)/COUNT(a.ori) AS covered_rate
FROM agency_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
JOIN ref_agency_county rac ON rac.agency_id = a.agency_id AND rac.data_year = c.year
JOIN ref_county rc ON rc.county_id = rac.county_id
LEFT OUTER JOIN ref_agency_covered_by racb ON racb.agency_id=c.agency_id AND racb.data_year=c.year
GROUP BY c.year, rc.county_id, rc.county_name;

UPDATE participation_rates_temp
SET total_population=(SELECT COALESCE(SUM(rac.population), 0)
                      FROM ref_agency_county rac
                      JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                      WHERE ra.state_id=participation_rates_temp.state_id
                      AND rac.data_year=participation_rates_temp.year)
WHERE state_id IS NOT NULL;

UPDATE participation_rates_temp
SET participating_population=(SELECT COALESCE(SUM(rac.population), 0)
                              FROM ref_agency_county rac
                              JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                              JOIN agency_participation c ON c.agency_id=ra.agency_id AND c.year=rac.data_year
                              WHERE ra.state_id=participation_rates_temp.state_id
                              AND rac.data_year=participation_rates_temp.year
                              AND c.participated = 1)
WHERE state_id IS NOT NULL;

UPDATE participation_rates_temp
SET nibrs_participating_population=(SELECT COALESCE(SUM(rac.population), 0)
FROM ref_agency_county rac
JOIN ref_agency ra ON ra.agency_id=rac.agency_id
JOIN agency_participation c ON c.agency_id=ra.agency_id AND c.year=rac.data_year
WHERE ra.state_id=participation_rates_temp.state_id
AND rac.data_year=participation_rates_temp.year
AND c.nibrs_participated = 1)
WHERE state_id IS NOT NULL;

--- annual rollups
INSERT INTO participation_rates_temp(year, total_agencies, participating_agencies, participation_rate, nibrs_participating_agencies, nibrs_participation_rate, covered_agencies, covered_rate, participating_population)
SELECT
c.year,
COUNT(a.ori) AS total_agencies,
SUM(c.participated) AS participating_agencies,
CAST(SUM(c.participated) AS float)/COUNT(a.ORI) AS participation_rate,
SUM(c.nibrs_participated) AS nibrs_participating_agencies,
CAST(SUM(c.nibrs_participated) AS float)/COUNT(a.ORI) AS nibrs_participation_rate,
COUNT(racb.agency_id) as covered_agencies,
CAST(COUNT(racb.agency_id) AS float)/COUNT(a.ORI) AS covered_rate,
0 as participation_population
FROM agency_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
LEFT OUTER JOIN ref_agency_covered_by racb ON racb.agency_id=c.agency_id AND racb.data_year=c.year
GROUP BY c.year;

UPDATE participation_rates_temp
SET total_population=(SELECT COALESCE(SUM(rac.population), 0)
                      FROM ref_agency_county rac
                      JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                      WHERE rac.data_year=participation_rates_temp.year)
WHERE state_id IS NULL AND county_id IS NULL;

UPDATE participation_rates_temp
SET participating_population=(SELECT COALESCE(SUM(rac.population), 0)
                              FROM ref_agency_county rac
                              JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                              JOIN agency_participation c ON c.agency_id=rac.agency_id AND c.year=rac.data_year
                              WHERE rac.data_year=participation_rates_temp.year
                              AND c.participated=1)
                              WHERE state_id IS NULL AND county_id IS NULL;

UPDATE participation_rates_temp
SET nibrs_participating_population=(SELECT COALESCE(SUM(rac.population), 0)
FROM ref_agency_county rac
JOIN ref_agency ra ON ra.agency_id=rac.agency_id
JOIN agency_participation c ON c.agency_id=rac.agency_id AND c.year=rac.data_year
WHERE rac.data_year=participation_rates_temp.year
AND c.nibrs_participated=1)
WHERE state_id IS NULL AND county_id IS NULL;

DROP TABLE IF EXISTS participation_rates CASCADE;
ALTER TABLE participation_rates_temp RENAME TO participation_rates;

-- echo -n "Create cde_counties table..."
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

-- echo -n "Create cde_states table..."
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

-- echo -n "Create reta_agency_summary table..."
SET work_mem='2GB';
SET synchronous_commit TO OFF;

DROP TABLE IF EXISTS agency_reporting;
CREATE TABLE agency_reporting AS
SELECT rm.data_year,
rm.agency_id,
bool_and(CASE WHEN rm.reported_flag = 'Y' THEN TRUE ELSE FALSE END) AS reported
FROM reta_month rm
GROUP BY rm.data_year, rm.agency_id;

DROP TABLE IF EXISTS covering_counts;
CREATE TABLE covering_counts AS
SELECT data_year, covered_by_agency_id, COUNT(agency_id) AS count
FROM ref_agency_covered_by_flat
GROUP BY covered_by_agency_id, data_year;

DO
$do$
DECLARE
   -- ARRAY of Subcat Offense ID's - This could be replaced with a select statement in the future.
   arr integer[] := array[0, 11, 12, 20, 21, 22, 23, 24, 25, 30, 31, 32, 33, 34, 40, 41, 42, 43, 44, 45, 50, 51, 52, 53, 60, 70, 71, 72, 73, 80, 81, 82];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    RAISE NOTICE 'Executing Inserts for offense_subcat_id: %', i;
    SET work_mem='3GB';
    INSERT INTO agency_sums (data_year, agency_id, offense_subcat_id, reported, unfounded, actual, cleared, juvenile_cleared)  
    SELECT rm.data_year,
    rm.agency_id,
    ros.offense_subcat_id,
    SUM(rmos.reported_count) AS reported,
    SUM(rmos.unfounded_count) AS unfounded,
    SUM(rmos.actual_count) AS actual,
    SUM(rmos.cleared_count) AS cleared,
    SUM(rmos.juvenile_cleared_count) AS juvenile_cleared 
    FROM (SELECT * from reta_month_offense_subcat where offense_subcat_id=i AND reta_month_offense_subcat.actual_status NOT IN (2, 3, 4)) rmos
    JOIN reta_offense_subcat ros ON (rmos.offense_subcat_id = ros.offense_subcat_id)
    JOIN reta_month rm ON (rmos.reta_month_id = rm.reta_month_id)
    JOIN agency_reporting ar ON ar.agency_id=rm.agency_id AND ar.data_year=rm.data_year
    WHERE ar.reported IS TRUE and rm.data_year = 2015 
    GROUP BY rm.data_year, rm.agency_id, ros.offense_subcat_id;
   END LOOP;
END
$do$;

INSERT INTO agency_sums_view(id, year, agency_id, offense_subcat_id, offense_id, offense_code, offense_name, reported, unfounded, actual, cleared, juvenile_cleared,ori,pub_agency_name,offense_subcat_name,offense_subcat_code,state_postal_abbr)
  SELECT 
    asums.id,
    asums.data_year as year,
    asums.agency_id,
    asums.offense_subcat_id,
    ro.offense_id,
    ro.offense_code,
    ro.offense_name,
    asums.reported,
    asums.unfounded,
    asums.actual,
    asums.cleared,
    asums.juvenile_cleared,
    ag.ori,
    ag.pub_agency_name,
    ros.offense_subcat_name,
    ros.offense_subcat_code,
    rs.state_postal_abbr
  from agency_sums asums 
  JOIN ref_agency ag ON (asums.agency_id = ag.agency_id)
  JOIN reta_offense_subcat ros ON (asums.offense_subcat_id = ros.offense_subcat_id)
  JOIN reta_offense ro ON ros.offense_id=ro.offense_id
  JOIN ref_state rs ON (rs.state_id  = ag.state_id)
  WHERE asums.data_year = 2015;

DROP TABLE IF EXISTS agency_sums_by_offense;
CREATE table agency_sums_by_offense (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL,
offense_id bigint NOT NULL,
reported integer,
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer
);

INSERT INTO agency_sums_by_offense(data_year, agency_id, offense_id, reported, unfounded, actual, cleared, juvenile_cleared)
SELECT
a.data_year,
a.agency_id,
ro.offense_id,
SUM(a.reported) AS reported,
SUM(a.unfounded) AS unfounded,
SUM(a.actual) AS actual,
SUM(a.cleared) AS cleared,
SUM(a.juvenile_cleared) AS juvenile_cleared
FROM agency_sums a
JOIN reta_offense_subcat ros ON a.offense_subcat_id = ros.offense_subcat_id
JOIN reta_offense ro ON ro.offense_id = ros.offense_id
WHERE a.data_year = 2015 
GROUP by a.data_year, a.agency_id, ro.offense_id;


INSERT INTO agency_offenses_view(year, agency_id, offense_id, offense_code, offense_name, reported, unfounded, actual, cleared, juvenile_cleared, ori, pub_agency_name, state_postal_abbr)
  SELECT 
    a.data_year,
    a.agency_id,
    a.offense_id,
    ro.offense_code,
    ro.offense_name,
    a.reported,
    a.unfounded,
    a.actual,
    a.cleared,
    a.juvenile_cleared,
    c.ori,
    c.agency_name,
    c.state_abbr
FROM agency_sums_by_offense a
JOIN cde_agencies c ON c.agency_id=a.agency_id
JOIN reta_offense ro ON ro.offense_id = a.offense_id
WHERE a.data_year = 2015;

DROP TABLE IF EXISTS agency_sums_aggravated;
CREATE table agency_sums_aggravated (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL,
reported integer,
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer
);

INSERT INTO agency_sums_aggravated(data_year, agency_id, reported, unfounded, actual, cleared, juvenile_cleared)
SELECT
a.data_year,
a.agency_id,
SUM(a.reported) AS reported,
SUM(a.unfounded) AS unfounded,
SUM(a.actual) AS actual,
SUM(a.cleared) AS cleared,
SUM(a.juvenile_cleared) AS juvenile_cleared
FROM agency_sums a
JOIN reta_offense_subcat ros ON a.offense_subcat_id = ros.offense_subcat_id
JOIN reta_offense ro ON ro.offense_id = ros.offense_id
WHERE a.offense_subcat_id IN (40, 41, 42, 43, 44) AND a.data_year = 2015 
GROUP by a.data_year, a.agency_id, ro.offense_id;

INSERT INTO agency_offenses_view(year, agency_id, offense_id, offense_code, offense_name, reported, unfounded, actual, cleared, juvenile_cleared, ori, pub_agency_name, state_postal_abbr)
SELECT
a.data_year,
a.agency_id,
40 as offense_id,
'X_AGG' AS offense_code,
'Aggravated Assault' as offense_name,
a.reported,
a.unfounded,
a.actual,
a.cleared,
a.juvenile_cleared,
c.ori,
c.agency_name,
c.state_abbr
FROM agency_sums_aggravated a
JOIN cde_agencies c ON c.agency_id=a.agency_id 
WHERE a.data_year = 2015;

DROP TABLE agency_sums_aggravated;
DROP TABLE agency_sums_by_offense;

-- classifications grouping
DROP TABLE IF EXISTS agency_sums_by_classification;
CREATE table agency_sums_by_classification (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL,
classification TEXT NOT NULL,
reported integer,
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer
);

INSERT INTO agency_sums_by_classification(data_year, agency_id, classification, reported, unfounded, actual, cleared, juvenile_cleared)
SELECT
a.data_year,
a.agency_id,
oc.classification_name AS classification,
SUM(a.reported) AS reported,
SUM(a.unfounded) AS unfounded,
SUM(a.actual) AS actual,
SUM(a.cleared) AS cleared,
SUM(a.juvenile_cleared) AS juvenile_cleared
FROM agency_sums a
JOIN reta_offense_subcat ros ON a.offense_subcat_id = ros.offense_subcat_id
JOIN reta_offense ro ON ro.offense_id = ros.offense_id
JOIN offense_classification oc ON oc.classification_id = ro.classification_id
WHERE a.offense_subcat_id <> 45 AND a.data_year = 2015 
GROUP by a.data_year, a.agency_id, oc.classification_name;

DROP TABLE IF EXISTS agency_classification_view CASCADE;
create TABLE agency_classification_view (
 id SERIAL,
 year smallint NOT NULL,
 agency_id bigint NOT NULL,
 classification text,
 reported integer,
 unfounded integer,
 actual integer,
 cleared integer,
 juvenile_cleared integer,
 ori text,
 pub_agency_name text,
 state_postal_abbr varchar(2)
);

DROP TRIGGER IF EXISTS agency_classification_view_insert_state_partition ON agency_classification_view;
CREATE TRIGGER agency_classification_view_insert_state_partition
BEFORE INSERT ON agency_classification_view
FOR EACH ROW EXECUTE PROCEDURE create_state_partition_and_insert();

INSERT INTO agency_classification_view(year, agency_id, classification, reported, unfounded, actual, cleared, juvenile_cleared, ori, pub_agency_name, state_postal_abbr)
  SELECT
    a.data_year,
    a.agency_id,
    a.classification,
    a.reported,
    a.unfounded,
    a.actual,
    a.cleared,
    a.juvenile_cleared,
    c.ori,
    c.agency_name,
    c.state_abbr
FROM agency_sums_by_classification a
JOIN cde_agencies c ON c.agency_id=a.agency_id
WHERE a.data_year = 2015;

DROP TABLE agency_sums_by_classification;

----- Add arson to agency sums
DROP TABLE IF EXISTS arson_agency_reporting;
CREATE TABLE arson_agency_reporting AS
SELECT rm.data_year,
rm.agency_id,
SUM(CASE WHEN rm.reported_flag = 'Y' THEN 1 ELSE 0 END) AS months_reported
FROM arson_month rm
GROUP BY rm.data_year, rm.agency_id;

DROP TABLE IF EXISTS arson_agency_sums CASCADE;
CREATE TABLE arson_agency_sums (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL, 
reported integer, 
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer,
uninhabited bigint,
est_damage_value bigint
);

INSERT INTO arson_agency_sums (data_year, agency_id, reported, unfounded, actual, cleared, juvenile_cleared, uninhabited, est_damage_value)  
SELECT am.data_year,
am.agency_id,
SUM(ambs.reported_count) AS reported,
SUM(ambs.unfounded_count) AS unfounded,
SUM(ambs.actual_count) AS actual,
SUM(ambs.cleared_count) AS cleared,
SUM(ambs.juvenile_cleared_count) AS juvenile_cleared,
SUM(ambs.uninhabited_count) AS uninhabited,
SUM(ambs.est_damage_value) AS est_damage_value
FROM arson_month_by_subcat ambs
JOIN arson_month am ON ambs.arson_month_id = am.arson_month_id
JOIN arson_agency_reporting rep ON rep.agency_id=am.agency_id AND rep.data_year=am.data_year
WHERE rep.months_reported = 12 AND am.data_year = 2015 
AND ambs.actual_status = 0
GROUP BY am.data_year, am.agency_id;

DROP TABLE IF EXISTS agency_arson_view CASCADE;

create TABLE agency_arson_view (
id SERIAL PRIMARY KEY,
year smallint NOT NULL,
agency_id bigint NOT NULL, 
reported integer, 
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer,
uninhabited integer,
est_damage_value bigint,
ori text,
pub_agency_name text,
state_postal_abbr text
);

INSERT INTO agency_arson_view(year, agency_id, reported, unfounded, actual, cleared, juvenile_cleared, uninhabited, est_damage_value, ori, pub_agency_name, state_postal_abbr)
SELECT
a.data_year,
a.agency_id,
a.reported,
a.unfounded,
a.actual,
a.cleared,
a.juvenile_cleared,
a.uninhabited,
a.est_damage_value,
c.ori,
c.agency_name,
c.state_abbr
FROM arson_agency_sums a
JOIN cde_agencies c ON c.agency_id=a.agency_id 
WHERE a.data_year = 2015;

DROP TABLE arson_agency_sums;
DROP TABLE arson_agency_reporting;

--- Add arsons to the offense table
INSERT INTO agency_offenses_view(year, agency_id, offense_id, offense_code, offense_name, reported, unfounded, actual, cleared, juvenile_cleared, ori, pub_agency_name, state_postal_abbr)
SELECT
  a.year,
  a.agency_id,
  NULL as offense_id,
  'X_ARS' as offense_code,
  'Arson' as offense_name,
  a.reported,
  a.unfounded,
  a.actual,
  a.cleared,
  a.juvenile_cleared,
  a.ori,
  a.pub_agency_name,
  a.state_postal_abbr
FROM agency_arson_view a 
WHERE a.year = 2015;

-- echo -n "Arson tables..."
DROP TABLE IF EXISTS arson_agency_reporting;
CREATE TABLE arson_agency_reporting AS
SELECT rm.data_year,
rm.agency_id,
SUM(CASE WHEN rm.reported_flag = 'Y' THEN 1 ELSE 0 END) AS months_reported
FROM arson_month rm
GROUP BY rm.data_year, rm.agency_id;

INSERT INTO arson_summary(grouping_bitmap, year, state_id, state_abbr, agency_id, ori, subcategory_name, subcategory_code, reported, unfounded, actual, cleared, juvenile_cleared, uninhabited, est_damage_value)
SELECT
GROUPING(am.data_year,
rs.state_id,
rs.state_postal_abbr,
ra.agency_id,
ra.ori,
asuc.subcategory_name,
asuc.subcategory_code
) AS grouping_bitmap,
am.data_year AS year,
rs.state_id AS state_id,
rs.state_postal_abbr AS state_abbr,
ra.agency_id AS agency_id,
ra.ori AS ori,
asuc.subcategory_name AS offense_subcat,
asuc.subcategory_code AS offense_subcat_code,
SUM(ambs.reported_count) AS reported,
SUM(ambs.unfounded_count) AS unfounded,
SUM(ambs.actual_count) AS actual,
SUM(ambs.cleared_count) AS cleared,
SUM(ambs.juvenile_cleared_count) AS juvenile_cleared,
SUM(ambs.uninhabited_count) AS uninhabited,
SUM(ambs.est_damage_value) AS est_damage_value
FROM arson_month_by_subcat ambs
JOIN   arson_month am ON ambs.arson_month_id = am.arson_month_id
JOIN   arson_subcategory asuc ON ambs.subcategory_id = asuc.subcategory_id
JOIN   ref_agency ra ON am.agency_id = ra.agency_id
LEFT OUTER JOIN ref_state rs ON ra.state_id = rs.state_id
JOIN arson_agency_reporting ar ON ar.agency_id=am.agency_id AND ar.data_year=am.data_year
WHERE ar.months_reported = 12 AND ambs.actual_status = 0 AND am.data_year = 2015 
GROUP BY GROUPING SETS(
(year),
(year, offense_subcat, offense_subcat_code),
(year, rs.state_id, state_postal_abbr),
(year, rs.state_id, state_postal_abbr, offense_subcat, offense_subcat_code),
(year, rs.state_id, state_postal_abbr, ra.agency_id, ori),
(year, rs.state_id, state_postal_abbr, ra.agency_id, ori, offense_subcat, offense_subcat_code)
);

DROP TABLE arson_agency_reporting;


-- Refresh year count view.
REFRESH MATERIALIZED VIEW nibrs_years;