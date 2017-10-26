DROP TABLE IF EXISTS temp_covering_counts;
CREATE TABLE temp_covering_counts AS
SELECT data_year, covered_by_agency_id, COUNT(agency_id) AS count
FROM ref_agency_covered_by_flat
GROUP BY covered_by_agency_id, data_year;
