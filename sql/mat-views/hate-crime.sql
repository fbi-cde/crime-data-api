SET work_mem='4096MB'; -- Go Super Saiyan.

-- Generates Hate Crime stats.
drop materialized view hc_counts;
create materialized view hc_counts as select count(incident_id), bias_name, year, county_id, state_id , agency_id
from ( SELECT DISTINCT(hc_incident.incident_id), bias_name, hc_incident.agency_id,county_id, state_id, EXTRACT(YEAR FROM hc_incident.incident_date) as year from hc_incident 
    LEFT OUTER JOIN hc_offense ON hc_incident.incident_id = hc_offense.incident_id 
    LEFT OUTER JOIN hc_bias_motivation ON hc_offense.offense_id = hc_bias_motivation.offense_id 
    LEFT OUTER JOIN nibrs_bias_list ON nibrs_bias_list.bias_id = hc_bias_motivation.bias_id 
    JOIN ref_agency ON ref_agency.agency_id = hc_incident.agency_id
    JOIN ref_agency_county ON ref_agency.agency_id = ref_agency_county.agency_id
     ) as temp where year = '2014' 
GROUP BY GROUPING SETS (
    (year, bias_name),
    (year, state_id, bias_name),
    (year, county_id, bias_name),
    (year, agency_id, bias_name)
);