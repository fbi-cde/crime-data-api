SET work_mem='4096MB'; -- Go Super Saiyan.

drop materialized view cde_annual_participation;
create materialized view cde_annual_participation AS
SELECT rm.data_year,
rs.state_name AS state_name,
rs.state_postal_abbr AS state_abbr,
ra.agency_id,
ra.ori as agency_ori,
ra.pub_agency_name as agency_name,
rap.population AS agency_population,
rpg.population_group_code AS population_group_code,
rpg.population_group_desc AS population_group,
bool_or(CASE WHEN reported_flag = 'Y' THEN TRUE ELSE FALSE END)::int AS reported,
bool_and(CASE WHEN reported_flag = 'Y' THEN TRUE ELSE FALSE END)::int AS reported_12mos
from reta_month rm
JOIN ref_agency ra ON ra.agency_id = rm.agency_id
JOIN ref_state rs ON rs.state_id = ra.state_id
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id = rm.agency_id AND rap.data_year = rm.data_year
LEFT OUTER JOIN ref_population_group rpg ON rpg.population_group_id = rap.population_group_id
group by rm.data_year, rs.state_name, rs.state_postal_abbr, ra.agency_id, ra.ori, ra.pub_agency_name, rap.population, rpg.population_group_code, rpg.population_group_desc
ORDER by rm.data_year, rs.state_name, ra.pub_agency_name;

drop table if exists cde_participation_rates;
CREATE TABLE cde_participation_rates
(
    data_year smallint NOT NULL,
    state_id bigint,
    county_id bigint,
    total_agencies int,
    reporting_agencies int,
    reporting_rate float,
    total_population bigint,
    covered_population bigint
)
WITH (
    OIDS = FALSE
);

INSERT INTO cde_participation_rates(data_year, state_id, total_agencies, reporting_agencies, reporting_rate)
SELECT c.data_year, a.state_id, COUNT(a.ori) AS total_agencies, SUM(c.reported) AS reporting_agencies,
CAST(SUM(c.reported) AS float)/COUNT(a.ORI) AS reporting_rate
FROM cde_annual_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
GROUP BY c.data_year, a.state_id;

-- If an agency spans multiple counties, it will be counted once in
-- the total/reporting agencies counts for each county. Its population
-- is apportioned individually though, so its full population won't be
-- duplicated for each county
INSERT INTO cde_participation_rates(data_year, county_id, total_agencies, reporting_agencies, reporting_rate, total_population, covered_population)
SELECT c.data_year, rc.county_id, COUNT(a.ori) AS total_agencies, SUM(c.reported) AS reporting_agencies,
CAST(SUM(c.reported) AS float)/COUNT(a.ori) AS reporting_rate,
rcp.population AS total_population,
SUM(rac.population) AS covered_population
FROM cde_annual_participation c
JOIN ref_agency a ON a.agency_id = c.agency_id
JOIN ref_agency_county rac ON rac.agency_id = a.agency_id AND rac.data_year = c.data_year
JOIN ref_county rc ON rc.county_id = rac.county_id
JOIN ref_county_population rcp ON rcp.county_id = rac.county_id AND rcp.data_year = c.data_year
GROUP BY c.data_year, rc.county_id, rcp.population;

UPDATE cde_participation_rates
SET total_population=(SELECT SUM(rcp.population)
                          FROM ref_county_population rcp
                          JOIN ref_county rc ON rc.county_id=rcp.county_id
                          WHERE rc.state_id=cde_participation_rates.state_id
                          AND rcp.data_year=cde_participation_rates.data_year)
WHERE state_id IS NOT NULL;

UPDATE cde_participation_rates
SET covered_population=(SELECT SUM(rca.population)
                        FROM ref_agency_county rca
                        JOIN ref_agency ra ON ra.agency_id=rca.agency_id
                        JOIN cde_annual_participation cap ON cap.agency_id=rca.agency_id
                        WHERE cap.data_year = rca.data_year
                        AND cap.data_year = cde_participation_rates.data_year
                        AND ra.state_id = cde_participation_rates.state_id
                        AND cap.reported = 1)
WHERE state_id IS NOT NULL;
