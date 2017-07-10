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

-- Race reporting is a bit more complicated. You need to look at what was filed
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

DROP function IF EXISTS create_year_partition_and_insert() CASCADE;
CREATE OR REPLACE FUNCTION create_year_partition_and_insert() RETURNS trigger AS
$BODY$
DECLARE
partition TEXT;
BEGIN
partition := TG_RELNAME || '_' || NEW.year;
IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=lower(partition)) THEN
RAISE NOTICE 'A partition has been created %', partition;
EXECUTE 'CREATE TABLE IF NOT EXISTS ' || partition || ' (check (year = ' || NEW.year || ')) INHERITS (' || TG_RELNAME || ');';
END IF;
EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').*;';
RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

CREATE TABLE IF NOT EXISTS asr_offense_summary (
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

CREATE INDEX asr_offense_juvenile_idx ON asr_offense_summary (juvenile_flag);
CREATE INDEX asr_offense_sex_idx ON asr_offense_summary (sex);
CREATE INDEX asr_offense_age_range_code_idx ON asr_offense_summary (age_range_code);
CREATE INDEX asr_offense_race_code_idx ON asr_offense_summary (race_code);
CREATE INDEX asr_offense_offense_code_idx ON asr_offense_summary (offense_code);
CREATE INDEX asr_offense_offense_subcat_code_idx ON asr_offense_summary (offense_subcat_code);

CREATE TRIGGER asr_offense_summary_partition_insert_trigger
BEFORE INSERT ON asr_offense_summary
FOR EACH ROW EXECUTE PROCEDURE create_year_partition_and_insert();

DO
$do$
DECLARE
   arr integer[] := array[2014,2013,2012,2011,2010,2009,2008,2007,2006,2005,2004,2003,2002,2001,2000,1999,1998,1997,1996,1995,1994,1993,1992,1991,1990];
   offenses text[] := array['ASR_JUV_DIS', 'ASR_HOM', 'ASR_MAN', 'ASR_RPE', 'ASR_ROB', 'ASR_AST', 'ASR_BRG', 'ASR_LRC', 'ASR_MVT', 'ASR_AST_SMP', 'ASR_ARSON', 'ASR_FOR', 'ASR_FRD', 'ASR_EMB', 'ASR_STP', 'ASR_VAN', 'ASR_WEAP', 'ASR_PRS', 'ASR_SEX', 'ASR_DRG', 'ASR_DRG_MAN', 'ASR_DRG_POS', 'ASR_GAM', 'ASR_FAM', 'ASR_DUI', 'ASR_LIQ', 'ASR_DRK', 'ASR_DIS', 'ASR_VAG', 'ASR_OTH', 'ASR_SUS', 'ASR_CUR', 'ASR_RUN', 'ASR_HT', 'ASR_ZERO'];
   i integer;
   offense text;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
      SET work_mem='3GB';
      RAISE NOTICE 'Dropping view for year: %', i;
      EXECUTE 'drop table  IF EXISTS asr_offense_summary_' || i::TEXT || ' CASCADE';
      RAISE NOTICE 'Creating view for year: %', i;
      FOREACH offense IN ARRAY offenses
      LOOP
          EXECUTE 'INSERT INTO asr_offense_summary(year, juvenile_flag, sex, age_range_code, age_range_name, race_code, race_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name, arrest_count) SELECT am.data_year, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name, rr.race_code, rr.race_desc AS race_name,
       ao.offense_code, ao.offense_name, aos.offense_subcat_code, aos.offense_subcat_name,
       SUM(aas.arrest_count) AS arrest_count
FROM asr_age_sex_subcat aas
JOIN asr_month am ON am.asr_month_id = aas.asr_month_id
LEFT OUTER JOIN asr_race_offense_subcat ros ON ros.asr_month_id = aas.asr_month_id
LEFT OUTER JOIN ref_race rr ON rr.race_id = ros.race_id
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aas.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aas.age_range_id
JOIN ref_agency ra ON ra.agency_id = am.agency_id
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id = ra.agency_id AND rap.data_year = am.data_year
JOIN asr_reporting ar ON ar.agency_id = ra.agency_id AND ar.data_year = am.data_year
WHERE ar.months_reported = 12 AND aas.arrest_status = 0 and am.data_year = ' || i::TEXT || ' AND ao.offense_code = ''' || offense || '''
GROUP BY GROUPING SETS(
(am.data_year, offense_code, offense_name),
(am.data_year, offense_code, offense_name, aar.juvenile_flag),
(am.data_year, offense_code, offense_name, age_sex),
(am.data_year, offense_code, offense_name, aar.juvenile_flag, age_sex),
(am.data_year, offense_code, offense_name, aar.age_range_code, aar.age_range_name),
(am.data_year, offense_code, offense_name, race_code, race_desc),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, age_sex),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag, age_sex),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_range_code, aar.age_range_name),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, race_code, race_desc)
);';
   END LOOP;
   END LOOP;
END
$do$;

UPDATE asr_offense_summary
SET agencies=asr_aas_populations.agencies, population=asr_aas_populations.population
FROM asr_aas_populations
WHERE data_year=asr_aas_populations.data_year
AND state_abbr IS NULL;

UPDATE asr_offense_summary
SET agencies=asr_race_populations.agencies, population=asr_race_populations.population
FROM asr_race_populations
WHERE data_year=asr_race_populations.data_year
AND state_abbr IS NULL AND race_code IS NOT NULL;

--
-- DROP function IF EXISTS create_state_partition_and_insert() CASCADE;
-- CREATE OR REPLACE FUNCTION create_state_partition_and_insert() RETURNS trigger AS
-- $BODY$
-- DECLARE
-- partition_state TEXT;
-- partition TEXT;
-- BEGIN
-- partition_state := lower(NEW.state_abbr);
-- partition := TG_RELNAME || '_' || partition_state;
-- IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=lower(partition)) THEN
-- RAISE NOTICE 'A partition has been created %', partition;
-- EXECUTE 'CREATE TABLE IF NOT EXISTS ' || partition || ' (check (lower(state_abbr) = lower(''' || NEW.state_abbr || '''))) INHERITS (' || TG_RELNAME || ');';
-- END IF;
-- EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').*;';
-- RETURN NULL;
-- END;
-- $BODY$
-- LANGUAGE plpgsql VOLATILE
-- COST 100;

-- CREATE TABLE IF NOT EXISTS asr_offense_state_summary (
-- id serial PRIMARY KEY,
-- year smallint,
-- state_abbr character(2),
-- state_name text,
-- juvenile_flag character(1),
-- sex character(1),
-- age_range_code text,
-- age_range_name text,
-- race_code character(1),
-- race_name text,
-- offense_code text,
-- offense_name text,
-- offense_subcat_code text,
-- offense_subcat_name text,
-- arrest_count integer,
-- agencies integer,
-- population bigint
-- );

-- DROP TRIGGER IF EXISTS asr_offense_state_summary_insert_state_partition ON asr_offense_state_summary;
-- CREATE TRIGGER asr_offense_state_summary_insert_state_partition
-- BEFORE INSERT ON asr_offense_state_summary
-- FOR EACH ROW EXECUTE PROCEDURE create_state_partition_and_insert();

-- DO
-- $do$
-- DECLARE
-- arr text[] := array['ak', 'al', 'ar', 'as', 'az', 'ca', 'co', 'ct', 'cz', 'dc', 'de', 'fl', 'ga', 'gu', 'hi', 'ia', 'id', 'il', 'in', 'ks', 'ky', 'la', 'ma', 'md', 'me', 'mi', 'mn', 'mo', 'mp', 'ms', 'mt', 'nc', 'nd', 'ne', 'nh', 'nj', 'nm', 'nv', 'ny', 'oh', 'ok', 'or', 'ot', 'pa', 'pr', 'ri', 'sc', 'sd', 'tn', 'ts', 'tx', 'ut', 'va', 'vi', 'vt', 'wa', 'wi', 'wv', 'wy'];
-- abbr text;
-- BEGIN
-- FOREACH abbr IN ARRAY arr
-- LOOP
-- SET work_mem='2GB';
-- EXECUTE 'DROP TABLE IF EXISTS asr_offense_state_summary_' || abbr;
-- EXECUTE 'INSERT INTO asr_offense_state_summary(year, state_abbr, state_name, juvenile_flag, sex, age_range_code, age_range_name, race_code, race_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name, arrest_count, agencies, population)
-- SELECT am.data_year, rs.state_postal_abbr, rs.state_name, aar.juvenile_flag, aar.age_sex, aar.age_range_code, aar.age_range_name, rr.race_code, rr.race_desc AS race_name,
--        ao.offense_code, ao.offense_name, aos.offense_subcat_code, aos.offense_subcat_name,
--        SUM(aas.arrest_count) AS arrest_count,
--        COUNT(DISTINCT ra.agency_id) AS agencies,
--        SUM(rap.population) AS population
-- FROM asr_age_sex_subcat aas
-- JOIN asr_month am ON am.asr_month_id = aas.asr_month_id
-- LEFT OUTER JOIN asr_race_offense_subcat ros ON ros.asr_month_id = aas.asr_month_id
-- LEFT OUTER JOIN ref_race rr ON rr.race_id = ros.race_id
-- JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aas.offense_subcat_id
-- JOIN asr_offense ao ON ao.offense_id = aos.offense_id
-- JOIN asr_age_range aar ON aar.age_range_id = aas.age_range_id
-- JOIN ref_agency ra ON ra.agency_id = am.agency_id
-- JOIN ref_state rs ON rs.state_id = ra.state_id
-- LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id = ra.agency_id AND rap.data_year = am.data_year
-- JOIN asr_reporting ar ON ar.agency_id = ra.agency_id AND ar.data_year = am.data_year
-- WHERE ar.months_reported = 12 AND aas.arrest_status = 0 AND rs.state_postal_abbr = ''' || abbr || ''' AND am.data_year > 1994
-- GROUP BY GROUPING SETS(
-- (am.data_year, rs.state_postal_abbr, rs.state_name),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, aar.juvenile_flag),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, age_sex),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, aar.juvenile_flag, age_sex),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, aar.age_range_code, aar.age_range_name),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, race_code),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, aar.juvenile_flag),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, age_sex),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, aar.juvenile_flag, age_sex),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, aar.age_range_code, aar.age_range_name),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, race_code, race_desc),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name, age_sex),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag, age_sex),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_range_code, aar.age_range_name),
-- (am.data_year, rs.state_postal_abbr, rs.state_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name, race_code, race_desc)
-- );';
--   END LOOP;
-- END;
-- $do$;

-- CREATE INDEX asr_state_offense_year_idx ON asr_offense_state_summary (year);
-- CREATE INDEX asr_state_offense_state_abbr_idx ON asr_offense_state_summary (state_abbr);
-- CREATE INDEX asr_state_offense_juvenile_idx ON asr_offense_state_summary (juvenile_flag);
-- CREATE INDEX asr_state_offense_sex_idx ON asr_offense_state_summary (sex);
-- CREATE INDEX asr_state_offense_age_range_code_idx ON asr_offense_state_summary (age_range_code);
-- CREATE INDEX asr_state_offense_race_code_idx ON asr_offense_state_summary (race_code);
-- CREATE INDEX asr_state_offense_offense_code_idx ON asr_offense_state_summary (offense_code);
-- CREATE INDEX asr_state_offense_offense_subcat_code_idx ON asr_offense_state_summary (offense_subcat_code);
