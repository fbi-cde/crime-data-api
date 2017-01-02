CREATE TABLE reta_cube AS
    SELECT GROUPING(data_year,
             month_num,
             offense_subcat_name,
             offense_subcat_code,
             offense_name,
             offense_code,
             offense_category_name,
             classification_name,
             state_name,
             state_abbr ) AS grouping_bitmap,
           SUM(rmos.reported_count) AS reported,
           SUM(rmos.unfounded_count) AS unfounded,
           SUM(rmos.actual_count) AS actual,
           SUM(rmos.cleared_count) AS cleared,
           SUM(rmos.juvenile_cleared_count) AS juvenile_cleared,
           rm.data_year AS year,
           rm.month_num AS month,
           ros.offense_subcat_name AS offense_subcat,
           ros.offense_subcat_code,
           ro.offense_name AS offense,
           ro.offense_code,
           roc.offense_category_name AS offense_category,
           oc.classification_name AS classification,
           rs.state_name,
           rs.state_abbr AS state
    FROM   reta_month_offense_subcat rmos
    LEFT OUTER JOIN   reta_offense_subcat ros ON (rmos.offense_subcat_id = ros.offense_subcat_id)
    LEFT OUTER JOIN   reta_offense ro ON (ros.offense_id = ro.offense_id)
    LEFT OUTER JOIN   reta_offense_category roc ON (ro.offense_category_id = roc.offense_category_id)
    LEFT OUTER JOIN   offense_classification oc ON (ro.classification_id = oc.classification_id)
    LEFT OUTER JOIN   reta_month rm ON (rmos.reta_month_id = rm.reta_month_id)
    LEFT OUTER JOIN   ref_agency ra ON (rm.agency_id = ra.agency_id)
    LEFT OUTER JOIN   ref_state rs ON (ra.state_id = rs.state_id)
    GROUP BY CUBE (data_year, month_num,
                   (offense_subcat_name, offense_subcat_code),
                   (offense_name, offense_code,
                   offense_category_name,
                   classification_name),
                   (state_name, state_abbr)
                   );
