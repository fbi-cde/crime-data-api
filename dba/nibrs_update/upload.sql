-- select NI.AGENCY_ID, NI.INCIDENT_ID, NI.NIBRS_MONTH_ID, NI.INCIDENT_NUMBER, NI.CARGO_THEFT_FLAG, NI.SUBMISSION_DATE, NI.INCIDENT_DATE, NI.REPORT_DATE_FLAG, NI.INCIDENT_HOUR, NI.CLEARED_EXCEPT_ID, NI.CLEARED_EXCEPT_DATE, NI.INCIDENT_STATUS, NI.DATA_HOME, NI.DDOCNAME, NI.ORIG_FORMAT, NI.FF_LINE_NUMBER, NI.DID from nibrs_incident NI JOIN NIBRS_MONTH NM ON NI.NIBRS_MONTH_ID = NM.NIBRS_MONTH_ID WHERE DATA_YEAR = 2016;
\COPY nibrs_incident_csv (agency_id, incident_id, nibrs_month_id, incident_number, cargo_theft_flag, submission_date, incident_date, report_date_flag, incident_hour, cleared_except_id, cleared_except_date, incident_status, data_home, ddocname, orig_format, ff_line_number, did) FROM 'NIBRS_I.csv' WITH (FORMAT csv, DELIMITER ',', FORCE_NULL (submission_date));

-- select NIBRS_MONTH_ID, AGENCY_ID, MONTH_NUM, DATA_YEAR, REPORTED_STATUS, REPORT_DATE, PREPARED_DATE, UPDATE_FLAG, ORIG_FORMAT, FF_LINE_NUMBER, DATA_HOME, DDOCNAME, DID from NIBRS_MONTH NM WHERE DATA_YEAR = 2016;
\COPY nibrs_month_csv (nibrs_month_id, agency_id, month_num, data_year, reported_status, report_date, prepared_date, update_flag, orig_format, ff_line_number, data_home, ddocname, did) FROM 'NIBRS_M.csv' WITH (FORMAT csv, DELIMITER ',',  FORCE_NULL (report_date));

\COPY nibrs_arrestee_csv (arrestee_id, incident_id, arrestee_seq_num, arrest_num, arrest_date, arrest_type_id, multiple_indicator, offense_type_id, age_id, age_num, sex_code, race_id, ethnicity_id, resident_code, under_18_disposition_code, clearance_ind, ff_line_number, age_range_low_num, age_range_high_num) FROM 'NIBRS_A.csv' WITH (FORMAT csv, DELIMITER ',', FORCE_NULL(ff_line_number));

\COPY nibrs_arrestee_weapon_csv (arrestee_id, weapon_id, nibrs_arrestee_weapon_id) FROM 'NIBRS_AW.csv' WITH DELIMITER ',';

\COPY nibrs_bias_motivation_csv (bias_id, offense_id) FROM 'NIBRS_BM.csv' WITH DELIMITER ',';

\COPY nibrs_criminal_act_csv (criminal_act_id, offense_id) FROM 'NIBRS_CA.csv' WITH DELIMITER ',';

\COPY nibrs_offense_csv (offense_id, incident_id, offense_type_id, attempt_complete_flag, location_id, num_premises_entered, method_entry_code, ff_line_number) FROM 'NIBRS_OFF.csv' WITH (FORMAT csv, DELIMITER ',', FORCE_NULL(num_premises_entered));

\COPY nibrs_offender_csv (offender_id, incident_id, offender_seq_num, age_id, age_num, sex_code, race_id, ethnicity_id, ff_line_number, age_range_low_num, age_range_high_num) FROM 'NIBRS_OF.csv' WITH (FORMAT csv, DELIMITER ',', FORCE_NULL(age_num));

\COPY nibrs_property_csv (property_id, incident_id, prop_loss_id, stolen_count, recovered_count, ff_line_number) FROM 'NIBRS_P.csv' WITH (DELIMITER ',', FORMAT csv, FORCE_NULL(stolen_count, recovered_count));

\COPY nibrs_property_desc_csv (property_id, prop_desc_id, property_value, date_recovered, nibrs_prop_desc_id) FROM 'NIBRS_PD.csv' WITH (FORMAT csv, DELIMITER ',', FORCE_NULL(date_recovered));

\COPY nibrs_suspected_drug_csv (suspected_drug_type_id, property_id, est_drug_qty, drug_measure_type_id, nibrs_suspected_drug_id) FROM 'NIBRS_SD.csv' WITH (FORMAT csv, DELIMITER ',', FORCE_NULL(drug_measure_type_id));

\COPY nibrs_suspect_using_csv (suspect_using_id, offense_id) FROM 'NIBRS_SU.csv' WITH DELIMITER ',';

\COPY nibrs_victim_csv (victim_id, incident_id, victim_seq_num, victim_type_id, assignment_type_id, activity_type_id, outside_agency_id, age_id, age_num, sex_code, race_id, ethnicity_id, resident_status_code, ff_line_number, age_range_low_num, age_range_high_num) FROM 'NIBRS_V.csv' WITH (FORMAT csv, DELIMITER ',', FORCE_NULL(assignment_type_id, activity_type_id, age_range_high_num, age_range_low_num));

\COPY nibrs_victim_circumstances_csv (victim_id, circumstances_id, justifiable_force_id) FROM 'NIBRS_VC.csv' WITH (FORMAT CSV, DELIMITER ',', FORCE_NULL(justifiable_force_id));

\COPY nibrs_victim_injury_csv (victim_id, injury_id) FROM 'NIBRS_VI.csv' WITH DELIMITER ',';

\COPY nibrs_victim_offense_csv (victim_id, offense_id) FROM 'NIBRS_VO.csv' WITH DELIMITER ',';

\COPY nibrs_victim_offender_rel_csv (victim_id, offender_id, relationship_id, nibrs_victim_offender_id) FROM 'NIBRS_VOR.csv' WITH DELIMITER ',';

\COPY nibrs_weapon_csv (weapon_id, offense_id, nibrs_weapon_id) FROM 'NIBRS_W.csv' WITH (DELIMITER ',', FORMAT csv);
