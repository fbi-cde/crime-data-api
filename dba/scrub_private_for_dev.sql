-- NULLs out database fields with potentially sensitive information
-- erring on the side of caution!
-- Slightly stricter than `scrub_private_for_prod.sql`
-- so that the resulting datafile can be completely uncontrolled
-- See https://github.com/18F/crime-data-api/issues/113

UPDATE arson_month
SET    ddocname = NULL;


UPDATE asr_month
SET    ddocname = NULL,
       did = NULL;

UPDATE asr_race_offense_subcat
SET    ff_line_number = NULL;


UPDATE ct_incident
SET    incident_number = NULL,
       ddocname = NULL,
       ff_line_number = NULL,
       did = NULL;


UPDATE ct_month
SET
       ddocname = NULL,
       ff_line_number = NULL,
       did = NULL;

UPDATE hc_incident
SET    incident_no = NULL,
       data_home = NULL,
       ddocname = NULL,
       ff_line_number = NULL,
       orig_format = NULL,
       did = NULL;

UPDATE hc_quarter
SET
       ddocname = NULL,
       ff_line_number = NULL,
       orig_format = NULL,
       did = NULL;

UPDATE ht_month
SET
       ddocname = NULL,
       ff_line_number = NULL,
       did = NULL,
       prepared_by_user = NULL,
       prepared_by_email = NULL;

UPDATE nibrs_arrestee
SET    arrest_num = NULL,
       ff_line_number = NULL;

UPDATE nibrs_eds
SET    ddocname = NULL,
       incident_num = NULL,
       data_field = NULL,
       error_msg = NULL;

UPDATE nibrs_grpb_arrest
SET    ff_line_number = NULL,
       arrest_num = NULL,
       ddocname = NULL,
       did = NULL;

UPDATE nibrs_incident
SET    ddocname = NULL,
       ff_line_number = NULL,
       did = NULL,
       incident_number = NULL;


UPDATE nibrs_month
SET    ddocname = NULL,
       ff_line_number = NULL,
       did = NULL;


UPDATE nibrs_offender
SET    ff_line_number = NULL;

UPDATE nibrs_offense
SET    ff_line_number = NULL;

UPDATE nibrs_property
SET    ff_line_number = NULL;

DROP TABLE nibrs_sum_month_temp;


UPDATE nibrs_victim
SET    ff_line_number = NULL;

UPDATE ref_agency
SET    special_mailing_group = NULL,
       special_mailing_address = NULL,
       change_user = NULL;

UPDATE ref_agency_county
SET
       change_user = NULL;


UPDATE ref_campus_population
SET
       change_user = NULL;



UPDATE ref_county_population
SET
       change_user = NULL;


UPDATE ref_metro_div_population
SET
       change_user = NULL;


UPDATE ref_poc
SET
poc_name         = NULL,
poc_title        = NULL,
poc_email        = NULL,
poc_phone1       = NULL,
poc_phone2       = NULL,
mailing_address_1= NULL,
mailing_address_2= NULL,
mailing_address_3= NULL,
mailing_address_4= NULL,
state_id         = NULL,
zip_code         = NULL,
city_name        = NULL,
poc_fax1         = NULL,
poc_fax2         = NULL;


-- Some name and address information
UPDATE ref_submitting_agency
SET    comments = NULL;


UPDATE ref_tribe_population
SET
       change_user = NULL;

UPDATE reta_month
SET    ddocname = NULL,
       prepared_by_user = NULL,
       prepared_by_email = NULL,
       did = NULL,
       ff_line_number = NULL;

UPDATE shr_incident
SET    ddocname = NULL,
       did = NULL,
       ff_line_number = NULL;


UPDATE shr_month
SET    ddocname = NULL,
       did = NULL,
       ff_line_number = NULL;

UPDATE shr_offender
SET    offender_num = NULL;


UPDATE shr_victim
SET    victim_num = NULL;


UPDATE supp_month
SET    ddocname = NULL,
       did = NULL,
       ff_line_number = NULL;
