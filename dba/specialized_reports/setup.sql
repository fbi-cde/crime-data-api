-- Some background tables that are useful for building specialized
-- reports. This file will have some descriptions of what they are

-- There can be up to 99 offenders associated with an incident. This
-- table gives a count of how many offenders per incident
CREATE MATERIALIZED VIEW counts_nibrs_known_offenders AS
SELECT incident_id, COUNT(offender_id) AS offender_count
FROM nibrs_offender
WHERE offender_seq_num > 0
GROUP by incident_id;

-- There can be up to two circumstances associated with an
-- incident. This SQL creates a "flat" table where instead of 2 rows
-- or less per incident there are repeated columns for each
-- circumstance. Since we are going to use this kind of flat or
-- crosstab style in our CSVs, we will do this for a few tables.
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

-- There can be up to 3 weapons associated with an offense. This is a
-- flat version of that table
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

-- There can be multiple injuries but we will just concatenate into a
-- single field because it's unlikely that this will be something that
-- people filter on
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

-- This is a big section so I'm going to break it down in parts. The
-- NIBRS database currently maps offenders directly to incidents, but
-- maps offenses to victims and victim to offenders through two
-- separate tables (offenders are assumed to have committed all
-- crimes).
--
-- For many crimes against persons, it's important to understand the
-- relationships between victims and offenders. This first table
-- groups the offenders for a crime by their relationship to the
-- victim. The victim_id is unique to a single victim in an incident,
-- so there is no need to copy over the incident_id
DROP TABLE IF EXISTS count_victim_relationships;
CREATE TABLE count_victim_relationships (
  victim_id bigint PRIMARY KEY,
  family smallint,
  known smallint,
  stranger smallint,
  victim_offender smallint,
  unknown smallint
);

DROP TABLE temp_victim_relationship_summaries;
CREATE TABLE temp_victim_relationship_summaries AS
SELECT vor.victim_id,
CASE WHEN r.relationship_code IN ('SE', 'CS', 'PA', 'SB', 'CH', 'GP', 'GC', 'IL', 'SP', 'SC', 'SS', 'OF') THEN 'family'
WHEN r.relationship_code IN ('AQ', 'FR', 'NE', 'BE', 'BG', 'CF', 'XS', 'EE', 'ER', 'OK') THEN 'known'
WHEN r.relationship_code = 'ST' THEN 'stranger'
WHEN r.relationship_code = 'VO' THEN 'victim_offender'
ELSE 'unknown' END AS category, count(*) AS total
FROM nibrs_victim_offender_rel vor
JOIN nibrs_relationship r ON r.relationship_id = vor.relationship_id
GROUP by vor.victim_id, category;

INSERT INTO count_victim_relationships
SELECT ct.*
FROM CROSSTAB (
  $$
  SELECT victim_id,
  category,
  total
  FROM temp_victim_relationship_summaries
  ORDER BY 1,2
  $$,
  $$ VALUES ('family'::text), ('known'), ('stranger'), ('unknown'), ('victim_offender') $$
) AS ct(victim_id bigint, family int, known smallint, stranger smallint, unknown smallint, victim_offender smallint);

-- Our next big project is to build a flat view of the first 5
-- offenders relative to a victim in a crime. Note that there can be
-- up to 99 offenders associated with a crime and each offender might
-- have different relationships with victims.
--
-- The first challenge is that offender_seq_num is not ordered in any
-- sense of priority, so we want to reorder things so that immediately
-- family are listed first, then friends, then strangers and
-- others. This will make sure that in cases where there are more than
-- 5 offenders, we prioritize the relationships first. The first step
-- is to create a new table with a derived seq_num that involves
-- addinding a boost to offender_seq_num depending on the relationship
-- (note that it should also work for situations where no relationship
-- is provided). These new seq_nums do not have to be contiguous
-- within an offense, but work in the sort ordr we need.
DROP TABLE IF EXISTS temp_reorder_nibrs_victim_offender_rel;
CREATE TABLE temp_reorder_nibrs_victim_offender_rel (
  id serial PRIMARY KEY,
  incident_id bigint NOT NULL,
  victim_id bigint NOT NULL,
  seq_num integer,
  offender_id bigint NOT NULL,
  nibrs_victim_offender_id bigint,
  relationship_code varchar(2),
  relationship_name varchar(100),
  relationship_class varchar(32)
);

INSERT INTO temp_reorder_nibrs_victim_offender_rel(nibrs_victim_offender_id, incident_id, victim_id, seq_num, offender_id, relationship_code, relationship_name, relationship_class)
SELECT vor.nibrs_victim_offender_id, o.incident_id, v.victim_id,
CASE WHEN nr.relationship_code IN ('SE', 'CS', 'PA', 'SB', 'CH', 'GP', 'GC', 'IL', 'SP', 'SC', 'SS', 'OF') THEN o.offender_seq_num
WHEN nr.relationship_code IN ('AQ', 'FR', 'NE', 'BE', 'BG', 'CF', 'XS', 'EE', 'ER', 'OK') THEN 100 + o.offender_seq_num
WHEN nr.relationship_code = 'ST' THEN 200 + o.offender_seq_num
WHEN nr.relationship_code = 'VO' THEN 400 + o.offender_seq_num
ELSE 300 + o.offender_seq_num END AS seq_num,
o.offender_id, nr.relationship_code, nr.relationship_name,
CASE WHEN nr.relationship_code IN ('SE', 'CS', 'PA', 'SB', 'CH', 'GP', 'GC', 'IL', 'SP', 'SC', 'SS', 'OF') THEN 'family'
WHEN nr.relationship_code IN ('AQ', 'FR', 'NE', 'BE', 'BG', 'CF', 'XS', 'EE', 'ER', 'OK') THEN 'known'
WHEN nr.relationship_code = 'ST' THEN 'stranger'
WHEN nr.relationship_code = 'VO' THEN 'victim_offender'
ELSE 'unknown' END AS relationship_class
FROM nibrs_victim v
JOIN nibrs_offender o ON o.incident_id = v.incident_id
LEFT OUTER JOIN nibrs_victim_offender_rel vor ON o.offender_id = vor.offender_id AND vor.victim_id = v.victim_id
LEFT OUTER JOIN nibrs_relationship nr ON nr.relationship_id = vor.relationship_id;

-- For now, we only need the first 5 items, so we do a window function
-- on the previous table to get up to 5 offenders per victim_id sorted
-- in ascending order
CREATE MATERIALIZED VIEW temp_nibrs_victim_offender_rowsort AS
SELECT * FROM (
  select victim_id,
  		 incident_id,
         offender_id,
         seq_num,
         relationship_code,
         relationship_name,
         relationship_class,
         row_number() over (partition by victim_id order by seq_num) as rownum
  from temp_reorder_nibrs_victim_offender_rel
) a
WHERE rownum <= 5
order by victim_id, seq_num;

CREATE UNIQUE INDEX flat_nibrs_victim_offender_rel_victim_ix ON flat_nibrs_victim_offender_rel(victim_id, rownum);
CREATE INDEX temp_nibrs_victim_offender_rowsort_rownum_ix ON temp_nibrs_victim_offender_rowsort(rownum);
CREATE INDEX temp_nibrs_victim_offender_rowsort_offender_ix ON temp_nibrs_victim_offender_rowsort(offender_id);

-- Finally we can use that table to create a flat table with the 5
-- closest offenders to each victim for each victim. This query takes
-- a while compared to the other ones which weren't exactly fast
-- either, so make yourself some coffee or get lunch while it runs.
DROP TABLE IF EXISTS flat_nibrs_victim_offender CASCADE;
CREATE TABLE flat_nibrs_victim_offender (
  victim_id bigint PRIMARY KEY,
  incident_id bigint,
  num_offenders int,
  offender1_id bigint,
  offender1_age_code varchar(2),
  offender1_age_num smallint,
  offender1_sex varchar(1),
  offender1_race varchar(2),
  offender1_ethnicity varchar(1),
  offender1_relationship_code varchar(2),
  offender1_relationship_name varchar(100),
  offender2_id bigint,
  offender2_age_code varchar(2),
  offender2_age_num smallint,
  offender2_sex varchar(1),
  offender2_race varchar(2),
  offender2_ethnicity varchar(1),
  offender2_relationship_code varchar(2),
  offender2_relationship_name varchar(100),
  offender3_id bigint,
  offender3_age_code varchar(2),
  offender3_age_num smallint,
  offender3_sex varchar(1),
  offender3_race varchar(2),
  offender3_ethnicity varchar(1),
  offender3_relationship_code varchar(2),
  offender3_relationship_name varchar(100),
  offender4_id bigint,
  offender4_age_code varchar(2),
  offender4_age_num smallint,
  offender4_sex varchar(1),
  offender4_race varchar(2),
  offender4_ethnicity varchar(1),
  offender4_relationship_code varchar(2),
  offender4_relationship_name varchar(100),
  offender5_id bigint,
  offender5_age_code varchar(2),
  offender5_age_num smallint,
  offender5_sex varchar(1),
  offender5_race varchar(2),
  offender5_ethnicity varchar(1),
  offender5_relationship_code varchar(2),
  offender5_relationship_name varchar(100)
);

INSERT INTO flat_nibrs_victim_offender(victim_id, incident_id, num_offenders, offender1_id, offender1_age_code, offender1_age_num, offender1_sex, offender1_race, offender1_ethnicity, offender1_relationship_code, offender1_relationship_name)
SELECT nvo.victim_id, o.incident_id, koc.offender_count,
o.offender_id, oa.age_code, o.age_num, o.sex_code, orr.race_code, oe.ethnicity_code, nvo.relationship_code, nvo.relationship_name
FROM temp_nibrs_victim_offender_rowsort nvo
JOIN nibrs_offender o ON o.offender_id = nvo.offender_id
LEFT OUTER JOIN count_nibrs_known_offenders koc ON koc.incident_id = o.incident_id
LEFT OUTER JOIN nibrs_age oa ON oa.age_id = o.age_id
LEFT OUTER JOIN ref_race orr ON orr.race_id = o.race_id
LEFT OUTER JOIN nibrs_ethnicity oe ON oe.ethnicity_id = o.ethnicity_id
WHERE nvo.rownum = 1;

UPDATE flat_nibrs_victim_offender
SET offender2_id = temp_nibrs_victim_offender_rowsort.offender_id,
    offender2_age_code = nibrs_age.age_code,
    offender2_age_num = nibrs_offender.age_num,
    offender2_sex = nibrs_offender.sex_code,
    offender2_race = ref_race.race_code,
    offender2_ethnicity = nibrs_ethnicity.ethnicity_code,
    offender2_relationship_code = temp_nibrs_victim_offender_rowsort.relationship_code,
    offender2_relationship_name = temp_nibrs_victim_offender_rowsort.relationship_name
FROM temp_nibrs_victim_offender_rowsort
JOIN nibrs_offender ON nibrs_offender.offender_id = temp_nibrs_victim_offender_rowsort.offender_id
LEFT OUTER JOIN nibrs_age ON nibrs_age.age_id = nibrs_offender.age_id
LEFT OUTER JOIN ref_race ON ref_race.race_id = nibrs_offender.race_id
LEFT OUTER JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_offender.ethnicity_id
WHERE temp_nibrs_victim_offender_rowsort.victim_id = flat_nibrs_victim_offender.victim_id
AND temp_nibrs_victim_offender_rowsort.rownum = 2;

UPDATE flat_nibrs_victim_offender
SET offender3_id = temp_nibrs_victim_offender_rowsort.offender_id,
    offender3_age_code = nibrs_age.age_code,
    offender3_age_num = nibrs_offender.age_num,
    offender3_sex = nibrs_offender.sex_code,
    offender3_race = ref_race.race_code,
    offender3_ethnicity = nibrs_ethnicity.ethnicity_code,
    offender3_relationship_code = temp_nibrs_victim_offender_rowsort.relationship_code,
    offender3_relationship_name = temp_nibrs_victim_offender_rowsort.relationship_name
FROM temp_nibrs_victim_offender_rowsort
JOIN nibrs_offender ON nibrs_offender.offender_id = temp_nibrs_victim_offender_rowsort.offender_id
LEFT OUTER JOIN nibrs_age ON nibrs_age.age_id = nibrs_offender.age_id
LEFT OUTER JOIN ref_race ON ref_race.race_id = nibrs_offender.race_id
LEFT OUTER JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_offender.ethnicity_id
WHERE temp_nibrs_victim_offender_rowsort.victim_id = flat_nibrs_victim_offender.victim_id
AND temp_nibrs_victim_offender_rowsort.rownum = 3;

UPDATE flat_nibrs_victim_offender
SET offender4_id = temp_nibrs_victim_offender_rowsort.offender_id,
    offender4_age_code = nibrs_age.age_code,
    offender4_age_num = nibrs_offender.age_num,
    offender4_sex = nibrs_offender.sex_code,
    offender4_race = ref_race.race_code,
    offender4_ethnicity = nibrs_ethnicity.ethnicity_code,
    offender4_relationship_code = temp_nibrs_victim_offender_rowsort.relationship_code,
    offender4_relationship_name = temp_nibrs_victim_offender_rowsort.relationship_name
FROM temp_nibrs_victim_offender_rowsort
JOIN nibrs_offender ON nibrs_offender.offender_id = temp_nibrs_victim_offender_rowsort.offender_id
LEFT OUTER JOIN nibrs_age ON nibrs_age.age_id = nibrs_offender.age_id
LEFT OUTER JOIN ref_race ON ref_race.race_id = nibrs_offender.race_id
LEFT OUTER JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_offender.ethnicity_id
WHERE temp_nibrs_victim_offender_rowsort.victim_id = flat_nibrs_victim_offender.victim_id
AND temp_nibrs_victim_offender_rowsort.rownum = 4;

UPDATE flat_nibrs_victim_offender
SET offender5_id = temp_nibrs_victim_offender_rowsort.offender_id,
    offender5_age_code = nibrs_age.age_code,
    offender5_age_num = nibrs_offender.age_num,
    offender5_sex = nibrs_offender.sex_code,
    offender5_race = ref_race.race_code,
    offender5_ethnicity = nibrs_ethnicity.ethnicity_code,
    offender5_relationship_code = temp_nibrs_victim_offender_rowsort.relationship_code,
    offender5_relationship_name = temp_nibrs_victim_offender_rowsort.relationship_name
FROM temp_nibrs_victim_offender_rowsort
JOIN nibrs_offender ON nibrs_offender.offender_id = temp_nibrs_victim_offender_rowsort.offender_id
LEFT OUTER JOIN nibrs_age ON nibrs_age.age_id = nibrs_offender.age_id
LEFT OUTER JOIN ref_race ON ref_race.race_id = nibrs_offender.race_id
LEFT OUTER JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_offender.ethnicity_id
WHERE temp_nibrs_victim_offender_rowsort.victim_id = flat_nibrs_victim_offender.victim_id
AND temp_nibrs_victim_offender_rowsort.rownum = 5;

--
-- Flat file for victims of violent offense. The idea of this table is
-- to flatten multiple rows of violent offenses into boolean flags to
-- indicate particular offenses that a victim has suffered. So for
-- instance, if a victim was victimized by rape and robbery, those
-- columns would be 1 while the others would be 0
DROP TABLE IF EXISTS flat_nibrs_victim_violent_offense;
CREATE TABLE flat_nibrs_victim_violent_offense (
  victim_id bigint PRIMARY KEY,
  homicide smallint NOT NULL DEFAULT 0,
  manslaughter smallint NOT NULL DEFAULT 0,
  kidnapping smallint NOT NULL DEFAULT 0,
  robbery smallint NOT NULL DEFAULT 0,
  rape smallint NOT NULL DEFAULT 0,
  sodomy smallint NOT NULL DEFAULT 0,
  sex_assault_with_object smallint NOT NULL DEFAULT 0,
  fondling smallint NOT NULL DEFAULT 0,
  aggravated_assault smallint NOT NULL DEFAULT 0,
  simple_assault smallint NOT NULL DEFAULT 0,
  intimidation smallint NOT NULL DEFAULT 0
);

INSERT INTO flat_nibrs_victim_violent_offense (victim_id, homicide)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '09A';

INSERT INTO flat_nibrs_victim_violent_offense (victim_id, manslaughter)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '09B'
ON CONFLICT (victim_id) DO UPDATE SET homicide=flat_nibrs_victim_violent_offense.homicide,
  									  manslaughter=1,
  									  kidnapping=flat_nibrs_victim_violent_offense.kidnapping,
									    robbery=flat_nibrs_victim_violent_offense.robbery,
									    rape=flat_nibrs_victim_violent_offense.rape,
  									  sodomy=flat_nibrs_victim_violent_offense.sodomy,
  									  sex_assault_with_object=flat_nibrs_victim_violent_offense.sex_assault_with_object,
  									  fondling=flat_nibrs_victim_violent_offense.fondling,
  									  aggravated_assault=flat_nibrs_victim_violent_offense.aggravated_assault,
  									  simple_assault=flat_nibrs_victim_violent_offense.simple_assault,
  									  intimidation=flat_nibrs_victim_violent_offense.intimidation;

INSERT INTO flat_nibrs_victim_violent_offense (victim_id, kidnapping)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '100'
ON CONFLICT (victim_id) DO UPDATE SET homicide=flat_nibrs_victim_violent_offense.homicide,
  									  manslaughter=flat_nibrs_victim_violent_offense.manslaughter,
  									  kidnapping=1,
									    robbery=flat_nibrs_victim_violent_offense.robbery,
									    rape=flat_nibrs_victim_violent_offense.rape,
  									  sodomy=flat_nibrs_victim_violent_offense.sodomy,
  									  sex_assault_with_object=flat_nibrs_victim_violent_offense.sex_assault_with_object,
  									  fondling=flat_nibrs_victim_violent_offense.fondling,
  									  aggravated_assault=flat_nibrs_victim_violent_offense.aggravated_assault,
  									  simple_assault=flat_nibrs_victim_violent_offense.simple_assault,
  									  intimidation=flat_nibrs_victim_violent_offense.intimidation;

INSERT INTO flat_nibrs_victim_violent_offense (victim_id, robbery)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '120'
ON CONFLICT (victim_id) DO UPDATE SET homicide=flat_nibrs_victim_violent_offense.homicide,
  									  manslaughter=flat_nibrs_victim_violent_offense.manslaughter,
  									  kidnapping=flat_nibrs_victim_violent_offense.kidnapping,
									    robbery=1,
									    rape=flat_nibrs_victim_violent_offense.rape,
  									  sodomy=flat_nibrs_victim_violent_offense.sodomy,
  									  sex_assault_with_object=flat_nibrs_victim_violent_offense.sex_assault_with_object,
  									  fondling=flat_nibrs_victim_violent_offense.fondling,
  									  aggravated_assault=flat_nibrs_victim_violent_offense.aggravated_assault,
  									  simple_assault=flat_nibrs_victim_violent_offense.simple_assault,
  									  intimidation=flat_nibrs_victim_violent_offense.intimidation;
------
INSERT INTO flat_nibrs_victim_violent_offense (victim_id, sodomy)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '11B'
ON CONFLICT (victim_id) DO UPDATE SET homicide=flat_nibrs_victim_violent_offense.homicide,
  									  manslaughter=flat_nibrs_victim_violent_offense.manslaughter,
  									  kidnapping=flat_nibrs_victim_violent_offense.kidnapping,
									    robbery=flat_nibrs_victim_violent_offense.robbery,
									    rape=flat_nibrs_victim_violent_offense.rape,
  									  sodomy=1,
  									  sex_assault_with_object=flat_nibrs_victim_violent_offense.sex_assault_with_object,
  									  fondling=flat_nibrs_victim_violent_offense.fondling,
  									  aggravated_assault=flat_nibrs_victim_violent_offense.aggravated_assault,
  									  simple_assault=flat_nibrs_victim_violent_offense.simple_assault,
  									  intimidation=flat_nibrs_victim_violent_offense.intimidation;

INSERT INTO flat_nibrs_victim_violent_offense (victim_id, sex_assault_with_object)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '11C'
ON CONFLICT (victim_id) DO UPDATE SET homicide=flat_nibrs_victim_violent_offense.homicide,
  									  manslaughter=flat_nibrs_victim_violent_offense.manslaughter,
  									  kidnapping=flat_nibrs_victim_violent_offense.kidnapping,
									    robbery=flat_nibrs_victim_violent_offense.robbery,
									    rape=flat_nibrs_victim_violent_offense.rape,
  									  sodomy=flat_nibrs_victim_violent_offense.sodomy,
  									  sex_assault_with_object=1,
  									  fondling=flat_nibrs_victim_violent_offense.fondling,
  									  aggravated_assault=flat_nibrs_victim_violent_offense.aggravated_assault,
  									  simple_assault=flat_nibrs_victim_violent_offense.simple_assault,
  									  intimidation=flat_nibrs_victim_violent_offense.intimidation;

INSERT INTO flat_nibrs_victim_violent_offense (victim_id, fondling)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '11D'
ON CONFLICT (victim_id) DO UPDATE SET homicide=flat_nibrs_victim_violent_offense.homicide,
  									  manslaughter=flat_nibrs_victim_violent_offense.manslaughter,
  									  kidnapping=flat_nibrs_victim_violent_offense.kidnapping,
									    robbery=flat_nibrs_victim_violent_offense.robbery,
									    rape=flat_nibrs_victim_violent_offense.rape,
  									  sodomy=flat_nibrs_victim_violent_offense.sodomy,
  									  sex_assault_with_object=flat_nibrs_victim_violent_offense.sex_assault_with_object,
  									  fondling=1,
  									  aggravated_assault=flat_nibrs_victim_violent_offense.aggravated_assault,
  									  simple_assault=flat_nibrs_victim_violent_offense.simple_assault,
  									  intimidation=flat_nibrs_victim_violent_offense.intimidation;

INSERT INTO flat_nibrs_victim_violent_offense (victim_id, aggravated_assault)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '13A'
ON CONFLICT (victim_id) DO UPDATE SET homicide=flat_nibrs_victim_violent_offense.homicide,
  									  manslaughter=flat_nibrs_victim_violent_offense.manslaughter,
  									  kidnapping=flat_nibrs_victim_violent_offense.kidnapping,
									    robbery=flat_nibrs_victim_violent_offense.robbery,
									    rape=flat_nibrs_victim_violent_offense.rape,
  									  sodomy=flat_nibrs_victim_violent_offense.sodomy,
  									  sex_assault_with_object=flat_nibrs_victim_violent_offense.sex_assault_with_object,
  									  fondling=flat_nibrs_victim_violent_offense.fondling,
  									  aggravated_assault=1,
  									  simple_assault=flat_nibrs_victim_violent_offense.simple_assault,
  									  intimidation=flat_nibrs_victim_violent_offense.intimidation;

INSERT INTO flat_nibrs_victim_violent_offense (victim_id, simple_assault)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '13B'
ON CONFLICT (victim_id) DO UPDATE SET homicide=flat_nibrs_victim_violent_offense.homicide,
  									  manslaughter=flat_nibrs_victim_violent_offense.manslaughter,
  									  kidnapping=flat_nibrs_victim_violent_offense.kidnapping,
									    robbery=flat_nibrs_victim_violent_offense.robbery,
									    rape=flat_nibrs_victim_violent_offense.rape,
  									  sodomy=flat_nibrs_victim_violent_offense.sodomy,
  									  sex_assault_with_object=flat_nibrs_victim_violent_offense.sex_assault_with_object,
  									  fondling=flat_nibrs_victim_violent_offense.fondling,
  									  aggravated_assault=flat_nibrs_victim_violent_offense.aggravated_assault,
  									  simple_assault=1,
  									  intimidation=flat_nibrs_victim_violent_offense.intimidation;

INSERT INTO flat_nibrs_victim_violent_offense (victim_id, intimidation)
SELECT v.victim_id, 1
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE ot.offense_code = '13B'
ON CONFLICT (victim_id) DO UPDATE SET homicide=flat_nibrs_victim_violent_offense.homicide,
  									  manslaughter=flat_nibrs_victim_violent_offense.manslaughter,
  									  kidnapping=flat_nibrs_victim_violent_offense.kidnapping,
									    robbery=flat_nibrs_victim_violent_offense.robbery,
									    rape=flat_nibrs_victim_violent_offense.rape,
  									  sodomy=flat_nibrs_victim_violent_offense.sodomy,
  									  sex_assault_with_object=flat_nibrs_victim_violent_offense.sex_assault_with_object,
  									  fondling=flat_nibrs_victim_violent_offense.fondling,
  									  aggravated_assault=flat_nibrs_victim_violent_offense.aggravated_assault,
  									  simple_assault=flat_nibrs_victim_violent_offense.simple_assault,
  									  intimidation=1;

-- Count the number of arrests associated with each nibrs_incident
select * from count_nibrs_incident_arrests limit 10;

INSERT INTO count_nibrs_incident_arrests
SELECT incident_id, count(*), min(arrest_date::date) from nibrs_arrestee group by incident_id;

-- Associate weapons directly with nibrs_incidents
DROP TABLE IF EXISTS flat_nibrs_incident_weapons;
CREATE TABLE flat_nibrs_incident_weapons (
  incident_id bigint PRIMARY KEY,
  unarmed smallint NOT NULL DEFAULT 0,
  firearm smallint NOT NULL DEFAULT 0,
  handgun smallint NOT NULL DEFAULT 0,
  rifle smallint NOT NULL DEFAULT 0,
  shotgun smallint NOT NULL DEFAULT 0,
  other_firearm smallint NOT NULL DEFAULT 0,
  automatic_firearm smallint NOT NULL DEFAULT 0,
  automatic_handgun smallint NOT NULL DEFAULT 0,
  automatic_rifle smallint NOT NULL DEFAULT 0,
  automatic_shotgun smallint NOT NULL DEFAULT 0,
  automatic_other_firearm smallint NOT NULL DEFAULT 0,
  pushed_out_window smallint NOT NULL DEFAULT 0,
  drowning smallint NOT NULL DEFAULT 0,
  strangulation smallint NOT NULL DEFAULT 0,
  lethal_cutting smallint NOT NULL DEFAULT 0,
  club smallint NOT NULL DEFAULT 0,
  knife smallint NOT NULL DEFAULT 0,
  blunt_object smallint NOT NULL DEFAULT 0,
  motor_vehicle smallint NOT NULL DEFAULT 0,
  personal_weapons smallint NOT NULL DEFAULT 0,
  poison smallint NOT NULL DEFAULT 0,
  explosives smallint NOT NULL DEFAULT 0,
  fire smallint NOT NULL DEFAULT 0,
  drugs smallint NOT NULL DEFAULT 0,
  asphyxiation smallint NOT NULL DEFAULT 0,
  other_weapon smallint NOT NULL DEFAULT 0,
  unknown_weapon smallint NOT NULL DEFAULT 0,
  no_weapon smallint NOT NULL DEFAULT 0
);

INSERT INTO flat_nibrs_incident_weapons SELECT DISTINCT o.incident_id FROM nibrs_weapon w JOIN nibrs_offense o ON w.offense_id = o.offense_id;

UPDATE flat_nibrs_incident_weapons
SET automatic_firearm=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '11A';

UPDATE flat_nibrs_incident_weapons
SET automatic_handgun=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '12A';

UPDATE flat_nibrs_incident_weapons
SET automatic_rifle=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '13A';

UPDATE flat_nibrs_incident_weapons
SET automatic_shotgun=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '14A';

UPDATE flat_nibrs_incident_weapons
SET automatic_other_firearm=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '15A';

UPDATE flat_nibrs_incident_weapons
SET firearm=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '11';

UPDATE flat_nibrs_incident_weapons
SET handgun=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '12';

UPDATE flat_nibrs_incident_weapons
SET rifle=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '13';

UPDATE flat_nibrs_incident_weapons
SET shotgun=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '14';

UPDATE flat_nibrs_incident_weapons
SET other_firearm=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '15';

UPDATE flat_nibrs_incident_weapons
SET pushed_out_window=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '55';

UPDATE flat_nibrs_incident_weapons
SET drowning=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '75';

UPDATE flat_nibrs_incident_weapons
SET strangulation=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '80';

UPDATE flat_nibrs_incident_weapons
SET unarmed=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '01';

UPDATE flat_nibrs_incident_weapons
SET lethal_cutting=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '16';

UPDATE flat_nibrs_incident_weapons
SET club=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '17';

UPDATE flat_nibrs_incident_weapons
SET knife=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '20';

UPDATE flat_nibrs_incident_weapons
SET blunt_object=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '30';

UPDATE flat_nibrs_incident_weapons
SET motor_vehicle=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '35';

UPDATE flat_nibrs_incident_weapons
SET personal_weapons=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '40';

UPDATE flat_nibrs_incident_weapons
SET poison=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '50';

UPDATE flat_nibrs_incident_weapons
SET explosives=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '60';

UPDATE flat_nibrs_incident_weapons
SET fire=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '65';

UPDATE flat_nibrs_incident_weapons
SET drugs=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '70';

UPDATE flat_nibrs_incident_weapons
SET asphyxiation=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '80';

UPDATE flat_nibrs_incident_weapons
SET other_weapon=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '90';

UPDATE flat_nibrs_incident_weapons
SET unknown_weapon=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '95';

UPDATE flat_nibrs_incident_weapons
SET no_weapon=1
FROM nibrs_weapon
JOIN nibrs_weapon_type ON nibrs_weapon_type.weapon_id = nibrs_weapon.weapon_id
JOIN nibrs_offense ON nibrs_offense.offense_id = nibrs_weapon.offense_id
WHERE flat_nibrs_incident_weapons.incident_id = nibrs_offense.incident_id AND nibrs_weapon_type.weapon_code = '99';
