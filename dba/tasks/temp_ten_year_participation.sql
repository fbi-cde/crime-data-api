DO $$
DECLARE
max_year smallint;
BEGIN
max_year := (SELECT MAX(year) from agency_participation);

DROP TABLE IF EXISTS temp_ten_year_participation;
CREATE TABLE temp_ten_year_participation AS
SELECT agency_id,
SUM(reported) AS years_reporting
FROM agency_participation
WHERE year <= max_year
AND year > max_year - 10
GROUP BY agency_id;
END $$;
