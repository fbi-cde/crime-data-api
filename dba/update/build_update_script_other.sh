echo "

\set ON_ERROR_STOP on;



-----------------------------
-- 
-- 
-- Hate Crime tables upload.
-- 
-- 
-----------------------------

-- hc_incident
DROP TABLE IF EXISTS hc_incident_temp;
CREATE TABLE hc_incident_temp (
    incident_id text,
    agency_id text,
    incident_no text,
    incident_date text,
    data_home text,
    source_flag text,
    ddocname text,
    report_date text,
    prepared_date text,
    victim_count text,
    adult_victim_count text,
    incident_status text,
    juvenile_victim_count text,
    offender_count text,
    adult_offender_count text,
    juvenile_offender_count text,
    offender_race_id text,
    offender_ethnicity_id text,
    update_flag text,
    hc_quarter_id text,
    ff_line_number text,
    orig_format text,
    did text,
    nibrs_incident_id text
);

\COPY hc_incident_temp (incident_id, agency_id, incident_no, incident_date, data_home, source_flag, ddocname, report_date, prepared_date, victim_count, adult_victim_count, incident_status, juvenile_victim_count, offender_count, adult_offender_count, juvenile_offender_count, offender_race_id, offender_ethnicity_id, update_flag, hc_quarter_id, ff_line_number, orig_format, did, nibrs_incident_id) FROM '$MYPWD/Hate_I.csv' WITH DELIMITER ',';

-- hc_quarter
DROP TABLE IF EXISTS hc_quarter_temp;
CREATE TABLE hc_quarter_temp (
    agency_id text,
    quarter_num text,
    data_year text,
    reported_status text,
    reported_count text,
    hc_quarter_id text,
    update_flag text,
    orig_format text,
    ff_line_number text,
    ddocname text,
    did text,
    data_home text,
    quarter_pub_status text
);


\COPY hc_quarter_temp (agency_id, quarter_num, data_year, reported_status, reported_count, hc_quarter_id, update_flag, orig_format, ff_line_number, ddocname, did, data_home, quarter_pub_status) FROM '$MYPWD/Hate_Q.csv' WITH DELIMITER ',';


-- hc_bias_motivation
DROP TABLE IF EXISTS hc_bias_motivation_temp;
CREATE TABLE hc_bias_motivation_temp (
    offense_id text,
    bias_id text
);

\COPY hc_bias_motivation_temp (offense_id, bias_id) FROM '$MYPWD/Hate_BM.csv' WITH DELIMITER ',';

-- hc_offense
DROP TABLE IF EXISTS hc_offense_temp;
CREATE TABLE hc_offense_temp (
    offense_id text,
    incident_id text,
    offense_type_id text,
    victim_count text,
    location_id text,
    nibrs_offense_id text
);

\COPY hc_offense_temp (offense_id, incident_id, offense_type_id, victim_count, location_id, nibrs_offense_id) FROM '$MYPWD/Hate_O.csv' WITH DELIMITER ',';

-- hc_victim
DROP TABLE IF EXISTS hc_victim_temp;
CREATE TABLE hc_victim_temp (
    offense_id text,
    victim_type_id text
);

\COPY hc_victim_temp (offense_id, victim_type_id) FROM '$MYPWD/Hate_V.csv' WITH DELIMITER ',';


-----------------------------
-- 
-- 
-- Cargo Theft tables upload.
-- 
-- 
-----------------------------

-- ct_incident
DROP TABLE IF EXISTS ct_incident_temp;
CREATE TABLE ct_incident_temp (
    incident_id text,
    agency_id text,
    data_year text,
    incident_number text,
    incident_date text,
    source_flag text,
    ddocname text,
    report_date text,
    prepared_date text,
    report_date_flag text,
    incident_hour text,
    cleared_except_flag text,
    update_flag text,
    ct_month_id text,
    ff_line_number text,
    data_home text,
    orig_format text,
    unknown_offender text,
    did text,
    nibrs_incident_id text
);

\COPY ct_incident_temp (incident_id, agency_id, data_year, incident_number, incident_date, source_flag, ddocname, report_date, prepared_date, report_date_flag, incident_hour, cleared_except_flag, update_flag, ct_month_id, ff_line_number, data_home, orig_format, unknown_offender, did, nibrs_incident_id) FROM '$MYPWD/Cargo_I.csv' WITH DELIMITER ',';

-- ct_victim
DROP TABLE IF EXISTS ct_victim_temp;
CREATE TABLE ct_victim_temp (
    incident_id text,
    victim_type_id text
);

\COPY ct_victim_temp (incident_id, victim_type_id) FROM '$MYPWD/Cargo_V.csv' WITH DELIMITER ',';


-- ct_offense
DROP TABLE IF EXISTS ct_offense_temp;
CREATE TABLE ct_offense_temp (
    offense_id text,
    incident_id text,
    offense_type_id text,
    location_id text,
    ct_offense_flag text
);

\COPY ct_offense_temp (offense_id, incident_id, offense_type_id, location_id, ct_offense_flag) FROM '$MYPWD/Cargo_OO.csv' WITH DELIMITER ',';


-- ct_offender
DROP TABLE IF EXISTS ct_offender_temp;
CREATE TABLE ct_offender_temp (
    offender_id text,
    incident_id text,
    age text,
    sex_code text,
    ethnicity_id text,
    race_id text
);

\COPY ct_offender_temp (offender_id, incident_id, age, sex_code, ethnicity_id, race_id) FROM '$MYPWD/Cargo_O.csv' WITH DELIMITER ',';

-- ct_arrestee_temp
DROP TABLE IF EXISTS ct_arrestee_temp;
CREATE TABLE ct_arrestee_temp (
    arrestee_id text,
    incident_id text,
    age text,
    sex_code text,
    ethnicity_id text,
    race_id text
);

\COPY ct_arrestee_temp (arrestee_id, incident_id, age, sex_code, ethnicity_id, race_id) FROM '$MYPWD/Cargo_A.csv' WITH DELIMITER ',';

-- ct_weapon
DROP TABLE IF EXISTS ct_weapon_temp;
CREATE TABLE ct_weapon_temp (
    incident_id text,
    weapon_id text,
    ct_weapon_id text
);

\COPY ct_weapon_temp (incident_id, weapon_id, ct_weapon_id) FROM '$MYPWD/Cargo_W.csv' WITH DELIMITER ',';

-- ct_property
DROP TABLE IF EXISTS ct_property_temp;
CREATE TABLE ct_property_temp (
    property_id text,
    prop_desc_id text,
    incident_id text,
    stolen_value text,
    recovered_flag text,
    date_recovered text,
    recovered_value text
);

\COPY ct_property_temp (property_id, prop_desc_id, incident_id, stolen_value, recovered_flag, date_recovered, recovered_value) FROM '$MYPWD/Cargo_P.csv' WITH DELIMITER ',';


-- hc_*  - DONE!
INSERT INTO hc_quarter (SELECT convert_to_integer(agency_id), convert_to_integer(quarter_num), convert_to_integer(data_year), reported_status, convert_to_integer(reported_count), convert_to_integer(hc_quarter_id), update_flag, orig_format, convert_to_integer(ff_line_number), ddocname, convert_to_integer(did), data_home from hc_quarter_temp);
INSERT INTO hc_incident (SELECT convert_to_integer(incident_id), convert_to_integer(agency_id), incident_no, to_timestamp_ucr(incident_date), data_home, source_flag, ddocname, to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), convert_to_integer(victim_count), convert_to_integer(adult_victim_count), convert_to_integer(incident_status), convert_to_integer(juvenile_victim_count), convert_to_integer(offender_count), convert_to_integer(adult_offender_count), convert_to_integer(juvenile_offender_count), convert_to_integer(offender_race_id), convert_to_integer(offender_ethnicity_id), update_flag, convert_to_integer(hc_quarter_id), convert_to_integer(ff_line_number), orig_format, convert_to_integer(did), convert_to_integer(nibrs_incident_id) from hc_incident_temp);
INSERT INTO hc_offense (SELECT convert_to_integer(offense_id), convert_to_integer(incident_id), convert_to_integer(offense_type_id), convert_to_integer(victim_count), convert_to_integer(location_id), convert_to_integer(nibrs_offense_id) from hc_offense_temp);
INSERT INTO hc_victim (SELECT convert_to_integer(offense_id), convert_to_integer(victim_type_id) from hc_victim_temp);
INSERT INTO hc_bias_motivation (SELECT convert_to_integer(offense_id), convert_to_integer(bias_id) from hc_bias_motivation_temp);


-- ct_*
INSERT INTO ct_incident (SELECT convert_to_integer(incident_id), convert_to_integer(agency_id), convert_to_integer(data_year), incident_number, to_timestamp_ucr(incident_date), source_flag, ddocname, to_timestamp_ucr(report_date), to_timestamp_ucr(prepared_date), report_date_flag, convert_to_integer(incident_hour), cleared_except_flag, update_flag, convert_to_integer(ct_month_id), convert_to_integer(ff_line_number), data_home, orig_format, unknown_offender, convert_to_integer(did), convert_to_integer(nibrs_incident_id) from ct_incident_temp);
INSERT INTO ct_victim (SELECT convert_to_integer(incident_id), convert_to_integer(victim_type_id) from ct_victim_temp);
INSERT INTO ct_offense (SELECT convert_to_integer(offense_id), convert_to_integer(incident_id), convert_to_integer(offense_type_id), convert_to_integer(location_id), ct_offense_flag from ct_offense_temp);
INSERT INTO ct_offender (SELECT convert_to_integer(offender_id), convert_to_integer(incident_id), convert_to_integer(age), sex_code, convert_to_integer(ethnicity_id), convert_to_integer(race_id) from ct_offender_temp);
INSERT INTO ct_property (SELECT convert_to_integer(property_id), convert_to_integer(prop_desc_id), convert_to_integer(incident_id), convert_to_integer(stolen_value), recovered_flag, to_timestamp_ucr(date_recovered), convert_to_integer(recovered_value) from ct_property_temp);
INSERT INTO ct_arrestee (SELECT convert_to_integer(arrestee_id), convert_to_integer(incident_id), convert_to_integer(age), sex_code, convert_to_integer(ethnicity_id), convert_to_integer(race_id) from ct_arrestee_temp);
INSERT INTO ct_weapon (SELECT convert_to_integer(incident_id), convert_to_integer(weapon_id), convert_to_integer(ct_weapon_id) from ct_weapon_temp);


---------
-- CARGO THEFT
---------
SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates CT stats.
drop materialized view IF EXISTS ct_counts_states_new;
create materialized view ct_counts_states_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, state_id,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    state_id, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id

    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id

    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, prop_desc_name),
    (year, location_name),
    (year, victim_type_name),
    (year, offense_name),
    
    (year, state_id, prop_desc_name),
    (year, state_id, location_name),
    (year, state_id, victim_type_name),
    (year, state_id, offense_name)
);

drop materialized view IF EXISTS  ct_counts_ori_new;
create materialized view ct_counts_ori_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, ori,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    ref_agency.ori, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id

    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id

    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, prop_desc_name),
    (year, ori, location_name),
    (year, ori, victim_type_name),
    (year, ori, offense_name)
);

SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates CT stats.
create materialized view offense_ct_counts_states_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, state_id,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    state_id, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id

    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, offense_name, prop_desc_name),
    (year, offense_name, location_name),
    (year, offense_name, victim_type_name),

    (year, state_id, offense_name, prop_desc_name),
    (year, state_id, offense_name, location_name),
    (year, state_id, offense_name, victim_type_name)
);

create materialized view offense_ct_counts_ori_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, ori,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    ref_agency.ori, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id
    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, offense_name, prop_desc_name),
    (year, ori, offense_name, location_name),
    (year, ori, offense_name, victim_type_name)
);