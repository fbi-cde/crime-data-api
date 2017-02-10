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
(state_name, state_postal_abbr, classification, offense_category, offense, offense_code),
(classification, offense_category, offense, offense_code),
(classification, offense_category, offense, offense_code, subcategory_name, subcategory_code),
(data_year, state_name, state_postal_abbr, classification, offense_category, offense, offense_code),
(data_year, classification, offense_category, offense, offense_code),
(data_year, month_num, classification, offense_category, offense, offense_code)
);
