DROP TABLE IF EXISTS nibrs_start_years;
CREATE TABLE nibrs_start_years (
agency_id bigint PRIMARY KEY,
year smallint
);

WITH last_non_nibrs AS (select agency_id, max(year) AS year from agency_participation where nibrs_participated = 0 group by agency_id)
INSERT INTO nibrs_start_years(agency_id, year)
SELECT ap.agency_id, min(ap.year) AS nibrs_start_year
from agency_participation ap
JOIN last_non_nibrs l ON l.agency_id = ap.agency_id
where ap.nibrs_participated = 1
AND ap.year > l.year
GROUP BY ap.agency_id;
