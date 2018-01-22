-- Make sure to run the queries in setup.sql first
--
-- Build a table for violence against women

-- Let's flatten and concatenate location_types
DROP TABLE IF EXISTS flat_location_types CASCADE;
CREATE TABLE flat_location_types (
incident_id bigint PRIMARY KEY,
location_types text
);
INSERT INTO flat_location_types
SELECT i.incident_id, string_agg(DISTINCT nlt.location_name, ', ')
FROM nibrs_offense o
JOIN nibrs_incident i ON i.incident_id = o.incident_id
JOIN nibrs_location_type nlt ON nlt.location_id = o.location_id
JOIN nibrs_month m ON m.nibrs_month_id = i.nibrs_month_id
GROUP BY i.incident_id;

DROP MATERIALIZED VIEW IF EXISTS violence_against_women;
CREATE MATERIALIZED VIEW violence_against_women AS
SELECT m.data_year AS year, c.state_abbr AS state_abbr, i.incident_id, i.incident_date::date AS incident_date, i.incident_hour,
c.ori AS agency_ori, c.agency_name, c.agency_type_name AS agency_type, c.population_group_desc AS agency_group,
cnia.arrest_count AS num_arrests, cnia.first_arrest_date AS first_arrest_date,
i.cleared_except_date::date AS except_clearance_date, CASE WHEN ncl.cleared_except_code != '6' THEN ncl.cleared_except_name ELSE NULL END AS except_clearance_type,
v.victim_id, va.age_code, v.age_num, vr.race_code, ve.ethnicity_code, fv.homicide, fv.manslaughter, fv.kidnapping, fv.robbery,
fv.rape, fv.sodomy, fv.sex_assault_with_object, fv.fondling, fv.aggravated_assault, fv.simple_assault, fv.intimidation, flt.location_types AS locations,
fnvc.circumstance1_code, fnvc.circumstance1_name, fnvc.circumstance2_code, fnvc.circumstance2_name,
CASE WHEN fniw.automatic_firearm + fniw.automatic_handgun + fniw.automatic_rifle + fniw.automatic_shotgun + fniw.automatic_other_firearm + fniw.firearm + fniw.handgun + fniw.rifle + fniw.shotgun + fniw.other_firearm > 0 THEN 1 ELSE 0 END as weapon_gun,
CASE WHEN fniw.lethal_cutting + fniw.knife > 0 THEN 1 ELSE 0 END as weapon_knife,
CASE WHEN fniw.club + fniw.blunt_object > 0 THEN 1 ELSE 0 END as weapon_blunt_object,
CASE WHEN fniw.drugs + fniw.poison > 0 THEN 1 ELSE 0 END as weapon_poison,
CASE WHEN fniw.fire + fniw.explosives > 0 THEN 1 ELSE 0 END as weapon_incendiary,
fniw.motor_vehicle AS weapon_motor_vehicle,
CASE WHEN fniw.personal_weapons + fniw.other_weapon > 0 THEN 1 ELSE 0 END as weapon_other,
fni.injuries AS injuries,
koc.offender_count AS known_offenders, cvr.family, cvr.known, cvr.stranger, cvr.victim_offender, cvr.unknown,
fnvo.offender1_id, fnvo.offender1_age_code, fnvo.offender1_age_num, fnvo.offender1_sex, fnvo.offender1_race, fnvo.offender1_ethnicity, fnvo.offender1_relationship_code, fnvo.offender1_relationship_name,
fnvo.offender2_id, fnvo.offender2_age_code, fnvo.offender2_age_num, fnvo.offender2_sex, fnvo.offender2_race, fnvo.offender2_ethnicity, fnvo.offender2_relationship_code, fnvo.offender2_relationship_name,
fnvo.offender3_id, fnvo.offender3_age_code, fnvo.offender3_age_num, fnvo.offender3_sex, fnvo.offender3_race, fnvo.offender3_ethnicity, fnvo.offender3_relationship_code, fnvo.offender3_relationship_name
FROM nibrs_victim v
JOIN nibrs_incident i ON i.incident_id = v.incident_id
JOIN nibrs_month m ON m.nibrs_month_id = i.nibrs_month_id
JOIN cde_agencies c ON c.agency_id = m.agency_id
JOIN flat_nibrs_victim_violent_offense fv ON fv.victim_id = v.victim_id
LEFT OUTER JOIN count_nibrs_incident_arrests cnia ON cnia.incident_id = i.incident_id
LEFT OUTER JOIN flat_nibrs_incident_weapons fniw ON fniw.incident_id = i.incident_id
LEFT OUTER JOIN nibrs_cleared_except ncl ON ncl.cleared_except_id = i.cleared_except_id
LEFT OUTER JOIN nibrs_age va ON va.age_id = v.age_id
LEFT OUTER JOIN ref_race vr ON vr.race_id = v.race_id
LEFT OUTER JOIN nibrs_ethnicity ve ON ve.ethnicity_id = v.ethnicity_id
LEFT OUTER JOIN count_nibrs_known_offenders koc ON koc.incident_id = i.incident_id
LEFT OUTER JOIN count_victim_relationships cvr ON cvr.victim_id = v.victim_id
LEFT OUTER JOIN flat_nibrs_injury fni ON fni.victim_id = v.victim_id
LEFT OUTER JOIN flat_location_types flt ON flt.incident_id = i.incident_id
LEFT OUTER JOIN flat_nibrs_victim_circumstances fnvc ON fnvc.victim_id = v.victim_id
LEFT OUTER JOIN flat_nibrs_victim_offender fnvo ON fnvo.victim_id = v.victim_id
WHERE v.sex_code = 'F';

CREATE INDEX violence_against_women_year_ix ON violence_against_women(year);
CREATE INDEX violence_against_women_ori_ix ON violence_against_women(agency_ori);
CREATE INDEX violence_against_women_state_abbr_ix ON violence_against_women(state_abbr);
CREATE INDEX violence_against_women_incident_date_ix ON violence_against_women(incident_date);
