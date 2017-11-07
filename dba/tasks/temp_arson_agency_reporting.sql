DROP TABLE IF EXISTS temp_arson_agency_reporting;
CREATE TABLE temp_arson_agency_reporting AS
SELECT rm.data_year,
rm.agency_id,
SUM(CASE WHEN rm.reported_flag = 'Y' THEN 1 ELSE 0 END) AS months_reported
FROM arson_month rm
GROUP BY rm.data_year, rm.agency_id;
