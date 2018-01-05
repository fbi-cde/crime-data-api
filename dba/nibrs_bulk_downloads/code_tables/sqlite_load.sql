.mode csv
.import 'cde_agencies.csv' cde_agencies
.import 'agency_participation.csv' agency_participation
.import 'nibrs_arrestee.csv' nibrs_arrestee
.import 'nibrs_arrestee_weapon.csv' nibrs_arrestee_weapon
.import 'nibrs_bias_motivation.csv' nibrs_bias_motivation
.import 'nibrs_month.csv' nibrs_month
.import 'nibrs_incident.csv' nibrs_incident
.import 'nibrs_offender.csv' nibrs_offender
.import 'nibrs_offense.csv' nibrs_offense
.import 'nibrs_property.csv' nibrs_property
.import 'nibrs_property_desc.csv' nibrs_property_desc
.import 'nibrs_suspect_using.csv' nibrs_suspect_using
.import 'nibrs_suspected_drug.csv' nibrs_suspected_drug
.import 'nibrs_victim.csv' nibrs_victim
.import 'nibrs_victim_circumstances.csv' nibrs_victim_circumstances
.import 'nibrs_victim_injury.csv' nibrs_victim_injury
.import 'nibrs_victim_offender_rel.csv' nibrs_victim_offender_rel
.import 'nibrs_victim_offense.csv' nibrs_victim_offense
.import 'nibrs_weapon.csv' nibrs_weapon

-- Sqlite will import the CSV header if the table already exists. Ugh

delete from cde_agencies where agency_id = 'agency_id';
delete from agency_participation where year = 'year';
delete from nibrs_arrestee where arrestee_id = 'arrestee_id';
delete from nibrs_arrestee_weapon where arrestee_id = 'arrestee_id';
delete from nibrs_bias_motivation where bias_id='bias_id';
delete from nibrs_month where nibrs_month_id = 'nibrs_month_id';
delete from nibrs_incident where incident_id = 'incident_id';
delete from nibrs_offender where offender_id = 'offender_id';
delete from nibrs_offense where offense_id = 'offense_id';
delete from nibrs_property where property_id = 'property_id';
delete from nibrs_property_desc where property_id = 'property_id';
delete from nibrs_suspect_using where suspect_using_id = 'suspect_using_id';
delete from nibrs_suspected_drug where suspected_drug_type_id = 'suspected_drug_type_id';
delete from nibrs_victim where victim_id = 'victim_id';
delete from nibrs_victim_injury where victim_id = 'victim_id';
delete from nibrs_victim_circumstances where victim_id = 'victim_id';
delete from nibrs_victim_offender_rel where victim_id = 'victim_id';
delete from nibrs_victim_offense where victim_id = 'victim_id';
delete from nibrs_weapon where weapon_id = 'weapon_id';
