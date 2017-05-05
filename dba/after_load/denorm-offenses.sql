SET synchronous_commit='off'; -- Go Super Saiyan.

drop table nibrs_offense_denorm CASCADE;
create table nibrs_offense_denorm (
    offense_id bigint, -- nibrs_offender.offender_id
    incident_id bigint, -- nibrs_offender.incident_id
    agency_id bigint, -- ref_agency.agency_id
    state_id int, -- nibrs_incident.state_id
    county_id int,
    incident_date timestamp, -- nibrs_incident.date
    year varchar(4),
    ori varchar(9),

    offense_type_id bigint,
    offense_name varchar(100),
    location_id int, -- nibrs_location.id
    location_code varchar(2),
    location_name varchar(100), -- nibrs_location_type.location_name
    weapon_id bigint,
    weapon_name varchar(100), -- nibrs_weapon_type

    method_entry_code varchar(1), -- nibrs_offense
    num_premises_entered int,  -- nibrs_offense
    state_code varchar(2), -- ref_state.state_code
    PRIMARY KEY(offense_id)
);

CREATE TRIGGER offense_partition_insert_trigger
BEFORE INSERT ON nibrs_offense_denorm
FOR EACH ROW EXECUTE PROCEDURE create_partition_and_insert();

INSERT INTO nibrs_offense_denorm (incident_id, agency_id, year, incident_date, offense_id, method_entry_code, num_premises_entered, location_id, offense_type_id) SELECT nibrs_offense.incident_id, nibrs_incident.agency_id, EXTRACT(YEAR FROM nibrs_incident.incident_date) as year, nibrs_incident.incident_date, nibrs_offense.offense_id, nibrs_offense.method_entry_code, nibrs_offense.num_premises_entered, nibrs_offense.location_id, nibrs_offense.offense_type_id from nibrs_offense JOIN nibrs_incident on nibrs_incident.incident_id = nibrs_offense.incident_id;

UPDATE nibrs_offense_denorm SET state_id = ref_agency.state_id, county_id = ref_agency_county.county_id from ref_agency JOIN ref_agency_county ON ref_agency.agency_id = ref_agency_county.agency_id where nibrs_offense_denorm.agency_id = ref_agency.agency_id;
UPDATE nibrs_offense_denorm SET state_code = ref_state.state_code from ref_state where nibrs_offense_denorm.state_id = ref_state.state_id;

UPDATE nibrs_offense_denorm SET location_name = nibrs_location_type.location_name, location_code=nibrs_location_type.location_code from nibrs_location_type where nibrs_location_type.location_id = nibrs_offense_denorm.location_id;
UPDATE nibrs_offense_denorm SET offense_name = nibrs_offense_type.offense_name from nibrs_offense_type where nibrs_offense_type.offense_type_id = nibrs_offense_denorm.offense_type_id;
UPDATE nibrs_offense_denorm SET weapon_id = nibrs_weapon.weapon_id from nibrs_weapon where nibrs_weapon.offense_id = nibrs_offense_denorm.offense_id;
UPDATE nibrs_offense_denorm SET weapon_name = nibrs_weapon_type.weapon_name from nibrs_weapon_type where nibrs_weapon_type.weapon_id = nibrs_offense_denorm.weapon_id;