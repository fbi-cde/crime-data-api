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
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(a.hands_fists_feet_actual)+sum(a.other_actual) as group_1_actual_ct,
   sum(a.cleared_count) as group_1_cleared_ct
 FROM public.leoka_assault_activity_assignemnt_data a JOIN public.agency_data b on b.agency_id=a.agency_id
 WHERE b.population_group_code like '1%'
 GROUP BY a.data_year, a.activity_name, a.activity_id) table1
JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(a.hands_fists_feet_actual)+sum(a.other_actual) as group_2_actual_ct,
   sum(a.cleared_count) as group_2_cleared_ct
 FROM public.leoka_assault_activity_assignemnt_data a JOIN public.agency_data b on b.agency_id=a.agency_id
 WHERE b.population_group_code = '2'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table2 ON table1.activity_id=table2.activity_id
 JOIN (SELECT a.data_year,
   a.activity_name,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(a.hands_fists_feet_actual)+sum(a.other_actual) as group_3_actual_ct,
   sum(a.cleared_count) as group_3_cleared_ct
 FROM public.leoka_assault_activity_assignemnt_data a JOIN public.agency_data b on b.agency_id=a.agency_id
 WHERE b.population_group_code = '3'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table3 ON table1.activity_id=table3.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(a.hands_fists_feet_actual)+sum(a.other_actual) as group_4_actual_ct,
   sum(a.cleared_count) as group_4_cleared_ct
 FROM public.leoka_assault_activity_assignemnt_data a JOIN public.agency_data b on b.agency_id=a.agency_id
 WHERE b.population_group_code = '4'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table4 ON table1.activity_id=table4.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(a.hands_fists_feet_actual)+sum(a.other_actual) as group_5_actual_ct,
   sum(a.cleared_count) as group_5_cleared_ct
 FROM public.leoka_assault_activity_assignemnt_data a JOIN public.agency_data b on b.agency_id=a.agency_id
 WHERE b.population_group_code = '4'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table5 ON table1.activity_id=table5.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(a.hands_fists_feet_actual)+sum(a.other_actual) as group_6_actual_ct,
   sum(a.cleared_count) as group_6_cleared_ct
 FROM public.leoka_assault_activity_assignemnt_data a JOIN public.agency_data b on b.agency_id=a.agency_id
 WHERE b.population_group_code = '6'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table6 ON table1.activity_id=table6.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(a.hands_fists_feet_actual)+sum(a.other_actual) as group_7_actual_ct,
   sum(a.cleared_count) as group_7_cleared_ct
 FROM public.leoka_assault_activity_assignemnt_data a JOIN public.agency_data b on b.agency_id=a.agency_id
 WHERE b.population_group_code = '7'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table7 ON table1.activity_id=table7.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(a.hands_fists_feet_actual)+sum(a.other_actual) as group_8_actual_ct,
   sum(a.cleared_count) as group_8_cleared_ct
 FROM public.leoka_assault_activity_assignemnt_data a JOIN public.agency_data b on b.agency_id=a.agency_id
 WHERE b.population_group_code like '8%'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table8 ON table1.activity_id=table8.activity_id
 JOIN (SELECT a.data_year,
   a.activity_id,
   sum(a.firearm_actual)+sum(a.knife_actual)+sum(a.hands_fists_feet_actual)+sum(a.other_actual) as group_9_actual_ct,
   sum(a.cleared_count) as group_9_cleared_ct
 FROM public.leoka_assault_activity_assignemnt_data a JOIN public.agency_data b on b.agency_id=a.agency_id
 WHERE b.population_group_code like '9%'
 GROUP BY a.data_year, a.activity_name, a.activity_id
 ) table9 ON table1.activity_id=table9.activity_id
 ORDER BY activity_id;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_group_regional_totals AS
 select lc.data_year, lc.activity_name, lc.activity_id, a.region_name,a.region_code,a.population_group_code,
 sum(lc.firearm_actual)+sum(lc.knife_actual)+sum(lc.hands_fists_feet_actual)+sum(lc.other_actual) as group_count,
 sum(lc.cleared_count) as cleared_count
 FROM public.leoka_assault_activity_assignemnt_data lc
 JOIN public.agency_data a on a.agency_id=lc.agency_id
 GROUP BY lc.data_year, a.region_code,a.region_name,lc.activity_name, lc.activity_id, a.population_group_code
 ORDER BY lc.data_year, lc.activity_id;


 CREATE MATERIALIZED VIEW public.leoka_assault_by_group_regional AS
 SELECT
    data_year,
    region_code,
    region_name,
    activity_id,
    activity_name,
    sum(CASE WHEN population_group_code like '1%' then group_count else 0 end) as group_1_actual_ct,
    sum(CASE WHEN population_group_code like '1%' then cleared_count else 0 end) as group_1_cleared_ct,
    sum(CASE WHEN population_group_code like '2%' then group_count else 0 end) as group_2_actual_ct,
    sum(CASE WHEN population_group_code like '2%' then cleared_count else 0 end) as group_2_cleared_ct,
    sum(CASE WHEN population_group_code like '3%' then group_count else 0 end) as group_3_actual_ct,
    sum(CASE WHEN population_group_code like '3%' then cleared_count else 0 end) as group_3_cleared_ct,
    sum(CASE WHEN population_group_code like '4%' then group_count else 0 end) as group_4_actual_ct,
    sum(CASE WHEN population_group_code like '4%' then cleared_count else 0 end) as group_4_cleared_ct,
    sum(CASE WHEN population_group_code like '5%' then group_count else 0 end) as group_5_actual_ct,
    sum(CASE WHEN population_group_code like '5%' then cleared_count else 0 end) as group_5_cleared_ct,
    sum(CASE WHEN population_group_code like '6%' then group_count else 0 end) as group_6_actual_ct,
    sum(CASE WHEN population_group_code like '6%' then cleared_count else 0 end) as group_6_cleared_ct,
    sum(CASE WHEN population_group_code like '7%' then group_count else 0 end) as group_7_actual_ct,
    sum(CASE WHEN population_group_code like '7%' then cleared_count else 0 end) as group_7_cleared_ct,
    sum(CASE WHEN population_group_code like '8%' then group_count else 0 end) as group_8_actual_ct,
    sum(CASE WHEN population_group_code like '8%' then cleared_count else 0 end) as group_8_cleared_ct,
    sum(CASE WHEN population_group_code like '9%' then group_count else 0 end) as group_9_actual_ct,
    sum(CASE WHEN population_group_code like '9%' then cleared_count else 0 end) as group_9_cleared_ct
 from public.leoka_assault_by_group_regional_totals
 group by data_year, region_code,region_name,activity_id,activity_name
 ORDER BY data_year, activity_id,region_code;


 CREATE MATERIALIZED VIEW public.leoka_assault_by_group_state_totals AS
 select lc.data_year, lc.activity_name, lc.activity_id, a.state_abbr,a.state_id,a.population_group_code,
 sum(lc.firearm_actual)+sum(lc.knife_actual)+sum(lc.hands_fists_feet_actual)+sum(lc.other_actual) as group_count,
 sum(lc.cleared_count) as cleared_count
 FROM public.leoka_assault_activity_assignemnt_data lc
 JOIN public.agency_data a on a.agency_id=lc.agency_id
 GROUP BY lc.data_year, a.state_abbr,a.state_id,lc.activity_name, lc.activity_id, a.population_group_code
 ORDER BY lc.data_year, lc.activity_id;


 CREATE MATERIALIZED VIEW public.leoka_assault_by_group_state AS
 SELECT
    data_year,
    state_abbr,
    state_id,
    activity_id,
    activity_name,
    sum(CASE WHEN population_group_code like '1%' then group_count else 0 end) as group_1_actual_ct,
    sum(CASE WHEN population_group_code like '1%' then cleared_count else 0 end) as group_1_cleared_ct,
    sum(CASE WHEN population_group_code like '2%' then group_count else 0 end) as group_2_actual_ct,
    sum(CASE WHEN population_group_code like '2%' then cleared_count else 0 end) as group_2_cleared_ct,
    sum(CASE WHEN population_group_code like '3%' then group_count else 0 end) as group_3_actual_ct,
    sum(CASE WHEN population_group_code like '3%' then cleared_count else 0 end) as group_3_cleared_ct,
    sum(CASE WHEN population_group_code like '4%' then group_count else 0 end) as group_4_actual_ct,
    sum(CASE WHEN population_group_code like '4%' then cleared_count else 0 end) as group_4_cleared_ct,
    sum(CASE WHEN population_group_code like '5%' then group_count else 0 end) as group_5_actual_ct,
    sum(CASE WHEN population_group_code like '5%' then cleared_count else 0 end) as group_5_cleared_ct,
    sum(CASE WHEN population_group_code like '6%' then group_count else 0 end) as group_6_actual_ct,
    sum(CASE WHEN population_group_code like '6%' then cleared_count else 0 end) as group_6_cleared_ct,
    sum(CASE WHEN population_group_code like '7%' then group_count else 0 end) as group_7_actual_ct,
    sum(CASE WHEN population_group_code like '7%' then cleared_count else 0 end) as group_7_cleared_ct,
    sum(CASE WHEN population_group_code like '8%' then group_count else 0 end) as group_8_actual_ct,
    sum(CASE WHEN population_group_code like '8%' then cleared_count else 0 end) as group_8_cleared_ct,
    sum(CASE WHEN population_group_code like '9%' then group_count else 0 end) as group_9_actual_ct,
    sum(CASE WHEN population_group_code like '9%' then cleared_count else 0 end) as group_9_cleared_ct
 from public.leoka_assault_by_group_state_totals
 group by data_year, state_abbr,state_id,activity_id,activity_name
 ORDER BY data_year, activity_id;

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
 FROM public.leoka_assault_activity_assignemnt_data
 GROUP BY data_year, activity_name, activity_id
 ORDER BY data_year, activity_id;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_assign_dist_regional AS
 SELECT a.data_year,
   b.region_code,
   b.region_name,
   a.activity_name,
   a.activity_id,
   sum(TWO_OFFICER_VEHICLE_ACTUAL) as TWO_OFFICER_VEHICLE_ACTUAL,
   sum(ONE_OFFICER_VEHICLE_ACTUAL) as ONE_OFFICER_VEHICLE_ACTUAL,
   sum(ONE_OFFICER_ASSISTED_ACTUAL) as ONE_OFFICER_ASSISTED_ACTUAL,
   sum(DET_SPE_ASS_ALONE_ACTUAL) as DET_SPE_ASS_ALONE_ACTUAL,
   sum(DET_SPE_ASS_ASSISTED_ACTUAL) as DET_SPE_ASS_ASSISTED_ACTUAL,
   sum(OTHER_ALONE_ACTUAL) as OTHER_ALONE_ACTUAL,
   sum(OTHER_ASSISTED_ACTUAL) as OTHER_ASSISTED_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data a
 JOIN public.agency_data b on b.agency_id=a.agency_id
 GROUP BY a.data_year, b.region_code, b.region_name,a.activity_name, a.activity_id
 ORDER BY a.data_year, b.region_code, b.region_name,a.activity_id;


 CREATE MATERIALIZED VIEW public.leoka_assault_by_assign_dist_state AS
 SELECT a.data_year,
   b.state_abbr,
   a.activity_name,
   a.activity_id,
   sum(TWO_OFFICER_VEHICLE_ACTUAL) as TWO_OFFICER_VEHICLE_ACTUAL,
   sum(ONE_OFFICER_VEHICLE_ACTUAL) as ONE_OFFICER_VEHICLE_ACTUAL,
   sum(ONE_OFFICER_ASSISTED_ACTUAL) as ONE_OFFICER_ASSISTED_ACTUAL,
   sum(DET_SPE_ASS_ALONE_ACTUAL) as DET_SPE_ASS_ALONE_ACTUAL,
   sum(DET_SPE_ASS_ASSISTED_ACTUAL) as DET_SPE_ASS_ASSISTED_ACTUAL,
   sum(OTHER_ALONE_ACTUAL) as OTHER_ALONE_ACTUAL,
   sum(OTHER_ASSISTED_ACTUAL) as OTHER_ASSISTED_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data a
 JOIN public.agency_data b on b.agency_id=a.agency_id
 GROUP BY a.data_year, b.state_abbr, b.state_id, a.activity_name,  a.activity_id
 ORDER BY  a.data_year, b.state_abbr,   b.state_id,a.activity_id;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_assign_dist_agency AS
 SELECT a.data_year,
   b.ori,
   b.agency_id,
   b.state_abbr,
   a.activity_name,
   a.activity_id,
   sum(a.TWO_OFFICER_VEHICLE_ACTUAL) as TWO_OFFICER_VEHICLE_ACTUAL,
   sum(a.ONE_OFFICER_VEHICLE_ACTUAL) as ONE_OFFICER_VEHICLE_ACTUAL,
   sum(a.ONE_OFFICER_ASSISTED_ACTUAL) as ONE_OFFICER_ASSISTED_ACTUAL,
   sum(a.DET_SPE_ASS_ALONE_ACTUAL) as DET_SPE_ASS_ALONE_ACTUAL,
   sum(a.DET_SPE_ASS_ASSISTED_ACTUAL) as DET_SPE_ASS_ASSISTED_ACTUAL,
   sum(a.OTHER_ALONE_ACTUAL) as OTHER_ALONE_ACTUAL,
   sum(a.OTHER_ASSISTED_ACTUAL) as OTHER_ASSISTED_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data a
 JOIN public.agency_data b on b.agency_id=a.agency_id
 GROUP BY a.data_year, b.ori, b.state_abbr, b.agency_id,a.activity_name, a.activity_id
 ORDER BY a.data_year, b.ori, b.state_abbr, a.activity_id;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_national AS
 SELECT data_year,
   sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data
 GROUP BY data_year
 ORDER BY data_year;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_regional AS
 SELECT a.data_year,
   b.region_code,
   b.region_name,
   sum(a.FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(a.KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(a.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(a.OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data a
 JOIN public.agency_data b on b.agency_id=a.agency_id
 GROUP BY a.data_year,  b.region_name,b.region_code
 ORDER BY a.data_year,  b.region_name,b.region_code;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_state AS
 SELECT a.data_year,
   b.state_abbr,
   b.state_id,
   sum(a.FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(a.KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(a.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(a.OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data a
 JOIN public.agency_data b on b.agency_id=a.agency_id
 GROUP BY a.data_year, b.state_abbr, b.state_id
 ORDER BY a.data_year, b.state_abbr, b.state_id;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_agency AS
 SELECT a.data_year,
   b.ori,
   b.agency_id,
   b.state_abbr,
   b.state_id,
   sum(a.FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(a.KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(a.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(a.OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data a
 JOIN public.agency_data b on b.agency_id=a.agency_id
 GROUP BY a.data_year, b.ori, b.state_abbr, b.state_id, b.agency_id
 ORDER BY a.data_year, b.ori, b.state_abbr, b.state_id, b.agency_id;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_group_national AS
 SELECT distinct a.population_group_code,
   a.population_group_desc,
   b.data_year,
   sum(b.FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(b.KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(b.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(b.OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.agency_data a
 JOIN public.leoka_assault_activity_assignemnt_data b on a.agency_id=b.agency_id
 GROUP BY b.data_year, a.population_group_code, a.population_group_desc
 ORDER BY b.data_year, a.population_group_code;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_group_regional AS
 SELECT distinct a.population_group_code,
   a.population_group_desc,
   b.data_year,
   a.region_code,
   a.region_name,
   sum(b.FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(b.KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(b.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(b.OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.agency_data a
 JOIN public.leoka_assault_activity_assignemnt_data b on a.agency_id=b.agency_id
 GROUP BY b.data_year, a.region_code,a.region_name, a.population_group_code, a.population_group_desc
 ORDER BY b.data_year, a.region_code, a.region_name,a.population_group_code;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_group_state AS
 SELECT distinct a.population_group_code,
   a.population_group_desc,
   b.data_year,
   a.state_abbr,
   a.state_id,
   sum(b.FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(b.KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(b.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(b.OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.agency_data a
 JOIN public.leoka_assault_activity_assignemnt_data b on a.agency_id=b.agency_id
 GROUP BY b.data_year, a.state_abbr,  a.state_id, a.population_group_code, a.population_group_desc
 ORDER BY b.data_year, a.state_abbr,   a.state_id,a.population_group_code;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_activity_national AS
 SELECT data_year,
   activity_name,
   activity_id,
   sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data
 GROUP BY data_year, activity_name, activity_id
 ORDER BY data_year, activity_id;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_activity_regional AS
 SELECT a.data_year,
   b.region_code,
   b.region_name,
   a.activity_name,
   a.activity_id,
   sum(a.FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(a.KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(a.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(a.OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data a
 JOIN public.agency_data b on b.agency_id=a.agency_id
 GROUP BY a.data_year, b.region_code, b.region_name, a.activity_name, a.activity_id
 ORDER BY a.data_year, b.region_code,b.region_name, a.activity_id;


 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_activity_state AS
 SELECT a.data_year,
   b.state_abbr,
   b.state_id,
   a.activity_name,
   a.activity_id,
   sum(FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data a
 JOIN public.agency_data b on b.agency_id=a.agency_id
 GROUP BY a.data_year, b.state_abbr, b.state_id,a.activity_name, a.activity_id
 ORDER BY a.data_year, b.state_abbr, b.state_id,a.activity_id;

 CREATE MATERIALIZED VIEW public.leoka_assault_by_weapon_per_activity_agency AS
 SELECT a.data_year,
   b.ori,
   b.agency_id,
   b.state_abbr,
   b.state_id,
   a.activity_name,
   a.activity_id,
   sum(a.FIREARM_ACTUAL) as FIREARM_ACTUAL,
   sum(a.KNIFE_ACTUAL) as KNIFE_ACTUAL,
   sum(a.HANDS_FISTS_FEET_ACTUAL) as HANDS_FISTS_FEET_ACTUAL,
   sum(a.OTHER_ACTUAL) as OTHER_ACTUAL
 FROM public.leoka_assault_activity_assignemnt_data a
 JOIN public.agency_data b on b.agency_id=a.agency_id
 GROUP BY a.data_year, b.ori,b.agency_id, b.state_abbr, b.state_id,a.activity_name, a.activity_id
 ORDER BY a.data_year, b.ori, b.agency_id , b.state_abbr, b.state_id,a.activity_id;


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
