SET work_mem='4096MB'; -- Go Super Saiyan.

create materialized view cde_annual_participation_temp AS
SELECT rm.data_year,
rs.state_name AS state_name,
rs.state_postal_abbr AS state_abbr,
ra.agency_id,
ra.ori as agency_ori,
ra.pub_agency_name as agency_name,
rap.population AS agency_population,
rpg.population_group_code AS population_group_code,
rpg.population_group_desc AS population_group,
bool_or(CASE WHEN rm.reported_flag = 'Y' THEN TRUE ELSE FALSE END)::int AS reported,
SUM(CASE WHEN rm.reported_flag = 'Y' THEN 1 ELSE 0 END)::int AS months_reported,
bool_or(CASE WHEN nm.reported_status IN ('I', 'Z') THEN TRUE ELSE FALSE END)::int AS reported_nibrs,
SUM(CASE WHEN nm.reported_status IN ('I', 'Z') THEN 1 ELSE 0 END)::int AS months_reported_nibrs
FROM reta_month rm
JOIN ref_agency ra ON ra.agency_id = rm.agency_id
JOIN ref_state rs ON rs.state_id = ra.state_id
LEFT OUTER JOIN nibrs_month nm ON nm.agency_id = rm.agency_id AND nm.data_year = rm.data_year AND nm.month_num = rm.month_num
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id = rm.agency_id AND rap.data_year = rm.data_year
LEFT OUTER JOIN ref_population_group rpg ON rpg.population_group_id = rap.population_group_id
group by rm.data_year, rs.state_name, rs.state_postal_abbr, ra.agency_id, ra.ori, ra.pub_agency_name, rap.population, rpg.population_group_code, rpg.population_group_desc
ORDER by rm.data_year, rs.state_name, ra.pub_agency_name;

--- this lets us rebuild with less disruption
DROP MATERIALIZED VIEW IF EXISTS cde_annual_participation CASCADE;
ALTER MATERIALIZED VIEW cde_annual_participation_temp RENAME TO cde_annual_participation;


drop table if exists cde_participation_rates_temp;
CREATE TABLE cde_participation_rates_temp
(
    data_year smallint NOT NULL,
    state_id bigint,
    state_name varchar(255),
    county_id bigint,
    county_name varchar(255),
    total_agencies int,
    reporting_agencies int,
    reporting_rate float,
    nibrs_reporting_agencies int,
    nibrs_reporting_rate float,
    total_population bigint,
    covered_population bigint,
    nibrs_covered_population bigint
)
WITH (
    OIDS = FALSE
);

ALTER TABLE ONLY cde_participation_rates_temp
ADD CONSTRAINT cde_participation_rates_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);

ALTER TABLE ONLY cde_participation_rates_temp
ADD CONSTRAINT cde_participation_rates_county_fk FOREIGN KEY (county_id) REFERENCES ref_county(county_id);


INSERT INTO cde_participation_rates_temp(data_year, state_id, state_name, total_agencies, reporting_agencies, reporting_rate, nibrs_reporting_agencies, nibrs_reporting_rate)
SELECT c.data_year, a.state_id, rs.state_name, COUNT(a.ori) AS total_agencies, SUM(c.reported) AS reporting_agencies,
CAST(SUM(c.reported) AS float)/COUNT(a.ORI) AS reporting_rate,
SUM(c.reported_nibrs) AS nibrs_reporting_agencies,
CAST(SUM(c.reported_nibrs) AS float)/COUNT(a.ORI) AS nibrs_reporting_rate
FROM cde_annual_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
JOIN ref_state rs ON a.state_id = rs.state_id
GROUP BY c.data_year, a.state_id, rs.state_name;

-- If an agency spans multiple counties, it will be counted once in
-- the total/reporting agencies counts for each county. Its population
-- is apportioned individually though, so its full population won't be
-- duplicated for each county
INSERT INTO cde_participation_rates_temp(data_year, county_id, county_name, total_agencies, reporting_agencies, reporting_rate, nibrs_reporting_agencies, nibrs_reporting_rate, total_population, covered_population, nibrs_covered_population)
SELECT c.data_year, rc.county_id, rc.county_name, COUNT(a.ori) AS total_agencies, SUM(c.reported) AS reporting_agencies,
CAST(SUM(c.reported) AS float)/COUNT(a.ori) AS reporting_rate,
SUM(c.reported_nibrs) AS nibrs_reporting_agencies,
CAST(SUM(c.reported_nibrs) AS float)/COUNT(a.ori) AS nibrs_reporting_rate,
SUM(rac.population) AS total_population,
SUM(CASE WHEN c.reported = 1 THEN rac.population ELSE 0 END) AS covered_population,
SUM(CASE WHEN c.reported_nibrs = 1 THEN rac.population ELSE 0 END) AS nibrs_covered_population
FROM cde_annual_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
JOIN ref_agency_county rac ON rac.agency_id = a.agency_id AND rac.data_year = c.data_year
JOIN ref_county rc ON rc.county_id = rac.county_id
GROUP BY c.data_year, rc.county_id, rc.county_name;

UPDATE cde_participation_rates_temp
SET total_population=(SELECT SUM(rac.population)
                      FROM ref_agency_county rac
                      JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                      WHERE ra.state_id=cde_participation_rates_temp.state_id
                      AND rac.data_year=cde_participation_rates_temp.data_year)
WHERE state_id IS NOT NULL;

UPDATE cde_participation_rates_temp
SET covered_population=(SELECT SUM(rca.population)
                        FROM ref_agency_county rca
                        JOIN ref_agency ra ON ra.agency_id=rca.agency_id
                        JOIN cde_annual_participation cap ON cap.agency_id=rca.agency_id
                        WHERE cap.data_year = rca.data_year
                        AND cap.data_year = cde_participation_rates_temp.data_year
                        AND ra.state_id = cde_participation_rates_temp.state_id
                        AND cap.reported = 1)
WHERE state_id IS NOT NULL;

UPDATE cde_participation_rates_temp
SET nibrs_covered_population=(SELECT SUM(rca.population)
                              FROM ref_agency_county rca
                              JOIN ref_agency ra ON ra.agency_id=rca.agency_id
                              JOIN cde_annual_participation cap ON cap.agency_id=rca.agency_id
                              WHERE cap.data_year = rca.data_year
                              AND cap.data_year = cde_participation_rates_temp.data_year
                              AND ra.state_id = cde_participation_rates_temp.state_id
                              AND cap.reported_nibrs = 1)
WHERE state_id IS NOT NULL;

--- annual rollups
INSERT INTO cde_participation_rates_temp(data_year, total_agencies, reporting_agencies, reporting_rate, nibrs_reporting_agencies, nibrs_reporting_rate)
SELECT c.data_year, COUNT(a.ori) AS total_agencies, SUM(c.reported) AS reporting_agencies,
CAST(SUM(c.reported) AS float)/COUNT(a.ORI) AS reporting_rate,
SUM(c.reported_nibrs) AS nibrs_reporting_agencies,
CAST(SUM(c.reported_nibrs) AS float)/COUNT(a.ORI) AS nibrs_reporting_rate
FROM cde_annual_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
GROUP BY c.data_year;

UPDATE cde_participation_rates_temp
SET total_population=(SELECT SUM(rac.population)
                      FROM ref_agency_county rac
                      JOIN ref_agency ra ON ra.agency_id=rac.agency_id
                      WHERE rac.data_year=cde_participation_rates_temp.data_year)
WHERE state_id IS NULL AND county_id IS NULL;

UPDATE cde_participation_rates_temp
SET covered_population=(SELECT SUM(rca.population)
                        FROM ref_agency_county rca
                        JOIN ref_agency ra ON ra.agency_id=rca.agency_id
                        JOIN cde_annual_participation cap ON cap.agency_id=rca.agency_id
                        WHERE cap.data_year = rca.data_year
                        AND cap.data_year = cde_participation_rates_temp.data_year
                        AND cap.reported = 1)
WHERE state_id IS NULL AND county_id IS NULL;

UPDATE cde_participation_rates_temp
SET nibrs_covered_population=(SELECT SUM(rca.population)
                              FROM ref_agency_county rca
                              JOIN ref_agency ra ON ra.agency_id=rca.agency_id
                              JOIN cde_annual_participation cap ON cap.agency_id=rca.agency_id
                              WHERE cap.data_year = rca.data_year
                              AND cap.data_year = cde_participation_rates_temp.data_year
                              AND cap.reported_nibrs = 1)
WHERE state_id IS NULL AND county_id IS NULL;

DROP TABLE IF EXISTS cde_participation_rates CASCADE;
ALTER TABLE cde_participation_rates_temp RENAME TO cde_participation_rates;
