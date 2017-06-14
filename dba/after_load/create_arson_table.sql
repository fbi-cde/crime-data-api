DROP TABLE IF EXISTS arson_agency_reporting;
CREATE TABLE arson_agency_reporting AS
SELECT rm.data_year,
rm.agency_id,
SUM(CASE WHEN rm.reported_flag = 'Y' THEN 1 ELSE 0 END) AS months_reported
FROM arson_month rm
GROUP BY rm.data_year, rm.agency_id;

DROP TABLE IF EXISTS arson_summary_temp;
CREATE TABLE arson_summary_temp(
arson_summary_id serial PRIMARY KEY,
grouping_bitmap integer,
year smallint,
state_id integer,
state_abbr text,
agency_id bigint,
ori text,
subcategory_name text,
subcategory_code text,
reported integer,
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer,
uninhabited integer,
est_damage_value bigint);

INSERT INTO arson_summary_temp(grouping_bitmap, year, state_id, state_abbr, agency_id, ori, subcategory_name, subcategory_code, reported, unfounded, actual, cleared, juvenile_cleared, uninhabited, est_damage_value)
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
WHERE ar.months_reported = 12 AND ambs.actual_status = 0
GROUP BY GROUPING SETS(
(year),
(year, offense_subcat, offense_subcat_code),
(year, rs.state_id, state_postal_abbr),
(year, rs.state_id, state_postal_abbr, offense_subcat, offense_subcat_code),
(year, rs.state_id, state_postal_abbr, ra.agency_id, ori),
(year, rs.state_id, state_postal_abbr, ra.agency_id, ori, offense_subcat, offense_subcat_code)
);

DROP TABLE arson_agency_reporting;

DROP TABLE IF EXISTS arson_summary;
ALTER TABLE ONLY arson_summary_temp RENAME TO arson_summary;
