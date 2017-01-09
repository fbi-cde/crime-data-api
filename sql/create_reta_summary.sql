\set ON_ERROR_STOP on

DROP SEQUENCE IF EXISTS retacubeseq;
CREATE SEQUENCE retacubeseq;

CREATE TABLE reta_cube_rollup AS
    SELECT NEXTVAL('retacubeseq') AS reta_month_offense_subcat_summary_id,
           GROUPING(data_year,
             month_num,
             state_name,
             state_abbr,
             classification_name, offense_category_name,
             offense_name, offense_code,
             offense_subcat_name, offense_subcat_code
             ) AS grouping_bitmap,
           SUM(rmos.reported_count) AS reported,
           SUM(rmos.unfounded_count) AS unfounded,
           SUM(rmos.actual_count) AS actual,
           SUM(rmos.cleared_count) AS cleared,
           SUM(rmos.juvenile_cleared_count) AS juvenile_cleared,
           rm.data_year AS year,
           rm.month_num AS month,
           rs.state_name,
           rs.state_abbr AS state,
           oc.classification_name AS classification,
           roc.offense_category_name AS offense_category,
           ro.offense_code,
           ro.offense_name AS offense,
           ros.offense_subcat_name AS offense_subcat,
           ros.offense_subcat_code
    FROM   reta_month_offense_subcat rmos
    LEFT OUTER JOIN   reta_offense_subcat ros ON (rmos.offense_subcat_id = ros.offense_subcat_id)
    LEFT OUTER JOIN   reta_offense ro ON (ros.offense_id = ro.offense_id)
    LEFT OUTER JOIN   reta_offense_category roc ON (ro.offense_category_id = roc.offense_category_id)
    LEFT OUTER JOIN   offense_classification oc ON (ro.classification_id = oc.classification_id)
    LEFT OUTER JOIN   reta_month rm ON (rmos.reta_month_id = rm.reta_month_id)
    LEFT OUTER JOIN   ref_agency ra ON (rm.agency_id = ra.agency_id)
    LEFT OUTER JOIN   ref_state rs ON (ra.state_id = rs.state_id)
    GROUP BY CUBE (data_year, month_num, (state_name, state_abbr)),
             ROLLUP (classification_name, offense_category_name,
                     (offense_name, offense_code),
                     (offense_subcat_name, offense_subcat_code))
;

DROP TABLE IF EXISTS reta_month_offense_subcat_summary CASCADE;
ALTER TABLE reta_cube_rollup RENAME TO reta_month_offense_subcat_summary;
