SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates CT stats.
drop materialized view IF EXISTS  ct_counts;
create materialized view ct_counts as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, ori, state_id,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    ref_agency.ori, 
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
    (year, state_id, offense_name),

    (year, ori, prop_desc_name),
    (year, ori, location_name),
    (year, ori, victim_type_name),
    (year, ori, offense_name)
);

SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates CT stats.
drop materialized view  IF EXISTS offense_ct_counts;
create materialized view offense_ct_counts as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, ori, state_id,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    ref_agency.ori, 
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
    (year, state_id, offense_name, victim_type_name),

    (year, ori, offense_name, prop_desc_name),
    (year, ori, offense_name, location_name),
    (year, ori, offense_name, victim_type_name)
);

CREATE INDEX ct_counts_state_id_idx ON ct_counts (state_id, year);
CREATE INDEX offense_ct_counts_state_id_idx ON offense_ct_counts (state_id, year);

CREATE INDEX ct_counts_ori_idx ON ct_counts (ori, year);
CREATE INDEX offense_ct_counts_ori_idx ON offense_ct_counts (ori, year);