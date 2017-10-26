DROP TABLE IF EXISTS participation_rates_temp CASCADE;
CREATE TABLE participation_rates_temp
(
    participation_id serial PRIMARY KEY,
    year smallint NOT NULL,
    state_id bigint,
    state_name varchar(255),
    county_id bigint,
    county_name varchar(255),
    total_agencies int,
    participating_agencies int,
    participation_rate float,
    nibrs_participating_agencies int,
    nibrs_participation_rate float,
    covered_agencies int,
    covered_rate float,
    total_population bigint,
    participating_population bigint,
    nibrs_participating_population bigint
);

ALTER TABLE ONLY participation_rates_temp
ADD CONSTRAINT participation_rates_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);

ALTER TABLE ONLY participation_rates_temp
ADD CONSTRAINT participation_rates_county_fk FOREIGN KEY (county_id) REFERENCES ref_county(county_id);

INSERT INTO participation_rates_temp(year, state_id, state_name, total_agencies, participating_agencies, participation_rate, nibrs_participating_agencies, nibrs_participation_rate, covered_agencies, covered_rate, participating_population, nibrs_participating_population)
SELECT
c.year,
a.state_id,
rs.state_name,
COUNT(a.ori) AS total_agencies,
SUM(c.participated) AS participating_agencies,
CAST(SUM(c.participated) AS float)/COUNT(a.ORI) AS participation_rate,
SUM(c.nibrs_participated) AS nibrs_participating_agencies,
CAST(SUM(c.nibrs_participated) AS float)/COUNT(a.ORI) AS nibrs_participation_rate,
COUNT(racb.agency_id) AS covered_agencies,
CAST(COUNT(racb.agency_id) AS float)/COUNT(a.ORI) AS covered_rate,
0 AS participating_population,
0 as nibrs_participating_population
FROM agency_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
JOIN ref_state rs ON a.state_id = rs.state_id
LEFT OUTER JOIN ref_agency_covered_by racb ON racb.agency_id=c.agency_id AND racb.data_year=c.year
GROUP BY c.year, a.state_id, rs.state_name;

-- If an agency spans multiple counties, it will be counted once in
-- the total/reporting agencies counts for each county. Its population
-- is apportioned individually though, so its full population won't be
-- duplicated for each county
INSERT INTO participation_rates_temp(year, county_id, county_name, total_agencies, participating_agencies, participation_rate, nibrs_participating_agencies, nibrs_participation_rate, total_population, participating_population, nibrs_participating_population, covered_agencies, covered_rate)
SELECT
c.year,
rc.county_id,
rc.county_name,
COUNT(a.ori) AS total_agencies,
SUM(c.participated) AS participating_agencies,
CAST(SUM(c.participated) AS float)/COUNT(a.ori) AS participation_rate,
SUM(c.nibrs_participated) AS nibrs_participating_agencies,
CAST(SUM(c.nibrs_participated) AS float)/COUNT(a.ori) AS nibrs_participation_rate,
SUM(rac.population) AS total_population,
SUM(CASE WHEN c.participated = 1 THEN rac.population ELSE 0 END) AS participating_population,
SUM(CASE WHEN c.nibrs_participated = 1 THEN rac.population ELSE 0 END) AS nibrs_participating_population,
COUNT(racb.agency_id) AS covered_agencies,
CAST(COUNT(racb.agency_id) AS float)/COUNT(a.ori) AS covered_rate
FROM agency_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
JOIN ref_agency_county rac ON rac.agency_id = a.agency_id AND rac.data_year = c.year
JOIN ref_county rc ON rc.county_id = rac.county_id
LEFT OUTER JOIN ref_agency_covered_by racb ON racb.agency_id=c.agency_id AND racb.data_year=c.year
GROUP BY c.year, rc.county_id, rc.county_name;

UPDATE participation_rates_temp
SET total_population=(SELECT COALESCE(SUM(rac.population), 0)
                      FROM ref_agency_county rac
                      JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                      WHERE ra.state_id=participation_rates_temp.state_id
                      AND rac.data_year=participation_rates_temp.year)
WHERE state_id IS NOT NULL;

UPDATE participation_rates_temp
SET participating_population=(SELECT COALESCE(SUM(rac.population), 0)
                              FROM ref_agency_county rac
                              JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                              JOIN agency_participation c ON c.agency_id=ra.agency_id AND c.year=rac.data_year
                              WHERE ra.state_id=participation_rates_temp.state_id
                              AND rac.data_year=participation_rates_temp.year
                              AND c.participated = 1)
WHERE state_id IS NOT NULL;

UPDATE participation_rates_temp
SET nibrs_participating_population=(SELECT COALESCE(SUM(rac.population), 0)
FROM ref_agency_county rac
JOIN ref_agency ra ON ra.agency_id=rac.agency_id
JOIN agency_participation c ON c.agency_id=ra.agency_id AND c.year=rac.data_year
WHERE ra.state_id=participation_rates_temp.state_id
AND rac.data_year=participation_rates_temp.year
AND c.nibrs_participated = 1)
WHERE state_id IS NOT NULL;

--- annual rollups
INSERT INTO participation_rates_temp(year, total_agencies, participating_agencies, participation_rate, nibrs_participating_agencies, nibrs_participation_rate, covered_agencies, covered_rate, participating_population)
SELECT
c.year,
COUNT(a.ori) AS total_agencies,
SUM(c.participated) AS participating_agencies,
CAST(SUM(c.participated) AS float)/COUNT(a.ORI) AS participation_rate,
SUM(c.nibrs_participated) AS nibrs_participating_agencies,
CAST(SUM(c.nibrs_participated) AS float)/COUNT(a.ORI) AS nibrs_participation_rate,
COUNT(racb.agency_id) as covered_agencies,
CAST(COUNT(racb.agency_id) AS float)/COUNT(a.ORI) AS covered_rate,
0 as participation_population
FROM agency_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
LEFT OUTER JOIN ref_agency_covered_by racb ON racb.agency_id=c.agency_id AND racb.data_year=c.year
GROUP BY c.year;

UPDATE participation_rates_temp
SET total_population=(SELECT COALESCE(SUM(rac.population), 0)
                      FROM ref_agency_county rac
                      JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                      WHERE rac.data_year=participation_rates_temp.year)
WHERE state_id IS NULL AND county_id IS NULL;

UPDATE participation_rates_temp
SET participating_population=(SELECT COALESCE(SUM(rac.population), 0)
                              FROM ref_agency_county rac
                              JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                              JOIN agency_participation c ON c.agency_id=rac.agency_id AND c.year=rac.data_year
                              WHERE rac.data_year=participation_rates_temp.year
                              AND c.participated=1)
                              WHERE state_id IS NULL AND county_id IS NULL;

UPDATE participation_rates_temp
SET nibrs_participating_population=(SELECT COALESCE(SUM(rac.population), 0)
FROM ref_agency_county rac
JOIN ref_agency ra ON ra.agency_id=rac.agency_id
JOIN agency_participation c ON c.agency_id=rac.agency_id AND c.year=rac.data_year
WHERE rac.data_year=participation_rates_temp.year
AND c.nibrs_participated=1)
WHERE state_id IS NULL AND county_id IS NULL;

DROP TABLE IF EXISTS participation_rates CASCADE;
ALTER TABLE participation_rates_temp RENAME TO participation_rates;
