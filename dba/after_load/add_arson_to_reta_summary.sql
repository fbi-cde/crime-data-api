-- Add arson counts into RMOSS table
INSERT INTO reta_month_offense_subcat_summary
SELECT NEXTVAL('retacubeseq') AS reta_month_offense_subcat_summary_id,
GROUPING(data_year,
month_num,
state_name,
state_postal_abbr,
classification, offense_category,
offense, offense_code,
subcategory_name, subcategory_code) AS grouping_bitmap,
SUM(ambs.reported_count) AS reported,
SUM(ambs.unfounded_count) AS unfounded,
SUM(ambs.actual_count) AS actual,
SUM(ambs.cleared_count) AS cleared,
SUM(ambs.juvenile_cleared_count) AS juvenile_cleared,
am.data_year AS year,
am.month_num AS month,
rs.state_name,
rs.state_postal_abbr AS state,
t.classification,
t.offense_category,
t.offense_code,
t.offense,
asuc.subcategory_name AS offense_subcat,
asuc.subcategory_code AS offense_subcat_code
FROM (VALUES('Property', 'Arson', 'X_ARS', 'Arson')) AS t(classification, offense_category, offense_code, offense), arson_month_by_subcat ambs
JOIN   arson_month am ON ambs.arson_month_id = am.arson_month_id
JOIN   arson_subcategory asuc ON ambs.subcategory_id = asuc.subcategory_id
LEFT OUTER JOIN   ref_agency ra ON am.agency_id = ra.agency_id
LEFT OUTER JOIN   ref_state rs ON ra.state_id = rs.state_id
GROUP BY GROUPING SETS(
(data_year, month_num, state_name, state_postal_abbr, classification, offense_category, offense, offense_code, subcategory_name, subcategory_code),
(data_year, month_num, state_name, state_postal_abbr, classification, offense_category, offense, offense_code),
(data_year, month_num, state_name, state_postal_abbr, classification, offense_category),
(state_name, state_postal_abbr, classification, offense_category, offense, offense_code),
(classification, offense_category, offense, offense_code),
(classification, offense_category, offense, offense_code, subcategory_name, subcategory_code),
(data_year, state_name, state_postal_abbr, classification, offense_category, offense, offense_code),
(data_year, state_name, state_postal_abbr, classification, offense_category),
(data_year, classification, offense_category, offense, offense_code),
(data_year, classification, offense_category),
(data_year, month_num, classification, offense_category, offense, offense_code),
(data_year, month_num, classification, offense_category)
);

-- update the participation counts
-- 31 = classification, year, month, state
WITH arson_totals AS (
     SELECT year, month, state,
     sum(reported) AS reported,
     sum(unfounded) AS unfounded,
     sum(actual) AS actual,
     sum(cleared) AS cleared,
     sum(juvenile_cleared) AS juvenile_cleared
     FROM reta_month_offense_subcat_summary
     WHERE offense = 'Arson'
     AND grouping_bitmap = 0
     AND reported > 0
     GROUP BY year, month, state
)
UPDATE reta_month_offense_subcat_summary r
SET reported = r.reported + arson_totals.reported,
    actual = r.actual + arson_totals.actual,
    unfounded = r.unfounded + arson_totals.unfounded,
    cleared = r.cleared + arson_totals.cleared,
    juvenile_cleared = r.juvenile_cleared + arson_totals.juvenile_cleared
FROM arson_totals
WHERE r.classification = 'Property'
AND r.year = arson_totals.year
AND r.month = arson_totals.month
AND r.state = arson_totals.state
AND r.grouping_bitmap = 31;

-- 223 = classification, year, month
WITH arson_totals AS (
     SELECT year, month,
     sum(reported) AS reported,
     sum(unfounded) AS unfounded,
     sum(actual) AS actual,
     sum(cleared) AS cleared,
     sum(juvenile_cleared) AS juvenile_cleared
     FROM reta_month_offense_subcat_summary
     WHERE offense = 'Arson'
     AND grouping_bitmap = 0
     AND reported > 0
     GROUP BY year, month
)
UPDATE reta_month_offense_subcat_summary r
SET reported = r.reported + arson_totals.reported,
    actual = r.actual + arson_totals.actual,
    unfounded = r.unfounded + arson_totals.unfounded,
    cleared = r.cleared + arson_totals.cleared,
    juvenile_cleared = r.juvenile_cleared + arson_totals.juvenile_cleared
FROM arson_totals
WHERE r.classification = 'Property'
AND r.year = arson_totals.year
AND r.month = arson_totals.month
AND r.grouping_bitmap = 223;

-- 287 = classification, year, state
WITH arson_totals AS (
     SELECT year, state,
     sum(reported) AS reported,
     sum(unfounded) AS unfounded,
     sum(actual) AS actual,
     sum(cleared) AS cleared,
     sum(juvenile_cleared) AS juvenile_cleared
FROM reta_month_offense_subcat_summary
WHERE offense = 'Arson'
AND grouping_bitmap = 0
AND reported > 0
GROUP BY year, state
)
UPDATE reta_month_offense_subcat_summary r
SET reported = r.reported + arson_totals.reported,
actual = r.actual + arson_totals.actual,
unfounded = r.unfounded + arson_totals.unfounded,
cleared = r.cleared + arson_totals.cleared,
juvenile_cleared = r.juvenile_cleared + arson_totals.juvenile_cleared
FROM arson_totals
WHERE r.classification = 'Property'
AND r.year = arson_totals.year
AND r.state = arson_totals.state
AND r.grouping_bitmap = 287;

-- 543 = classification, month, state
WITH arson_totals AS (
SELECT month, state,
       sum(reported) AS reported,
       sum(unfounded) AS unfounded,
       sum(actual) AS actual,
       sum(cleared) AS cleared,
       sum(juvenile_cleared) AS juvenile_cleared
FROM reta_month_offense_subcat_summary
WHERE offense = 'Arson'
AND grouping_bitmap = 0
AND reported > 0
GROUP BY month, state
)
UPDATE reta_month_offense_subcat_summary r
SET reported = r.reported + arson_totals.reported,
actual = r.actual + arson_totals.actual,
unfounded = r.unfounded + arson_totals.unfounded,
cleared = r.cleared + arson_totals.cleared,
juvenile_cleared = r.juvenile_cleared + arson_totals.juvenile_cleared
FROM arson_totals
WHERE r.classification = 'Property'
AND r.state = arson_totals.state
AND r.month = arson_totals.month
AND r.grouping_bitmap = 543;

-- 799 = classification, state
WITH arson_totals AS (
SELECT state,
       sum(reported) AS reported,
       sum(unfounded) AS unfounded,
       sum(actual) AS actual,
       sum(cleared) AS cleared,
       sum(juvenile_cleared) AS juvenile_cleared
FROM reta_month_offense_subcat_summary
WHERE offense = 'Arson'
AND grouping_bitmap = 0
AND reported > 0
GROUP BY state
)
UPDATE reta_month_offense_subcat_summary r
SET reported = r.reported + arson_totals.reported,
actual = r.actual + arson_totals.actual,
unfounded = r.unfounded + arson_totals.unfounded,
cleared = r.cleared + arson_totals.cleared,
juvenile_cleared = r.juvenile_cleared + arson_totals.juvenile_cleared
FROM arson_totals
WHERE r.classification = 'Property'
AND r.state = arson_totals.state
AND r.grouping_bitmap = 799;

-- 479 = classification, year
WITH arson_totals AS (
SELECT year,
       sum(reported) AS reported,
       sum(unfounded) AS unfounded,
       sum(actual) AS actual,
       sum(cleared) AS cleared,
       sum(juvenile_cleared) AS juvenile_cleared
FROM reta_month_offense_subcat_summary
WHERE offense = 'Arson'
AND grouping_bitmap = 0
AND reported > 0
GROUP BY year
)
UPDATE reta_month_offense_subcat_summary r
SET reported = r.reported + arson_totals.reported,
actual = r.actual + arson_totals.actual,
unfounded = r.unfounded + arson_totals.unfounded,
cleared = r.cleared + arson_totals.cleared,
juvenile_cleared = r.juvenile_cleared + arson_totals.juvenile_cleared
FROM arson_totals
WHERE r.classification = 'Property'
AND r.year = arson_totals.year
AND r.grouping_bitmap = 479;

-- 735 = classification, month
WITH arson_totals AS (
SELECT year,
       sum(reported) AS reported,
       sum(unfounded) AS unfounded,
       sum(actual) AS actual,
       sum(cleared) AS cleared,
       sum(juvenile_cleared) AS juvenile_cleared
FROM reta_month_offense_subcat_summary
WHERE offense = 'Arson'
AND grouping_bitmap = 0
AND reported > 0
GROUP BY year
)
UPDATE reta_month_offense_subcat_summary r
SET reported = r.reported + arson_totals.reported,
actual = r.actual + arson_totals.actual,
unfounded = r.unfounded + arson_totals.unfounded,
cleared = r.cleared + arson_totals.cleared,
juvenile_cleared = r.juvenile_cleared + arson_totals.juvenile_cleared
FROM arson_totals
WHERE r.classification = 'Property'
AND r.year = arson_totals.year
AND r.grouping_bitmap = 735;

--991 = classification
WITH arson_totals AS (
SELECT sum(reported) AS reported,
       sum(unfounded) AS unfounded,
       sum(actual) AS actual,
       sum(cleared) AS cleared,
       sum(juvenile_cleared) AS juvenile_cleared
FROM reta_month_offense_subcat_summary
WHERE offense = 'Arson'
AND grouping_bitmap = 0
AND reported > 0
)
UPDATE reta_month_offense_subcat_summary r
SET reported = r.reported + arson_totals.reported,
actual = r.actual + arson_totals.actual,
unfounded = r.unfounded + arson_totals.unfounded,
cleared = r.cleared + arson_totals.cleared,
juvenile_cleared = r.juvenile_cleared + arson_totals.juvenile_cleared
FROM arson_totals
WHERE r.classification = 'Property'
AND r.grouping_bitmap = 991;
