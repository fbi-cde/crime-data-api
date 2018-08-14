CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_sex AS
select
offense_name as offense_name,
data_year as data_year,
sum(case when sex_code = 'M' then count end), 0) as male_count,
sum(case when sex_code = 'F' then count end), 0) as female_count,
sum(case when sex_code = 'U' then count end), 0) as unknown_count
from public.nibrs_victim_count group by offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_count AS
select
offense_name as offense_name,
data_year as data_year,
sum(count) as count
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_race AS
select
offense_name as offense_name,
data_year as data_year,
sum(case when race_desc = 'Asian' then count end), 0) as asian,
sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
sum(case when race_desc = 'Black or African American' then count end), 0) as black,
sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
sum(case when race_desc = 'Unknown' then count end), 0) as unknown,
sum(case when race_desc = 'White' then count end), 0) as white
from public.nibrs_victim_count group by offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_ethnicity AS
select
offense_name as offense_name,
data_year as data_year,
sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,a
sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
sum(case when ethnicity_name = 'Unknown' then count end), 0) as unknown
from public.nibrs_victim_count group by offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_age AS
select
offense_name as offense_name,
data_year as data_year,
sum(case when age_range = '0-9' then count end), 0) as range_0_9,
sum(case when age_range = '10-19' then count end), 0) as range_10_19,
sum(case when age_range = '20-29' then count end), 0) as range_20_29,
sum(case when age_range = '30-39' then count end), 0) as range_30_39,
sum(case when age_range = '40-49' then count end), 0) as range_40_49,
sum(case when age_range = '50-59' then count end), 0) as range_50_59,
sum(case when age_range = '60-69' then count end), 0) as range_60_69,
sum(case when age_range = '70-79' then count end), 0) as range_70_79,
sum(case when age_range = '80-89' then count end), 0) as range_80_89,
sum(case when age_range = '90-99' then count end), 0) as range_90_99,
sum(case when age_range = 'UNKNOWN' then count end), 0) as unknown
from public.nibrs_victim_count group by  offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_sex AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
sum(case when sex_code = 'M' then count end), 0) as male_count,
sum(case when sex_code = 'F' then count end), 0) as female_count,
sum(case when sex_code = 'U' then count end), 0) as unknown_count
from public.nibrs_victim_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_count AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
sum(count) as count
from public.nibrs_victim_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_race AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
sum(case when race_desc = 'Asian' then count end), 0) as asian,
sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
sum(case when race_desc = 'Black or African American' then count end), 0) as black,
sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
sum(case when race_desc = 'Unknown' then count end), 0) as unknown,
sum(case when race_desc = 'White' then count end), 0) as white
from public.nibrs_victim_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_ethnicity AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
sum(case when ethnicity_name = 'Unknown' then count end), 0) as unknown
from public.nibrs_victim_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_age AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
sum(case when age_range = '0-9' then count end), 0) as range_0_9,
sum(case when age_range = '10-19' then count end), 0) as range_10_19,
sum(case when age_range = '20-29' then count end), 0) as range_20_29,
sum(case when age_range = '30-39' then count end), 0) as range_30_39,
sum(case when age_range = '40-49' then count end), 0) as range_40_49,
sum(case when age_range = '50-59' then count end), 0) as range_50_59,
sum(case when age_range = '60-69' then count end), 0) as range_60_69,
sum(case when age_range = '70-79' then count end), 0) as range_70_79,
sum(case when age_range = '80-89' then count end), 0) as range_80_89,
sum(case when age_range = '90-99' then count end), 0) as range_90_99,
sum(case when age_range = 'UNKNOWN' then count end), 0) as unknown
from public.nibrs_victim_count group by state_id, state_abbr, offense_name, data_year;


CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_sex AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
sum(case when sex_code = 'M' then count end), 0) as male_count,
sum(case when sex_code = 'F' then count end), 0) as female_count,
sum(case when sex_code = 'U' then count end), 0) as unknown_count
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_count AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
sum(count) as count
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_race AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
sum(case when race_desc = 'Asian' then count end), 0) as asian,
sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
sum(case when race_desc = 'Black or African American' then count end), 0) as black,
sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
sum(case when race_desc = 'Unknown' then count end), 0) as unknown,
sum(case when race_desc = 'White' then count end), 0) as white
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_ethnicity AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
sum(case when ethnicity_name = 'Unknown' then count end), 0) as unknown
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_age AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
sum(case when age_range = '0-9' then count end), 0) as range_0_9,
sum(case when age_range = '10-19' then count end), 0) as range_10_19,
sum(case when age_range = '20-29' then count end), 0) as range_20_29,
sum(case when age_range = '30-39' then count end), 0) as range_30_39,
sum(case when age_range = '40-49' then count end), 0) as range_40_49,
sum(case when age_range = '50-59' then count end), 0) as range_50_59,
sum(case when age_range = '60-69' then count end), 0) as range_60_69,
sum(case when age_range = '70-79' then count end), 0) as range_70_79,
sum(case when age_range = '80-89' then count end), 0) as range_80_89,
sum(case when age_range = '90-99' then count end), 0) as range_90_99,
sum(case when age_range = 'UNKNOWN' then count end), 0) as unknown
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;

CCREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_location_temp AS
select  c.agency_id as agency_id,
c.ori as ori,
c.offense_name as offense_name,
c.data_year as data_year,
c.location as location,
sum(c.count)
from public.nibrs_victim_count c group by agency_id, ori, offense_name, data_year,location;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_location AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
sum(case when location = 'Residence/Home' then sum end), 0) as Residence_Home,
sum(case when location = 'Parking Garage/Lot' then sum end), 0) as Parking_Garage__Lot,
sum(case when location = 'Abandoned/Condemned Structure' then sum end), 0) as Abandoned_Condemned__Structure,
sum(case when location = 'Air/Bus/Train Terminal' then sum end), 0) as Air__Bus__Train_Terminal,
sum(case when location = 'Amusement Park' then sum end), 0) as Amusement_Park,
sum(case when location = 'Arena/Stadium/Fairgrounds/Coliseum' then sum end), 0) as Arena__Stadium__Fairgrounds,
sum(case when location = 'ATM Separate from Bank' then sum end), 0) as ATM_Separate_from_Bank,
sum(case when location = 'Auto Dealership New/Used' then sum end), 0) as Auto_Dealership,
sum(case when location = 'Bank/Savings and Loan' then sum end), 0) as Bank,
sum(case when location = 'Bar/Nightclub' then sum end), 0) as Bar_Nightclub,
sum(case when location = 'Camp/Campground' then sum end), 0) as Campground,
sum(case when location = 'Church/Synagogue/Temple/Mosque' then sum end), 0) as Church__Synagogue__Temple__Mosque,
sum(case when location = 'Commercial/Office Building' then sum end), 0) as Commercial__Office_Building,
sum(case when location = 'Community Center' then sum end), 0) as Community_Center,
sum(case when location = 'Construction Site' then sum end), 0) as Construction_Site,
sum(case when location = 'Cyberspace' then sum end), 0) as Cyberspace,
sum(case when location = 'Daycare Facility' then sum end), 0) as Daycare_Facility,
sum(case when location = 'Department/Discount Store' then sum end), 0) as Department__Discount_Store,
sum(case when location = 'Dock/Wharf/Freight/Modal Terminal' then sum end), 0) as Dock__Wharf__Shipping_Terminal,
sum(case when location = 'Drug Store/Doctor’s Office/Hospital' then sum end), 0) as Drug_Store__Doctors_Office__Hospital,
sum(case when location = 'Farm Facility' then sum end), 0) as Farm_Facility,
sum(case when location = 'Field/Woods' then sum end), 0) as Field__Woods,
sum(case when location = 'Gambling Facility/Casino/Race Track' then sum end), 0) as Gambling_Facility__Casino__Race_Track,
sum(case when location = 'Government/Public Building' then sum end), 0) as Government__Public_Building,
sum(case when location = 'Grocery/Supermarket' then sum end), 0) as Grocery_Store,
sum(case when location = 'Highway/Road/Alley/Street/Sidewalk' then sum end), 0) as Highway__Alley__Street__Sidewalk,
sum(case when location = 'Hotel/Motel/Etc.' then sum end), 0) as Hotel__Motel,
sum(case when location = 'Industrial Site' then sum end), 0) as Industrial_Site,
sum(case when location = 'Jail/Prison/Penitentiary/Corrections Facility' then sum end), 0) as Jail__Prison__Corrections_Facility,
sum(case when location = 'Lake/Waterway/Beach' then sum end), 0) as Lake__Waterway__Beach,
sum(case when location = 'Liquor Store' then sum end), 0) as Liquor_Store,
sum(case when location = 'Military Installation' then sum end), 0) as Military_Base,
sum(case when location = 'Other/Unknown' then sum end), 0) as Unknown,
sum(case when location = 'Park/Playground' then sum end), 0) as Park__Playground,
sum(case when location = 'Rental Storage Facility' then sum end), 0) as Rental_Storage_Facility,
sum(case when location = 'Rest Area' then sum end), 0) as Rest_Area,
sum(case when location = 'Restaurant' then sum end), 0) as Restaurant,
sum(case when location = 'School/College' then sum end), 0) as School__College,
sum(case when location = 'School-College/University' then sum end), 0) as School_College__University,
sum(case when location = 'School-Elementary/Secondary' then sum end), 0) as School_Elementary__Secondary,
sum(case when location = 'Service/Gas Station' then sum end), 0) as Gas_Station,
sum(case when location = 'Shelter-Mission/Homeless' then sum end), 0) as Mission__Homeless_Shelter,
sum(case when location = 'Shopping Mall' then sum end), 0) as Shopping_Mall,
sum(case when location = 'Specialty Store' then sum end), 0) as Specialty_Store,
sum(case when location = 'Tribal Lands' then sum end), 0) as Tribal_Lands,
sum(case when location = 'Convenience Store' then sum end), 0) as convenience_store
from public.nibrs_agency_denorm_victim_location_temp  group by agency_id, ori, offense_name, data_year;



CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_location_temp AS
select  c.state_id as state_id,
c.state_abbr as state_abbr,
c.offense_name as offense_name,
c.data_year as data_year,
c.location as location,
sum(c.count)
from public.nibrs_victim_count c group by state_id,state_abbr,offense_name, data_year,location;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_location AS
select state_id as state_id,
agency_id as state_abbr,
offense_name as offense_name,
data_year as data_year,
sum(case when location = 'Residence/Home' then sum end), 0) as Residence_Home,
sum(case when location = 'Parking Garage/Lot' then sum end), 0) as Parking_Garage__Lot,
sum(case when location = 'Abandoned/Condemned Structure' then sum end), 0) as Abandoned_Condemned__Structure,
sum(case when location = 'Air/Bus/Train Terminal' then sum end), 0) as Air__Bus__Train_Terminal,
sum(case when location = 'Amusement Park' then sum end), 0) as Amusement_Park,
sum(case when location = 'Arena/Stadium/Fairgrounds/Coliseum' then sum end), 0) as Arena__Stadium__Fairgrounds,
sum(case when location = 'ATM Separate from Bank' then sum end), 0) as ATM_Separate_from_Bank,
sum(case when location = 'Auto Dealership New/Used' then sum end), 0) as Auto_Dealership,
sum(case when location = 'Bank/Savings and Loan' then sum end), 0) as Bank,
sum(case when location = 'Bar/Nightclub' then sum end), 0) as Bar_Nightclub,
sum(case when location = 'Camp/Campground' then sum end), 0) as Campground,
sum(case when location = 'Church/Synagogue/Temple/Mosque' then sum end), 0) as Church__Synagogue__Temple__Mosque,
sum(case when location = 'Commercial/Office Building' then sum end), 0) as Commercial__Office_Building,
sum(case when location = 'Community Center' then sum end), 0) as Community_Center,
sum(case when location = 'Construction Site' then sum end), 0) as Construction_Site,
sum(case when location = 'Cyberspace' then sum end), 0) as Cyberspace,
sum(case when location = 'Daycare Facility' then sum end), 0) as Daycare_Facility,
sum(case when location = 'Department/Discount Store' then sum end), 0) as Department__Discount_Store,
sum(case when location = 'Dock/Wharf/Freight/Modal Terminal' then sum end), 0) as Dock__Wharf__Shipping_Terminal,
sum(case when location = 'Drug Store/Doctor’s Office/Hospital' then sum end), 0) as Drug_Store__Doctors_Office__Hospital,
sum(case when location = 'Farm Facility' then sum end), 0) as Farm_Facility,
sum(case when location = 'Field/Woods' then sum end), 0) as Field__Woods,
sum(case when location = 'Gambling Facility/Casino/Race Track' then sum end), 0) as Gambling_Facility__Casino__Race_Track,
sum(case when location = 'Government/Public Building' then sum end), 0) as Government__Public_Building,
sum(case when location = 'Grocery/Supermarket' then sum end), 0) as Grocery_Store,
sum(case when location = 'Highway/Road/Alley/Street/Sidewalk' then sum end), 0) as Highway__Alley__Street__Sidewalk,
sum(case when location = 'Hotel/Motel/Etc.' then sum end), 0) as Hotel__Motel,
sum(case when location = 'Industrial Site' then sum end), 0) as Industrial_Site,
sum(case when location = 'Jail/Prison/Penitentiary/Corrections Facility' then sum end), 0) as Jail__Prison__Corrections_Facility,
sum(case when location = 'Lake/Waterway/Beach' then sum end), 0) as Lake__Waterway__Beach,
sum(case when location = 'Liquor Store' then sum end), 0) as Liquor_Store,
sum(case when location = 'Military Installation' then sum end), 0) as Military_Base,
sum(case when location = 'Other/Unknown' then sum end), 0) as Unknown,
sum(case when location = 'Park/Playground' then sum end), 0) as Park__Playground,
sum(case when location = 'Rental Storage Facility' then sum end), 0) as Rental_Storage_Facility,
sum(case when location = 'Rest Area' then sum end), 0) as Rest_Area,
sum(case when location = 'Restaurant' then sum end), 0) as Restaurant,
sum(case when location = 'School/College' then sum end), 0) as School__College,
sum(case when location = 'School-College/University' then sum end), 0) as School_College__University,
sum(case when location = 'School-Elementary/Secondary' then sum end), 0) as School_Elementary__Secondary,
sum(case when location = 'Service/Gas Station' then sum end), 0) as Gas_Station,
sum(case when location = 'Shelter-Mission/Homeless' then sum end), 0) as Mission__Homeless_Shelter,
sum(case when location = 'Shopping Mall' then sum end), 0) as Shopping_Mall,
sum(case when location = 'Specialty Store' then sum end), 0) as Specialty_Store,
sum(case when location = 'Tribal Lands' then sum end), 0) as Tribal_Lands,
sum(case when location = 'Convenience Store' then sum end), 0) as convenience_store
from public.nibrs_state_denorm_victim_location_temp  group by state_id, state_abbr,offense_name, data_year;


CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_location_temp AS
select
c.offense_name as offense_name,
c.data_year as data_year,
c.location as location,
sum(c.count)
from public.nibrs_victim_count c group by offense_name, data_year,location;

CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_location AS
select
offense_name as offense_name,
data_year as data_year,
sum(case when location = 'Residence/Home' then sum end), 0) as Residence_Home,
sum(case when location = 'Parking Garage/Lot' then sum end), 0) as Parking_Garage__Lot,
sum(case when location = 'Abandoned/Condemned Structure' then sum end), 0) as Abandoned_Condemned__Structure,
sum(case when location = 'Air/Bus/Train Terminal' then sum end), 0) as Air__Bus__Train_Terminal,
sum(case when location = 'Amusement Park' then sum end), 0) as Amusement_Park,
sum(case when location = 'Arena/Stadium/Fairgrounds/Coliseum' then sum end), 0) as Arena__Stadium__Fairgrounds,
sum(case when location = 'ATM Separate from Bank' then sum end), 0) as ATM_Separate_from_Bank,
sum(case when location = 'Auto Dealership New/Used' then sum end), 0) as Auto_Dealership,
sum(case when location = 'Bank/Savings and Loan' then sum end), 0) as Bank,
sum(case when location = 'Bar/Nightclub' then sum end), 0) as Bar_Nightclub,
sum(case when location = 'Camp/Campground' then sum end), 0) as Campground,
sum(case when location = 'Church/Synagogue/Temple/Mosque' then sum end), 0) as Church__Synagogue__Temple__Mosque,
sum(case when location = 'Commercial/Office Building' then sum end), 0) as Commercial__Office_Building,
sum(case when location = 'Community Center' then sum end), 0) as Community_Center,
sum(case when location = 'Construction Site' then sum end), 0) as Construction_Site,
sum(case when location = 'Cyberspace' then sum end), 0) as Cyberspace,
sum(case when location = 'Daycare Facility' then sum end), 0) as Daycare_Facility,
sum(case when location = 'Department/Discount Store' then sum end), 0) as Department__Discount_Store,
sum(case when location = 'Dock/Wharf/Freight/Modal Terminal' then sum end), 0) as Dock__Wharf__Shipping_Terminal,
sum(case when location = 'Drug Store/Doctor’s Office/Hospital' then sum end), 0) as Drug_Store__Doctors_Office__Hospital,
sum(case when location = 'Farm Facility' then sum end), 0) as Farm_Facility,
sum(case when location = 'Field/Woods' then sum end), 0) as Field__Woods,
sum(case when location = 'Gambling Facility/Casino/Race Track' then sum end), 0) as Gambling_Facility__Casino__Race_Track,
sum(case when location = 'Government/Public Building' then sum end), 0) as Government__Public_Building,
sum(case when location = 'Grocery/Supermarket' then sum end), 0) as Grocery_Store,
sum(case when location = 'Highway/Road/Alley/Street/Sidewalk' then sum end), 0) as Highway__Alley__Street__Sidewalk,
sum(case when location = 'Hotel/Motel/Etc.' then sum end), 0) as Hotel__Motel,
sum(case when location = 'Industrial Site' then sum end), 0) as Industrial_Site,
sum(case when location = 'Jail/Prison/Penitentiary/Corrections Facility' then sum end), 0) as Jail__Prison__Corrections_Facility,
sum(case when location = 'Lake/Waterway/Beach' then sum end), 0) as Lake__Waterway__Beach,
sum(case when location = 'Liquor Store' then sum end), 0) as Liquor_Store,
sum(case when location = 'Military Installation' then sum end), 0) as Military_Base,
sum(case when location = 'Other/Unknown' then sum end), 0) as Unknown,
sum(case when location = 'Park/Playground' then sum end), 0) as Park__Playground,
sum(case when location = 'Rental Storage Facility' then sum end), 0) as Rental_Storage_Facility,
sum(case when location = 'Rest Area' then sum end), 0) as Rest_Area,
sum(case when location = 'Restaurant' then sum end), 0) as Restaurant,
sum(case when location = 'School/College' then sum end), 0) as School__College,
sum(case when location = 'School-College/University' then sum end), 0) as School_College__University,
sum(case when location = 'School-Elementary/Secondary' then sum end), 0) as School_Elementary__Secondary,
sum(case when location = 'Service/Gas Station' then sum end), 0) as Gas_Station,
sum(case when location = 'Shelter-Mission/Homeless' then sum end), 0) as Mission__Homeless_Shelter,
sum(case when location = 'Shopping Mall' then sum end), 0) as Shopping_Mall,
sum(case when location = 'Specialty Store' then sum end), 0) as Specialty_Store,
sum(case when location = 'Tribal Lands' then sum end), 0) as Tribal_Lands,
sum(case when location = 'Convenience Store' then sum end), 0) as convenience_store
from public.nibrs_national_denorm_victim_location_temp  group by offense_name, data_year;


--regions
CREATE MATERIALIZED VIEW nibrs_region_denorm_victim_sex AS
select  s.region_code as region_code,
r.region_name as region_name,
n.offense_name as offense_name,
n.data_year as data_year,
SUM(n.male_count) as male_count,
SUM(n.female_count) as female_count,
SUM(n.unknown_count) as unknown_count
from public.nibrs_state_denorm_victim_sex n, public.state_lk s,public.region_lk r
where s.region_code = r.region_code group by s.region_code,r.region_name, n.offense_name, n.data_year;


CREATE MATERIALIZED VIEW nibrs_region_denorm_victim_count AS
select  s.region_code as region_code,
r.region_name as region_name,
n.offense_name as offense_name,
n.data_year as data_year,
sum(n.count) as count
from public.nibrs_victim_count n, public.state_lk s,public.region_lk r
where s.region_code = r.region_code group by s.region_code,r.region_name, n.offense_name, n.data_year;

CREATE MATERIALIZED VIEW nibrs_region_denorm_victim_race AS
select  s.region_code as region_code,
r.region_name as region_name,
n.offense_name as offense_name,
n.data_year as data_year,
sum(n.asian) as asian,
sum(n.native_hawaiian) as native_hawaiian,
sum(n.black) as black,
sum(n.american_indian) as american_indian,
sum(n.unknown) as unknown,
sum(n.white) as white
from public.nibrs_state_denorm_victim_race n, public.state_lk s,public.region_lk r
where s.region_code = r.region_code
group by s.region_code,r.region_name, n.offense_name, n.data_year;

CREATE MATERIALIZED VIEW nibrs_region_denorm_victim_ethnicity AS
select  s.region_code as region_code,
r.region_name as region_name,
n.offense_name as offense_name,
n.data_year as data_year,
sum(n.hispanic) as hispanic,
sum(n.multiple) as multiple,
sum(n.not_Hispanic) as not_Hispanic,
sum(n.unknown) as unknown
from public.nibrs_state_denorm_victim_ethnicity  n, public.state_lk s,public.region_lk r
where s.region_code = r.region_code
group by s.region_code,r.region_name, n.offense_name, n.data_year;

CREATE MATERIALIZED VIEW nibrs_region_denorm_victim_age AS
select  s.region_code as region_code,
r.region_name as region_name,
n.offense_name as offense_name,
n.data_year as data_year,
sum(n.range_0_9) as range_0_9,
sum(n.range_10_19) as range_10_19,
sum(n.range_20_29) as range_20_29,
sum(n.range_30_39) as range_30_39,
sum(n.range_40_49) as range_40_49,
sum(n.range_50_59) as range_50_59,
sum(n.range_60_69) as range_60_69,
sum(n.range_70_79) as range_70_79,
sum(n.range_80_89) as range_80_89,
sum(n.range_90_99) as range_90_99,
sum(n.unknown) as unknown
from public.nibrs_state_denorm_victim_age n, public.state_lk s,public.region_lk r
where s.region_code = r.region_code
group by s.region_code,r.region_name, n.offense_name, n.data_year;

CREATE MATERIALIZED VIEW nibrs_region_denorm_victim_location AS
select  s.region_code as region_code,
r.region_name as region_name,
n.offense_name as offense_name,
n.data_year as data_year,
sum(n.Residence_Home) as Residence_Home,
sum(n.Parking_Garage__Lot) as Parking_Garage__Lot,
sum(n.Abandoned_Condemned__Structure) as Abandoned_Condemned__Structure,
sum(n.Air__Bus__Train_Terminal) as Air__Bus__Train_Terminal,
sum(n.Amusement_Park) as Amusement_Park,
sum(n.Arena__Stadium__Fairgrounds) as Arena__Stadium__Fairgrounds,
sum(n.ATM_Separate_from_Bank) as ATM_Separate_from_Bank,
sum(n.Auto_Dealership) as Auto_Dealership,
sum(n.Bank) as Bank,
sum(n.Bar_Nightclub) as Bar_Nightclub,
sum(n.Campground) as Campground,
sum(n.Church__Synagogue__Temple__Mosque) as Church__Synagogue__Temple__Mosque,
sum(n.Commercial__Office_Building) as Commercial__Office_Building,
sum(n.Community_Center) as Community_Center,
sum(n.Construction_Site) as Construction_Site,
sum(n.Cyberspace) as Cyberspace,
sum(n.Daycare_Facility) as Daycare_Facility,
sum(n.Department__Discount_Store) as Department__Discount_Store,
sum(n.Dock__Wharf__Shipping_Terminal) as Dock__Wharf__Shipping_Terminal,
sum(n.Drug_Store__Doctors_Office__Hospital) as Drug_Store__Doctors_Office__Hospital,
sum(n.Farm_Facility) as Farm_Facility,
sum(n.Field__Woods) as Field__Woods,
sum(n.Gambling_Facility__Casino__Race_Track) as Gambling_Facility__Casino__Race_Track,
sum(n.Government__Public_Building) as Government__Public_Building,
sum(n.Grocery_Store) as Grocery_Store,
sum(n.Highway__Alley__Street__Sidewalk) as Highway__Alley__Street__Sidewalk,
sum(n.Hotel__Motel) as Hotel__Motel,
sum(n.Industrial_Site) as Industrial_Site,
sum(n.Jail__Prison__Corrections_Facility) as Jail__Prison__Corrections_Facility,
sum(n.Lake__Waterway__Beach) as Lake__Waterway__Beach,
sum(n.Liquor_Store) as Liquor_Store,
sum(n.Military_Base) as Military_Base,
sum(n.Unknown) as Unknown,
sum(n.Park__Playground) as Park__Playground,
sum(n.Rental_Storage_Facility) as Rental_Storage_Facility,
sum(n.Rest_Area) as Rest_Area,
sum(n.Restaurant) as Restaurant,
sum(n.School__College) as School__College,
sum(n.School_College__University) as School_College__University,
sum(n.School_Elementary__Secondary) as School_Elementary__Secondary,
sum(n.Gas_Station) as Gas_Station,
sum(n.Mission__Homeless_Shelter) as Mission__Homeless_Shelter,
sum(n.Shopping_Mall) as Shopping_Mall,
sum(n.Specialty_Store) as Specialty_Store,
sum(n.Tribal_Lands) as Tribal_Lands,
sum(n.convenience_store) as convenience_store
from public.nibrs_state_denorm_victim_location  n, public.state_lk s,public.region_lk r
where s.region_code = r.region_code
group by s.region_code,r.region_name, n.offense_name, n.data_year;


UPDATE nibrs_victim_count
SET  location = TRIM(location), victim_type_name= TRIM(victim_type_name), state_abbr = TRIM(state_abbr),ori = TRIM(ori),
offense_name = TRIM(offense_name),sex_code = TRIM(sex_code),
age_range = TRIM(age_range),race_desc = TRIM(race_desc),ethnicity_name = TRIM(ethnicity_name)
