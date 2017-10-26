DROP TABLE IF EXISTS temp_agency_reporting_nibrs CASCADE;
CREATE TABLE temp_agency_reporting_nibrs AS
SELECT
data_year,
agency_id,
SUM(CASE WHEN reported_status IN ('I', 'Z') THEN 1 ELSE 0 END)::int AS months_reported
FROM nibrs_month
GROUP by data_year, agency_id;
