\set ON_ERROR_STOP on

DROP TABLE IF EXISTS denorm_agencies_temp CASCADE;
CREATE TABLE denorm_agencies_temp
(
    agency_id bigint PRIMARY KEY,
    ori character(9) NOT NULL,
    legacy_ori character(9) NOT NULL,
    agency_name character varying(100),
    agency_type_id smallint NOT NULL,
    agency_type_name character varying(100),
    tribe_id bigint,
    campus_id bigint,
    city_id bigint,
    city_name character varying(100),
    state_id smallint NOT NULL,
    state_abbr character(2) NOT NULL,
    agency_status character(1) NOT NULL,
    submitting_agency_id bigint,
    submitting_sai character varying(9),
    submitting_name character varying(150),
    submitting_state_abbr character varying(2),
    start_year smallint,
    dormant_year smallint,
    current_year smallint,
    revised_rape_start smallint,
    population bigint,
    population_group_code character varying(2),
    population_group_desc character varying(150),
    population_source_flag character varying(1),
    suburban_area_flag character varying(1),
    core_city_flag character varying(1),
    months_reported smallint,
    nibrs_months_reported smallint,
    covered_by_id bigint,
    covered_by_ori character(9),
    covered_by_name character varying(100),
    staffing_year smallint,
    total_officers int,
    total_civilians int
 );

--- foreign keys
ALTER TABLE ONLY denorm_agencies_temp
ADD CONSTRAINT agencies_tribe_fk FOREIGN KEY (tribe_id) REFERENCES ref_tribe(tribe_id);

ALTER TABLE ONLY denorm_agencies_temp
ADD CONSTRAINT agencies_city_fk FOREIGN KEY (city_id) REFERENCES ref_city(city_id);

ALTER TABLE ONLY denorm_agencies_temp
ADD CONSTRAINT agencies_campus_fk FOREIGN KEY (campus_id) REFERENCES ref_university_campus(campus_id);

ALTER TABLE ONLY denorm_agencies_temp
ADD CONSTRAINT agencies_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);

ALTER TABLE denorm_agencies_temp DISABLE TRIGGER ALL;


INSERT INTO denorm_agencies_temp
SELECT
ra.agency_id,
ra.ori,
ra.legacy_ori,
ra.pub_agency_name AS agency_name,
ra.agency_type_id,
rat.agency_type_name,
ra.tribe_id,
ra.campus_id,
ra.city_id,
rc.city_name,
ra.state_id,
rs.state_postal_abbr AS state_abbr,
ra.agency_status,
ra.submitting_agency_id,
rsa.sai AS submitting_sai,
rsa.agency_name AS submitting_name,
rss.state_postal_abbr AS submitting_state_abbr,
y.start_year,
ra.dormant_year,
y.current_year AS current_year,
radc.revised_year AS revised_rape_start,
rap.population,
rpg.population_group_code,
rpg.population_group_desc,
rap.source_flag AS population_source_flag,
rap.suburban_area_flag,
rac.core_city_flag,
cap.months_reported,
cap.nibrs_reported AS nibrs_months_reported,
racp.covered_by_agency_id AS covered_by_id,
covering.ori AS covered_by_ori,
covering.pub_agency_name AS covered_by_name,
pe.staffing_year AS staffing_year,
COALESCE(ped.male_officer + ped.female_officer) AS total_officers,
COALESCE(ped.male_civilian + ped.female_civilian) AS total_civilians
FROM ref_agency ra
JOIN ref_agency_type rat ON rat.agency_type_id = ra.agency_type_id
LEFT OUTER JOIN (SELECT agency_id, min(data_year) AS start_year, max(data_year) AS current_year FROM ref_agency_population GROUP BY agency_id) y ON y.agency_id=ra.agency_id
LEFT OUTER JOIN (SELECT agency_id, max(data_year) AS staffing_year FROM pe_employee_data WHERE reported_flag='Y' GROUP BY agency_id) pe ON pe.agency_id=ra.agency_id
LEFT OUTER JOIN (SELECT agency_id, min(data_year) AS revised_year FROM ref_agency_data_content WHERE summary_rape_def = 'R' GROUP BY agency_id) radc ON radc.agency_id=ra.agency_id
LEFT OUTER JOIN ref_city rc ON rc.city_id=ra.city_id
LEFT OUTER JOIN ref_state rs ON rs.state_id=ra.state_id
LEFT OUTER JOIN agency_participation cap ON cap.agency_id=ra.agency_id AND cap.year=y.current_year
LEFT OUTER JOIN ref_submitting_agency rsa ON rsa.agency_id=ra.submitting_agency_id
LEFT OUTER JOIN ref_state rss ON rss.state_id=rsa.state_id
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id=ra.agency_id AND rap.data_year=y.current_year
LEFT OUTER JOIN (SELECT DISTINCT ON (agency_id, data_year) agency_id, data_year, core_city_flag FROM ref_agency_county ORDER BY agency_id, data_year, core_city_flag DESC) rac ON rac.agency_id=ra.agency_id AND rac.data_year=y.current_year
LEFT OUTER JOIN ref_population_group rpg ON rpg.population_group_id=rap.population_group_id
LEFT OUTER JOIN ref_agency_covered_by_flat racp ON racp.agency_id=ra.agency_id AND racp.data_year=y.current_year
LEFT OUTER JOIN ref_agency covering ON covering.agency_id=racp.covered_by_agency_id
LEFT OUTER JOIN pe_employee_data ped ON ped.agency_id=ra.agency_id AND ped.data_year=pe.staffing_year;

ALTER TABLE denorm_agencies_temp ENABLE TRIGGER ALL;
DROP TABLE IF EXISTS cde_agencies CASCADE;
ALTER TABLE denorm_agencies_temp RENAME TO cde_agencies;
