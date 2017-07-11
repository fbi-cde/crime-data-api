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
   years int[] := array[2014, 2013, 2012, 2011, 2010, 2009, 2008, 2007, 2006, 2005, 2004, 2003, 2002, 2001, 2000, 1999, 1998, 1997, 1996, 1995, 1994, 1993, 1992, 1991, 1990, 1989, 1988, 1987, 1986, 1985, 1984, 1983, 1982, 1981, 1980];
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
   offense_subcat_id int,
   arrest_count bigint
);

DO
$do$
DECLARE
  years int[] := array[2014, 2013, 2012, 2011, 2010, 2009, 2008, 2007, 2006, 2005, 2004, 2003, 2002, 2001, 2000, 1999, 1998, 1997, 1996, 1995, 1994, 1993, 1992, 1991, 1990, 1989, 1988, 1987, 1986, 1985, 1984, 1983, 1982, 1981, 1980];
  y int;
BEGIN
  SET work_mem = '3GB';
  FOREACH y IN ARRAY years
  LOOP
    EXECUTE 'INSERT INTO asr_race_suboffense_summary(data_year, state_id, race_id, offense_subcat_id, arrest_count)
             SELECT am.data_year, ra.state_id, aas.race_id, aas.offense_subcat_id, SUM(arrest_count)
             FROM asr_race_offense_subcat aas
             JOIN asr_month am ON aas.asr_month_id = am.asr_month_id
             JOIN ref_agency ra ON ra.agency_id = am.agency_id
             JOIN asr_reporting ar ON ar.agency_id = am.agency_id AND ar.data_year = am.data_year
             WHERE am.data_year = ' || y || ' AND ar.months_reported = 12
             GROUP BY am.data_year, ra.state_id, aas.race_id, aas.offense_subcat_id;';
  END LOOP;
END;
$do$;

DROP TABLE IF EXISTS asr_offense_summary_temp;
CREATE TABLE IF NOT EXISTS asr_offense_summary_temp (
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

INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, juvenile_flag, arrest_count)
SELECT aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
GROUP BY aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag;

INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, juvenile_flag, arrest_count)
SELECT aass.data_year, offense_code, offense_name, aar.juvenile_flag, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
GROUP BY aass.data_year, offense_code, offense_name, aar.juvenile_flag;

INSERT INTO asr_offense_summary_temp(year, juvenile_flag, arrest_count)
SELECT aass.data_year, aar.juvenile_flag, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
GROUP BY aass.data_year, aar.juvenile_flag;

INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, sex, arrest_count)
SELECT aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_sex, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
GROUP BY aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_sex;

INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, sex, arrest_count)
SELECT aass.data_year, offense_code, offense_name, aar.age_sex, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
GROUP BY aass.data_year, offense_code, offense_name, aar.age_sex;

INSERT INTO asr_offense_summary_temp(year, sex, arrest_count)
SELECT aass.data_year, aar.age_sex, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
GROUP BY aass.data_year, aar.age_sex;

INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, age_range_code, age_range_name, arrest_count)
SELECT aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_range_code, aar.age_range_name, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
GROUP BY aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_range_code, aar.age_range_name;

INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, age_range_code, age_range_name, arrest_count)
SELECT aass.data_year, offense_code, offense_name, aar.age_range_code, aar.age_range_name, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
GROUP BY aass.data_year, offense_code, offense_name, aar.age_range_code, aar.age_range_name;

INSERT INTO asr_offense_summary_temp(year, age_range_code, age_range_name, arrest_count)
SELECT aass.data_year, aar.age_range_code, aar.age_range_name, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
GROUP BY aass.data_year, aar.age_range_code, aar.age_range_name;

INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, race_code, race_name, arrest_count)
SELECT aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, rr.race_code, rr.race_desc, SUM(aass.arrest_count)
FROM asr_race_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN ref_race rr ON aass.race_id = rr.race_id
GROUP BY aass.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, rr.race_code, rr.race_desc;

INSERT INTO asr_offense_summary_temp(year, offense_code, offense_name, race_code, race_name, arrest_count)
SELECT aass.data_year, offense_code, offense_name, rr.race_code, rr.race_desc, SUM(aass.arrest_count)
FROM asr_race_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN ref_race rr ON aass.race_id = rr.race_id
GROUP BY aass.data_year, offense_code, offense_name, rr.race_code, rr.race_desc;

INSERT INTO asr_offense_summary_temp(year, race_code, race_name, arrest_count)
SELECT aass.data_year, rr.race_code, rr.race_desc, SUM(aass.arrest_count)
FROM asr_race_suboffense_summary aass
JOIN ref_race rr ON aass.race_id = rr.race_id
GROUP BY aass.data_year, rr.race_code, rr.race_desc;


CREATE INDEX asr_offense_juvenile_idx ON asr_offense_summary_temp (juvenile_flag);
CREATE INDEX asr_offense_sex_idx ON asr_offense_summary_temp (sex);
CREATE INDEX asr_offense_age_range_code_idx ON asr_offense_summary_temp (age_range_code);
CREATE INDEX asr_offense_race_code_idx ON asr_offense_summary_temp (race_code);
CREATE INDEX asr_offense_offense_code_idx ON asr_offense_summary_temp (offense_code);
CREATE INDEX asr_offense_offense_subcat_code_idx ON asr_offense_summary_temp (offense_subcat_code);

UPDATE asr_offense_summary_temp
SET agencies=asr_aas_populations.agencies, population=asr_aas_populations.population
FROM asr_aas_populations
WHERE data_year=asr_aas_populations.data_year
AND state_abbr IS NULL;

UPDATE asr_offense_summary_temp
SET agencies=asr_race_populations.agencies, population=asr_race_populations.population
FROM asr_race_populations
WHERE data_year=asr_race_populations.data_year
AND state_abbr IS NULL AND race_code IS NOT NULL;

ALTER TABLE asr_offense_summary_temp RENAME TO asr_offense_summary;

-------
DROP TABLE IF EXISTS asr_state_offense_summary_temp;
CREATE TABLE asr_state_offense_summary_temp (
   id serial PRIMARY KEY,
   year smallint NOT NULL,
   state_abbr character(2),
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

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, juvenile_flag, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, juvenile_flag, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, aar.juvenile_flag, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, offense_code, offense_name, aar.juvenile_flag;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, juvenile_flag, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, aar.juvenile_flag, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, aar.juvenile_flag;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, sex, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_sex, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_sex;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, sex, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, aar.age_sex, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, offense_code, offense_name, aar.age_sex;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, sex, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, aar.age_sex, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, aar.age_sex;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, age_range_code, age_range_name, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_range_code, aar.age_range_name, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.age_range_code, aar.age_range_name;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, age_range_code, age_range_name, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, aar.age_range_code, aar.age_range_name, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, offense_code, offense_name, aar.age_range_code, aar.age_range_name;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, age_range_code, age_range_name, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, aar.age_range_code, aar.age_range_name, SUM(aass.arrest_count)
FROM asr_age_suboffense_summary aass
JOIN asr_age_range aar ON aar.age_range_id = aass.age_range_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, aar.age_range_code, aar.age_range_name;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, race_code, race_name, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, rr.race_code, rr.race_desc, SUM(aass.arrest_count)
FROM asr_race_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN ref_race rr ON aass.race_id = rr.race_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, offense_code, offense_name, offense_subcat_code, offense_subcat_name, rr.race_code, rr.race_desc;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, offense_code, offense_name, race_code, race_name, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, offense_code, offense_name, rr.race_code, rr.race_desc, SUM(aass.arrest_count)
FROM asr_race_suboffense_summary aass
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aass.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN ref_race rr ON aass.race_id = rr.race_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, offense_code, offense_name, rr.race_code, rr.race_desc;

INSERT INTO asr_state_offense_summary_temp(year, state_abbr, race_code, race_name, arrest_count)
SELECT aass.data_year, rs.state_postal_abbr, rr.race_code, rr.race_desc, SUM(aass.arrest_count)
FROM asr_race_suboffense_summary aass
JOIN ref_race rr ON aass.race_id = rr.race_id
JOIN ref_state rs ON rs.state_id = aass.state_id
GROUP BY aass.data_year, rs.state_postal_abbr, rr.race_code, rr.race_desc;

CREATE INDEX asr_state_offense_juvenile_idx ON asr_state_offense_summary_temp (state_abbr, juvenile_flag);
CREATE INDEX asr_state_offense_sex_idx ON asr_state_offense_summary_temp (state_abbr, sex);
CREATE INDEX asr_state_offense_age_range_code_idx ON asr_state_offense_summary_temp (state_abbr, age_range_code);
CREATE INDEX asr_state_offense_race_code_idx ON asr_state_offense_summary_temp (state_abbr, race_code);
CREATE INDEX asr_state_offense_offense_code_idx ON asr_state_offense_summary_temp (state_abbr, offense_code);
CREATE INDEX asr_state_offense_offense_subcat_code_idx ON asr_state_offense_summary_temp (state_abbr, offense_subcat_code);

UPDATE asr_state_offense_summary_temp
SET agencies=asr_aas_populations.agencies, population=asr_aas_populations.population
FROM asr_aas_populations
WHERE data_year=asr_aas_populations.data_year
AND asr_state_offense_summary_temp.state_abbr=asr_aas_populations.state_abbr;

UPDATE asr_state_offense_summary_temp
SET agencies=asr_race_populations.agencies, population=asr_race_populations.population
FROM asr_race_populations
WHERE data_year=asr_race_populations.data_year
AND asr_state_offense_summary_temp.state_abbr=asr_race_populations.state_abbr AND race_code IS NOT NULL;

ALTER TABLE asr_state_offense_summary_temp RENAME TO asr_state_offense_summary;
