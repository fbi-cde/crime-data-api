SET work_mem='4096MB';
SET synchronous_commit='off';
SET effective_cache_size='4GB';

drop table nibrs_arrestee_denorm CASCADE;
create table nibrs_arrestee_denorm (
    incident_id bigint, -- nibrs_offender.incident_id
    agency_id bigint, -- ref_agency.agency_id
    incident_date timestamp, -- nibrs_incident.date
    arrestee_id bigint,
    arrest_type_id bigint,
    arrest_type_name varchar(100),
    age_id int, -- nibrs_offener.age_id
    age_num int,
    sex_code varchar(1),
    race_id int, -- ref_race.race_code
    race_code varchar(2), -- ref_race.race_code
    year varchar(4),
    ori varchar(9),
    PRIMARY KEY(incident_id)
);

CREATE TRIGGER arrestee_partition_insert_trigger
BEFORE INSERT ON nibrs_arrestee_denorm
FOR EACH ROW EXECUTE PROCEDURE create_partition_and_insert();


SET synchronous_commit='off'; -- Go Super Saiyan.


INSERT INTO nibrs_arrestee_denorm (incident_id,arrest_type_id, agency_id, year, incident_date, arrestee_id, age_id, age_num, sex_code, race_id) SELECT nibrs_arrestee.incident_id, nibrs_arrestee.arrest_type_id, nibrs_incident.agency_id, EXTRACT(YEAR FROM nibrs_incident.incident_date) as year, nibrs_incident.incident_date, nibrs_arrestee.arrestee_id, nibrs_arrestee.age_id, nibrs_arrestee.age_num::numeric, nibrs_arrestee.sex_code,nibrs_arrestee.race_id from nibrs_arrestee JOIN nibrs_incident on nibrs_incident.incident_id = nibrs_arrestee.incident_id;

UPDATE nibrs_arrestee_denorm SET race_code = ref_race.race_code from ref_race where nibrs_arrestee_denorm.race_id = ref_race.race_id; 
UPDATE nibrs_arrestee_denorm SET arrest_type_name = nibrs_arrest_type.arrest_type_name from nibrs_arrest_type where nibrs_arrestee_denorm.arrest_type_id = nibrs_arrest_type.arrest_type_id; 

-- Updates for new downloads.
ALTER TABLE nibrs_arrestee_denorm ADD COLUMN arrest_type_code text, ADD COLUMN arrest_date timestamp, ADD COLUMN ethnicity text, ADD COLUMN clearance_ind varchar(1), ADD COLUMN under_18_disposition_code varchar(1), ADD COLUMN resident_status varchar(1);
UPDATE nibrs_arrestee_denorm SET arrest_type_code = nibrs_arrest_type.arrest_type_code, arrest_date = nibrs_arrestee.arrest_date, ethnicity = nibrs_ethnicity.ethnicity_name, resident_status=nibrs_arrestee.resident_code, under_18_disposition_code= nibrs_arrestee.under_18_disposition_code, clearance_ind = nibrs_arrestee.clearance_ind from nibrs_arrestee JOIN nibrs_arrest_type ON (nibrs_arrestee.arrest_type_id = nibrs_arrest_type.arrest_type_id) JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_arrestee.ethnicity_id where nibrs_arrestee.arrestee_id = nibrs_arrestee_denorm.arrestee_id;



CREATE INDEX nibrs_arrestee_denorm_state_year_id_idx ON nibrs_arrestee_denorm (state_code, year);
