SET work_mem='4096MB';
SET synchronous_commit='off';
SET effective_cache_size='4GB';

drop table nibrs_offender_denorm CASCADE;
create table nibrs_offender_denorm (
    offender_id bigint, -- nibrs_offender.offender_id
    incident_id bigint, -- nibrs_offender.incident_id
    agency_id bigint, -- ref_agency.agency_id
    state_id int, -- nibrs_incident.state_id
    county_id int,
    incident_date timestamp, -- nibrs_incident.date
    race_id int,
    year varchar(4),

    age_id int, -- nibrs_offener.age_id
    age_num int,
    sex_code varchar(1),
    race_code varchar(2), -- ref_race.race_code
    offense_type_id bigint,
    offense_name varchar(100),
    location_id int, -- nibrs_location.id
    location_code varchar(2),
    location_name varchar(100), -- nibrs_location_type.location_name


    property_id bigint,
    prop_desc_name varchar(100),
    property_desc_id int,
    property_loss_id int,

    age_code varchar(10), -- ref_age.age_code
    state_code varchar(2), -- ref_state.state_code
    PRIMARY KEY(offender_id)
);

CREATE TRIGGER offender_partition_insert_trigger
BEFORE INSERT ON nibrs_offender_denorm
FOR EACH ROW EXECUTE PROCEDURE create_partition_and_insert();


SET synchronous_commit='off'; -- Go Super Saiyan.

INSERT INTO nibrs_offender_denorm (incident_id, agency_id, year, incident_date, offender_id, age_id, age_num, sex_code, race_id) SELECT nibrs_offender.incident_id, nibrs_incident.agency_id, EXTRACT(YEAR FROM nibrs_incident.incident_date) as year, nibrs_incident.incident_date, nibrs_offender.offender_id, nibrs_offender.age_id, ceil(nibrs_offender.age_num::numeric / 10) * 10, nibrs_offender.sex_code,nibrs_offender.race_id from nibrs_offender JOIN nibrs_incident on nibrs_incident.incident_id = nibrs_offender.incident_id;

-- UPDATE nibrs_offender_denorm SET agency_id = nibrs_incident.agency_id, incident_date=nibrs_incident.incident_date from nibrs_incident where nibrs_offender_denorm.incident_id = nibrs_incident.incident_id;
UPDATE nibrs_offender_denorm SET state_id = ref_agency.state_id, county_id = ref_agency_county.county_id from ref_agency JOIN ref_agency_county ON ref_agency.agency_id = ref_agency_county.agency_id where nibrs_offender_denorm.agency_id = ref_agency.agency_id;
UPDATE nibrs_offender_denorm SET state_code = ref_state.state_code from ref_state where nibrs_offender_denorm.state_id = ref_state.state_id;
UPDATE nibrs_offender_denorm SET race_code = ref_race.race_code from ref_race where nibrs_offender_denorm.race_id = ref_race.race_id; 
UPDATE nibrs_offender_denorm SET offense_type_id = nibrs_offense.offense_type_id, location_id = nibrs_offense.location_id from nibrs_offense where nibrs_offense.incident_id = nibrs_offender_denorm.incident_id;
UPDATE nibrs_offender_denorm SET offense_name = nibrs_offense_type.offense_name from nibrs_offense_type where nibrs_offense_type.offense_type_id = nibrs_offender_denorm.offense_type_id;
UPDATE nibrs_offender_denorm SET location_name = nibrs_location_type.location_name, location_code=nibrs_location_type.location_code from nibrs_location_type where nibrs_location_type.location_id = nibrs_offender_denorm.location_id;

UPDATE nibrs_offender_denorm SET property_id = nibrs_property.property_id, property_loss_id=nibrs_property.prop_loss_id from nibrs_property where nibrs_property.incident_id = nibrs_offender_denorm.incident_id;
UPDATE nibrs_offender_denorm SET property_desc_id = nibrs_property_desc.prop_desc_id from nibrs_property_desc where nibrs_property_desc.property_id = nibrs_offender_denorm.property_id;
UPDATE nibrs_offender_denorm SET prop_desc_name = nibrs_prop_desc_type.prop_desc_name from nibrs_prop_desc_type where nibrs_prop_desc_type.prop_desc_id = nibrs_offender_denorm.property_desc_id;


# TO RUN:
ALTER TABLE nibrs_offender_denorm ADD COLUMN bias_id smallint, ADD COLUMN bias_name varchar(100), ADD COLUMN offense_id bigint;
UPDATE nibrs_offender_denorm SET offense_id = nibrs_offense.offense_id from nibrs_offense where nibrs_offender_denorm.incident_id = nibrs_offense.incident_id;
UPDATE nibrs_offender_denorm SET bias_id = nibrs_bias_motivation.bias_id from nibrs_bias_motivation where nibrs_bias_motivation.offense_id = nibrs_offender_denorm.offense_id;
UPDATE nibrs_offender_denorm SET bias_name = nibrs_bias_list.bias_name from nibrs_bias_list where nibrs_offender_denorm.bias_id = nibrs_bias_list.bias_id;

ALTER TABLE nibrs_offender_denorm ADD COLUMN ethnicity varchar(100);
UPDATE nibrs_offender_denorm SET ethnicity = nibrs_ethnicity.ethnicity_name from nibrs_offender JOIN nibrs_ethnicity ON nibrs_ethnicity.ethnicity_id = nibrs_offender.ethnicity_id where nibrs_offender.offender_id = nibrs_offender_denorm.offender_id;



