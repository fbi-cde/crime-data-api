-- Some background tables that are useful for building specialized
-- reports
CREATE MATERIALIZED VIEW counts_nibrs_known_offenders AS SELECT incident_id, COUNT(offender_id) AS offender_count FROM nibrs_offender WHERE offender_seq_num > 0 GROUP by incident_id;

-- There can be up to two circumstances associated with an incident
DROP TABLE IF EXISTS flat_nibrs_victim_circumstances CASCADE;
CREATE TABLE nibrs_victim_circumstances_flat (
  victim_id bigint PRIMARY KEY,
  circumstance1_code smallint,
  circumstance1_name varchar(100),
  justifiable1_code varchar(1),
  justifiable1_name varchar(100),
  circumstance2_code smallint,
  circumstance2_name varchar(100)
);

INSERT INTO flat_nibrs_victim_circumstances
SELECT vc1.victim_id, c1.circumstances_code, c1.circumstances_name,
       jf1.justifiable_force_code, jf1.justifiable_force_name,
       c2.circumstances_code, c2.circumstances_name
FROM nibrs_victim_circumstances vc1
JOIN nibrs_circumstances c1 ON c1.circumstances_id = vc1.circumstances_id
LEFT OUTER JOIN nibrs_justifiable_force jf1 ON jf1.justifiable_force_id = vc1.justifiable_force_id
JOIN nibrs_victim_circumstances vc2 ON vc2.victim_id = vc1.victim_id AND vc2.circumstances_id > vc1.circumstances_id
JOIN nibrs_circumstances c2 ON c2.circumstances_id = vc2.circumstances_id;

INSERT INTO flat_nibrs_victim_circumstances
SELECT vc1.victim_id, c1.circumstances_code, c1.circumstances_name,
       jf1.justifiable_force_code, jf1.justifiable_force_name
FROM nibrs_victim_circumstances vc1
JOIN nibrs_circumstances c1 ON c1.circumstances_id = vc1.circumstances_id
LEFT OUTER JOIN nibrs_justifiable_force jf1 ON jf1.justifiable_force_id = vc1.justifiable_force_id
ON CONFLICT DO NOTHING; -- only if not already in the table

-- There can be up to 99 offenders associated with an incident, but we
-- will just do first 4
DROP TABLE IF EXISTS flat_nibrs_offender CASCADE;
CREATE TABLE flat_nibrs_offender (
  incident_id bigint PRIMARY KEY,
  num_offenders int,
  offender1_id bigint,
  offender1_age_code varchar(2),
  offender1_age_num smallint,
  offender1_sex varchar(1),
  offender1_race varchar(2),
  offender1_ethnicity varchar(1),
  offender2_id bigint,
  offender2_age_code varchar(2),
  offender2_age_num smallint,
  offender2_sex varchar(1),
  offender2_race varchar(2),
  offender2_ethnicity varchar(1),
  offender3_id bigint,
  offender3_age_code varchar(2),
  offender3_age_num smallint,
  offender3_sex varchar(1),
  offender3_race varchar(2),
  offender3_ethnicity varchar(1),
  offender4_id bigint,
  offender4_age_code varchar(2),
  offender4_age_num smallint,
  offender4_sex varchar(1),
  offender4_race varchar(2),
  offender4_ethnicity varchar(1)
);

INSERT INTO flat_nibrs_offender
SELECT o1.incident_id, koc.offender_count,
o1.offender_id, o1a.age_code, o1.age_num, o1.sex_code, o1r.race_code, o1e.ethnicity_code,
o2.offender_id, o2a.age_code, o2.age_num, o2.sex_code, o2r.race_code, o2e.ethnicity_code,
o3.offender_id, o3a.age_code, o3.age_num, o3.sex_code, o3r.race_code, o3e.ethnicity_code,
o4.offender_id, o4a.age_code, o4.age_num, o4.sex_code, o4r.race_code, o4e.ethnicity_code
FROM nibrs_offender o1
LEFT OUTER JOIN count_nibrs_known_offenders koc ON koc.incident_id = o1.incident_id
LEFT OUTER JOIN nibrs_age o1a ON o1a.age_id = o1.age_id
LEFT OUTER JOIN ref_race o1r ON o1r.race_id = o1.race_id
LEFT OUTER JOIN nibrs_ethnicity o1e ON o1e.ethnicity_id = o1.ethnicity_id
LEFT OUTER JOIN nibrs_offender o2 ON o2.incident_id = o1.incident_id AND o2.offender_seq_num = 2
LEFT OUTER JOIN nibrs_age o2a ON o2a.age_id = o2.age_id
LEFT OUTER JOIN ref_race o2r ON o2r.race_id = o2.race_id
LEFT OUTER JOIN nibrs_ethnicity o2e ON o2e.ethnicity_id = o2.ethnicity_id
LEFT OUTER JOIN nibrs_offender o3 ON o3.incident_id = o1.incident_id AND o3.offender_seq_num = 3
LEFT OUTER JOIN nibrs_age o3a ON o3a.age_id = o3.age_id
LEFT OUTER JOIN ref_race o3r ON o3r.race_id = o3.race_id
LEFT OUTER JOIN nibrs_ethnicity o3e ON o3e.ethnicity_id = o3.ethnicity_id
LEFT OUTER JOIN nibrs_offender o4 ON o4.incident_id = o1.incident_id AND o4.offender_seq_num = 4
LEFT OUTER JOIN nibrs_age o4a ON o4a.age_id = o4.age_id
LEFT OUTER JOIN ref_race o4r ON o4r.race_id = o4.race_id
LEFT OUTER JOIN nibrs_ethnicity o4e ON o4e.ethnicity_id = o4.ethnicity_id
WHERE o1.offender_seq_num = 1;

-- There can be up to 3 weapons associated with an offense
DROP TABLE IF EXISTS flat_nibrs_weapon CASCADE;
CREATE TABLE flat_nibrs_weapon (
  offense_id bigint PRIMARY KEY,
  weapon1_code varchar(3),
  weapon1_name varchar(100),
  weapon2_code varchar(3),
  weapon2_name varchar(100),
  weapon3_code varchar(3),
  weapon3_name varchar(100)
);

INSERT INTO flat_nibrs_weapon
SELECT nw1.offense_id, nwt1.weapon_code, nwt2.weapon_name, nwt2.weapon_code, nwt2.weapon_name, nwt3.weapon_code, nwt3.weapon_name
FROM nibrs_weapon nw1
JOIN nibrs_weapon_type nwt1 ON nwt1.weapon_id = nw1.weapon_id
JOIN nibrs_weapon nw2 ON nw2.offense_id = nw1.offense_id AND nw2.weapon_id > nw1.weapon_id
JOIN nibrs_weapon_type nwt2 ON nwt2.weapon_id = nw2.weapon_id
JOIN nibrs_weapon nw3 ON nw3.offense_id = nw2.offense_id AND nw3.weapon_id > nw2.weapon_id
JOIN nibrs_weapon_type nwt3 ON nwt3.weapon_id = nw3.weapon_id;

INSERT INTO flat_nibrs_weapon(offense_id, weapon1_code, weapon1_name, weapon2_code, weapon2_name)
SELECT nw1.offense_id, nwt1.weapon_code, nwt1.weapon_name, nwt2.weapon_code, nwt2.weapon_name
FROM nibrs_weapon nw1
JOIN nibrs_weapon_type nwt1 ON nwt1.weapon_id = nw1.weapon_id
JOIN nibrs_weapon nw2 ON nw2.offense_id = nw1.offense_id AND nw2.weapon_id > nw1.weapon_id
JOIN nibrs_weapon_type nwt2 ON nwt2.weapon_id = nw2.weapon_id
ON CONFLICT DO NOTHING;

INSERT INTO flat_nibrs_weapon(offense_id, weapon1_code, weapon1_name)
SELECT nw1.offense_id, nwt1.weapon_code, nwt1.weapon_name FROM nibrs_weapon nw1
JOIN nibrs_weapon_type nwt1 ON nwt1.weapon_id = nw1.weapon_id
ON CONFLICT DO NOTHING;

-- There can be multiple injuries but we will just concatenate into a single field
DROP TABLE IF EXISTS flat_nibrs_injury;
CREATE TABLE flat_nibrs_injury (
  victim_id bigint PRIMARY KEY,
  injuries text
);

INSERT INTO flat_nibrs_injury
select v.victim_id, string_agg(i.injury_name, ', ')
from nibrs_victim_injury v
JOIN nibrs_injury i ON i.injury_id = v.injury_id
GROUP BY v.victim_id;
