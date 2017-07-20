DROP TABLE IF EXISTS shr_weapon_rollup;
CREATE TABLE shr_weapon_rollup AS
SELECT m.data_year AS year, ra.state_id, w.weapon_code, w.weapon_name, count(DISTINCT v.victim_id) AS total
FROM shr_victim v
JOIN shr_offense o ON o.victim_id = v.victim_id
JOIN shr_incident i ON i.incident_id = o.incident_id
JOIN shr_month m ON i.shr_month_id = m.shr_month_id
JOIN ref_agency ra ON ra.agency_id = m.agency_id
JOIN nibrs_weapon_type w ON o.weapon_id = w.weapon_id
JOIN shr_circumstances c ON c.circumstances_id = o.circumstances_id
WHERE i.homicide_code = 'A'
AND c.circumstances_code NOT IN ('50', '51', '52', '53', '59', '80', '81') -- remove negligent manslaughter
GROUP by m.data_year, ra.state_id, w.weapon_code, w.weapon_name;

DROP TABLE IF EXISTS shr_populations;
CREATE TABLE shr_populations AS
SELECT m.data_year AS year, ra.state_id, COUNT(DISTINCT m.agency_id) AS agencies, COUNT(DISTINCT i.incident_id) AS incidents, COUNT(DISTINCT v.victim_id) AS victims, SUM(rap.population) AS population
FROM shr_incident i
JOIN shr_offense o ON o.incident_id = i.incident_id
JOIN shr_victim v ON v.victim_id = o.victim_id
JOIN shr_month m ON m.shr_month_id = i.shr_month_id
JOIN ref_agency ra ON ra.agency_id = m.agency_id
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id = m.agency_id AND rap.data_year = m.data_year
JOIN shr_circumstances c ON c.circumstances_id = o.circumstances_id
WHERE c.circumstances_code NOT IN ('50', '51', '52', '53', '59', '80', '81') -- remove negligent manslaughter
AND i.homicide_code = 'A'
GROUP BY m.data_year, ra.state_id;

DROP TABLE IF EXISTS shr_weapon_crosstab;
CREATE TABLE shr_weapon_crosstab (
   id serial PRIMARY KEY,
   year smallint NOT NULL,
   state_abbr character(2),
   agencies bigint,
   incidents bigint,
   victims bigint,
   population bigint,
   firearm bigint,
   handgun bigint,
   rifle bigint,
   shotgun bigint,
   other_firearm bigint,
   knife bigint,
   blunt_object bigint,
   personal_weapons bigint,
   poison bigint,
   pushed_out_window bigint,
   explosives bigint,
   fire bigint,
   drugs bigint,
   drowning bigint,
   strangulation bigint,
   asphyxiation bigint,
   other bigint
);

DROP TABLE IF EXISTS shr_weapon_labels;
CREATE TEMPORARY TABLE shr_weapon_labels (
  code text,
  label text
);

INSERT INTO shr_weapon_labels VALUES
  ('11', 'firearm'),
  ('12', 'handgun'),
  ('13', 'rifle'),
  ('14', 'shotgun'),
  ('15', 'other_firearm'),
  ('20', 'knife'),
  ('30', 'blunt_object'),
  ('40', 'personal_weapons'),
  ('50', 'poison'),
  ('55', 'pushed_out_window'),
  ('60', 'explosives'),
  ('65', 'fire'),
  ('70', 'drugs'),
  ('75', 'drowning'),
  ('80', 'strangulation'),
  ('85', 'asphyxiation'),
  ('90', 'other');

INSERT INTO shr_weapon_crosstab(year, firearm, handgun, rifle, shotgun, other_firearm, knife, blunt_object, personal_weapons, poison, pushed_out_window, explosives, fire, drugs, drowning, strangulation, asphyxiation, other)
SELECT year, firearm, handgun, rifle, shotgun, other_firearm, knife, blunt_object, personal_weapons, poison, pushed_out_window, explosives, fire, drugs, drowning, strangulation, asphyxiation, other
FROM CROSSTAB(
$$ SELECT s.year,
          c.label,
          SUM(total) AS total
          FROM shr_weapon_rollup s
          JOIN shr_weapon_labels c ON c.code = s.weapon_code
          GROUP by s.year, c.label
          ORDER by 1, 2$$,
$$ select label from shr_weapon_labels ORDER by label $$
) AS ct (
  "year" smallint,
  "asphyxiation" bigint,
  "blunt_object" bigint,
  "drowning" bigint,
  "drugs" bigint,
  "explosives" bigint,
  "fire" bigint,
  "firearm" bigint,
  "handgun" bigint,
  "knife" bigint,
  "other" bigint,
  "other_firearm" bigint,
  "personal_weapons" bigint,
  "poison" bigint,
  "pushed_out_window" bigint,
  "rifle" bigint,
  "shotgun" bigint,
  "strangulation" bigint
);

UPDATE shr_weapon_crosstab
SET agencies = sp.agencies,
    incidents = sp.incidents,
    population = sp.population,
    victims = sp.victims
FROM (SELECT year, SUM(agencies) AS agencies, SUM(incidents) AS incidents, SUM(population) AS population, SUM(victims) AS victims
      FROM shr_populations GROUP by year) AS sp
WHERE sp.year = shr_weapon_crosstab.year;

DO
$do$
DECLARE
states text[] := array['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS', 'MT', 'NE', 'NC', 'ND', 'NH', 'NJ', 'NM', 'NV',  'NY', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY'];
st text;
BEGIN
  FOREACH st IN ARRAY states
  LOOP
INSERT INTO shr_weapon_crosstab(state_abbr, year, firearm, handgun, rifle, shotgun, other_firearm, knife, blunt_object, personal_weapons, poison, pushed_out_window, explosives, fire, drugs, drowning, strangulation, asphyxiation, other)
SELECT st AS state_abbr, ct.year, COALESCE(ct.firearm, 0) as firearm, COALESCE(ct.handgun, 0) AS handgun, COALESCE(ct.rifle, 0) AS rifle, COALESCE(ct.shotgun, 0) AS shotgun, COALESCE(ct.other_firearm, 0) AS other_firearm, COALESCE(ct.knife, 0) AS knife, COALESCE(ct.blunt_object, 0) AS blunt_object, COALESCE(ct.personal_weapons, 0) AS personal_weapons, COALESCE(ct.poison, 0) AS poison, COALESCE(ct.pushed_out_window, 0) AS pushed_out_window, COALESCE(ct.explosives, 0) AS explosives, COALESCE(ct.fire, 0) AS fire, COALESCE(ct.drugs, 0) AS drugs, COALESCE(ct.drowning, 0) AS drowning, COALESCE(ct.strangulation, 0) AS strangulation, COALESCE(ct.asphyxiation, 0) AS asphyxiation, COALESCE(ct.other, 0) AS other
FROM CROSSTAB(
$$ SELECT s.year,
          c.label,
          SUM(total) AS total
          FROM shr_weapon_rollup s
          JOIN shr_weapon_labels c ON c.code = s.weapon_code
          JOIN ref_state rs ON rs.state_id = s.state_id
          WHERE rs.state_postal_abbr = '$$ || st || $$'
          GROUP by s.year, c.label
          ORDER by 1, 2$$,
$$ select label from shr_weapon_labels ORDER by label $$
) AS ct (
  "year" smallint,
  "asphyxiation" bigint,
  "blunt_object" bigint,
  "drowning" bigint,
  "drugs" bigint,
  "explosives" bigint,
  "fire" bigint,
  "firearm" bigint,
  "handgun" bigint,
  "knife" bigint,
  "other" bigint,
  "other_firearm" bigint,
  "personal_weapons" bigint,
  "poison" bigint,
  "pushed_out_window" bigint,
  "rifle" bigint,
  "shotgun" bigint,
  "strangulation" bigint
);

END LOOP;
END
$do$;

UPDATE shr_weapon_crosstab
SET agencies = sp.agencies,
incidents = sp.incidents,
population = sp.population,
victims = sp.victims
FROM (SELECT year, rs.state_postal_abbr AS state_abbr, SUM(agencies) AS agencies, SUM(incidents) AS incidents, SUM(population) AS population, SUM(victims) AS victims
FROM shr_populations p
JOIN ref_state rs ON rs.state_id = p.state_id GROUP by year, rs.state_postal_abbr) AS sp
WHERE sp.year = shr_weapon_crosstab.year AND
      sp.state_abbr = shr_weapon_crosstab.state_abbr;

------- CIRCUMSTANCE CROSSTAB
DROP TABLE IF EXISTS shr_circumstance_rollup;
CREATE TABLE shr_circumstance_rollup AS
SELECT m.data_year AS year, ra.state_id, c.circumstances_code, c.circumstances_name, count(DISTINCT v.victim_id) AS total
FROM shr_victim v
JOIN shr_offense o ON o.victim_id = v.victim_id
JOIN shr_incident i ON i.incident_id = o.incident_id
JOIN shr_month m ON i.shr_month_id = m.shr_month_id
JOIN ref_agency ra ON ra.agency_id = m.agency_id
JOIN shr_circumstances c ON c.circumstances_id = o.circumstances_id
WHERE c.circumstances_code NOT IN ('50', '51', '52', '53', '59', '80', '81') -- remove negligent manslaughter
AND i.homicide_code = 'A'
GROUP by m.data_year, ra.state_id, c.circumstances_code, c.circumstances_name;

DROP TABLE IF EXISTS shr_circumstance_labels;
CREATE TEMPORARY TABLE shr_circumstance_labels (
  code text,
  label text
);

INSERT INTO shr_circumstance_labels VALUES
('02', 'rape'),
('03', 'robbery'),
('05', 'burglary'),
('06', 'larceny'),
('07', 'motor_vehicle_theft'),
('09', 'arson'),
('11', 'prostitution'),
('17', 'other_sex_offenses'),
('32', 'abortion'),
('18', 'drug'),
('19', 'gambling'),
('26', 'not_specified'),
('40', 'lovers_triangle'),
('41', 'child_killed_by_sitter'),
('42', 'brawl_alcohol'),
('43', 'brawl_drugs'),
('44', 'money_property_argument'),
('45', 'other_argument'),
('46', 'gang_killing'),
('47', 'juvenile_gang_killing'),
('48', 'institutional_killing'),
('49', 'sniper'),
('60', 'other'),
('70', 'all_supected_felony'),
('99', 'undetermined'),
('30', 'human_trafficking'),
('31', 'human_trafficking');

DROP TABLE IF EXISTS shr_circumstance_crosstab;
CREATE TABLE shr_circumstance_crosstab (
id serial PRIMARY KEY,
year smallint NOT NULL,
state_abbr character(2),
agencies bigint,
incidents bigint,
victims bigint,
population bigint,
rape bigint,
robbery bigint,
burglary bigint,
larceny bigint,
motor_vehicle_theft bigint,
arson bigint,
prostitution bigint,
other_sex_offenses bigint,
abortion bigint,
drug bigint,
gambling bigint,
not_specified bigint,
lovers_triangle bigint,
child_killed_by_sitter bigint,
brawl_alcohol bigint,
brawl_drugs bigint,
money_property_argument bigint,
other_argument bigint,
gang_killing bigint,
juvenile_gang_killing bigint,
institutional_killing bigint,
sniper bigint,
other bigint,
all_suspected_felony bigint,
undetermined bigint,
human_trafficking bigint
);

INSERT INTO shr_circumstance_crosstab(year, rape, robbery, burglary, larceny, motor_vehicle_theft, arson, prostitution, other_sex_offenses, abortion, drug, gambling, not_specified, lovers_triangle, child_killed_by_sitter, brawl_alcohol, brawl_drugs, money_property_argument, other_argument, gang_killing, juvenile_gang_killing, institutional_killing, sniper, other, all_suspected_felony, undetermined, human_trafficking)
SELECT year, rape, robbery, burglary, larceny, motor_vehicle_theft, arson, prostitution, other_sex_offenses, abortion, drug, gambling, not_specified, lovers_triangle, child_killed_by_sitter, brawl_alcohol, brawl_drugs, money_property_argument, other_argument, gang_killing, juvenile_gang_killing, institutional_killing, sniper, other, all_suspected_felony, undetermined, human_trafficking
FROM CROSSTAB(
$$ SELECT s.year,
          c.label,
          SUM(total) AS total
          FROM shr_circumstance_rollup s
          JOIN shr_circumstance_labels c ON c.code = s.circumstances_code
          GROUP by s.year, c.label
          ORDER by 1, 2$$,
$$ select DISTINCT label from shr_circumstance_labels ORDER by label $$
) AS ct (
  "year" smallint,
  "abortion" bigint,
  "all_suspected_felony" bigint,
  "arson" bigint,
  "brawl_alcohol" bigint,
  "brawl_drugs" bigint,
  "burglary" bigint,
  "child_killed_by_sitter" bigint,
  "drug" bigint,
  "gambling" bigint,
  "gang_killing" bigint,
  "human_trafficking" bigint,
  "institutional_killing" bigint,
  "juvenile_gang_killing" bigint,
  "larceny" bigint,
  "lovers_triangle" bigint,
  "money_property_argument" bigint,
  "motor_vehicle_theft" bigint,
  "not_specified" bigint,
  "other" bigint,
  "other_argument" bigint,
  "other_sex_offenses" bigint,
  "prostitution" bigint,
  "rape" bigint,
  "robbery" bigint,
  "sniper" bigint,
  "undetermined" bigint
);

UPDATE shr_circumstance_crosstab
SET agencies = sp.agencies,
    incidents = sp.incidents,
    population = sp.population,
    victims = sp.victims
FROM (SELECT year, SUM(agencies) AS agencies, SUM(incidents) AS incidents, SUM(population) AS population, SUM(victims) AS victims
      FROM shr_populations GROUP by year) AS sp
WHERE sp.year = shr_circumstance_crosstab.year;

DO
$do$
DECLARE
states text[] := array['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS', 'MT', 'NE', 'NC', 'ND', 'NH', 'NJ', 'NM', 'NV',  'NY', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY'];
st text;
BEGIN
FOREACH st IN ARRAY states
LOOP
INSERT INTO shr_circumstance_crosstab(state_abbr, year, rape, robbery, burglary, larceny, motor_vehicle_theft, arson, prostitution, other_sex_offenses, abortion, drug, gambling, not_specified, lovers_triangle, child_killed_by_sitter, brawl_alcohol, brawl_drugs, money_property_argument, other_argument, gang_killing, juvenile_gang_killing, institutional_killing, sniper, other, all_suspected_felony, undetermined, human_trafficking)
SELECT st AS state_abbr, year, rape, robbery, burglary, larceny, motor_vehicle_theft, arson, prostitution, other_sex_offenses, abortion, drug, gambling, not_specified, lovers_triangle, child_killed_by_sitter, brawl_alcohol, brawl_drugs, money_property_argument, other_argument, gang_killing, juvenile_gang_killing, institutional_killing, sniper, other, all_suspected_felony, undetermined, human_trafficking
FROM CROSSTAB(
$$ SELECT s.year,
          c.label,
          SUM(total) AS total
          FROM shr_circumstance_rollup s
          JOIN shr_circumstance_labels c ON c.code = s.circumstances_code
          GROUP by s.year, c.label
          ORDER by 1, 2$$,
$$ select DISTINCT label from shr_circumstance_labels ORDER by label $$
) AS ct (
  "year" smallint,
  "abortion" bigint,
  "all_suspected_felony" bigint,
  "arson" bigint,
  "brawl_alcohol" bigint,
  "brawl_drugs" bigint,
  "burglary" bigint,
  "child_killed_by_sitter" bigint,
  "drug" bigint,
  "gambling" bigint,
  "gang_killing" bigint,
  "human_trafficking" bigint,
  "institutional_killing" bigint,
  "juvenile_gang_killing" bigint,
  "larceny" bigint,
  "lovers_triangle" bigint,
  "money_property_argument" bigint,
  "motor_vehicle_theft" bigint,
  "not_specified" bigint,
  "other" bigint,
  "other_argument" bigint,
  "other_sex_offenses" bigint,
  "prostitution" bigint,
  "rape" bigint,
  "robbery" bigint,
  "sniper" bigint,
  "undetermined" bigint
);
END LOOP;
END
$do$;

UPDATE shr_circumstance_crosstab
SET agencies = sp.agencies,
incidents = sp.incidents,
population = sp.population,
victims = sp.victims
FROM (SELECT year, rs.state_postal_abbr AS state_abbr, SUM(agencies) AS agencies, SUM(incidents) AS incidents, SUM(population) AS population, SUM(victims) AS victims
FROM shr_populations p
JOIN ref_state rs ON rs.state_id = p.state_id GROUP by year, rs.state_postal_abbr) AS sp
WHERE sp.year = shr_circumstance_crosstab.year AND
sp.state_abbr = shr_circumstance_crosstab.state_abbr;
