-- you might want to do the table rename first at
-- move_default_ct_tables.sql. That should only be done once to
-- preserve the CT tables they gave us.

DROP TABLE IF EXISTS ct_csv;

CREATE TABLE ct_csv (
  incident_id serial PRIMARY KEY,
  record_type text,
  ori text,
  agency_name text,
  incident_num text,
  incident_date text,
  data_source character(1) NOT NULL,
  report_date_indicator text,
  incident_hour smallint,
  cleared_exceptionally character(1),
  ct_offense_1 text,
  ct_location_1 text,
  ct_offense_2 text,
  ct_location_2 text,
  ct_offense_3 text,
  ct_location_3 text,
  ct_offense_4 text,
  ct_location_4 text,
  ct_offense_5 text,
  ct_location_5 text,
  ct_offense_6 text,
  ct_location_6 text,
  ct_offense_7 text,
  ct_location_7 text,
  ct_offense_8 text,
  ct_location_8 text,
  ct_offense_9 text,
  ct_location_9 text,
  ct_offense_10 text,
  ct_location_10 text,
  wpn_type_1 text,
  wpn_auto_1 text,
  wpn_type_2 text,
  wpn_auto_2 text,
  wpn_type_3 text,
  wpn_auto_3 text,
  victim_type_1 text,
  victim_type_2 text,
  victim_type_3 text,
  victim_type_4 text,
  victim_type_5 text,
  victim_type_6 text,
  victim_type_7 text,
  victim_type_8 text,
  victim_type_9 text,
  stolen_prop_desc_1 text,
  stolen_prop_value_1 integer,
  prop_rec_date_1 text,
  prop_rec_value_1 integer,
  stolen_prop_desc_2 text,
  stolen_prop_value_2 integer,
  prop_rec_date_2 text,
  prop_rec_value_2 integer,
  stolen_prop_desc_3 text,
  stolen_prop_value_3 integer,
  prop_rec_date_3 text,
  prop_rec_value_3 integer,
  stolen_prop_desc_4 text,
  stolen_prop_value_4 integer,
  prop_rec_date_4 text,
  prop_rec_value_4 integer,
  stolen_prop_desc_5 text,
  stolen_prop_value_5 integer,
  prop_rec_date_5 text,
  prop_rec_value_5 integer,
  stolen_prop_desc_6 text,
  stolen_prop_value_6 integer,
  prop_rec_date_6 text,
  prop_rec_value_6 integer,
  stolen_prop_desc_7 text,
  stolen_prop_value_7 integer,
  prop_rec_date_7 text,
  prop_rec_value_7 integer,
  stolen_prop_desc_8 text,
  stolen_prop_value_8 integer,
  prop_rec_date_8 text,
  prop_rec_value_8 integer,
  stolen_prop_desc_9 text,
  stolen_prop_value_9 integer,
  prop_rec_date_9 text,
  prop_rec_value_9 integer,
  stolen_prop_desc_10 text,
  stolen_prop_value_10 integer,
  prop_rec_date_10 text,
  prop_rec_value_10 integer,
  unknown_offender_indicator character(2),
  offender_count integer,
  offender_age_1 integer,
  offender_sex_1 text,
  offender_race_1 text,
  offender_ethnicity_1 text,
  offender_age_2 integer,
  offender_sex_2 text,
  offender_race_2 text,
  offender_ethnicity_2 text,
  offender_age_3 integer,
  offender_sex_3 text,
  offender_race_3 text,
  offender_ethnicity_3 text,
  offender_age_4 integer,
  offender_sex_4 text,
  offender_race_4 text,
  offender_ethnicity_4 text,
  offender_age_5 integer,
  offender_sex_5 text,
  offender_race_5 text,
  offender_ethnicity_5 text,
  arrestee_count smallint,
  arrestee_age_1 integer,
  arrestee_sex_1 text,
  arrestee_race_1 text,
  arrestee_ethnicity_1 text,
  arrestee_age_2 integer,
  arrestee_sex_2 text,
  arrestee_race_2 text,
  arrestee_ethnicity_2 text,
  arrestee_age_3 integer,
  arrestee_sex_3 text,
  arrestee_race_3 text,
  arrestee_ethnicity_3 text,
  arrestee_age_4 integer,
  arrestee_sex_4 text,
  arrestee_race_4 text,
  arrestee_ethnicity_4 text,
  arrestee_age_5 integer,
  arrestee_sex_5 text,
  arrestee_race_5 text,
  arrestee_ethnicity_5 text
);

\COPY ct_csv(record_type,ori,agency_name,incident_num,incident_date,data_source,report_date_indicator,incident_hour,cleared_exceptionally,ct_offense_1,ct_location_1,ct_offense_2,ct_location_2,ct_offense_3,ct_location_3,ct_offense_4,ct_location_4,ct_offense_5,ct_location_5,ct_offense_6,ct_location_6,ct_offense_7,ct_location_7,ct_offense_8,ct_location_8,ct_offense_9,ct_location_9,ct_offense_10,ct_location_10,wpn_type_1,wpn_auto_1,wpn_type_2,wpn_auto_2,wpn_type_3,wpn_auto_3,victim_type_1,victim_type_2,victim_type_3,victim_type_4,victim_type_5,victim_type_6,victim_type_7,victim_type_8,victim_type_9,stolen_prop_desc_1,stolen_prop_value_1,prop_rec_date_1,prop_rec_value_1,stolen_prop_desc_2,stolen_prop_value_2,prop_rec_date_2,prop_rec_value_2,stolen_prop_desc_3,stolen_prop_value_3,prop_rec_date_3,prop_rec_value_3,stolen_prop_desc_4,stolen_prop_value_4,prop_rec_date_4,prop_rec_value_4,stolen_prop_desc_5,stolen_prop_value_5,prop_rec_date_5,prop_rec_value_5,stolen_prop_desc_6,stolen_prop_value_6,prop_rec_date_6,prop_rec_value_6,stolen_prop_desc_7,stolen_prop_value_7,prop_rec_date_7,prop_rec_value_7,stolen_prop_desc_8,stolen_prop_value_8,prop_rec_date_8,prop_rec_value_8,stolen_prop_desc_9,stolen_prop_value_9,prop_rec_date_9,prop_rec_value_9,stolen_prop_desc_10,stolen_prop_value_10,prop_rec_date_10,prop_rec_value_10,unknown_offender_indicator,offender_count,offender_age_1,offender_sex_1,offender_race_1,offender_ethnicity_1,offender_age_2,offender_sex_2,offender_race_2,offender_ethnicity_2,offender_age_3,offender_sex_3,offender_race_3,offender_ethnicity_3,offender_age_4,offender_sex_4,offender_race_4,offender_ethnicity_4,offender_age_5,offender_sex_5,offender_race_5,offender_ethnicity_5,arrestee_count,arrestee_age_1,arrestee_sex_1,arrestee_race_1,arrestee_ethnicity_1,arrestee_age_2,arrestee_sex_2,arrestee_race_2,arrestee_ethnicity_2,arrestee_age_3,arrestee_sex_3,arrestee_race_3,arrestee_ethnicity_3,arrestee_age_4,arrestee_sex_4,arrestee_race_4,arrestee_ethnicity_4,arrestee_age_5,arrestee_sex_5,arrestee_race_5,arrestee_ethnicity_5)  FROM 'ct_2013.csv' DELIMITER ',' HEADER CSV;

\COPY ct_csv(record_type,ori,agency_name,incident_num,incident_date,data_source,report_date_indicator,incident_hour,cleared_exceptionally,ct_offense_1,ct_location_1,ct_offense_2,ct_location_2,ct_offense_3,ct_location_3,ct_offense_4,ct_location_4,ct_offense_5,ct_location_5,ct_offense_6,ct_location_6,ct_offense_7,ct_location_7,ct_offense_8,ct_location_8,ct_offense_9,ct_location_9,ct_offense_10,ct_location_10,wpn_type_1,wpn_auto_1,wpn_type_2,wpn_auto_2,wpn_type_3,wpn_auto_3,victim_type_1,victim_type_2,victim_type_3,victim_type_4,victim_type_5,victim_type_6,victim_type_7,victim_type_8,victim_type_9,stolen_prop_desc_1,stolen_prop_value_1,prop_rec_date_1,prop_rec_value_1,stolen_prop_desc_2,stolen_prop_value_2,prop_rec_date_2,prop_rec_value_2,stolen_prop_desc_3,stolen_prop_value_3,prop_rec_date_3,prop_rec_value_3,stolen_prop_desc_4,stolen_prop_value_4,prop_rec_date_4,prop_rec_value_4,stolen_prop_desc_5,stolen_prop_value_5,prop_rec_date_5,prop_rec_value_5,stolen_prop_desc_6,stolen_prop_value_6,prop_rec_date_6,prop_rec_value_6,stolen_prop_desc_7,stolen_prop_value_7,prop_rec_date_7,prop_rec_value_7,stolen_prop_desc_8,stolen_prop_value_8,prop_rec_date_8,prop_rec_value_8,stolen_prop_desc_9,stolen_prop_value_9,prop_rec_date_9,prop_rec_value_9,stolen_prop_desc_10,stolen_prop_value_10,prop_rec_date_10,prop_rec_value_10,unknown_offender_indicator,offender_count,offender_age_1,offender_sex_1,offender_race_1,offender_ethnicity_1,offender_age_2,offender_sex_2,offender_race_2,offender_ethnicity_2,offender_age_3,offender_sex_3,offender_race_3,offender_ethnicity_3,offender_age_4,offender_sex_4,offender_race_4,offender_ethnicity_4,offender_age_5,offender_sex_5,offender_race_5,offender_ethnicity_5,arrestee_count,arrestee_age_1,arrestee_sex_1,arrestee_race_1,arrestee_ethnicity_1,arrestee_age_2,arrestee_sex_2,arrestee_race_2,arrestee_ethnicity_2,arrestee_age_3,arrestee_sex_3,arrestee_race_3,arrestee_ethnicity_3,arrestee_age_4,arrestee_sex_4,arrestee_race_4,arrestee_ethnicity_4,arrestee_age_5,arrestee_sex_5,arrestee_race_5,arrestee_ethnicity_5)  FROM 'ct_2014.csv' DELIMITER ',' HEADER CSV;

\COPY ct_csv(record_type,ori,agency_name,incident_num,incident_date,data_source,report_date_indicator,incident_hour,cleared_exceptionally,ct_offense_1,ct_location_1,ct_offense_2,ct_location_2,ct_offense_3,ct_location_3,ct_offense_4,ct_location_4,ct_offense_5,ct_location_5,ct_offense_6,ct_location_6,ct_offense_7,ct_location_7,ct_offense_8,ct_location_8,ct_offense_9,ct_location_9,ct_offense_10,ct_location_10,wpn_type_1,wpn_auto_1,wpn_type_2,wpn_auto_2,wpn_type_3,wpn_auto_3,victim_type_1,victim_type_2,victim_type_3,victim_type_4,victim_type_5,victim_type_6,victim_type_7,victim_type_8,victim_type_9,stolen_prop_desc_1,stolen_prop_value_1,prop_rec_date_1,prop_rec_value_1,stolen_prop_desc_2,stolen_prop_value_2,prop_rec_date_2,prop_rec_value_2,stolen_prop_desc_3,stolen_prop_value_3,prop_rec_date_3,prop_rec_value_3,stolen_prop_desc_4,stolen_prop_value_4,prop_rec_date_4,prop_rec_value_4,stolen_prop_desc_5,stolen_prop_value_5,prop_rec_date_5,prop_rec_value_5,stolen_prop_desc_6,stolen_prop_value_6,prop_rec_date_6,prop_rec_value_6,stolen_prop_desc_7,stolen_prop_value_7,prop_rec_date_7,prop_rec_value_7,stolen_prop_desc_8,stolen_prop_value_8,prop_rec_date_8,prop_rec_value_8,stolen_prop_desc_9,stolen_prop_value_9,prop_rec_date_9,prop_rec_value_9,stolen_prop_desc_10,stolen_prop_value_10,prop_rec_date_10,prop_rec_value_10,unknown_offender_indicator,offender_count,offender_age_1,offender_sex_1,offender_race_1,offender_ethnicity_1,offender_age_2,offender_sex_2,offender_race_2,offender_ethnicity_2,offender_age_3,offender_sex_3,offender_race_3,offender_ethnicity_3,offender_age_4,offender_sex_4,offender_race_4,offender_ethnicity_4,offender_age_5,offender_sex_5,offender_race_5,offender_ethnicity_5,arrestee_count,arrestee_age_1,arrestee_sex_1,arrestee_race_1,arrestee_ethnicity_1,arrestee_age_2,arrestee_sex_2,arrestee_race_2,arrestee_ethnicity_2,arrestee_age_3,arrestee_sex_3,arrestee_race_3,arrestee_ethnicity_3,arrestee_age_4,arrestee_sex_4,arrestee_race_4,arrestee_ethnicity_4,arrestee_age_5,arrestee_sex_5,arrestee_race_5,arrestee_ethnicity_5)  FROM 'ct_2015.csv' DELIMITER ',' HEADER CSV;


TRUNCATE TABLE ct_incident;

INSERT INTO ct_incident(incident_id, agency_id, data_year, incident_date, incident_number, source_flag, report_date_flag, incident_hour, cleared_except_flag, unknown_offender)
SELECT
  csv.incident_id,
  ra.agency_id AS agency_id,
  extract(year from to_date(csv.incident_date, 'YYYYMMDD')) AS data_year,
  to_date(csv.incident_date, 'YYYYMMDD') AS incident_date,
  csv.incident_num AS incident_number,
  csv.data_source AS source_flag,
  csv.report_date_indicator AS report_date_flag,
  csv.incident_hour AS incident_hour,
  csv.cleared_exceptionally AS cleared_except_flag,
  csv.unknown_offender_indicator AS unknown_offender
FROM ct_csv csv
JOIN ref_agency ra ON ra.ori=csv.ori;

TRUNCATE TABLE ct_offense;

DO
$do$
DECLARE
  arr integer[] := array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  i integer;
  offense_type_col varchar;
  location_id_col varchar;
BEGIN
  FOREACH i in ARRAY arr
  LOOP
    offense_type_col = CONCAT('ct_offense_', i::text);
    location_id_col = CONCAT('ct_location_', i::text);

EXECUTE format('INSERT INTO ct_offense(incident_id, offense_type_id, location_id)
                SELECT
                  incident_id,
                  no.offense_type_id AS offense_type_id,
                  nl.location_id AS location_id
                FROM ct_csv
                JOIN nibrs_offense_type no ON no.offense_code=%I
                JOIN nibrs_location_type nl ON nl.location_code=%I
                WHERE %I IS NOT NULL', offense_type_col, location_id_col, offense_type_col);
  END LOOP;
END
$do$;

TRUNCATE TABLE ct_arrestee;

DO
$do$
DECLARE
  arr integer[] := array[1, 2, 3, 4, 5];
  i integer;
  age_col varchar;
  sex_col varchar;
  race_col varchar;
  ethnicity_col varchar;
BEGIN
  FOREACH i in ARRAY arr
  LOOP
    age_col = CONCAT('arrestee_age_', i::text);
    sex_col = CONCAT('arrestee_sex_', i::text);
    race_col = CONCAT('arrestee_race_', i::text);
    ethnicity_col = CONCAT('arrestee_ethnicity_', i::text);

EXECUTE format('INSERT INTO ct_arrestee(incident_id, age, sex_code, ethnicity_id, race_id)
                SELECT
                  incident_id,
                  %I as age,
                  %I as sex_code,
                  re.ethnicity_id AS ethnicity_id,
                  rr.race_id AS race_id
                FROM ct_csv
                JOIN ref_race rr ON rr.race_code=%I
                JOIN nibrs_ethnicity re ON re.ethnicity_code=%I
                WHERE %I IS NOT NULL', age_col, sex_col, race_col, ethnicity_col, age_col);
  END LOOP;
END
$do$;

TRUNCATE table ct_offender;

DO
$do$
DECLARE
arr integer[] := array[1, 2, 3, 4, 5];
i integer;
age_col varchar;
sex_col varchar;
race_col varchar;
ethnicity_col varchar;
BEGIN
FOREACH i in ARRAY arr
LOOP
age_col = CONCAT('offender_age_', i::text);
sex_col = CONCAT('offender_sex_', i::text);
race_col = CONCAT('offender_race_', i::text);
ethnicity_col = CONCAT('offender_ethnicity_', i::text);

EXECUTE format('INSERT INTO ct_offender(incident_id, age, sex_code, ethnicity_id, race_id)
SELECT
incident_id,
%I as age,
%I as sex_code,
re.ethnicity_id AS ethnicity_id,
rr.race_id AS race_id
FROM ct_csv
JOIN ref_race rr ON rr.race_code=%I
JOIN nibrs_ethnicity re ON re.ethnicity_code=%I
WHERE %I IS NOT NULL', age_col, sex_col, race_col, ethnicity_col, age_col);
END LOOP;
END
$do$;

TRUNCATE TABLE ct_property;

DO
$do$
DECLARE
arr integer[] := array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
i integer;
prop_desc_col varchar;
prop_value_col varchar;
rec_date_col varchar;
rec_value_col varchar;
BEGIN
FOREACH i in ARRAY arr
LOOP
prop_desc_col = CONCAT('stolen_prop_desc_', i::text);
prop_value_col = CONCAT('stolen_prop_value_', i::text);
rec_date_col = CONCAT('prop_rec_date_', i::text);
rec_value_col = CONCAT('prop_rec_value_', i::text);

EXECUTE format('INSERT INTO ct_property(incident_id, prop_desc_id, stolen_value, recovered_flag, date_recovered, recovered_value)
SELECT
incident_id,
pd.prop_desc_id AS prop_desc_id,
%I as stolen_value,
CASE WHEN %I IS NOT NULL THEN ''Y'' ELSE ''N'' END as recovered_flag,
to_date(%I, ''YYYYMMDD'') AS date_recovered,
%I AS rec_value_col
FROM ct_csv
JOIN nibrs_prop_desc_type pd ON pd.prop_desc_code=%I
WHERE %I is NOT NULL', prop_value_col, rec_date_col, rec_date_col, rec_value_col, prop_desc_col, prop_desc_col);
END LOOP;
END
$do$;


TRUNCATE TABLE ct_victim;

DO
$do$
DECLARE
arr integer[] := array[1, 2, 3, 4, 5, 6, 7, 8, 9];
i integer;
victim_col varchar;
BEGIN
FOREACH i in ARRAY arr
LOOP
victim_col = CONCAT('victim_type_', i::text);

EXECUTE format('INSERT INTO ct_victim(incident_id, victim_type_id)
SELECT
incident_id,
vt.victim_type_id AS victim_type_id
FROM ct_csv
JOIN nibrs_victim_type vt ON vt.victim_type_code = %I
WHERE %I is NOT NULL', victim_col, victim_col);
END LOOP;
END
$do$;
