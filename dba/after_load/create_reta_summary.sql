\set ON_ERROR_STOP on

DROP TABLE IF EXISTS agency_reporting;

CREATE TABLE agency_reporting AS
SELECT rm.data_year,
rm.agency_id,
SUM(CASE WHEN rm.reported_flag = 'Y' THEN 1 ELSE 0 END) AS reported_months
FROM reta_month rm
GROUP BY rm.data_year, rm.agency_id;
y
DROP SEQUENCE IF EXISTS retacubeseq CASCADE;
CREATE SEQUENCE retacubeseq;

CREATE TABLE reta_cube_rollup AS
SELECT

NEXTVAL('retacubeseq') AS reta_month_offense_subcat_summary_id,
GROUPING(year,
    month,
    state_name,
    state,
    classification, offense_category,
    offense, offense_code,
    offense_subcat, offense_subcat_code
    ) AS grouping_bitmap,
SUM(u.reported_count) AS reported,
SUM(u.unfounded_count) AS unfounded,
SUM(u.actual_count) AS actual,
SUM(u.cleared_count) AS cleared,
SUM(u.juvenile_cleared_count) AS juvenile_cleared,
u.year,
u.month,
u.state_name,
u.state,
u.classification,
u.offense_category,
u.offense_code,
u.offense,
u.offense_subcat,
u.offense_subcat_code
FROM
(
  (SELECT
           rmos.reported_count,
           rmos.unfounded_count,
           rmos.actual_count,
           rmos.cleared_count,
           rmos.juvenile_cleared_count,
           rm.data_year AS year,
           rm.month_num AS month,
           rs.state_name,
           rs.state_postal_abbr AS state,
           oc.classification_name AS classification,
           roc.offense_category_name AS offense_category,
           ro.offense_code,
           ro.offense_name AS offense,
           ros.offense_subcat_name AS offense_subcat,
           ros.offense_subcat_code
    FROM   reta_month_offense_subcat rmos
    JOIN   reta_month rm ON (rmos.reta_month_id = rm.reta_month_id)
    JOIN   ref_agency ra ON (rm.agency_id = ra.agency_id)
    JOIN   agency_reporting ar ON (ar.agency_id=rm.agency_id AND ar.data_year=rm.data_year)
    JOIN   reta_offense_subcat ros ON (rmos.offense_subcat_id = ros.offense_subcat_id)
    JOIN   reta_offense ro ON (ros.offense_id = ro.offense_id)
    JOIN   reta_offense_category roc ON (ro.offense_category_id = roc.offense_category_id)
    JOIN   offense_classification oc ON (ro.classification_id = oc.classification_id)
    JOIN   ref_state rs ON (ra.state_id = rs.state_id)
    WHERE ar.reported_months = 12
    AND rmos.actual_status = 0
    )
  UNION
    (SELECT
            ambs.reported_count,
            ambs.unfounded_count,
            ambs.actual_count,
            ambs.cleared_count,
            ambs.juvenile_cleared_count,
            am.data_year AS year,
            am.month_num AS month,
            rs.state_name,
            rs.state_postal_abbr AS state,
            NULL as classification,
            'Arson'::text as offense_category,
            'X_ARS'::text as offense_code,
            'Arson'::text as offense,
            asuc.subcategory_name AS offense_subcat,
            asuc.subcategory_code AS offense_subcat_code
    FROM arson_month_by_subcat ambs
    JOIN   arson_month am ON ambs.arson_month_id = am.arson_month_id
    LEFT OUTER JOIN   arson_subcategory asuc ON ambs.subcategory_id = asuc.subcategory_id
    JOIN   ref_agency ra ON am.agency_id = ra.agency_id
    LEFT OUTER JOIN   ref_state rs ON ra.state_id = rs.state_id
    JOIN   agency_reporting ar ON ar.agency_id=am.agency_id AND ar.data_year=am.data_year
    WHERE ar.reported_months = 12
    AND ambs.actual_status = 0)
) AS u
    GROUP BY CUBE (year, month, (state_name, state)),
             ROLLUP (classification, offense_category,
                     (offense, offense_code),
                     (offense_subcat, offense_subcat_code))
;

DROP TABLE IF EXISTS reta_month_offense_subcat_summary CASCADE;
ALTER TABLE reta_cube_rollup RENAME TO reta_month_offense_subcat_summary;
-- DROP TABLE IF EXISTS agency_reporting;
