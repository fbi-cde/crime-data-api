

-- Only include agencies that have reported ASR for 12 months in the ASR crosstabs
DROP TABLE IF EXISTS asr_reporting;
CREATE TABLE asr_reporting (
   data_year smallint NOT NULL,
   agency_id int NOT NULL,
   months_reported smallint
);

INSERT INTO asr_reporting
SELECT data_year, agency_id, SUM(CASE WHEN reported_flag = 'Y' THEN 1 ELSE 0 END) AS reported_months
FROM asr_month GROUP by data_year, agency_id;

-- You can't submit arrest data without providing age/sex/race so
-- these are just checking the agencies reported for 12 months
DROP TABLE IF EXISTS asr_aas_populations;
CREATE TABLE asr_aas_populations(
data_year smallint NOT NULL,
state_abbr character(2),
agencies integer,
population bigint);

INSERT INTO asr_aas_populations
SELECT
asr.data_year,
rs.state_postal_abbr,
COUNT(ra.agency_id),
SUM(rap.population)
FROM asr_reporting asr
JOIN ref_agency ra ON ra.agency_id = asr.agency_id
JOIN ref_state rs ON rs.state_id = ra.state_id
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id = ra.agency_id AND rap.data_year = asr.data_year
WHERE asr.months_reported = 12
GROUP BY GROUPING SETS(
(asr.data_year),
(asr.data_year, rs.state_postal_abbr)
);

-- Race reporting is a bit more complicated. You need to look at what
-- was filed to get a count of the agencies that provided racial data
DROP TABLE IF EXISTS asr_race_populations;
CREATE TABLE asr_race_populations(
data_year smallint NOT NULL,
state_abbr character(2),
agencies integer,
population bigint);

WITH race_agencies AS (select DISTINCT am.data_year, am.agency_id FROM asr_month am JOIN asr_race_offense_subcat ros ON ros.asr_month_id = am.asr_month_id)
INSERT INTO asr_race_populations
SELECT
asr.data_year,
rs.state_postal_abbr,
COUNT(ra.agency_id),
SUM(rap.population)
FROM asr_reporting asr
JOIN ref_agency ra ON ra.agency_id = asr.agency_id
JOIN ref_state rs ON rs.state_id = ra.state_id
JOIN race_agencies a ON a.agency_id = asr.agency_id AND a.data_year = asr.data_year
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id = ra.agency_id AND rap.data_year = asr.data_year
WHERE asr.months_reported = 12
GROUP BY GROUPING SETS(
(asr.data_year),
(asr.data_year, rs.state_postal_abbr)
);

-- Build a rollup at the suboffense level. These queries take the longest to run (about 3-4 hours)
DROP TABLE IF EXISTS asr_age_suboffense_summary;
CREATE TABLE asr_age_suboffense_summary (
   id serial PRIMARY KEY,
   data_year smallint NOT NULL,
   state_id INTEGER NOT NULL,
   age_range_id integer,
   offense_subcat_id int,
   arrest_count bigint
);

DO
$do$
DECLARE
   years int[] := array[2016];
   y int;
BEGIN
  SET work_mem = '3GB';
  FOREACH y IN ARRAY years
  LOOP
  EXECUTE 'INSERT INTO asr_age_suboffense_summary(data_year, state_id, age_range_id, offense_subcat_id, arrest_count)
SELECT am.data_year, ra.state_id, aas.age_range_id, aas.offense_subcat_id, SUM(arrest_count)
FROM asr_age_sex_subcat aas JOIN asr_month am ON aas.asr_month_id = am.asr_month_id JOIN ref_agency ra ON ra.agency_id = am.agency_id
JOIN asr_reporting ar ON ar.agency_id = am.agency_id AND ar.data_year = am.data_year
WHERE am.data_year = ' || y || ' AND ar.months_reported = 12
GROUP BY am.data_year, ra.state_id, aas.age_range_id, aas.offense_subcat_id;';
  END LOOP;
END;
$do$;

DROP TABLE IF EXISTS asr_race_suboffense_summary;
CREATE TABLE asr_race_suboffense_summary (
   id serial PRIMARY KEY,
   data_year smallint NOT NULL,
   state_id INTEGER NOT NULL,
   race_id integer,
   juvenile_flag char(1),
   offense_subcat_id int,
   arrest_count bigint
);

DO
$do$
DECLARE
  years int[] := array[2016];
  y int;
BEGIN
  SET work_mem = '3GB';
  FOREACH y IN ARRAY years
  LOOP
    EXECUTE 'INSERT INTO asr_race_suboffense_summary(data_year, state_id, race_id, juvenile_flag, offense_subcat_id, arrest_count)
             SELECT am.data_year, ra.state_id, aas.race_id, aas.juvenile_flag, aas.offense_subcat_id, SUM(arrest_count)
             FROM asr_race_offense_subcat aas
             JOIN asr_month am ON aas.asr_month_id = am.asr_month_id
             JOIN ref_agency ra ON ra.agency_id = am.agency_id
             JOIN asr_reporting ar ON ar.agency_id = am.agency_id AND ar.data_year = am.data_year
             WHERE am.data_year = ' || y || ' AND ar.months_reported = 12
             GROUP BY am.data_year, ra.state_id, aas.race_id, aas.juvenile_flag, aas.offense_subcat_id;';
  END LOOP;
END;
$do$;

-- Add up suboffenses to the offense level.
DROP TABLE IF EXISTS asr_offense_summary_temp;
CREATE TABLE asr_offense_summary_temp (
   id serial PRIMARY KEY,
   year smallint NOT NULL,
   juvenile_flag character(1),
   sex character(1),
   age_range_code text,
   age_range_name text,
   race_code character(2),
   race_name text,
   offense_code text,
   offense_name text,
   offense_subcat_code text,
   offense_subcat_name text,
   arrest_count integer,
   agencies integer,
   population bigint
);

-- Some suboffenses are actually subtotals and totals of other
-- offenses. So the offense_subcat_id WHERE clause is there to limit
-- to only the lowest-level counts. You could use these tables in an
-- API response.
INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, juvenile_flag, sex, age_range_code, age_range_name, arrest_count)
SELECT aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
WHERE aos.offense_subcat_id IN (11, 12, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 18, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 301, 302)
GROUP BY GROUPING SETS(
(aass.data_year),
(aass.data_year, aar.juvenile_flag),
(aass.data_year, aar.age_sex),
(aass.data_year, aar.juvenile_flag, aar.age_sex),
(aass.data_year, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name),
(aass.data_year, offense_code, offense_name),
(aass.data_year, aar.juvenile_flag, offense_code, offense_name),
(aass.data_year, aar.age_sex, offense_code, offense_name),
(aass.data_year, aar.juvenile_flag, aar.age_sex, offense_code, offense_name),
(aass.data_year, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name, offense_code, offense_name),
(aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, aar.juvenile_flag, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, aar.age_sex, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, aar.juvenile_flag, aar.age_sex, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name)
);

INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, juvenile_flag, race_code, race_name, arrest_count)
SELECT aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, juvenile_flag, rr.race_code, rr.race_desc, SUM(arrest_count)
FROM asr_race_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN ref_race rr ON rr.race_id = aass.race_id
WHERE aos.offense_subcat_id IN (11, 12, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 18, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 301, 302)
GROUP BY GROUPING SETS(
(aass.data_year, race_code, race_desc),
(aass.data_year, juvenile_flag, race_code, race_desc),
(aass.data_year, race_code, race_desc, offense_code, offense_name),
(aass.data_year, juvenile_flag, race_code, race_desc, offense_code, offense_name),
(aass.data_year, race_code, race_desc, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, juvenile_flag, race_code, race_desc, offense_code, offense_name, offense_subcat_code, offense_subcat_name)
);

-- Apply the agencies and population counts to the table
UPDATE asr_offense_summary_temp
SET agencies=p.agencies, population=p.population
FROM asr_aas_populations p
WHERE data_year=p.data_year
AND p.state_abbr IS NULL;

UPDATE asr_offense_summary_temp
SET agencies=p.agencies, population=p.population
FROM asr_race_populations p
WHERE data_year=p.data_year
AND p.state_abbr IS NULL AND race_code IS NOT NULL;

DROP TABLE IF EXISTS asr_offense_summary CASCADE;
ALTER TABLE asr_offense_summary_temp RENAME TO asr_offense_summary;

CREATE INDEX asr_offense_juvenile_idx ON asr_offense_summary (juvenile_flag);
CREATE INDEX asr_offense_sex_idx ON asr_offense_summary (sex);
CREATE INDEX asr_offense_age_range_code_idx ON asr_offense_summary (age_range_code);
CREATE INDEX asr_offense_race_code_idx ON asr_offense_summary (race_code);
CREATE INDEX asr_offense_offense_code_idx ON asr_offense_summary (offense_code);
CREATE INDEX asr_offense_offense_subcat_code_idx ON asr_offense_summary (offense_subcat_code);

------- Same thing but at the state level
DROP TABLE IF EXISTS asr_state_offense_summary_temp;
CREATE TABLE asr_state_offense_summary_temp (
   id serial PRIMARY KEY,
   year smallint NOT NULL,
   state_abbr character(2) NOT NULL,
   juvenile_flag character(1),
   sex character(1),
   age_range_code text,
   age_range_name text,
   race_code character(2),
   race_name text,
   offense_code text,
   offense_name text,
   offense_subcat_code text,
   offense_subcat_name text,
   arrest_count integer,
   agencies integer,
   population bigint
);

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, juvenile_flag, sex, age_range_code, age_range_name, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
WHERE aos.offense_subcat_id IN (11, 12, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 18, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 301, 302)
GROUP BY GROUPING SETS(
(aass.data_year, rs.state_postal_abbr),
(aass.data_year, rs.state_postal_abbr, aar.juvenile_flag),
(aass.data_year, rs.state_postal_abbr, aar.age_sex),
(aass.data_year, rs.state_postal_abbr, aar.juvenile_flag, aar.age_sex),
(aass.data_year, rs.state_postal_abbr, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name),
(aass.data_year, rs.state_postal_abbr, offense_code, offense_name),
(aass.data_year, rs.state_postal_abbr, aar.juvenile_flag, offense_code, offense_name),
(aass.data_year, rs.state_postal_abbr, aar.age_sex, offense_code, offense_name),
(aass.data_year, rs.state_postal_abbr, aar.juvenile_flag, aar.age_sex, offense_code, offense_name),
(aass.data_year, rs.state_postal_abbr, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name, offense_code, offense_name),
(aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, rs.state_postal_abbr, aar.juvenile_flag, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, rs.state_postal_abbr, aar.age_sex, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, rs.state_postal_abbr, aar.juvenile_flag, aar.age_sex, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, rs.state_postal_abbr, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name)
);

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, juvenile_flag, race_code, race_name, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, juvenile_flag, rr.race_code, rr.race_desc, SUM(arrest_count)
FROM asr_race_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN ref_race rr ON rr.race_id = aass.race_id
JOIN ref_state rs ON rs.state_id = aass.state_id
WHERE aos.offense_subcat_id IN (11, 12, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 18, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 301, 302)
GROUP BY GROUPING SETS(
(aass.data_year, rs.state_postal_abbr, race_code, race_desc),
(aass.data_year, rs.state_postal_abbr, juvenile_flag, race_code, race_desc),
(aass.data_year, rs.state_postal_abbr, race_code, race_desc, offense_code, offense_name),
(aass.data_year, rs.state_postal_abbr, juvenile_flag, race_code, race_desc, offense_code, offense_name),
(aass.data_year, rs.state_postal_abbr, race_code, race_desc, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(aass.data_year, rs.state_postal_abbr, juvenile_flag, race_code, race_desc, offense_code, offense_name, offense_subcat_code, offense_subcat_name)
);

UPDATE asr_state_offense_summary_temp
SET agencies=p.agencies, population=p.population
FROM asr_aas_populations p
WHERE data_year=p.data_year
AND asr_state_offense_summary_temp.state_abbr=p.state_abbr;

UPDATE asr_state_offense_summary_temp
SET agencies=p.agencies, population=p.population
FROM asr_race_populations p
WHERE data_year=p.data_year
AND asr_state_offense_summary_temp.state_abbr=p.state_abbr AND race_code IS NOT NULL;

DROP TABLE IF EXISTS asr_state_offense_summary CASCADE;
ALTER TABLE asr_state_offense_summary_temp RENAME TO asr_state_offense_summary;

CREATE INDEX asr_state_offense_juvenile_idx ON asr_state_offense_summary (state_abbr, juvenile_flag);
CREATE INDEX asr_state_offense_sex_idx ON asr_state_offense_summary (state_abbr, sex);
CREATE INDEX asr_state_offense_age_range_code_idx ON asr_state_offense_summary (state_abbr, age_range_code);
CREATE INDEX asr_state_offense_race_code_idx ON asr_state_offense_summary (state_abbr, race_code);
CREATE INDEX asr_state_offense_offense_code_idx ON asr_state_offense_summary (state_abbr, offense_code);
CREATE INDEX asr_state_offense_offense_subcat_code_idx ON asr_state_offense_summary (state_abbr, offense_subcat_code);

---- JUVENILE CROSSTAB

--- Crosstabs are pivots of the sumamry tables where each row is a
--- single year, state_abbr, offense_code and the columns are the
--- count. I assemble these crosstabs from two smaller crosstabs
--- actually because Postgres has limited support for joining on
--- crosstabs.
DROP TABLE IF EXISTS asr_juvenile_crosstab;
CREATE TABLE asr_juvenile_crosstab(
  id serial PRIMARY KEY,
  year smallint,
  state_abbr character(2),
  offense_code text,
  offense_name text,
  agencies bigint,
  population bigint,
  total_male bigint,
  total_female bigint,
  m_0_9 bigint,
  m_10_12 bigint,
  m_13_14 bigint,
  m_15 bigint,
  m_16 bigint,
  m_17 bigint,
  f_0_9 bigint,
  f_10_12 bigint,
  f_13_14 bigint,
  f_15 bigint,
  f_16 bigint,
  f_17 bigint,
  race_agencies bigint,
  race_population bigint,
  white bigint,
  black bigint,
  asian_pacific_islander bigint,
  american_indian bigint,
  UNIQUE(year, state_abbr, offense_code)
);

DROP TABLE IF EXISTS asr_age_labels;
CREATE TEMPORARY TABLE asr_age_labels (
code text NOT NULL,
label text NOT NULL,
juvenile_flag character(1) NOT NULL
);

INSERT INTO asr_age_labels VALUES
  ('M_0_9', 'm_0_9', 'Y'),
  ('M_10_12', 'm_10_12', 'Y'),
  ('M_13_14', 'm_13_14', 'Y'),
  ('M_15', 'm_15', 'Y'),
  ('M_16', 'm_16', 'Y'),
  ('M_17', 'm_17', 'Y'),
  ('M_18', 'm_18', 'N'),
  ('M_19', 'm_19', 'N'),
  ('M_20', 'm_20', 'N'),
  ('M_21', 'm_21', 'N'),
  ('M_22', 'm_22', 'N'),
  ('M_23', 'm_23', 'N'),
  ('M_24', 'm_24', 'N'),
  ('M_25_29', 'm_25_29', 'N'),
  ('M_30_34', 'm_30_34', 'N'),
  ('M_35_39', 'm_35_39', 'N'),
  ('M_40_44', 'm_40_44', 'N'),
  ('M_45_49', 'm_45_49', 'N'),
  ('M_50_54', 'm_50_54', 'N'),
  ('M_55_59', 'm_55_59', 'N'),
  ('M_60_64', 'm_60_64', 'N'),
  ('M_65P', 'm_65p', 'N'),
  ('F_0_9', 'f_0_9', 'Y'),
  ('F_10_12', 'f_10_12', 'Y'),
  ('F_13_14', 'f_13_14', 'Y'),
  ('F_15', 'f_15', 'Y'),
  ('F_16', 'f_16', 'Y'),
  ('F_17', 'f_17', 'Y'),
  ('F_18', 'f_18', 'N'),
  ('F_19', 'f_19', 'N'),
  ('F_20', 'f_20', 'N'),
  ('F_21', 'f_21', 'N'),
  ('F_22', 'f_22', 'N'),
  ('F_23', 'f_23', 'N'),
  ('F_24', 'f_24', 'N'),
  ('F_25_29', 'f_25_29', 'N'),
  ('F_30_34', 'f_30_34', 'N'),
  ('F_35_39', 'f_35_39', 'N'),
  ('F_40_44', 'f_40_44', 'N'),
  ('F_45_49', 'f_45_49', 'N'),
  ('F_50_54', 'f_50_54', 'N'),
  ('F_55_59', 'f_55_59', 'N'),
  ('F_60_64', 'f_60_64', 'N'),
  ('F_65P', 'f_65p', 'N');


DROP TABLE IF EXISTS asr_juvenile_age_crosstab;
CREATE TEMPORARY TABLE asr_juvenile_age_crosstab(
   id serial PRIMARY KEY,
   year smallint,
   state_abbr character(2),
   offense_code text,
   f_0_9 bigint,
   f_10_12 bigint,
   f_13_14 bigint,
   f_15 bigint,
   f_16 bigint,
   f_17 bigint,
   m_0_9 bigint,
   m_10_12 bigint,
   m_13_14 bigint,
   m_15 bigint,
   m_16 bigint,
   m_17 bigint,
   UNIQUE(year, state_abbr, offense_code)
);

DROP TABLE IF EXISTS asr_race_labels;
CREATE TEMPORARY TABLE asr_race_labels (
code text,
label text
);

INSERT INTO asr_race_labels VALUES
('W', 'white'),
('B', 'black'),
('A', 'asian_pacific_islander'),  -- CJIS informed me that this field has pacific islander counts in it still
('AP', 'asian_pacific_islander'),
('I', 'american_indian');

DROP TABLE IF EXISTS asr_juvenile_race_crosstab;
CREATE TEMPORARY TABLE asr_juvenile_race_crosstab(
id serial PRIMARY KEY,
year smallint,
state_abbr character(2),
offense_code text,
white bigint,
black bigint,
asian_pacific_islander bigint,
american_indian bigint,
UNIQUE(year, state_abbr, offense_code)
);

DO
$do$
DECLARE
offense_codes text[] := ARRAY['ASR_HOM', 'ASR_MAN', 'ASR_RPE', 'ASR_ROB', 'ASR_AST', 'ASR_BRG', 'ASR_LRC', 'ASR_MVT', 'ASR_AST_SMP', 'ASR_ARSON', 'ASR_FOR', 'ASR_FRD', 'ASR_EMB', 'ASR_STP', 'ASR_VAN', 'ASR_WEAP', 'ASR_PRS', 'ASR_SEX', 'ASR_DRG', 'ASR_GAM', 'ASR_FAM', 'ASR_DUI', 'ASR_LIQ', 'ASR_DRK', 'ASR_DIS', 'ASR_VAG', 'ASR_OTH', 'ASR_SUS', 'ASR_CUR', 'ASR_RUN', 'ASR_HT'];
oc text;
states text[] := array['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS',
'MT', 'NE', 'NC', 'ND', 'NH', 'NJ', 'NM', 'NV',  'NY', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY'];
st text;
BEGIN
  FOREACH oc IN ARRAY offense_codes
  LOOP
  INSERT INTO asr_juvenile_age_crosstab(offense_code, year, f_0_9, f_10_12, f_13_14, f_15, f_16, f_17, m_0_9, m_10_12, m_13_14, m_15, m_16, m_17)
  SELECT oc AS offense_code, ct.*
    FROM CROSSTAB(
  $$
  SELECT year,
  l.label,
  SUM(arrest_count)
  FROM asr_offense_summary a
  JOIN asr_age_labels l ON l.code = a.age_range_code
  WHERE a.juvenile_flag = 'Y'
  AND age_range_code IS NOT NULL
  AND offense_code = '$$ || oc || $$'
  AND offense_subcat_code IS NULL
  GROUP by year, l.label
  ORDER by 1,2;
  $$,
  $$ select DISTINCT label from asr_age_labels where juvenile_flag='Y' order by label $$
  ) as ct (
  "year" smallint,
  -- these must be in the same order as the 2 queries above
  "f_0_9" bigint,
  "f_10_12" bigint,
  "f_13_14" bigint,
  "f_15" bigint,
  "f_16" bigint,
  "f_17" bigint,
  "m_0_9" bigint,
  "m_10_12" bigint,
  "m_13_14" bigint,
  "m_15" bigint,
  "m_16" bigint,
  "m_17" bigint
  );

  INSERT INTO asr_juvenile_race_crosstab(offense_code, year, white, black, asian_pacific_islander, american_indian)
  SELECT oc AS offense_code, ct.*
  FROM CROSSTAB(
  $$
  SELECT year,
  l.label,
  SUM(arrest_count) AS arrest_count
  FROM asr_offense_summary a
  JOIN asr_race_labels l ON l.code = a.race_code
  WHERE juvenile_flag = 'Y'
  AND race_code IS NOT NULL
  AND offense_code = '$$ || oc || $$'
  AND offense_subcat_code IS NULL
  GROUP by year, l.label
  ORDER by 1,2;
  $$,
  $$ select DISTINCT label from asr_race_labels order by label $$
  ) as ct (
  "year" smallint,
  "american_indian" bigint,
  "asian_pacific_islander" bigint,
  "black" bigint,
  "white" bigint
  );


  FOREACH st IN ARRAY states
  LOOP
    INSERT INTO asr_juvenile_age_crosstab(offense_code, state_abbr, year, f_0_9, f_10_12, f_13_14, f_15, f_16, f_17, m_0_9, m_10_12, m_13_14, m_15, m_16, m_17)
    SELECT oc AS offense_code, st AS state_abbr, ct.*
    FROM CROSSTAB(
    $$
    SELECT year,
    l.label,
    arrest_count
    FROM asr_state_offense_summary a
    JOIN asr_age_labels l ON l.code = a.age_range_code
    WHERE a.juvenile_flag = 'Y'
    AND age_range_code IS NOT NULL
    AND offense_code = '$$ || oc || $$'
    AND state_abbr = '$$ || st || $$'
    AND offense_subcat_code IS NULL
    ORDER by 1,2;
    $$,
    $$ select label from asr_age_labels where juvenile_flag='Y' order by label $$
    ) as ct (
      "year" smallint,
      "f_0_9" bigint,
      "f_10_12" bigint,
      "f_13_14" bigint,
      "f_15" bigint,
      "f_16" bigint,
      "f_17" bigint,
      "m_0_9" bigint,
      "m_10_12" bigint,
      "m_13_14" bigint,
      "m_15" bigint,
      "m_16" bigint,
      "m_17" bigint
    );

    INSERT INTO asr_juvenile_race_crosstab(offense_code, state_abbr, year, white, black, asian_pacific_islander, american_indian)
    SELECT oc AS offense_code, st AS state_abbr, ct.*
    FROM CROSSTAB(
    $$
    SELECT year,
    l.label,
    SUM(arrest_count) AS arrest_count
    FROM asr_state_offense_summary a
    JOIN asr_race_labels l ON l.code = a.race_code
    WHERE juvenile_flag = 'Y'
    AND race_code IS NOT NULL
    AND offense_code = '$$ || oc || $$'
    AND state_abbr = '$$ || st || $$'
    AND offense_subcat_code IS NULL
    GROUP by year, l.label
    ORDER by 1,2;
    $$,
    $$ select DISTINCT label from asr_race_labels order by label $$
    ) as ct (
      "year" smallint,
      "american_indian" bigint,
      "asian_pacific_islander" bigint,
      "black" bigint,
      "white" bigint
    );
    END LOOP;
  END LOOP;
END
$do$;

INSERT INTO asr_juvenile_crosstab(year, offense_code, offense_name, agencies, population, total_male, total_female, m_0_9, m_10_12, m_13_14, m_15, m_16, m_17, f_0_9, f_10_12, f_13_14, f_15, f_16, f_17, race_agencies, race_population, white, black, asian_pacific_islander, american_indian)
SELECT a.year, a.offense_code, o.offense_name, ap.agencies, ap.population, COALESCE(m_0_9,0)+COALESCE(m_10_12,0)+COALESCE(m_13_14,0)+COALESCE(m_15,0)+COALESCE(m_16,0)+COALESCE(m_17,0) AS total_male, COALESCE(f_0_9, 0)+COALESCE(f_10_12, 0)+COALESCE(f_13_14, 0)+COALESCE(f_15,0)+COALESCE(f_16,0)+COALESCE(f_17,0) AS total_female, m_0_9, m_10_12, m_13_14, m_15, m_16, m_17, f_0_9, f_10_12, f_13_14, f_15, f_16, f_17, rp.agencies, rp.population, white, black, asian_pacific_islander, american_indian
FROM asr_juvenile_age_crosstab a
JOIN asr_juvenile_race_crosstab r ON r.year = a.year AND r.offense_code = a.offense_code
JOIN asr_offense o ON o.offense_code = a.offense_code
JOIN asr_aas_populations ap ON ap.data_year = a.year and ap.state_abbr IS NULL
JOIN asr_race_populations rp ON rp.data_year = a.year and rp.state_abbr IS NULL
WHERE r.state_abbr IS NULL
AND a.state_abbr IS NULL;


INSERT INTO asr_juvenile_crosstab(year, state_abbr, offense_code, offense_name, agencies, population, total_male, total_female, m_0_9, m_10_12, m_13_14, m_15, m_16, m_17, f_0_9, f_10_12, f_13_14, f_15, f_16, f_17, race_agencies, race_population, white, black, asian_pacific_islander, american_indian)
SELECT a.year, a.state_abbr, a.offense_code, o.offense_name, ap.agencies, ap.population, COALESCE(m_0_9,0)+COALESCE(m_10_12,0)+COALESCE(m_13_14,0)+COALESCE(m_15,0)+COALESCE(m_16,0)+COALESCE(m_17,0) AS total_male, COALESCE(f_0_9, 0)+COALESCE(f_10_12, 0)+COALESCE(f_13_14, 0)+COALESCE(f_15,0)+COALESCE(f_16,0)+COALESCE(f_17,0) AS total_female, m_0_9, m_10_12, m_13_14, m_15, m_16, m_17, f_0_9, f_10_12, f_13_14, f_15, f_16, f_17, rp.agencies, rp.population, white, black, asian_pacific_islander, american_indian
FROM asr_juvenile_age_crosstab a
JOIN asr_juvenile_race_crosstab r ON r.year = a.year AND r.offense_code = a.offense_code AND r.state_abbr = a.state_abbr
JOIN asr_offense o ON o.offense_code = a.offense_code
JOIN asr_aas_populations ap ON ap.data_year = a.year and ap.state_abbr = a.state_abbr
JOIN asr_race_populations rp ON rp.data_year = a.year and rp.state_abbr = r.state_abbr;

------------  ADULT CROSSTAB
DROP TABLE IF EXISTS asr_adult_crosstab;
CREATE TABLE asr_adult_crosstab(
  id serial PRIMARY KEY,
  state_abbr character(2),
  year smallint,
  offense_code text,
  offense_name text,
  agencies bigint,
  population bigint,
  total_male bigint,
  total_female bigint,
  m_18 bigint,
  m_19 bigint,
  m_20 bigint,
  m_21 bigint,
  m_22 bigint,
  m_23 bigint,
  m_24 bigint,
  m_25_29 bigint,
  m_30_34 bigint,
  m_35_39 bigint,
  m_40_44 bigint,
  m_45_49 bigint,
  m_50_54 bigint,
  m_55_59 bigint,
  m_60_64 bigint,
  m_65p   bigint,
  f_18 bigint,
  f_19 bigint,
  f_20 bigint,
  f_21 bigint,
  f_22 bigint,
  f_23 bigint,
  f_24 bigint,
  f_25_29 bigint,
  f_30_34 bigint,
  f_35_39 bigint,
  f_40_44 bigint,
  f_45_49 bigint,
  f_50_54 bigint,
  f_55_59 bigint,
  f_60_64 bigint,
  f_65p bigint,
  race_agencies bigint,
  race_population bigint,
  white bigint,
  black bigint,
  asian_pacific_islander bigint,
  american_indian bigint,
  UNIQUE(year, state_abbr, offense_code)
);

DROP TABLE IF EXISTS asr_adult_age_crosstab;
CREATE TEMPORARY TABLE asr_adult_age_crosstab(
   id serial PRIMARY KEY,
   year smallint,
   state_abbr character(2),
   offense_code text,
   f_18 bigint,
   f_19 bigint,
   f_20 bigint,
   f_21 bigint,
   f_22 bigint,
   f_23 bigint,
   f_24 bigint,
   f_25_29 bigint,
   f_30_34 bigint,
   f_35_39 bigint,
   f_40_44 bigint,
   f_45_49 bigint,
   f_50_54 bigint,
   f_55_59 bigint,
   f_60_64 bigint,
   f_65p bigint,
   m_18 bigint,
   m_19 bigint,
   m_20 bigint,
   m_21 bigint,
   m_22 bigint,
   m_23 bigint,
   m_24 bigint,
   m_25_29 bigint,
   m_30_34 bigint,
   m_35_39 bigint,
   m_40_44 bigint,
   m_45_49 bigint,
   m_50_54 bigint,
   m_55_59 bigint,
   m_60_64 bigint,
   m_65p   bigint,
   UNIQUE(year, state_abbr, offense_code)
);

DROP TABLE IF EXISTS asr_adult_race_crosstab;
CREATE TEMPORARY TABLE asr_adult_race_crosstab(
  id serial PRIMARY KEY,
  state_abbr character(2),
  year smallint,
  offense_code text,
  white bigint,
  black bigint,
  asian_pacific_islander bigint,
  american_indian bigint,
  UNIQUE(year, state_abbr, offense_code)
);

DO
$do$
DECLARE
offense_codes text[] := ARRAY['ASR_HOM', 'ASR_MAN', 'ASR_RPE', 'ASR_ROB', 'ASR_AST', 'ASR_BRG', 'ASR_LRC', 'ASR_MVT', 'ASR_AST_SMP', 'ASR_ARSON', 'ASR_FOR', 'ASR_FRD', 'ASR_EMB', 'ASR_STP', 'ASR_VAN', 'ASR_WEAP', 'ASR_PRS', 'ASR_SEX', 'ASR_DRG', 'ASR_GAM', 'ASR_FAM', 'ASR_DUI', 'ASR_LIQ', 'ASR_DRK', 'ASR_DIS', 'ASR_VAG', 'ASR_OTH', 'ASR_SUS', 'ASR_CUR', 'ASR_RUN', 'ASR_HT'];
oc text;
states text[] := array['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS',
'MT', 'NE', 'NC', 'ND', 'NH', 'NJ', 'NM', 'NV',  'NY', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY'];
st text;
BEGIN
  FOREACH oc IN ARRAY offense_codes
  LOOP
    INSERT INTO asr_adult_age_crosstab(offense_code, year, f_18, f_19, f_20, f_21, f_22, f_23, f_24, f_25_29, f_30_34, f_35_39, f_40_44, f_45_49, f_50_54, f_55_59, f_60_64, f_65p, m_18, m_19, m_20, m_21, m_22, m_23, m_24, m_25_29, m_30_34, m_35_39, m_40_44, m_45_49, m_50_54, m_55_59, m_60_64, m_65p)
    SELECT oc AS offense_code, ct.*
    FROM CROSSTAB(
      $$
      SELECT year,
      l.label,
      arrest_count
      FROM asr_offense_summary a
      JOIN asr_age_labels l ON l.code = a.age_range_code
      WHERE a.juvenile_flag = 'N'
      AND age_range_code IS NOT NULL
      AND offense_code = '$$ || oc || $$'
      AND offense_subcat_code IS NULL
      ORDER by 1,2;
      $$,
      $$ SELECT label from asr_age_labels where juvenile_flag = 'N' order by label $$
    ) as ct (
      "year" smallint,
      "f_18" bigint,
      "f_19" bigint,
      "f_20" bigint,
      "f_21" bigint,
      "f_22" bigint,
      "f_23" bigint,
      "f_24" bigint,
      "f_25_29" bigint,
      "f_30_34" bigint,
      "f_35_39" bigint,
      "f_40_44" bigint,
      "f_45_49" bigint,
      "f_50_54" bigint,
      "f_55_59" bigint,
      "f_60_64" bigint,
      "f_65p"   bigint,
      "m_18" bigint,
      "m_19" bigint,
      "m_20" bigint,
      "m_21" bigint,
      "m_22" bigint,
      "m_23" bigint,
      "m_24" bigint,
      "m_25_29" bigint,
      "m_30_34" bigint,
      "m_35_39" bigint,
      "m_40_44" bigint,
      "m_45_49" bigint,
      "m_50_54" bigint,
      "m_55_59" bigint,
      "m_60_64" bigint,
      "m_65p"   bigint
    );

    INSERT INTO asr_adult_race_crosstab(offense_code, year, white, black, asian_pacific_islander, american_indian)
    SELECT oc AS offense_code, ct.*
    FROM CROSSTAB(
      $$
      SELECT year,
      l.label,
      SUM(arrest_count) AS arrest_count
      FROM asr_offense_summary a
      JOIN asr_race_labels l ON l.code = a.race_code
      WHERE juvenile_flag = 'N'
      AND race_code IS NOT NULL
      AND offense_code = '$$ || oc || $$'
      AND offense_subcat_code IS NULL
      GROUP by year, l.label
      ORDER by 1,2;
      $$,
      $$ select DISTINCT label from asr_race_labels ORDER by label $$
    ) as ct (
      "year" smallint,
      "american_indian" bigint,
      "asian_pacific_islander" bigint,
      "black" bigint,
      "white" bigint
    );

    FOREACH st IN ARRAY states
    LOOP
      INSERT INTO asr_adult_age_crosstab(offense_code, state_abbr, year, f_18, f_19, f_20, f_21, f_22, f_23, f_24, f_25_29, f_30_34, f_35_39, f_40_44, f_45_49, f_50_54, f_55_59, f_60_64, f_65p, m_18, m_19, m_20, m_21, m_22, m_23, m_24, m_25_29, m_30_34, m_35_39, m_40_44, m_45_49, m_50_54, m_55_59, m_60_64, m_65p)
      SELECT oc AS offense_code, st AS state_abbr, ct.*
      FROM CROSSTAB(
        $$
        SELECT year,
        l.label,
        arrest_count
        FROM asr_state_offense_summary a
        JOIN asr_age_labels l ON l.code = a.age_range_code
        WHERE a.juvenile_flag = 'N'
        AND age_range_code IS NOT NULL
        AND offense_code = '$$ || oc || $$'
        AND state_abbr = '$$ || st || $$'
        AND offense_subcat_code IS NULL
        ORDER by 1,2;
        $$,
        $$ SELECT label from asr_age_labels where juvenile_flag = 'N' order by label $$
      ) as ct (
        "year" smallint,
        "f_18" bigint,
        "f_19" bigint,
        "f_20" bigint,
        "f_21" bigint,
        "f_22" bigint,
        "f_23" bigint,
        "f_24" bigint,
        "f_25_29" bigint,
        "f_30_34" bigint,
        "f_35_39" bigint,
        "f_40_44" bigint,
        "f_45_49" bigint,
        "f_50_54" bigint,
        "f_55_59" bigint,
        "f_60_64" bigint,
        "f_65p"   bigint,
        "m_18" bigint,
        "m_19" bigint,
        "m_20" bigint,
        "m_21" bigint,
        "m_22" bigint,
        "m_23" bigint,
        "m_24" bigint,
        "m_25_29" bigint,
        "m_30_34" bigint,
        "m_35_39" bigint,
        "m_40_44" bigint,
        "m_45_49" bigint,
        "m_50_54" bigint,
        "m_55_59" bigint,
        "m_60_64" bigint,
        "m_65p"   bigint
      );

      INSERT INTO asr_adult_race_crosstab(offense_code, state_abbr, year, white, black, asian_pacific_islander, american_indian)
      SELECT oc AS offense_code, st AS state_abbr, ct.*
      FROM CROSSTAB(
        $$
        SELECT year,
        l.label,
        SUM(arrest_count) AS arrest_count
        FROM asr_state_offense_summary a
        JOIN asr_race_labels l ON l.code = a.race_code
        WHERE juvenile_flag = 'N'
        AND race_code IS NOT NULL
        AND offense_code = '$$ || oc || $$'
        AND state_abbr = '$$ || st || $$'
        AND offense_subcat_code IS NULL
        GROUP by year, l.label
        ORDER by 1,2;
        $$,
        $$ select DISTINCT label from asr_race_labels ORDER by label $$
      ) as ct (
        "year" smallint,
        "american_indian" bigint,
        "asian_pacific_islander" bigint,
        "black" bigint,
        "white" bigint
      );
    END LOOP;
  END LOOP;
END
$do$;

INSERT INTO asr_adult_crosstab(year, offense_code, offense_name, agencies, population, total_female, total_male, f_18, f_19, f_20, f_21, f_22, f_23, f_24, f_25_29, f_30_34, f_35_39, f_40_44, f_45_49, f_50_54, f_55_59, f_60_64, f_65p, m_18, m_19, m_20, m_21, m_22, m_23, m_24, m_25_29, m_30_34, m_35_39, m_40_44, m_45_49, m_50_54, m_55_59, m_60_64, m_65p, race_agencies, race_population, white, black, asian_pacific_islander, american_indian)
SELECT a.year, a.offense_code, o.offense_name, ap.agencies, ap.population, COALESCE(f_18, 0)+COALESCE(f_19, 0)+COALESCE(f_20, 0)+COALESCE(f_21, 0)+COALESCE(f_22, 0)+COALESCE(f_23, 0)+COALESCE(f_24, 0)+COALESCE(f_25_29, 0)+COALESCE(f_30_34, 0)+COALESCE(f_35_39, 0)+COALESCE(f_40_44, 0)+COALESCE(f_45_49, 0)+COALESCE(f_50_54, 0)+COALESCE(f_55_59, 0)+COALESCE(f_60_64, 0)+COALESCE(f_65p, 0) AS total_female, COALESCE(m_18, 0)+COALESCE(m_19, 0)+COALESCE(m_20, 0)+COALESCE(m_21, 0)+COALESCE(m_22, 0)+COALESCE(m_23, 0)+COALESCE(m_24, 0)+COALESCE(m_25_29, 0)+COALESCE(m_30_34, 0)+COALESCE(m_35_39, 0)+COALESCE(m_40_44, 0)+COALESCE(m_45_49, 0)+COALESCE(m_50_54, 0)+COALESCE(m_55_59, 0)+COALESCE(m_60_64, 0)+COALESCE(m_65p, 0) AS total_male, f_18, f_19, f_20, f_21, f_22, f_23, f_24, f_25_29, f_30_34, f_35_39, f_40_44, f_45_49, f_50_54, f_55_59, f_60_64, f_65p, m_18, m_19, m_20, m_21, m_22, m_23, m_24, m_25_29, m_30_34, m_35_39, m_40_44, m_45_49, m_50_54, m_55_59, m_60_64, m_65p, rp.agencies, rp.population, white, black, asian_pacific_islander, american_indian
FROM asr_adult_age_crosstab a
JOIN asr_adult_race_crosstab r ON r.year = a.year AND r.offense_code = a.offense_code
JOIN asr_offense o ON o.offense_code = a.offense_code
JOIN asr_aas_populations ap ON ap.data_year = a.year and ap.state_abbr IS NULL
JOIN asr_race_populations rp ON rp.data_year = a.year and rp.state_abbr IS NULL
WHERE a.state_abbr IS NULL AND r.state_abbr IS NULL;

INSERT INTO asr_adult_crosstab(year, state_abbr, offense_code, offense_name, agencies, population, total_female, total_male, f_18, f_19, f_20, f_21, f_22, f_23, f_24, f_25_29, f_30_34, f_35_39, f_40_44, f_45_49, f_50_54, f_55_59, f_60_64, f_65p, m_18, m_19, m_20, m_21, m_22, m_23, m_24, m_25_29, m_30_34, m_35_39, m_40_44, m_45_49, m_50_54, m_55_59, m_60_64, m_65p, race_agencies, race_population, white, black, asian_pacific_islander, american_indian)
SELECT a.year, a.state_abbr, a.offense_code, o.offense_name, ap.agencies, ap.population, COALESCE(f_18, 0)+COALESCE(f_19, 0)+COALESCE(f_20, 0)+COALESCE(f_21, 0)+COALESCE(f_22, 0)+COALESCE(f_23, 0)+COALESCE(f_24, 0)+COALESCE(f_25_29, 0)+COALESCE(f_30_34, 0)+COALESCE(f_35_39, 0)+COALESCE(f_40_44, 0)+COALESCE(f_45_49, 0)+COALESCE(f_50_54, 0)+COALESCE(f_55_59, 0)+COALESCE(f_60_64, 0)+COALESCE(f_65p, 0) AS total_female, COALESCE(m_18, 0)+COALESCE(m_19, 0)+COALESCE(m_20, 0)+COALESCE(m_21, 0)+COALESCE(m_22, 0)+COALESCE(m_23, 0)+COALESCE(m_24, 0)+COALESCE(m_25_29, 0)+COALESCE(m_30_34, 0)+COALESCE(m_35_39, 0)+COALESCE(m_40_44, 0)+COALESCE(m_45_49, 0)+COALESCE(m_50_54, 0)+COALESCE(m_55_59, 0)+COALESCE(m_60_64, 0)+COALESCE(m_65p, 0) AS total_male, f_18, f_19, f_20, f_21, f_22, f_23, f_24, f_25_29, f_30_34, f_35_39, f_40_44, f_45_49, f_50_54, f_55_59, f_60_64, f_65p, m_18, m_19, m_20, m_21, m_22, m_23, m_24, m_25_29, m_30_34, m_35_39, m_40_44, m_45_49, m_50_54, m_55_59, m_60_64, m_65p, rp.agencies, rp.population, white, black, asian_pacific_islander, american_indian
FROM asr_adult_age_crosstab a
JOIN asr_adult_race_crosstab r ON r.year = a.year AND r.offense_code = a.offense_code AND a.state_abbr = r.state_abbr
JOIN asr_offense o ON o.offense_code = a.offense_code
JOIN asr_aas_populations ap ON ap.data_year = a.year and ap.state_abbr = a.state_abbr
JOIN asr_race_populations rp ON rp.data_year = a.year and rp.state_abbr = r.state_abbr;


------------- DRUG CROSSTAB
DROP TABLE If EXISTS asr_drug_crosstab;
CREATE TABLE asr_drug_crosstab(
id serial PRIMARY KEY,
year smallint,
state_abbr character(2),
agencies bigint,
population bigint,
total_arrests bigint,
total_manufacture bigint,
opioid_manufacture bigint,
marijuana_manufacture bigint,
synthetic_manufacture bigint,
other_manufacture bigint,
total_possess bigint,
opioid_possess bigint,
marijuana_possess bigint,
synthetic_possess bigint,
other_possess bigint,
UNIQUE(year, state_abbr)
);

DROP TABLE IF EXISTS asr_drug_labels;
CREATE TEMPORARY TABLE asr_drug_labels (
  code text,
  label text
);

INSERT INTO asr_drug_labels VALUES
('ASR_DRG', 'total_arrests'),
('ASR_DRG_MAN', 'total_manufacture'),
('ASR_DRG_MAN_CKE', 'opioid_manufacture'),
('ASR_DRG_MAN_MAR', 'marijuana_manufacture'),
('ASR_DRG_MAN_SYN', 'synthetic_manufacture'),
('ASR_DRG_MAN_OTH', 'other_manufacture'),
('ASR_DRG_POS', 'total_possess'),
('ASR_DRG_POS_CKE', 'opioid_possess'),
('ASR_DRG_POS_MAR', 'marijuana_possess'),
('ASR_DRG_POS_SYN', 'synthetic_possess'),
('ASR_DRG_POS_OTH', 'other_possess');

DROP TABLE IF EXISTS asr_drug_rollup;
CREATE TEMPORARY TABLE asr_drug_rollup AS
SELECT s.data_year AS year, s.state_id, d.label, SUM(arrest_count) AS arrest_count
FROM asr_age_suboffense_summary s
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = s.offense_subcat_id
JOIN asr_drug_labels d ON d.code = aos.offense_subcat_code
GROUP BY GROUPING SETS(
(s.data_year, s.state_id, d.label),
(s.data_year, d.label));

INSERT INTO asr_drug_crosstab(year, total_arrests, total_manufacture, opioid_manufacture, marijuana_manufacture, synthetic_manufacture, other_manufacture, total_possess, opioid_possess, marijuana_possess, synthetic_possess, other_possess)
SELECT year, total_arrests, total_manufacture, opioid_manufacture, marijuana_manufacture, synthetic_manufacture, other_manufacture, total_possess, opioid_possess, marijuana_possess, synthetic_possess, other_possess
FROM CROSSTAB(
$$ SELECT year,
label,
arrest_count
FROM asr_drug_rollup
WHERE state_id IS NULL
ORDER BY 1,2$$,
$$ SELECT label from asr_drug_labels order by label $$
) AS ct (
"year" smallint,
"marijuana_manufacture" bigint,
"marijuana_possess" bigint,
"opioid_manufacture" bigint,
"opioid_possess" bigint,
"other_manufacture" bigint,
"other_possess" bigint,
"synthetic_manufacture" bigint,
"synthetic_possess" bigint,
"total_arrests" bigint,
"total_manufacture" bigint,
"total_possess" bigint
);

DO
$do$
DECLARE
states text[] := array['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS',
'MT', 'NE', 'NC', 'ND', 'NH', 'NJ', 'NM', 'NV',  'NY', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY'];
st text;
BEGIN
FOREACH st IN ARRAY states
LOOP
INSERT INTO asr_drug_crosstab(state_abbr, year, total_arrests, total_manufacture, opioid_manufacture, marijuana_manufacture, synthetic_manufacture, other_manufacture, total_possess, opioid_possess, marijuana_possess, synthetic_possess, other_possess)
SELECT st AS state_abbr, ct.year, total_arrests, total_manufacture, opioid_manufacture, marijuana_manufacture, synthetic_manufacture, other_manufacture, total_possess, opioid_possess, marijuana_possess, synthetic_possess, other_possess FROM CROSSTAB(
$$ SELECT year,
label,
arrest_count
FROM asr_drug_rollup a
JOIN ref_state rs ON rs.state_id = a.state_id
WHERE rs.state_postal_abbr = '$$ || st || $$'
ORDER BY 1,2$$,
$$ SELECT label from asr_drug_labels order by label $$
) AS ct (
"year" smallint,
"marijuana_manufacture" bigint,
"marijuana_possess" bigint,
"opioid_manufacture" bigint,
"opioid_possess" bigint,
"other_manufacture" bigint,
"other_possess" bigint,
"synthetic_manufacture" bigint,
"synthetic_possess" bigint,
"total_arrests" bigint,
"total_manufacture" bigint,
"total_possess" bigint
);

END LOOP;
END
$do$;

UPDATE asr_drug_crosstab
SET agencies=p.agencies, population=p.population
FROM asr_aas_populations p
WHERE asr_drug_crosstab.year=p.data_year
AND asr_drug_crosstab.state_abbr=p.state_abbr;

UPDATE asr_drug_crosstab
SET agencies=p.agencies, population=p.population
FROM asr_aas_populations p
WHERE asr_drug_crosstab.year=p.data_year
AND asr_drug_crosstab.state_abbr IS NULL
AND p.state_abbr IS NULL;
