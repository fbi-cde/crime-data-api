SET work_mem='4096MB';
SET synchronous_commit='off';
SET effective_cache_size='4GB';

drop table nibrs_arrestee_denorm CASCADE;
create table nibrs_arrestee_denorm (
    incident_id bigint, -- nibrs_offender.incident_id
    agency_id bigint, -- ref_agency.agency_id
    incident_date timestamp, -- nibrs_incident.date
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


INSERT INTO nibrs_arrestee_denorm (incident_id,arrest_type_id, agency_id, year, incident_date, arrestee_id, age_id, age_num, sex_code, race_id) SELECT nibrs_arrestee.incident_id, nibrs_arrestee.arrest_type_id, nibrs_incident.agency_id, EXTRACT(YEAR FROM nibrs_incident.incident_date) as year, nibrs_incident.incident_date, nibrs_arrestee.offender_id, nibrs_arrestee.age_id, ceil(nibrs_arrestee.age_num::numeric / 10) * 10, nibrs_arrestee.sex_code,nibrs_arrestee.race_id from nibrs_arrestee JOIN nibrs_incident on nibrs_incident.incident_id = nibrs_offender.incident_id;

UPDATE nibrs_arrestee_denorm SET race_code = ref_race.race_code from ref_race where nibrs_arrestee_denorm.race_id = ref_race.race_id; 
UPDATE nibrs_arrestee_denorm SET arrest_type_name = nibrs_arrest_type.arrest_type_name from nibrs_arrest_type where nibrs_arrestee_denorm.arrest_type_id = nibrs_arrest_type.arrest_type_id; 
