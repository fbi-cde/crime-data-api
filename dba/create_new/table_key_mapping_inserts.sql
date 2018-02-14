-- NIBRS
-- NIBRS  Count
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category)
VALUES ('nibrs_count_offender', 'count','Count' , 'text', 'Offender Count', 'Offender demographic');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category)
VALUES ('nibrs_count_victim', 'count','Count' , 'text', 'Victim Count', 'Victim demographic');
-- NIBRS Sex
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_sex_offender', 'male_count','Male' , 'stacked_table', 'Offender Sex', 'Offender demographic','Offender','Sex');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_sex_offender', 'female_count','Female' , 'stacked_table', 'Offender Sex', 'Offender demographic','Offender','Sex');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_sex_offender', 'unknown_count','Unknown' , 'stacked_table', 'Offender Sex', 'Offender demographic','Offender','Sex');


INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_sex_victim', 'male_count','Male' , 'stacked_table', 'Victim Sex', 'Victim demographic','Victim','Sex');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_sex_victim', 'female_count','Female' , 'stacked_table', 'Victim Sex', 'Victim demographic','Victim','Sex');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_sex_victim', 'unknown_count','Unknown' , 'stacked_table', 'Victim Sex', 'Victim demographic','Victim','Sex');

-- NIBRS Ethnicity
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_ethnicity_offender', 'hispanic','Hispanic' , 'basic_table', 'Offender Ethnicity', 'Offender demographic','Offender','Ethnicity');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_ethnicity_offender', 'multiple','Multiple' , 'basic_table', 'Offender Ethnicity', 'Offender demographic','Offender','Ethnicity');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_ethnicity_offender', 'not_hispanic','Not Hispanic' , 'basic_table', 'Offender Ethnicity', 'Offender demographic','Offender','Ethnicity');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_ethnicity_offender', 'unknown','Unknown' , 'basic_table', 'Offender Ethnicity', 'Offender demographic','Offender','Ethnicity');



INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_ethnicity_victim', 'hispanic','Hispanic' , 'basic_table', 'Victim Ethnicity', 'Victim demographic','Victim','Ethnicity');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_ethnicity_victim', 'multiple','Multiple' , 'basic_table', 'Victim Ethnicity', 'Victim demographic','Victim','Ethnicity');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_ethnicity_victim', 'not_hispanic','Not Hispanic' , 'basic_table', 'Victim Ethnicity', 'Victim demographic','Victim','Ethnicity');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_ethnicity_victim', 'unknown','Unknown' , 'basic_table', 'Victim Ethnicity', 'Victim demographic','Victim','Ethnicity');



-- NIBRS Race
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_offender', 'asian','Asian' , 'basic_table', 'Offender Race', 'Offender demographic','Offender','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_offender', 'native_hawaiian','Native Hawaiian' , 'basic_table', 'Offender Race', 'Offender demographic','Offender','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_offender', 'black','Black or African American' , 'basic_table', 'Offender Race', 'Offender demographic','Offender','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_offender', 'american_indian','American Indian or Alaska Native' , 'basic_table', 'Offender Race', 'Offender demographic','Offender','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_offender', 'white','White' , 'basic_table', 'Offender Race', 'Offender demographic','Offender','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_offender', 'unknown','Unknown' , 'basic_table', 'Offender Race', 'Offender demographic','Offender','Race');


INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_victim', 'asian','Asian' , 'basic_table', 'Victim Race', 'Victim demographic','Victim','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_victim', 'native_hawaiian','Native Hawaiian' , 'basic_table', 'Victim Race', 'Victim demographic','Victim','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_victim', 'black','Black or African American' , 'basic_table', 'Victim Race', 'Victim demographic','Victim','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_victim', 'american_indian','American Indian or Alaska Native' , 'basic_table', 'Victim Race', 'Victim demographic','Victim','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_victim', 'white','White' , 'basic_table', 'Victim Race', 'Victim demographic','Victim','Race');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_race_victim', 'unknown','Unknown' , 'basic_table', 'Victim Race', 'Victim demographic','Victim','Race');

-- NIBRS Age
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_0_9','0-9' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_10_19','10-19' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_20_29','20-29' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_30_39','30-39' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_40_49','40-49' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_50_59','50-59' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_60_69','60-69' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_70_79','70-79' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_80_89','80-89' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'range_90_99','90-99' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_offender', 'unknown','Unknown' , 'basic_table', 'Offender Age', 'Offender demographic','Offender','Age');



INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_0_9','0-9' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_10_19','10-19' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_20_29','20-29' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_30_39','30-39' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_40_49','40-49' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_50_59','50-59' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_60_69','60-69' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_70_79','70-79' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_80_89','80-89' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'range_90_99','90-99' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun, short_title)
VALUES ('nibrs_age_victim', 'unknown','Unknown' , 'basic_table', 'Victim Age', 'Victim demographic','Victim','Age');




-- NIBRS Location
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'residence_home','Residence Home' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'parking_garage__lot','Parking Garage/Lot' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'abandoned_condemned__structure','Abandoned Condemned/Structure' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'air__bus__train_terminal','Air/Bus/Train Terminal' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'amusement_park','Amusement Park' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'arena__stadium__fairgrounds','Arena/Stadium/Fairgrounds' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'atm_separate_from_bank','ATM Separate From Bank' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'auto_dealership','Auto Dealership' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'bank','Bank' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'bar_nightclub','Bar/Nightclub' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'campground','Campground' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'church__synagogue__temple__mosque','Church/Synagogue/Temple/Mosque' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'commercial__office_building','Commercial/Office Building' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'community_center','Community Center' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'construction_site','Construction Site' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'cyberspace','Cyberspace' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'daycare_facility','Daycare Facility' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'department__discount_store','Department/Discount Store' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'dock__wharf__shipping_terminal','Dock/Wharf/Shipping Terminal' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'drug_store__doctors_office__hospital','Drug Store/Doctors Office/Hospital' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'farm_facility','Farm Facility' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'field__woods','Field/Woods' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'gambling_facility__casino__race_track','Gambling Facility/Casino/Race Track' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'government__public_building','Government/Public Building' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'grocery_store','Grocery Store' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'highway__alley__street__sidewalk','Highway/Alley/Street/Sidewalk' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'hotel__motel','Hotel/Motel' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'industrial_site','Industrial Site' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'jail__prison__corrections_facility','Jail/Prison/Corrections Facility' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'lake__waterway__beach','Lake/Waterway/Beach' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'liquor_store','Liquor Store' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'military_base','Military Base' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'unknown','Unknown' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'park__playground','Park/Playground' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'rental_storage_facility','Rental Storage Facility' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'rest_area','Rest Area' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'restaurant','Restaurant' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'school__college','School/College' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'school_college__university','School College/University' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'school_elementary__secondary','School Elementary/Secondary' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'gas_station','Gas Station' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'mission__homeless_shelter','Mission/Homeless Shelter' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'shopping_mall','Shopping Mall' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'specialty_store','Specialty Store' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'tribal_lands','Tribal Lands' , 'basic_table', 'Location type','Location type','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_location', 'convenience_store','Convenience Store' , 'basic_table', 'Location type','Location type','incident');

-- NIBRS :Offender Relationship
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'acquaintance','Acquaintance' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'babysittee','Babysittee' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'boyfriend_girlfriend','Boyfriend/Girlfriend' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'child_boyfriend_girlfriend','Child of Boyfriend/Girlfriend' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'child','Child' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'common_law_spouse','Spouse' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'employee','Employee' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'employer','Employer' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'friend','Friend' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'grandchild','Grandchild' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'grandparent','Grandparent' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'homosexual_relationship','Homosexual Relationship' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'in_law','In-Law' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'neighbor','Neighbor' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'other_family_member','Other Family Member' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'otherwise_known','Otherwise Known' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'parent','Parent' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'relationship_unknown','Relationship Unknown' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'sibling','Sibling' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'stepchild','Stepchild' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'spouse','Spouse' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'stepparent','Stepparent' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'stepsibling','Stepsibling' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'stranger','Stranger' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'offender','Offender' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, category, noun)
VALUES ('nibrs_relatiopnship', 'ex_spouse','Ex Spouse' , 'basic_table', 'Victim’s relationship to the offender','Victim’s relationship to the offender','incident');

-- NIBRS Offense count
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, noun)
VALUES ('nibrs_offense_count', 'incident_count','Incident Count' , 'text', 'Offense Count','offense');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title, noun)
VALUES ('nibrs_offense_count', 'offense_count','Offense Count' , 'text', 'Offense Count','offense');

--LEOKA
-- LEOKA : Population Group Keys
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_1_actual_ct','Group 1' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_2_actual_ct','Group 2' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_2_actual_ct','Group 2' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_3_actual_ct','Group 3' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_4_actual_ct','Group 4' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_5_actual_ct','Group 5' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_6_actual_ct','Group 6' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_7_actual_ct','Group 7' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_8_actual_ct','Group 8' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_group', 'group_9_actual_ct','Group 9' , 'table', 'Population Group');

-- LEOKA: Assignment Dist
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_assign_dist', 'two_officer_vehicle_actual','2-Officer Vehicle' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_assign_dist', 'one_officer_vehicle_actual','1 Officer Vehicle Alone' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_assign_dist', 'one_officer_assisted_actual','1 Officer Vehicle Assisted' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_assign_dist', 'det_spe_ass_alone_actual','Detective/special Alone' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_assign_dist', 'det_spe_ass_assisted_actual','Detective/special Assisted' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_assign_dist', 'other_alone_actual','Other Alone', 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_assign_dist', 'other_assisted_actual','Other Assisted', 'table', 'Circumstance at Scene of Incident by Type of Assignment');


-- LEOKA: Circumstance Weapon
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon', 'firearm_actual','Firearm', 'basic_table', 'Assault by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon', 'knife_actual','Knife', 'basic_table', 'Assault by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon', 'hands_fists_feet_actual','Personal Weapons', 'basic_table', 'Assault by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon', 'other_actual','Other Dangerous Weapon', 'basic_table', 'Assault by Type of Weapon');


-- LEOKA: Group By Weapon Type
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon_per_group', 'firearm_actual','Firearm', 'table', 'Population Group by Type of Weapon');
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon_per_group', 'knife_actual','Knife', 'table', 'Population Group by Type of Weapon');
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon_per_group', 'hands_fists_feet_actual','Personal Weapons', 'table', 'Population Group by Type of Weapon');
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon_per_group', 'other_actual','Other Dangerous Weapon', 'table', ' Population Group by Type of Weapon');

-- LEOKA: Circumstance Weapon
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon_per_activity', 'firearm_actual','Firearm', 'table', 'Circumstance at Scene of Incident by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon_per_activity', 'knife_actual','Knife', 'table', 'Circumstance at Scene of Incident by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon_per_activity', 'hands_fists_feet_actual','Personal Weapons', 'table', 'Circumstance at Scene of Incident by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_weapon_per_activity', 'other_actual','Other Dangerous Weapon', 'table', 'Circumstance at Scene of Incident by Type of Weapon');

--- LEOKA: Weapon Injury
--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
--VALUES ('leoka_assault_weapon_injury', 'total_injury_cnt','Total Injury', 'basic_table', 'Type of Weapon and Percent Injured');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_weapon_injury', 'firearm_injury_cnt','Firearm Injury', 'basic_table', 'Injury by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_weapon_injury', 'knife_injury_cnt','Knife Injury', 'basic_table', 'Injury by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_weapon_injury', 'hands_fists_feet_injury_cnt','Personal Weapon Injury', 'basic_table', 'Injury by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_weapon_injury', 'other_injury_cnt','Other Weapon Injury', 'basic_table', 'Injury by Type of Weapon');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
--VALUES ('leoka_assault_weapon_injury', 'total_cnt','Total', 'basic_table', 'Type of Weapon and Percent Injured');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
--VALUES ('leoka_assault_weapon_injury', 'firearm_total_cnt','Firearm Total', 'basic_table', 'Type of Weapon and Percent Injured');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
--VALUES ('leoka_assault_weapon_injury', 'knife_total_cnt','Knife Total', 'basic_table', 'Type of Weapon and Percent Injured');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
--VALUES ('leoka_assault_weapon_injury', 'hands_fists_feet_total_cnt','Personal Weapon Total', 'basic_table', 'Type of Weapon and Percent Injured');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
--VALUES ('leoka_assault_weapon_injury', 'other_total_cnt','Other Weapon Total', 'basic_table', 'Type of Weapon and Percent Injured');

-- LEOKA: Time Dist
--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
--VALUES ('leoka_assault_by_time', 'total_cnt','Total Count', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
--VALUES ('leoka_assault_by_time', 'total_am_cnt','Total A.M.Count', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
--VALUES ('leoka_assault_by_time', 'total_pm_cnt','Total P.M.Count', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_0001_0200_cnt','12:01am-2am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_0201_0400_cnt','2:01am-4am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_0401_0600_cnt','4:01am-6am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_0601_0800_cnt','6:01am-8am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_0801_1000_cnt','8:01am-10am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_1001_1200_cnt','10:01am-Noon', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_1201_1400_cnt','12:01pm-2pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_1401_1600_cnt','2:01pm-4pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_1601_1800_cnt','4:01pm-6pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_1801_2000_cnt','6:01pm-8pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_2001_2200_cnt','8:01pm-10pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, title)
VALUES ('leoka_assault_by_time', 'time_2201_0000_cnt','10:01pm-Midnight', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');
