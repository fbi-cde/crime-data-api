MYPWD="$(pwd)/data"
YEAR=$1


echo "
-----------------------------
-- 
-- 
-- UPLOAD RETA tables.
-- 
-- 
-----------------------------

-- reta_month_temp
DROP TABLE IF EXISTS reta_month_temp;
CREATE TABLE reta_month_temp (
    reta_month_id text,
    agency_id text,
    data_year text,
    month_num text,
    data_home text,
    source_flag text,
    reported_flag text,
    ddocname text,
    month_included_in text,
    report_date text,
    prepared_date text,
    prepared_by_user text,
    prepared_by_email text,
    orig_format text,
    leoka_felony text,
    leoka_accident text,
    leoka_assault text,
    leoka_status text,
    update_flag text,
    did text,
    ff_line_number text,
    extra text
);

--RETA_MONTH_ID   AGENCY_ID   DATA_YEAR   MONTH_NUM   DATA_HOME   SOURCE_FLAG REPORTED_FLAG   DDOCNAME    MONTH_INCLUDED_IN   REPORT_DATE PREPARED_DATE   PREPARED_BY_USER    PREPARED_BY_EMAIL   ORIG_FORMAT LEOKA_FELONY    LEOKA_ACCIDENT  LEOKA_ASSAULT   LEOKA_STATUS    UPDATE_FLAG DID FF_LINE_NUMBER  MONTH_PUB_STATUS
\COPY reta_month_temp (reta_month_id, agency_id, data_year, month_num, data_home, source_flag, reported_flag, ddocname, month_included_in, report_date, prepared_date, prepared_by_user, prepared_by_email, orig_format, leoka_felony, leoka_accident, leoka_assault, leoka_status, update_flag, did, ff_line_number, extra) FROM '$MYPWD/RetAM.csv' WITH DELIMITER ',';

-- reta_month_offense_subcat
DROP TABLE IF EXISTS reta_month_offense_subcat_temp;
CREATE TABLE reta_month_offense_subcat_temp (
    reta_month_id text,
    offense_subcat_id text,
    reported_count text,
    reported_status text,
    unfounded_count text,
    unfounded_status text,
    actual_count text,
    actual_status text,
    cleared_count text,
    cleared_status text,
    juvenile_cleared_count text,
    juvenile_cleared_status text
);

-- RETA_MONTH_ID   OFFENSE_SUBCAT_ID   REPORTED_COUNT  REPORTED_STATUS UNFOUNDED_COUNT UNFOUNDED_STATUS    ACTUAL_COUNT    ACTUAL_STATUS   CLEARED_COUNT   CLEARED_STATUS  JUVENILE_CLEARED_COUNT  JUVENILE_CLEARED_STATUS
\COPY reta_month_offense_subcat_temp (reta_month_id, offense_subcat_id, reported_count, reported_status, unfounded_count, unfounded_status, actual_count, actual_status, cleared_count, cleared_status, juvenile_cleared_count, juvenile_cleared_status) FROM '$MYPWD/RETAMOS.csv' WITH DELIMITER ',';

-----------------------------
-- 
-- 
-- ASR tables upload.
-- 
-- 
-----------------------------

-- asr_month
DROP TABLE IF EXISTS asr_month_temp;
CREATE TABLE asr_month_temp (
    asr_month_id text,
    agency_id text,
    data_year text,
    month_num text,
    source_flag text,
    reported_flag text,
    orig_format text,
    update_flag text,
    ff_line_number text,
    ddocname text,
    did text,
    data_home text,
    extra text
);

\COPY asr_month_temp (asr_month_id, agency_id, data_year, month_num, source_flag, reported_flag, orig_format, update_flag, ff_line_number, ddocname, did, data_home, extra) FROM '$MYPWD/ASRM.csv' WITH DELIMITER ',';


DROP TABLE IF EXISTS asr_race_offense_subcat_temp;
CREATE TABLE asr_race_offense_subcat_temp (
    asr_month_id text,
    offense_subcat_id text,
    race_id text,
    juvenile_flag text,
    arrest_count text,
    arrest_status text,
    active_flag text,
    prepared_date text,
    report_date text,
    ff_line_number text
);


\COPY asr_race_offense_subcat_temp (asr_month_id , offense_subcat_id ,    race_id ,    juvenile_flag ,    arrest_count ,    arrest_status ,    active_flag ,    prepared_date ,    report_date ,    ff_line_number ) FROM '$MYPWD/ASROS.csv' WITH DELIMITER ',';


-- ASR_AGE_SEX_SUBCAT
DROP TABLE IF EXISTS asr_age_sex_subcat_temp;
CREATE TABLE asr_age_sex_subcat_temp (
    asr_month_id text,
    offense_subcat_id text,
    age_range_id text,
    arrest_count text,
    arrest_status text,
    active_flag text,
    prepared_date text,
    report_date text,
    ff_line_number text
);


\COPY asr_age_sex_subcat_temp (asr_month_id ,    offense_subcat_id ,    age_range_id ,    arrest_count ,    arrest_status ,    active_flag ,    prepared_date ,    report_date ,    ff_line_number ) FROM '$MYPWD/ASRASS.csv' WITH DELIMITER ',';

"