DROP TABLE IF EXISTS asr_reporting;
CREATE TABLE asr_reporting (
   data_year smallint NOT NULL,
   agency_id int NOT NULL,
   months_reported smallint
);

INSERT INTO asr_reporting
SELECT data_year, agency_id, SUM(CASE WHEN reported_flag = 'Y' THEN 1 ELSE 0 END) AS reported_months
FROM asr_month GROUP by data_year, agency_id;

DROP TABLE IF EXISTS asr_offense_summary_temp;
CREATE TABLE asr_offense_summary_temp (
   asr_offense_summary_id serial PRIMARY KEY,
   year smallint,
   state_abbr character(2),
   state_name text,
   juvenile_flag character(1),
   sex character(1),
   race_code character(1),
   race_name text,
   offense_code text,
   offense_name text,
   offense_subcat_code text,
   offense_subcat_name text,
   arrest_count integer,
   agencies integer,
   population bigint
);

INSERT INTO asr_offense_summary_temp(year, state_abbr, state_name, juvenile_flag, sex, race_code, race_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name, arrest_count, agencies, population)
SELECT am.data_year, rs.state_postal_abbr, rs.state_name, aar.juvenile_flag, aar.age_sex, rr.race_code, rr.race_desc AS race_name,
       ao.offense_code, ao.offense_name, aos.offense_subcat_code, aos.offense_subcat_name,
       SUM(aas.arrest_count) AS arrest_count,
       COUNT(DISTINCT ra.agency_id) AS agencies,
       SUM(rap.population) AS population
FROM asr_age_sex_subcat aas
JOIN asr_month am ON am.asr_month_id = aas.asr_month_id
LEFT OUTER JOIN asr_race_offense_subcat ros ON ros.asr_month_id = aas.asr_month_id
LEFT OUTER JOIN ref_race rr ON rr.race_id = ros.race_id
JOIN asr_offense_subcat aos ON aos.offense_subcat_id = aas.offense_subcat_id
JOIN asr_offense ao ON ao.offense_id = aos.offense_id
JOIN asr_age_range aar ON aar.age_range_id = aas.age_range_id
JOIN ref_agency ra ON ra.agency_id = am.agency_id
JOIN ref_state rs ON rs.state_id = ra.state_id
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id = ra.agency_id AND rap.data_year = am.data_year
JOIN asr_reporting ar ON ar.agency_id = ra.agency_id AND ar.data_year = am.data_year
WHERE ar.months_reported = 12 AND aas.arrest_status = 0
GROUP BY GROUPING SETS(
(am.data_year),
(am.data_year, aar.juvenile_flag),
(am.data_year, age_sex),
(am.data_year, aar.juvenile_flag, age_sex),
(am.data_year, race_code),
(am.data_year, offense_code, offense_name),
(am.data_year, offense_code, offense_name, aar.juvenile_flag),
(am.data_year, offense_code, offense_name, age_sex),
(am.data_year, offense_code, offense_name, aar.juvenile_flag, age_sex),
(am.data_year, offense_code, offense_name, race_code, race_desc),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, age_sex),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, aar.juvenile_flag, age_sex),
(am.data_year, offense_code, offense_name, offense_subcat_code, offense_subcat_name, race_code, race_desc),
(am.data_year, state_postal_abbr, state_name),
(am.data_year, state_postal_abbr, state_name, aar.juvenile_flag),
(am.data_year, state_postal_abbr, state_name, age_sex),
(am.data_year, state_postal_abbr, state_name, aar.juvenile_flag, age_sex),
(am.data_year, state_postal_abbr, state_name, race_code),
(am.data_year, state_postal_abbr, state_name, offense_code, offense_name),
(am.data_year, state_postal_abbr, state_name, aar.juvenile_flag, offense_code, offense_name),
(am.data_year, state_postal_abbr, state_name, age_sex, offense_code, offense_name),
(am.data_year, state_postal_abbr, state_name, aar.juvenile_flag, age_sex, offense_code, offense_name),
(am.data_year, state_postal_abbr, state_name, race_code, race_desc, offense_code, offense_name),
(am.data_year, state_postal_abbr, state_name, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(am.data_year, state_postal_abbr, state_name, aar.juvenile_flag, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(am.data_year, state_postal_abbr, state_name, age_sex, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(am.data_year, state_postal_abbr, state_name, aar.juvenile_flag, age_sex, offense_code, offense_name, offense_subcat_code, offense_subcat_name),
(am.data_year, state_postal_abbr, state_name, race_code, race_desc, offense_code, offense_name, offense_subcat_code, offense_subcat_name)
);

CREATE INDEX asr_offense_temp_year_idx ON asr_offense_summary_temp (year);
CREATE INDEX asr_offense_temp_state_abbr_idx ON asr_offense_summary_temp (state_abbr);
CREATE INDEX asr_offense_temp_juvenile_idx ON asr_offense_summary_temp (juvenile_flag);
CREATE INDEX asr_offense_temp_sex_idx ON asr_offense_summary_temp (sex);
CREATE INDEX asr_offense_temp_race_code_idx ON asr_offense_summary_temp (race_code);
CREATE INDEX asr_offense_temp_offense_code_idx ON asr_offense_summary_temp (offense_code);
CREATE INDEX asr_offense_temp_offense_subcat_code_idx ON asr_offense_summary_temp (offense_subcat_code);

DROP TABLE IF EXISTS asr_offense_summary;
ALTER TABLE asr_offense_summary_temp RENAME TO asr_offense_summary;

ALTER INDEX asr_offense_temp_year_idx RENAME TO asr_offense_year_idx;
ALTER INDEX asr_offense_temp_state_abbr_idx RENAME TO asr_offense_state_abbr_idx;
ALTER INDEX asr_offense_temp_juvenile_idx RENAME TO asr_offense_juvenile_idx;
ALTER INDEX asr_offense_temp_sex_idx RENAME TO asr_offense_sex_idx;
ALTER INDEX asr_offense_temp_race_code_idx RENAME TO asr_offense_race_code_idx;
ALTER INDEX asr_offense_temp_offense_code_idx RENAME TO asr_offense_offense_code_idx;
ALTER INDEX asr_offense_temp_offense_subcat_code_idx RENAME TO asr_offense_subcat_code_idx;
