DROP TABLE IF EXISTS temp_agency_sums_by_classification;
CREATE table agency_sums_by_classification (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL,
classification TEXT NOT NULL,
reported integer,
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer
);

INSERT INTO temp_agency_sums_by_classification(data_year, agency_id, classification, reported, unfounded, actual, cleared, juvenile_cleared)
SELECT
a.data_year,
a.agency_id,
oc.classification_name AS classification,
SUM(a.reported) AS reported,
SUM(a.unfounded) AS unfounded,
SUM(a.actual) AS actual,
SUM(a.cleared) AS cleared,
SUM(a.juvenile_cleared) AS juvenile_cleared
FROM temp_agency_sums a
JOIN reta_offense_subcat ros ON a.offense_subcat_id = ros.offense_subcat_id
JOIN reta_offense ro ON ro.offense_id = ros.offense_id
JOIN offense_classification oc ON oc.classification_id = ro.classification_id
WHERE a.offense_subcat_id <> 45
GROUP by a.data_year, a.agency_id, oc.classification_name;
