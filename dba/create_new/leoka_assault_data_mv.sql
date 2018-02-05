CREATE MATERIALIZED VIEW public.leoka_assault_by_group_national AS
select table1.data_year, table1.activity_name, table1.activity_id,
table1.group_1_actual_ct, table1.group_1_cleared_ct,
table2.group_2_actual_ct, table2.group_2_cleared_ct,
table3.group_3_actual_ct, table3.group_3_cleared_ct,
table4.group_4_actual_ct, table4.group_4_cleared_ct,
table5.group_5_actual_ct, table5.group_5_cleared_ct,
table6.group_6_actual_ct, table6.group_6_cleared_ct,
table7.group_7_actual_ct, table7.group_7_cleared_ct,
table8.group_8_actual_ct, table8.group_8_cleared_ct,
table9.group_9_actual_ct, table9.group_9_cleared_ct
FROM
(SELECT a.data_year,
   a.activity_name,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_1_actual_ct,
   sum(a.cleared_count) as group_1_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code like '1%'
 GROUP BY a.data_year, a.activity_name, a.activity_id) table1
JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_2_actual_ct,
   sum(a.cleared_count) as group_2_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '2'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table2 ON table1.activity_id=table2.activity_id
 JOIN (SELECT a.data_year,
   a.activity_name,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_3_actual_ct,
   sum(a.cleared_count) as group_3_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '3'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table3 ON table1.activity_id=table3.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_4_actual_ct,
   sum(a.cleared_count) as group_4_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '4'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table4 ON table1.activity_id=table4.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_5_actual_ct,
   sum(a.cleared_count) as group_5_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '4'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table5 ON table1.activity_id=table5.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_6_actual_ct,
   sum(a.cleared_count) as group_6_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '6'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table6 ON table1.activity_id=table6.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_7_actual_ct,
   sum(a.cleared_count) as group_7_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '7'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table7 ON table1.activity_id=table7.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_8_actual_ct,
   sum(a.cleared_count) as group_8_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code like '8%'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table8 ON table1.activity_id=table8.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_9_actual_ct,
   sum(a.cleared_count) as group_9_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code like '9%'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table9 ON table1.activity_id=table9.activity_id
 ORDER BY activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_group_regional AS
select table1.data_year, table1.region_code, table1.region_name, table1.activity_name, table1.activity_id,
table1.group_1_actual_ct, table1.group_1_cleared_ct,
table2.group_2_actual_ct, table2.group_2_cleared_ct,
table3.group_3_actual_ct, table3.group_3_cleared_ct,
table4.group_4_actual_ct, table4.group_4_cleared_ct,
table5.group_5_actual_ct, table5.group_5_cleared_ct,
table6.group_6_actual_ct, table6.group_6_cleared_ct,
table7.group_7_actual_ct, table7.group_7_cleared_ct,
table8.group_8_actual_ct, table8.group_8_cleared_ct,
table9.group_9_actual_ct, table9.group_9_cleared_ct
FROM
(SELECT a.data_year,
   a.region_code,
   a.region_name,
   a.activity_name,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_1_actual_ct,
   sum(a.cleared_count) as group_1_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code like '1%'
 GROUP BY a.data_year, a.region_code, a.region_name, a.activity_name, a.activity_id) table1
JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_2_actual_ct,
   sum(a.cleared_count) as group_2_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '2'
 GROUP BY a.data_year, a.region_code, a.region_name, a.activity_name, a.activity_id
 ) table2 ON table1.activity_id=table2.activity_id
 JOIN (SELECT a.data_year,
   a.activity_name,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_3_actual_ct,
   sum(a.cleared_count) as group_3_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '3'
 GROUP BY a.data_year, a.region_code, a.region_name, a.activity_name, a.activity_id
 ) table3 ON table1.activity_id=table3.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_4_actual_ct,
   sum(a.cleared_count) as group_4_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '4'
 GROUP BY a.data_year, a.region_code, a.region_name, a.activity_name, a.activity_id
 ) table4 ON table1.activity_id=table4.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_5_actual_ct,
   sum(a.cleared_count) as group_5_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '4'
 GROUP BY a.data_year, a.region_code, a.region_name, a.activity_name, a.activity_id
 ) table5 ON table1.activity_id=table5.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_6_actual_ct,
   sum(a.cleared_count) as group_6_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '6'
 GROUP BY a.data_year, a.region_code, a.region_name, a.activity_name, a.activity_id
 ) table6 ON table1.activity_id=table6.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_7_actual_ct,
   sum(a.cleared_count) as group_7_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '7'
 GROUP BY a.data_year, a.region_code, a.region_name, a.activity_name, a.activity_id
 ) table7 ON table1.activity_id=table7.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_8_actual_ct,
   sum(a.cleared_count) as group_8_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code like '8%'
 GROUP BY a.data_year, a.region_code, a.region_name, a.activity_name, a.activity_id
 ) table8 ON table1.activity_id=table8.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_9_actual_ct,
   sum(a.cleared_count) as group_9_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code like '9%'
 GROUP BY a.data_year, a.region_code, a.region_name, a.activity_name, a.activity_id
 ) table9 ON table1.activity_id=table9.activity_id
 ORDER BY activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_group_state AS
select table1.data_year, table1.state_abbr, table1.activity_name, table1.activity_id,
table1.group_1_actual_ct, table1.group_1_cleared_ct,
table2.group_2_actual_ct, table2.group_2_cleared_ct,
table3.group_3_actual_ct, table3.group_3_cleared_ct,
table4.group_4_actual_ct, table4.group_4_cleared_ct,
table5.group_5_actual_ct, table5.group_5_cleared_ct,
table6.group_6_actual_ct, table6.group_6_cleared_ct,
table7.group_7_actual_ct, table7.group_7_cleared_ct,
table8.group_8_actual_ct, table8.group_8_cleared_ct,
table9.group_9_actual_ct, table9.group_9_cleared_ct
FROM
(SELECT a.data_year,
   a.state_abbr,
   a.activity_name,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_1_actual_ct,
   sum(a.cleared_count) as group_1_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code like '1%'
 GROUP BY a.data_year, a.state_abbr, a.activity_name, a.activity_id) table1
JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_2_actual_ct,
   sum(a.cleared_count) as group_2_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '2'
 GROUP BY a.data_year, a.state_abbr, a.activity_name, a.activity_id
 ) table2 ON table1.activity_id=table2.activity_id
 JOIN (SELECT a.data_year,
   a.activity_name,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_3_actual_ct,
   sum(a.cleared_count) as group_3_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '3'
 GROUP BY a.data_year, a.state_abbr, a.activity_name, a.activity_id
 ) table3 ON table1.activity_id=table3.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_4_actual_ct,
   sum(a.cleared_count) as group_4_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '4'
 GROUP BY a.data_year, a.state_abbr, a.activity_name, a.activity_id
 ) table4 ON table1.activity_id=table4.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_5_actual_ct,
   sum(a.cleared_count) as group_5_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '4'
 GROUP BY a.data_year, a.state_abbr, a.activity_name, a.activity_id
 ) table5 ON table1.activity_id=table5.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_6_actual_ct,
   sum(a.cleared_count) as group_6_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '6'
 GROUP BY a.data_year, a.state_abbr, a.activity_name, a.activity_id
 ) table6 ON table1.activity_id=table6.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_7_actual_ct,
   sum(a.cleared_count) as group_7_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code = '7'
 GROUP BY a.data_year, a.state_abbr, a.activity_name, a.activity_id
 ) table7 ON table1.activity_id=table7.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_8_actual_ct,
   sum(a.cleared_count) as group_8_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code like '8%'
 GROUP BY a.data_year, a.state_abbr, a.activity_name, a.activity_id
 ) table8 ON table1.activity_id=table8.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(hands_fists_feet_actual)+sum(other_actual) as group_9_actual_ct,
   sum(a.cleared_count) as group_9_cleared_ct
 FROM public.leoka_assault_data a JOIN public.agency_data b on b.ori=a.ori
 WHERE b.population_group_code like '9%'
 GROUP BY a.data_year, a.state_abbr, a.activity_name, a.activity_id
 ) table9 ON table1.activity_id=table9.activity_id
 ORDER BY activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_assign_dist_national AS
SELECT data_year,
  activity_name,
  activity_id,
  sum(TWO_OFFICER_VEHICLE_ACTUAL) as TWO_OFFICER_VEHICLE_ACTUAL,
  sum(ONE_OFFICER_VEHICLE_ACTUAL) as ONE_OFFICER_VEHICLE_ACTUAL,
  sum(ONE_OFFICER_ASSISTED_ACTUAL) as ONE_OFFICER_ASSISTED_ACTUAL,
  sum(DET_SPE_ASS_ALONE_ACTUAL) as DET_SPE_ASS_ALONE_ACTUAL,
  sum(DET_SPE_ASS_ASSISTED_ACTUAL) as DET_SPE_ASS_ASSISTED_ACTUAL,
  sum(OTHER_ALONE_ACTUAL) as OTHER_ALONE_ACTUAL,
  sum(OTHER_ASSISTED_ACTUAL) as OTHER_ASSISTED_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, activity_name, activity_id
ORDER BY data_year, activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_assign_dist_regional AS
SELECT data_year,
  region_code,
  activity_name,
  activity_id,
  sum(TWO_OFFICER_VEHICLE_ACTUAL) as TWO_OFFICER_VEHICLE_ACTUAL,
  sum(ONE_OFFICER_VEHICLE_ACTUAL) as ONE_OFFICER_VEHICLE_ACTUAL,
  sum(ONE_OFFICER_ASSISTED_ACTUAL) as ONE_OFFICER_ASSISTED_ACTUAL,
  sum(DET_SPE_ASS_ALONE_ACTUAL) as DET_SPE_ASS_ALONE_ACTUAL,
  sum(DET_SPE_ASS_ASSISTED_ACTUAL) as DET_SPE_ASS_ASSISTED_ACTUAL,
  sum(OTHER_ALONE_ACTUAL) as OTHER_ALONE_ACTUAL,
  sum(OTHER_ASSISTED_ACTUAL) as OTHER_ASSISTED_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, region_code, activity_name, activity_id
ORDER BY data_year, region_code, activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_assign_dist_state AS
SELECT data_year,
  state_abbr,
  activity_name,
  activity_id,
  sum(TWO_OFFICER_VEHICLE_ACTUAL) as TWO_OFFICER_VEHICLE_ACTUAL,
  sum(ONE_OFFICER_VEHICLE_ACTUAL) as ONE_OFFICER_VEHICLE_ACTUAL,
  sum(ONE_OFFICER_ASSISTED_ACTUAL) as ONE_OFFICER_ASSISTED_ACTUAL,
  sum(DET_SPE_ASS_ALONE_ACTUAL) as DET_SPE_ASS_ALONE_ACTUAL,
  sum(DET_SPE_ASS_ASSISTED_ACTUAL) as DET_SPE_ASS_ASSISTED_ACTUAL,
  sum(OTHER_ALONE_ACTUAL) as OTHER_ALONE_ACTUAL,
  sum(OTHER_ASSISTED_ACTUAL) as OTHER_ASSISTED_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, state_abbr, activity_name, activity_id
ORDER BY data_year, state_abbr, activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_assign_dist_agency AS
SELECT data_year,
  ori,
  state_abbr,
  activity_name,
  activity_id,
  sum(TWO_OFFICER_VEHICLE_ACTUAL) as TWO_OFFICER_VEHICLE_ACTUAL,
  sum(ONE_OFFICER_VEHICLE_ACTUAL) as ONE_OFFICER_VEHICLE_ACTUAL,
  sum(ONE_OFFICER_ASSISTED_ACTUAL) as ONE_OFFICER_ASSISTED_ACTUAL,
  sum(DET_SPE_ASS_ALONE_ACTUAL) as DET_SPE_ASS_ALONE_ACTUAL,
  sum(DET_SPE_ASS_ASSISTED_ACTUAL) as DET_SPE_ASS_ASSISTED_ACTUAL,
  sum(OTHER_ALONE_ACTUAL) as OTHER_ALONE_ACTUAL,
  sum(OTHER_ASSISTED_ACTUAL) as OTHER_ASSISTED_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, ori, state_abbr, activity_name, activity_id
ORDER BY data_year, ori, state_abbr, activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_national AS
SELECT data_year,
  sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year
ORDER BY data_year;

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_regional AS
SELECT data_year,
  region_code,
  sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, region_code
ORDER BY data_year, region_code;

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_state AS
SELECT data_year,
  state_abbr,
  sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, state_abbr
ORDER BY data_year, state_abbr;

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_agency AS
SELECT data_year,
  ori,
  state_abbr,
  sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, ori, state_abbr
ORDER BY data_year, ori, state_abbr;

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_group_national AS
SELECT distinct a.population_group_code,
  a.population_group_desc,
  b.data_year,
  sum(b.FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(b.KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(b.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(b.OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.agency_data a
JOIN public.leoka_assault_data b on a.ori=b.ori
GROUP BY b.data_year, a.population_group_code, a.population_group_desc
ORDER BY b.data_year, a.population_group_code

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_group_regional AS
SELECT distinct a.population_group_code,
  a.population_group_desc,
  b.data_year,
  a.region_code,
  sum(b.FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(b.KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(b.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(b.OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.agency_data a
JOIN public.leoka_assault_data b on a.ori=b.ori
GROUP BY b.data_year, a.region_code, a.population_group_code, a.population_group_desc
ORDER BY b.data_year, a.region_code, a.population_group_code

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_group_state AS
SELECT distinct a.population_group_code,
  a.population_group_desc,
  b.data_year,
  a.state_abbr,
  sum(b.FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(b.KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(b.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(b.OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.agency_data a
JOIN public.leoka_assault_data b on a.ori=b.ori
GROUP BY b.data_year, a.state_abbr, a.population_group_code, a.population_group_desc
ORDER BY b.data_year, a.state_abbr, a.population_group_code

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_activity_national AS
SELECT data_year,
  activity_name,
  activity_id,
  sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, activity_name, activity_id
ORDER BY data_year, activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_activity_regional AS
SELECT data_year,
  region_code,
  activity_name,
  activity_id,
  sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, region_code, activity_name, activity_id
ORDER BY data_year, region_code, activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_activity_state AS
SELECT data_year,
  state_abbr,
  activity_name,
  activity_id,
  sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, state_abbr, activity_name, activity_id
ORDER BY data_year, state_abbr, activity_id;

CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_activity_agency AS
SELECT data_year,
  ori,
  state_abbr,
  activity_name,
  activity_id,
  sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
  sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
  sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
  sum(OTHER_ACTUAL) as OTHER_ACTUAL
FROM public.leoka_assault_data
GROUP BY data_year, ori, state_abbr, activity_name, activity_id
ORDER BY data_year, ori, state_abbr, activity_id;

 -- Drops
 drop MATERIALIZED VIEW leoka_assault_by_group_national;
 drop MATERIALIZED VIEW leoka_assault_by_group_regional;
 drop MATERIALIZED VIEW leoka_assault_by_group_state;
 drop MATERIALIZED VIEW leoka_assault_by_assign_dist_national;
 drop MATERIALIZED VIEW leoka_assault_by_assign_dist_regional;
 drop MATERIALIZED VIEW leoka_assault_by_assign_dist_state;
 drop MATERIALIZED VIEW leoka_assault_by_assign_dist_agency;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_national;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_regional;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_state;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_agency;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_per_group_national;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_per_group_regional;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_per_group_state;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_per_activity_national;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_per_activity_regional;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_per_activity_state;
 drop MATERIALIZED VIEW leoka_assault_by_weapon_per_activity_agency;

 --Refreshes
 refresh MATERIALIZED VIEW leoka_assault_by_group_national;
 refresh MATERIALIZED VIEW leoka_assault_by_group_regional;
 refresh MATERIALIZED VIEW leoka_assault_by_group_state;
 refresh MATERIALIZED VIEW leoka_assault_by_assign_dist_national;
 refresh MATERIALIZED VIEW leoka_assault_by_assign_dist_regional;
 refresh MATERIALIZED VIEW leoka_assault_by_assign_dist_state;
 refresh MATERIALIZED VIEW leoka_assault_by_assign_dist_agency;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_national;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_regional;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_state;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_agency;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_per_group_national;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_per_group_regional;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_per_group_state;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_per_activity_national;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_per_activity_regional;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_per_activity_state;
 refresh MATERIALIZED VIEW leoka_assault_by_weapon_per_activity_agency;
