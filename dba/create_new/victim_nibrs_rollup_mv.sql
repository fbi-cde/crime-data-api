CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_sex AS
select
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when sex_code = 'M' then count end), 0) as male_count,
coalesce(sum(case when sex_code = 'F' then count end), 0) as female_count,
coalesce(sum(case when sex_code = 'U' then count end), 0) as unknown_count
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
coalesce(sum(case when race_desc = 'Asian' then count end), 0) as asian,
coalesce(sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
coalesce(sum(case when race_desc = 'Black or African American' then count end), 0) as black,
coalesce(sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
coalesce(sum(case when race_desc = 'Unknown' then count end), 0) as unknown,
coalesce(sum(case when race_desc = 'White' then count end), 0) as white
from public.nibrs_victim_count group by offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_ethnicity AS
select
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
coalesce(sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
coalesce(sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
coalesce(sum(case when ethnicity_name = 'Unknown' then count end), 0) as unknown
from public.nibrs_victim_count group by offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_age AS
select
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when age_range = '0-9' then count end), 0) as range_0_9,
coalesce(sum(case when age_range = '10-19' then count end), 0) as range_10_11,
coalesce(sum(case when age_range = '20-29' then count end), 0) as range_20_29,
coalesce(sum(case when age_range = '30-39' then count end), 0) as range_30_39,
coalesce(sum(case when age_range = '40-49' then count end), 0) as range_40_49,
coalesce(sum(case when age_range = '50-59' then count end), 0) as range_50_59,
coalesce(sum(case when age_range = '60-69' then count end), 0) as range_60_69,
coalesce(sum(case when age_range = '70-79' then count end), 0) as range_70_79,
coalesce(sum(case when age_range = '80-89' then count end), 0) as range_80_89,
coalesce(sum(case when age_range = '90-99' then count end), 0) as range_90_99,
coalesce(sum(case when age_range = 'Unknown' then count end), 0) as unknown
from public.nibrs_victim_count group by  offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_national_denorm_victim_location AS
select
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when location = 'Residence/Home' then count end), 0) as Residence_Home,
coalesce(sum(case when location = 'Parking Garage/Lot' then count end), 0) as Parking_Garage__Lot,
coalesce(sum(case when location = 'Abandoned/Condemned Structure' then count end), 0) as Abandoned_Condemned__Structure,
coalesce(sum(case when location = 'Air/Bus/Train Terminal' then count end), 0) as Air__Bus__Train_Terminal,
coalesce(sum(case when location = 'Amusement Park' then count end), 0) as Amusement_Park,
coalesce(sum(case when location = 'Arena/Stadium/Fairgrounds' then count end), 0) as Arena__Stadium__Fairgrounds,
coalesce(sum(case when location = 'ATM Separate from Bank' then count end), 0) as ATM_Separate_from_Bank,
coalesce(sum(case when location = 'Auto Dealership' then count end), 0) as Auto_Dealership,
coalesce(sum(case when location = 'Bank' then count end), 0) as Bank,
coalesce(sum(case when location = 'Bar/Nightclub' then count end), 0) as Bar_Nightclub,
coalesce(sum(case when location = 'Campground' then count end), 0) as Campground,
coalesce(sum(case when location = 'Church/Synagogue/Temple/Mosque' then count end), 0) as Church__Synagogue__Temple__Mosque,
coalesce(sum(case when location = 'Commercial/Office Building' then count end), 0) as Commercial__Office_Building,
coalesce(sum(case when location = 'Community Center' then count end), 0) as Community_Center,
coalesce(sum(case when location = 'Construction Site' then count end), 0) as Construction_Site,
coalesce(sum(case when location = 'Cyberspace' then count end), 0) as Cyberspace,
coalesce(sum(case when location = 'Daycare Facility' then count end), 0) as Daycare_Facility,
coalesce(sum(case when location = 'Department/Discount Store' then count end), 0) as Department__Discount_Store,
coalesce(sum(case when location = 'Dock/Wharf/Shipping Terminal' then count end), 0) as Dock__Wharf__Shipping_Terminal,
coalesce(sum(case when location = 'Drug Store/Doctor’s Office/Hospital' then count end), 0) as Drug_Store__Doctors_Office__Hospital,
coalesce(sum(case when location = 'Farm Facility' then count end), 0) as Farm_Facility,
coalesce(sum(case when location = 'Field/Woods' then count end), 0) as Field__Woods,
coalesce(sum(case when location = 'Gambling Facility/Casino/Race Track' then count end), 0) as Gambling_Facility__Casino__Race_Track,
coalesce(sum(case when location = 'Government/Public Building' then count end), 0) as Government__Public_Building,
coalesce(sum(case when location = 'Grocery Store' then count end), 0) as Grocery_Store,
coalesce(sum(case when location = 'Highway/Alley/Street/Sidewalk' then count end), 0) as Highway__Alley__Street__Sidewalk,
coalesce(sum(case when location = 'Hotel/Motel' then count end), 0) as Hotel__Motel,
coalesce(sum(case when location = 'Industrial Site' then count end), 0) as Industrial_Site,
coalesce(sum(case when location = 'Jail/Prison/Corrections Facility' then count end), 0) as Jail__Prison__Corrections_Facility,
coalesce(sum(case when location = 'Lake/Waterway/Beach' then count end), 0) as Lake__Waterway__Beach,
coalesce(sum(case when location = 'Liquor Store' then count end), 0) as Liquor_Store,
coalesce(sum(case when location = 'Military Base' then count end), 0) as Military_Base,
coalesce(sum(case when location = 'Unknown' then count end), 0) as Unknown,
coalesce(sum(case when location = 'Park/Playground' then count end), 0) as Park__Playground,
coalesce(sum(case when location = 'Rental Storage Facility' then count end), 0) as Rental_Storage_Facility,
coalesce(sum(case when location = 'Rest Area' then count end), 0) as Rest_Area,
coalesce(sum(case when location = 'Restaurant' then count end), 0) as Restaurant,
coalesce(sum(case when location = 'School/College' then count end), 0) as School__College,
coalesce(sum(case when location = 'School - College/University' then count end), 0) as School_College__University,
coalesce(sum(case when location = 'School - Elementary/Secondary' then count end), 0) as School_Elementary__Secondary,
coalesce(sum(case when location = 'Gas Station' then count end), 0) as Gas_Station,
coalesce(sum(case when location = 'Mission/Homeless Shelter' then count end), 0) as Mission__Homeless_Shelter,
coalesce(sum(case when location = 'Shopping Mall' then count end), 0) as Shopping_Mall,
coalesce(sum(case when location = 'Specialty Store' then count end), 0) as Specialty_Store,
coalesce(sum(case when location = 'Tribal Lands' then count end), 0) as Tribal_Lands
from public.nibrs_victim_count group by  offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_sex AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when sex_code = 'M' then count end), 0) as male_count,
coalesce(sum(case when sex_code = 'F' then count end), 0) as female_count,
coalesce(sum(case when sex_code = 'U' then count end), 0) as unknown_count
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
coalesce(sum(case when race_desc = 'Asian' then count end), 0) as asian,
coalesce(sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
coalesce(sum(case when race_desc = 'Black or African American' then count end), 0) as black,
coalesce(sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
coalesce(sum(case when race_desc = 'Unknown' then count end), 0) as unknown,
coalesce(sum(case when race_desc = 'White' then count end), 0) as white
from public.nibrs_victim_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_ethnicity AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
coalesce(sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
coalesce(sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
coalesce(sum(case when ethnicity_name = 'Unknown' then count end), 0) as unknown
from public.nibrs_victim_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_age AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when age_range = '0-9' then count end), 0) as range_0_9,
coalesce(sum(case when age_range = '10-19' then count end), 0) as range_10_11,
coalesce(sum(case when age_range = '20-29' then count end), 0) as range_20_29,
coalesce(sum(case when age_range = '30-39' then count end), 0) as range_30_39,
coalesce(sum(case when age_range = '40-49' then count end), 0) as range_40_49,
coalesce(sum(case when age_range = '50-59' then count end), 0) as range_50_59,
coalesce(sum(case when age_range = '60-69' then count end), 0) as range_60_69,
coalesce(sum(case when age_range = '70-79' then count end), 0) as range_70_79,
coalesce(sum(case when age_range = '80-89' then count end), 0) as range_80_89,
coalesce(sum(case when age_range = '90-99' then count end), 0) as range_90_99,
coalesce(sum(case when age_range = 'Unknown' then count end), 0) as unknown
from public.nibrs_victim_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_state_denorm_victim_location AS
select  state_id as state_id,
state_abbr as state_abbr,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when location = 'Residence/Home' then count end), 0) as Residence_Home,
coalesce(sum(case when location = 'Parking Garage/Lot' then count end), 0) as Parking_Garage__Lot,
coalesce(sum(case when location = 'Abandoned/Condemned Structure' then count end), 0) as Abandoned_Condemned__Structure,
coalesce(sum(case when location = 'Air/Bus/Train Terminal' then count end), 0) as Air__Bus__Train_Terminal,
coalesce(sum(case when location = 'Amusement Park' then count end), 0) as Amusement_Park,
coalesce(sum(case when location = 'Arena/Stadium/Fairgrounds' then count end), 0) as Arena__Stadium__Fairgrounds,
coalesce(sum(case when location = 'ATM Separate from Bank' then count end), 0) as ATM_Separate_from_Bank,
coalesce(sum(case when location = 'Auto Dealership' then count end), 0) as Auto_Dealership,
coalesce(sum(case when location = 'Bank' then count end), 0) as Bank,
coalesce(sum(case when location = 'Bar/Nightclub' then count end), 0) as Bar_Nightclub,
coalesce(sum(case when location = 'Campground' then count end), 0) as Campground,
coalesce(sum(case when location = 'Church/Synagogue/Temple/Mosque' then count end), 0) as Church__Synagogue__Temple__Mosque,
coalesce(sum(case when location = 'Commercial/Office Building' then count end), 0) as Commercial__Office_Building,
coalesce(sum(case when location = 'Community Center' then count end), 0) as Community_Center,
coalesce(sum(case when location = 'Construction Site' then count end), 0) as Construction_Site,
coalesce(sum(case when location = 'Cyberspace' then count end), 0) as Cyberspace,
coalesce(sum(case when location = 'Daycare Facility' then count end), 0) as Daycare_Facility,
coalesce(sum(case when location = 'Department/Discount Store' then count end), 0) as Department__Discount_Store,
coalesce(sum(case when location = 'Dock/Wharf/Shipping Terminal' then count end), 0) as Dock__Wharf__Shipping_Terminal,
coalesce(sum(case when location = 'Drug Store/Doctor’s Office/Hospital' then count end), 0) as Drug_Store__Doctors_Office__Hospital,
coalesce(sum(case when location = 'Farm Facility' then count end), 0) as Farm_Facility,
coalesce(sum(case when location = 'Field/Woods' then count end), 0) as Field__Woods,
coalesce(sum(case when location = 'Gambling Facility/Casino/Race Track' then count end), 0) as Gambling_Facility__Casino__Race_Track,
coalesce(sum(case when location = 'Government/Public Building' then count end), 0) as Government__Public_Building,
coalesce(sum(case when location = 'Grocery Store' then count end), 0) as Grocery_Store,
coalesce(sum(case when location = 'Highway/Alley/Street/Sidewalk' then count end), 0) as Highway__Alley__Street__Sidewalk,
coalesce(sum(case when location = 'Hotel/Motel' then count end), 0) as Hotel__Motel,
coalesce(sum(case when location = 'Industrial Site' then count end), 0) as Industrial_Site,
coalesce(sum(case when location = 'Jail/Prison/Corrections Facility' then count end), 0) as Jail__Prison__Corrections_Facility,
coalesce(sum(case when location = 'Lake/Waterway/Beach' then count end), 0) as Lake__Waterway__Beach,
coalesce(sum(case when location = 'Liquor Store' then count end), 0) as Liquor_Store,
coalesce(sum(case when location = 'Military Base' then count end), 0) as Military_Base,
coalesce(sum(case when location = 'Unknown' then count end), 0) as Unknown,
coalesce(sum(case when location = 'Park/Playground' then count end), 0) as Park__Playground,
coalesce(sum(case when location = 'Rental Storage Facility' then count end), 0) as Rental_Storage_Facility,
coalesce(sum(case when location = 'Rest Area' then count end), 0) as Rest_Area,
coalesce(sum(case when location = 'Restaurant' then count end), 0) as Restaurant,
coalesce(sum(case when location = 'School/College' then count end), 0) as School__College,
coalesce(sum(case when location = 'School - College/University' then count end), 0) as School_College__University,
coalesce(sum(case when location = 'School - Elementary/Secondary' then count end), 0) as School_Elementary__Secondary,
coalesce(sum(case when location = 'Gas Station' then count end), 0) as Gas_Station,
coalesce(sum(case when location = 'Mission/Homeless Shelter' then count end), 0) as Mission__Homeless_Shelter,
coalesce(sum(case when location = 'Shopping Mall' then count end), 0) as Shopping_Mall,
coalesce(sum(case when location = 'Specialty Store' then count end), 0) as Specialty_Store,
coalesce(sum(case when location = 'Tribal Lands' then count end), 0) as Tribal_Lands
from public.nibrs_victim_count group by state_id, state_abbr, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_sex AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when sex_code = 'M' then count end), 0) as male_count,
coalesce(sum(case when sex_code = 'F' then count end), 0) as female_count,
coalesce(sum(case when sex_code = 'U' then count end), 0) as unknown_count
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
coalesce(sum(case when race_desc = 'Asian' then count end), 0) as asian,
coalesce(sum(case when race_desc = 'Native Hawaiian or Pacific Islander' then count end), 0) as native_hawaiian,
coalesce(sum(case when race_desc = 'Black or African American' then count end), 0) as black,
coalesce(sum(case when race_desc = 'American Indian or Alaska Native' then count end), 0) as american_indian,
coalesce(sum(case when race_desc = 'Unknown' then count end), 0) as unknown,
coalesce(sum(case when race_desc = 'White' then count end), 0) as white
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_ethnicity AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when ethnicity_name = 'Hispanic or Latino' then count end), 0) as hispanic,
coalesce(sum(case when ethnicity_name = 'Multiple' then count end), 0) as multiple,
coalesce(sum(case when ethnicity_name = 'Not Hispanic or Latino' then count end), 0) as not_Hispanic,
coalesce(sum(case when ethnicity_name = 'Unknown' then count end), 0) as unknown
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_age AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when age_range = '0-9' then count end), 0) as range_0_9,
coalesce(sum(case when age_range = '10-19' then count end), 0) as range_10_11,
coalesce(sum(case when age_range = '20-29' then count end), 0) as range_20_29,
coalesce(sum(case when age_range = '30-39' then count end), 0) as range_30_39,
coalesce(sum(case when age_range = '40-49' then count end), 0) as range_40_49,
coalesce(sum(case when age_range = '50-59' then count end), 0) as range_50_59,
coalesce(sum(case when age_range = '60-69' then count end), 0) as range_60_69,
coalesce(sum(case when age_range = '70-79' then count end), 0) as range_70_79,
coalesce(sum(case when age_range = '80-89' then count end), 0) as range_80_89,
coalesce(sum(case when age_range = '90-99' then count end), 0) as range_90_99,
coalesce(sum(case when age_range = 'Unknown' then count end), 0) as unknown
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;

CREATE MATERIALIZED VIEW nibrs_agency_denorm_victim_location AS
select  agency_id as agency_id,
ori as ori,
offense_name as offense_name,
data_year as data_year,
coalesce(sum(case when location = 'Residence/Home' then count end), 0) as Residence_Home,
coalesce(sum(case when location = 'Parking Garage/Lot' then count end), 0) as Parking_Garage__Lot,
coalesce(sum(case when location = 'Abandoned/Condemned Structure' then count end), 0) as Abandoned_Condemned__Structure,
coalesce(sum(case when location = 'Air/Bus/Train Terminal' then count end), 0) as Air__Bus__Train_Terminal,
coalesce(sum(case when location = 'Amusement Park' then count end), 0) as Amusement_Park,
coalesce(sum(case when location = 'Arena/Stadium/Fairgrounds' then count end), 0) as Arena__Stadium__Fairgrounds,
coalesce(sum(case when location = 'ATM Separate from Bank' then count end), 0) as ATM_Separate_from_Bank,
coalesce(sum(case when location = 'Auto Dealership' then count end), 0) as Auto_Dealership,
coalesce(sum(case when location = 'Bank' then count end), 0) as Bank,
coalesce(sum(case when location = 'Bar/Nightclub' then count end), 0) as Bar_Nightclub,
coalesce(sum(case when location = 'Campground' then count end), 0) as Campground,
coalesce(sum(case when location = 'Church/Synagogue/Temple/Mosque' then count end), 0) as Church__Synagogue__Temple__Mosque,
coalesce(sum(case when location = 'Commercial/Office Building' then count end), 0) as Commercial__Office_Building,
coalesce(sum(case when location = 'Community Center' then count end), 0) as Community_Center,
coalesce(sum(case when location = 'Construction Site' then count end), 0) as Construction_Site,
coalesce(sum(case when location = 'Cyberspace' then count end), 0) as Cyberspace,
coalesce(sum(case when location = 'Daycare Facility' then count end), 0) as Daycare_Facility,
coalesce(sum(case when location = 'Department/Discount Store' then count end), 0) as Department__Discount_Store,
coalesce(sum(case when location = 'Dock/Wharf/Shipping Terminal' then count end), 0) as Dock__Wharf__Shipping_Terminal,
coalesce(sum(case when location = 'Drug Store/Doctor’s Office/Hospital' then count end), 0) as Drug_Store__Doctors_Office__Hospital,
coalesce(sum(case when location = 'Farm Facility' then count end), 0) as Farm_Facility,
coalesce(sum(case when location = 'Field/Woods' then count end), 0) as Field__Woods,
coalesce(sum(case when location = 'Gambling Facility/Casino/Race Track' then count end), 0) as Gambling_Facility__Casino__Race_Track,
coalesce(sum(case when location = 'Government/Public Building' then count end), 0) as Government__Public_Building,
coalesce(sum(case when location = 'Grocery Store' then count end), 0) as Grocery_Store,
coalesce(sum(case when location = 'Highway/Alley/Street/Sidewalk' then count end), 0) as Highway__Alley__Street__Sidewalk,
coalesce(sum(case when location = 'Hotel/Motel' then count end), 0) as Hotel__Motel,
coalesce(sum(case when location = 'Industrial Site' then count end), 0) as Industrial_Site,
coalesce(sum(case when location = 'Jail/Prison/Corrections Facility' then count end), 0) as Jail__Prison__Corrections_Facility,
coalesce(sum(case when location = 'Lake/Waterway/Beach' then count end), 0) as Lake__Waterway__Beach,
coalesce(sum(case when location = 'Liquor Store' then count end), 0) as Liquor_Store,
coalesce(sum(case when location = 'Military Base' then count end), 0) as Military_Base,
coalesce(sum(case when location = 'Unknown' then count end), 0) as Unknown,
coalesce(sum(case when location = 'Park/Playground' then count end), 0) as Park__Playground,
coalesce(sum(case when location = 'Rental Storage Facility' then count end), 0) as Rental_Storage_Facility,
coalesce(sum(case when location = 'Rest Area' then count end), 0) as Rest_Area,
coalesce(sum(case when location = 'Restaurant' then count end), 0) as Restaurant,
coalesce(sum(case when location = 'School/College' then count end), 0) as School__College,
coalesce(sum(case when location = 'School - College/University' then count end), 0) as School_College__University,
coalesce(sum(case when location = 'School - Elementary/Secondary' then count end), 0) as School_Elementary__Secondary,
coalesce(sum(case when location = 'Gas Station' then count end), 0) as Gas_Station,
coalesce(sum(case when location = 'Mission/Homeless Shelter' then count end), 0) as Mission__Homeless_Shelter,
coalesce(sum(case when location = 'Shopping Mall' then count end), 0) as Shopping_Mall,
coalesce(sum(case when location = 'Specialty Store' then count end), 0) as Specialty_Store,
coalesce(sum(case when location = 'Tribal Lands' then count end), 0) as Tribal_Lands
from public.nibrs_victim_count group by agency_id, ori, offense_name, data_year;



REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_victim_location;
REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_victim_age;
REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_victim_ethnicity;
REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_victim_race;
REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_victim_count;
REFRESH MATERIALIZED VIEW public.nibrs_agency_denorm_victim_sex;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_victim_location;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_victim_age;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_victim_ethnicity;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_victim_race;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_victim_count;
REFRESH MATERIALIZED VIEW public.nibrs_state_denorm_victim_sex;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_victim_location;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_victim_age;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_victim_ethnicity;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_victim_race;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_victim_count;
REFRESH MATERIALIZED VIEW public.nibrs_national_denorm_victim_sex;


UPDATE nibrs_victim_count
SET location = TRIM(location), state_abbr = TRIM(state_abbr),ori = TRIM(ori),
offense_name = TRIM(offense_name),victim_type_name = TRIM(victim_type_name),sex_code = TRIM(sex_code),
age_range = TRIM(age_range),race_desc = TRIM(race_desc),ethnicity_name = TRIM(ethnicity_name)
