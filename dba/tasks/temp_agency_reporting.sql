SET work_mem='4096MB'; -- Go Super Saiyan.

-- first create reporting code
DROP TABLE IF EXISTS temp_agency_reporting CASCADE;
CREATE TABLE temp_agency_reporting AS
SELECT
data_year,
agency_id,
SUM(CASE WHEN reported_flag = 'Y' THEN 1 ELSE 0 END)::int AS months_reported
FROM reta_month
GROUP by data_year, agency_id;
