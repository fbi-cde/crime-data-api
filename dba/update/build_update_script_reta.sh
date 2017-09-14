MYPWD="$(pwd)/data"
YEAR=$1

echo "
-- Build RETA views, and other misc datasets:

\set ON_ERROR_STOP on;
SET work_mem='1GB'; -- Go Super Saiyan.



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
WHERE a.data_year = $YEAR;

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
WHERE a.offense_subcat_id IN (40, 41, 42, 43, 44) AND a.data_year = $YEAR 
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
WHERE a.data_year = $YEAR;


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
WHERE a.offense_subcat_id <> 45 AND a.data_year = $YEAR 
GROUP by a.data_year, a.agency_id, oc.classification_name;

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
WHERE a.data_year = $YEAR;


-------------------------------------------------------------------------------------------

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
WHERE rep.months_reported = 12 AND am.data_year = $YEAR 
AND ambs.actual_status = 0
GROUP BY am.data_year, am.agency_id;

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
WHERE a.data_year = $YEAR;

DROP TABLE arson_agency_sums;
DROP TABLE arson_agency_reporting;

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
WHERE a.year = $YEAR;

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
WHERE ar.months_reported = 12 AND ambs.actual_status = 0 AND am.data_year = $YEAR 
GROUP BY GROUPING SETS(
(year),
(year, offense_subcat, offense_subcat_code),
(year, rs.state_id, state_postal_abbr),
(year, rs.state_id, state_postal_abbr, offense_subcat, offense_subcat_code),
(year, rs.state_id, state_postal_abbr, ra.agency_id, ori),
(year, rs.state_id, state_postal_abbr, ra.agency_id, ori, offense_subcat, offense_subcat_code)
);


"
