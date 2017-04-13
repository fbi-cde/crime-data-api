\set ON_ERROR_STOP on

DROP SEQUENCE IF EXISTS retacubeseq CASCADE;
CREATE SEQUENCE retacubeseq;

CREATE TABLE reta_agency_rollup AS
SELECT
NEXTVAL('retacubeseq') AS reta_month_agency_summary_id,
GROUPING(year, agency_id, agency_ori, agency_name, population, months_reported, nibrs_months_reported, covered_by_id, covered_by_ori, covered_by_name, covered_by_root_id, covered_by_root_ori, covered_by_root_name, classification, offense_category, offense, offense_code) AS grouping_bitmap,
SUM(u.reported_count) AS reported,
SUM(u.unfounded_count) AS unfounded,
SUM(u.actual_count) AS actual,
SUM(u.cleared_count) AS cleared,
SUM(u.juvenile_cleared_count) AS juvenile_cleared,
u.year,
u.agency_id,
u.agency_ori,
u.agency_name,
u.classification,
u.offense_category,
u.offense_code,
u.offense,
u.months_reported,
u.nibrs_months_reported,
u.population,
u.covered_by_id,
u.covered_by_ori,
u.covered_by_name,
u.covered_by_root_id,
u.covered_by_root_ori,
u.covered_by_root_name
FROM
(
   (SELECT
           ra.agency_id,
           ra.ori AS agency_ori,
           ra.pub_agency_name AS agency_name,
           rmos.reported_count,
           rmos.unfounded_count,
           rmos.actual_count,
           rmos.cleared_count,
           rmos.juvenile_cleared_count,
           rm.data_year AS year,
           oc.classification_name AS classification,
           roc.offense_category_name AS offense_category,
           ro.offense_code,
           ro.offense_name AS offense,
           cap.agency_population AS population,
           cap.months_reported,
           cap.months_reported_nibrs AS nibrs_months_reported,
           covered.agency_id AS covered_by_id,
           covered.ori AS covered_by_ori,
           covered.pub_agency_name AS covered_by_name,
           root_covered.agency_id AS covered_by_root_id,
           root_covered.ori AS covered_by_root_ori,
           root_covered.pub_agency_name AS covered_by_root_name,
           cap.months_reported_nibrs AS nibrs_months_reported
    FROM   reta_month_offense_subcat rmos
    LEFT OUTER JOIN   reta_offense_subcat ros ON (rmos.offense_subcat_id = ros.offense_subcat_id)
    LEFT OUTER JOIN   reta_offense ro ON (ros.offense_id = ro.offense_id)
    LEFT OUTER JOIN   reta_offense_category roc ON (ro.offense_category_id = roc.offense_category_id)
    LEFT OUTER JOIN   offense_classification oc ON (ro.classification_id = oc.classification_id)
    LEFT OUTER JOIN   reta_month rm ON (rmos.reta_month_id = rm.reta_month_id)
    LEFT OUTER JOIN   ref_agency ra ON (rm.agency_id = ra.agency_id)
    LEFT OUTER JOIN   cde_annual_participation cap ON (cap.agency_id=rm.agency_id AND cap.data_year=rm.data_year)
    LEFT OUTER JOIN   ref_agency covered ON (covered.agency_id=cap.covered_by_id)
    LEFT OUTER JOIN   ref_agency root_covered ON (root_covered.agency_id=cap.covered_by_root_id)
    WHERE rmos.actual_status NOT IN (2,3,4) AND rm.data_year <= ra.dormant_year
  )
  -- UNION
  --     (SELECT
  --     		ra.agency_id,
  --          	ra.ori AS agency_ori,
  --           ra.pub_agency_name AS agency_name,
  --           ambs.reported_count,
  --           ambs.unfounded_count,
  --           ambs.actual_count,
  --           ambs.cleared_count,
  --           ambs.juvenile_cleared_count,
  --           am.data_year AS year,
  --           'Property'::text as classification,
  --           'Arson'::text as offense_category,
  --           'X_ARS'::text as offense_code,
  --           'Arson'::text as offense,
  --           cap.agency_population AS population,
  --           cap.months_reported,
  --           cap.months_reported_nibrs AS nibrs_months_reported
  --   FROM arson_month_by_subcat ambs
  --   JOIN   arson_month am ON ambs.arson_month_id = am.arson_month_id
  --   LEFT OUTER JOIN   arson_subcategory asuc ON ambs.subcategory_id = asuc.subcategory_id
  --   LEFT OUTER JOIN   ref_agency ra ON am.agency_id = ra.agency_id
  --   LEFT OUTER JOIN   cde_annual_participation cap ON (cap.agency_id=am.agency_id AND cap.data_year=am.data_year)
  --   WHERE ambs.actual_status = 0
	-- )
) AS u
GROUP BY GROUPING SETS(
(agency_id, agency_ori, agency_name),
(agency_id, agency_ori, agency_name, classification),
(agency_id, agency_ori, agency_name, classification, offense_category, offense, offense_code),
(year, agency_id, agency_ori, agency_name, population, months_reported, nibrs_months_reported, covered_by_id, covered_by_ori, covered_by_name, covered_by_root_id, covered_by_root_ori, covered_by_root_name),
(year, agency_id, agency_ori, agency_name, population, months_reported, nibrs_months_reported, covered_by_id, covered_by_ori, covered_by_name, covered_by_root_id, covered_by_root_ori, covered_by_root_name, classification),
(year, agency_id, agency_ori, agency_name, population, months_reported, nibrs_months_reported, covered_by_id, covered_by_ori, covered_by_name, covered_by_root_id, covered_by_root_ori, covered_by_root_name, classification, offense_category),
(year, agency_id, agency_ori, agency_name, population, months_reported, nibrs_months_reported, covered_by_id, covered_by_ori, covered_by_name, covered_by_root_id, covered_by_root_ori, covered_by_root_name, classification, offense_category, offense, offense_code)
);

DROP TABLE IF EXISTS reta_annual_offense_agency_summary CASCADE;
ALTER TABLE reta_agency_rollup RENAME TO reta_annual_offense_agency_summary;
