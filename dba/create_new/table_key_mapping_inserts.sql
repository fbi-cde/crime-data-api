-- LEOKA : Population Group Keys
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_1_actual_ct','Group 1' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_2_actual_ct','Group 2' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_2_actual_ct','Group 2' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_3_actual_ct','Group 3' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_4_actual_ct','Group 4' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_5_actual_ct','Group 5' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_6_actual_ct','Group 6' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_7_actual_ct','Group 7' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_8_actual_ct','Group 8' , 'table', 'Population Group');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_group', 'group_9_actual_ct','Group 9' , 'table', 'Population Group');

-- LEOKA: Assignment Dist
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_assign_dist', 'two_officer_vehicle_actual','2-Officer Vehicle' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_assign_dist', 'one_officer_vehicle_actual','1 Officer Vehicle Alone' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_assign_dist', 'one_officer_assisted_actual','1 Officer Vehicle Assisted' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_assign_dist', 'det_spe_ass_alone_actual','Detective/special Alone' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_assign_dist', 'det_spe_ass_assisted_actual','Detective/special Assisted' , 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_assign_dist', 'other_alone_actual','Other Alone', 'table', 'Circumstance at Scene of Incident by Type of Assignment');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_assign_dist', 'other_assisted_actual','Other Assisted', 'table', 'Circumstance at Scene of Incident by Type of Assignment');


-- LEOKA: Circumstance Weapon
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon', 'firearm_actual','Firearm', 'basic_table', 'Assault by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon', 'knife_actual','Knife', 'basic_table', 'Assault by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon', 'hands_fists_feet_actual','Personal Weapons', 'basic_table', 'Assault by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon', 'other_actual','Other Dangerous Weapon', 'basic_table', 'Assault by Type of Weapon');


-- LEOKA: Group By Weapon Type
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon_per_group', 'firearm_actual','Firearm', 'table', 'Population Group by Type of Weapon');
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon_per_group', 'knife_actual','Knife', 'table', 'Population Group by Type of Weapon');
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon_per_group', 'hands_fists_feet_actual','Personal Weapons', 'table', 'Population Group by Type of Weapon');
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon_per_group', 'other_actual','Other Dangerous Weapon', 'table', ' Population Group by Type of Weapon');

-- LEOKA: Circumstance Weapon
INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon_per_activity', 'firearm_actual','Firearm', 'table', 'Circumstance at Scene of Incident by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon_per_activity', 'knife_actual','Knife', 'table', 'Circumstance at Scene of Incident by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon_per_activity', 'hands_fists_feet_actual','Personal Weapons', 'table', 'Circumstance at Scene of Incident by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_weapon_per_activity', 'other_actual','Other Dangerous Weapon', 'table', 'Circumstance at Scene of Incident by Type of Weapon');

--- LEOKA: Weapon Injury
--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
--VALUES ('leoka_assault_weapon_injury', 'total_injury_cnt','Total Injury', 'basic_table', 'Type of Weapon and Percent Injured');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_weapon_injury', 'firearm_injury_cnt','Firearm Injury', 'basic_table', 'Injury by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_weapon_injury', 'knife_injury_cnt','Knife Injury', 'basic_table', 'Injury by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_weapon_injury', 'hands_fists_feet_injury_cnt','Personal Weapon Injury', 'basic_table', 'Injury by Type of Weapon');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_weapon_injury', 'other_injury_cnt','Other Weapon Injury', 'basic_table', 'Injury by Type of Weapon');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
--VALUES ('leoka_assault_weapon_injury', 'total_cnt','Total', 'basic_table', 'Type of Weapon and Percent Injured');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
--VALUES ('leoka_assault_weapon_injury', 'firearm_total_cnt','Firearm Total', 'basic_table', 'Type of Weapon and Percent Injured');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
--VALUES ('leoka_assault_weapon_injury', 'knife_total_cnt','Knife Total', 'basic_table', 'Type of Weapon and Percent Injured');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
--VALUES ('leoka_assault_weapon_injury', 'hands_fists_feet_total_cnt','Personal Weapon Total', 'basic_table', 'Type of Weapon and Percent Injured');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
--VALUES ('leoka_assault_weapon_injury', 'other_total_cnt','Other Weapon Total', 'basic_table', 'Type of Weapon and Percent Injured');

-- LEOKA: Time Dist
--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
--VALUES ('leoka_assault_by_time', 'total_cnt','Total Count', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
--VALUES ('leoka_assault_by_time', 'total_am_cnt','Total A.M.Count', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

--INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
--VALUES ('leoka_assault_by_time', 'total_pm_cnt','Total P.M.Count', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_0001_0200_cnt','12:01am-2am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_0201_0400_cnt','2:01am-4am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_0401_0600_cnt','4:01am-6am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_0601_0800_cnt','6:01am-8am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_0801_1000_cnt','8:01am-10am', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_1001_1200_cnt','10:01am-Noon', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_1201_1400_cnt','12:01pm-2pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_1401_1600_cnt','2:01pm-4pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_1601_1800_cnt','4:01pm-6pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_1801_2000_cnt','6:01pm-8pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_2001_2200_cnt','8:01pm-10pm', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');

INSERT INTO public.table_key_mapping(table_name, column_name, key, ui_component, ui_text)
VALUES ('leoka_assault_by_time', 'time_2201_0000_cnt','10:01pm-Midnight', 'basic_table', 'Time of Incident by Number of Assaults and Percent Distribution');
