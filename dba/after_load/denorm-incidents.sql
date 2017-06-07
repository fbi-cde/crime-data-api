SET work_mem='4096MB';
SET effective_cache_size='4GB';

drop table nibrs_incident_denorm CASCADE;
create table nibrs_incident_denorm (
    incident_id bigint, -- nibrs_offender.incident_id
    agency_id bigint, -- ref_agency.agency_id
    state_id int,
    incident_date timestamp, -- nibrs_incident.date
    year varchar(4),
    ori varchar(9),
    PRIMARY KEY(incident_id)
);

CREATE TRIGGER incident_partition_insert_trigger
BEFORE INSERT ON nibrs_incident_denorm
FOR EACH ROW EXECUTE PROCEDURE create_partition_and_insert();


INSERT INTO nibrs_incident_denorm (incident_id, agency_id, state_id, ori, year, incident_date) SELECT nibrs_incident.incident_id, nibrs_incident.agency_id, ref_agency.state_id, ref_agency.ori, EXTRACT(YEAR FROM nibrs_incident.incident_date) as year, nibrs_incident.incident_date from nibrs_incident JOIN ref_agency ON (ref_agency.agency_id = nibrs_incident.agency_id);

UPDATE nibrs_incident_denorm SET state_code = ref_state.state_code from ref_state where nibrs_offender_denorm.state_id = ref_state.state_id;

CREATE INDEX nibrs_incident_denorm_state_year_id_idx ON nibrs_incident_denorm (state_code, year);
