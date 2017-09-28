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
    month_pub_status text
);

\COPY reta_month_temp (reta_month_id, agency_id, data_year, month_num, data_home, source_flag, reported_flag, ddocname, month_included_in, report_date, prepared_date, prepared_by_user, prepared_by_email, orig_format, leoka_felony, leoka_accident, leoka_assault, leoka_status, update_flag, did, ff_line_number,month_pub_status) FROM '$MYPWD/RETAM.csv' WITH DELIMITER ',';

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

\COPY reta_month_offense_subcat_temp (reta_month_id, offense_subcat_id, reported_count, reported_status, unfounded_count, unfounded_status, actual_count, actual_status, cleared_count, cleared_status, juvenile_cleared_count, juvenile_cleared_status) FROM '$MYPWD/RETAMOS.csv' WITH DELIMITER ',';


DROP TABLE IF EXISTS reta_estimated_csv;



CREATE TABLE reta_estimated_csv

(

year smallint NOT NULL,

state_abbr character varying(2),

population bigint,

violent_crime bigint,

homicide bigint,

rape_legacy bigint,

rape_revised bigint,

robbery bigint,

aggravated_assault bigint,

property_crime bigint,

burglary bigint,

larceny bigint,

motor_vehicle_theft bigint,

caveats text

);



\COPY reta_estimated_csv FROM '$MYPWD/estimated_1995_$YEAR.csv' DELIMITER ',' HEADER CSV;



DROP TABLE IF EXISTS reta_estimated;



CREATE TABLE reta_estimated

(

  estimate_id SERIAL PRIMARY KEY,

  year smallint NOT NULL,

  state_id smallint REFERENCES ref_state (state_id),

  state_abbr character varying(2),

  population bigint,

  violent_crime bigint,

  homicide bigint,

  rape_legacy bigint,

  rape_revised bigint,

  robbery bigint,

  aggravated_assault bigint,

  property_crime bigint,

  burglary bigint,

  larceny bigint,

  motor_vehicle_theft bigint,

  caveats text,

  UNIQUE (year, state_id)

);



INSERT INTO reta_estimated(year, state_id, state_abbr, population, violent_crime, homicide, rape_legacy, rape_revised, robbery, aggravated_assault, property_crime, burglary, larceny, motor_vehicle_theft, caveats)

SELECT

ret.year,

rs.state_id,

ret.state_abbr,

ret.population,

ret.violent_crime,

ret.homicide,

ret.rape_legacy,

ret.rape_revised,

ret.robbery,

ret.aggravated_assault,

ret.property_crime,

ret.burglary,

ret.larceny,

ret.motor_vehicle_theft,

ret.caveats

FROM reta_estimated_csv ret

LEFT OUTER JOIN ref_state rs ON rs.state_postal_abbr=ret.state_abbr;



DROP TABLE reta_estimated_csv;


"
