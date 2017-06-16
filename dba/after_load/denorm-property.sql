drop table nibrs_property_denorm CASCADE;
create table nibrs_property_denorm (
    property_id bigint, -- nibrs_offender.offender_id
    incident_id bigint, -- nibrs_offender.incident_id
    agency_id bigint, -- ref_agency.agency_id
    state_id int, -- nibrs_incident.state_id
    incident_date timestamp, -- nibrs_incident.date
    year varchar(4),
    ori varchar(9),
    state_code varchar(2), -- ref_state.state_code
    property_desc_id int,
    prop_desc_name varchar(100),
    PRIMARY KEY(property_id)
);


CREATE TRIGGER property_partition_insert_trigger
BEFORE INSERT ON nibrs_property_denorm
FOR EACH ROW EXECUTE PROCEDURE create_partition_and_insert();

INSERT INTO nibrs_property_denorm (incident_id, agency_id, year, incident_date, property_id) SELECT nibrs_incident.incident_id, nibrs_incident.agency_id, EXTRACT(YEAR FROM nibrs_incident.incident_date) as year, nibrs_incident.incident_date, nibrs_property.property_id from nibrs_property JOIN nibrs_incident on nibrs_incident.incident_id = nibrs_property.incident_id;

UPDATE nibrs_property_denorm SET state_id = ref_agency.state_id, ori = ref_agency.ori from ref_agency where nibrs_property_denorm.agency_id = ref_agency.agency_id;
UPDATE nibrs_property_denorm SET state_code = ref_state.state_code from ref_state where nibrs_property_denorm.state_id = ref_state.state_id;

UPDATE nibrs_property_denorm SET property_desc_id = nibrs_property_desc.prop_desc_id from nibrs_property_desc where nibrs_property_desc.property_id = nibrs_property_denorm.property_id;
UPDATE nibrs_property_denorm SET prop_desc_name = nibrs_prop_desc_type.prop_desc_name from nibrs_prop_desc_type where nibrs_prop_desc_type.prop_desc_id = nibrs_property_denorm.property_desc_id;


-- Updates for new downloads.
ALTER TABLE nibrs_property_denorm ADD COLUMN date_recovered timestamp, ADD COLUMN property_value bigint, ADD COLUMN stolen_count int, ADD COLUMN drug_measure_name text, ADD COLUMN drug_measure_code varchar(2), ADD COLUMN est_drug_qty int;
UPDATE nibrs_property_denorm SET date_recovered = nibrs_property_desc.date_recovered, property_value = nibrs_property_desc.property_value, stolen_count = nibrs_property.stolen_count, est_drug_qty = nibrs_suspected_drug.est_drug_qty, drug_measure_code = nibrs_drug_measure_type.drug_measure_code, drug_measure_name = nibrs_drug_measure_type.drug_measure_name from nibrs_property JOIN nibrs_suspected_drug ON (nibrs_property.property_id = nibrs_suspected_drug.property_id) JOIN nibrs_drug_measure_type ON (nibrs_suspected_drug.drug_measure_type_id = nibrs_drug_measure_type.drug_measure_type_id) JOIN nibrs_property_desc ON (nibrs_property.property_id = nibrs_property_desc.property_id) where nibrs_property.property_id = nibrs_property_denorm.property_id;
