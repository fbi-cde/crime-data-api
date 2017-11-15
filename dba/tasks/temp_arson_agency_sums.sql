DROP TABLE IF EXISTS temp_arson_agency_sums CASCADE;
CREATE TABLE temp_arson_agency_sums (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL,
reported integer,
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer,
uninhabited bigint,
est_damage_value bigint
);

INSERT INTO temp_arson_agency_sums (data_year, agency_id, reported, unfounded, actual, cleared, juvenile_cleared, uninhabited, est_damage_value)
SELECT am.data_year,
am.agency_id,
SUM(ambs.reported_count) AS reported,
SUM(ambs.unfounded_count) AS unfounded,
SUM(ambs.actual_count) AS actual,
SUM(ambs.cleared_count) AS cleared,
SUM(ambs.juvenile_cleared_count) AS juvenile_cleared,
SUM(ambs.uninhabited_count) AS uninhabited,
SUM(ambs.est_damage_value) AS est_damage_value
FROM arson_month_by_subcat ambs
JOIN arson_month am ON ambs.arson_month_id = am.arson_month_id
JOIN temp_arson_agency_reporting rep ON rep.agency_id=am.agency_id AND rep.data_year=am.data_year
WHERE rep.months_reported = 12
AND ambs.actual_status = 0
GROUP BY am.data_year, am.agency_id;
