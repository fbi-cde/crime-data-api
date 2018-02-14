CREATE MATERIALIZED VIEW public.asr_age_male_count_agency AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  asr.AGENCY_ID as agency_id,
  agy.ori as ori,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(M_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_13_TO_14_ARR_CNT)+sum(M_AGE_15_ARR_CNT)+sum(M_AGE_16_ARR_CNT)+sum(M_AGE_17_ARR_CNT)+sum(M_AGE_18_ARR_CNT)+sum(M_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(M_AGE_20_ARR_CNT)+sum(M_AGE_21_ARR_CNT)+sum(M_AGE_22_ARR_CNT)+sum(M_AGE_23_ARR_CNT)+sum(M_AGE_24_ARR_CNT)+sum(M_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(M_AGE_30_TO_34_ARR_CNT)+sum(M_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(M_AGE_40_TO_44_ARR_CNT)+sum(M_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(M_AGE_50_TO_54_ARR_CNT)+sum(M_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(M_AGE_60_TO_64_ARR_CNT)+sum(M_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,asr.agency_id,ori
order by asr.data_year,ori,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_male_count_state AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  agy.STATE_ABBR as state_abbr,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(M_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_13_TO_14_ARR_CNT)+sum(M_AGE_15_ARR_CNT)+sum(M_AGE_16_ARR_CNT)+sum(M_AGE_17_ARR_CNT)+sum(M_AGE_18_ARR_CNT)+sum(M_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(M_AGE_20_ARR_CNT)+sum(M_AGE_21_ARR_CNT)+sum(M_AGE_22_ARR_CNT)+sum(M_AGE_23_ARR_CNT)+sum(M_AGE_24_ARR_CNT)+sum(M_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(M_AGE_30_TO_34_ARR_CNT)+sum(M_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(M_AGE_40_TO_44_ARR_CNT)+sum(M_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(M_AGE_50_TO_54_ARR_CNT)+sum(M_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(M_AGE_60_TO_64_ARR_CNT)+sum(M_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,state_abbr
order by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_male_count_region AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  agy.region_name as region_name,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(M_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_13_TO_14_ARR_CNT)+sum(M_AGE_15_ARR_CNT)+sum(M_AGE_16_ARR_CNT)+sum(M_AGE_17_ARR_CNT)+sum(M_AGE_18_ARR_CNT)+sum(M_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(M_AGE_20_ARR_CNT)+sum(M_AGE_21_ARR_CNT)+sum(M_AGE_22_ARR_CNT)+sum(M_AGE_23_ARR_CNT)+sum(M_AGE_24_ARR_CNT)+sum(M_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(M_AGE_30_TO_34_ARR_CNT)+sum(M_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(M_AGE_40_TO_44_ARR_CNT)+sum(M_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(M_AGE_50_TO_54_ARR_CNT)+sum(M_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(M_AGE_60_TO_64_ARR_CNT)+sum(M_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,region_name
order by asr.data_year,region_name,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_male_count_national AS
SELECT asr.DATA_YEAR as DATA_YEAR,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(M_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_13_TO_14_ARR_CNT)+sum(M_AGE_15_ARR_CNT)+sum(M_AGE_16_ARR_CNT)+sum(M_AGE_17_ARR_CNT)+sum(M_AGE_18_ARR_CNT)+sum(M_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(M_AGE_20_ARR_CNT)+sum(M_AGE_21_ARR_CNT)+sum(M_AGE_22_ARR_CNT)+sum(M_AGE_23_ARR_CNT)+sum(M_AGE_24_ARR_CNT)+sum(M_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(M_AGE_30_TO_34_ARR_CNT)+sum(M_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(M_AGE_40_TO_44_ARR_CNT)+sum(M_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(M_AGE_50_TO_54_ARR_CNT)+sum(M_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(M_AGE_60_TO_64_ARR_CNT)+sum(M_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_female_count_agency AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  asr.AGENCY_ID as agency_id,
  agy.ori as ori,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(F_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_13_TO_14_ARR_CNT)+sum(F_AGE_15_ARR_CNT)+sum(F_AGE_16_ARR_CNT)+sum(F_AGE_17_ARR_CNT)+sum(F_AGE_18_ARR_CNT)+sum(F_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(F_AGE_20_ARR_CNT)+sum(F_AGE_21_ARR_CNT)+sum(F_AGE_22_ARR_CNT)+sum(F_AGE_23_ARR_CNT)+sum(F_AGE_24_ARR_CNT)+sum(F_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(F_AGE_30_TO_34_ARR_CNT)+sum(F_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(F_AGE_40_TO_44_ARR_CNT)+sum(F_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(F_AGE_50_TO_54_ARR_CNT)+sum(F_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(F_AGE_60_TO_64_ARR_CNT)+sum(F_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,asr.agency_id,ori
order by asr.data_year,ori,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_female_count_state AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  agy.STATE_ABBR as state_abbr,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(F_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_13_TO_14_ARR_CNT)+sum(F_AGE_15_ARR_CNT)+sum(F_AGE_16_ARR_CNT)+sum(F_AGE_17_ARR_CNT)+sum(F_AGE_18_ARR_CNT)+sum(F_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(F_AGE_20_ARR_CNT)+sum(F_AGE_21_ARR_CNT)+sum(F_AGE_22_ARR_CNT)+sum(F_AGE_23_ARR_CNT)+sum(F_AGE_24_ARR_CNT)+sum(F_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(F_AGE_30_TO_34_ARR_CNT)+sum(F_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(F_AGE_40_TO_44_ARR_CNT)+sum(F_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(F_AGE_50_TO_54_ARR_CNT)+sum(F_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(F_AGE_60_TO_64_ARR_CNT)+sum(F_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,state_abbr
order by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_female_count_region AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  agy.region_name as region_name,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(F_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_13_TO_14_ARR_CNT)+sum(F_AGE_15_ARR_CNT)+sum(F_AGE_16_ARR_CNT)+sum(F_AGE_17_ARR_CNT)+sum(F_AGE_18_ARR_CNT)+sum(F_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(F_AGE_20_ARR_CNT)+sum(F_AGE_21_ARR_CNT)+sum(F_AGE_22_ARR_CNT)+sum(F_AGE_23_ARR_CNT)+sum(F_AGE_24_ARR_CNT)+sum(F_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(F_AGE_30_TO_34_ARR_CNT)+sum(F_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(F_AGE_40_TO_44_ARR_CNT)+sum(F_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(F_AGE_50_TO_54_ARR_CNT)+sum(F_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(F_AGE_60_TO_64_ARR_CNT)+sum(F_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,region_name
order by asr.data_year,region_name,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_female_count_national AS
SELECT asr.DATA_YEAR as DATA_YEAR,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(F_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_13_TO_14_ARR_CNT)+sum(F_AGE_15_ARR_CNT)+sum(F_AGE_16_ARR_CNT)+sum(F_AGE_17_ARR_CNT)+sum(F_AGE_18_ARR_CNT)+sum(F_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(F_AGE_20_ARR_CNT)+sum(F_AGE_21_ARR_CNT)+sum(F_AGE_22_ARR_CNT)+sum(F_AGE_23_ARR_CNT)+sum(F_AGE_24_ARR_CNT)+sum(F_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(F_AGE_30_TO_34_ARR_CNT)+sum(F_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(F_AGE_40_TO_44_ARR_CNT)+sum(F_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(F_AGE_50_TO_54_ARR_CNT)+sum(F_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(F_AGE_60_TO_64_ARR_CNT)+sum(F_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_race_count_agency AS
                SELECT DATA_YEAR as DATA_YEAR,
                AGENCY_ID as agency_id,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data group by data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,agency_id;

CREATE MATERIALIZED VIEW public.asr_race_count_state AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                agy.state_abbr as state_abbr,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,state_abbr,offense_subcat_id;

CREATE MATERIALIZED VIEW public.asr_race_count_region AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                agy.region_name as region_name,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,region_name,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,region_name,offense_subcat_id;

CREATE MATERIALIZED VIEW public.asr_race_count_national AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,offense_subcat_id;

CREATE MATERIALIZED VIEW public.asr_race_yth_count_agency AS
                SELECT DATA_YEAR as DATA_YEAR,
                AGENCY_ID as agency_id,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_YTH_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_YTH_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_YTH_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_YTH_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_YTH_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_YTH_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_YTH_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_YTH_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_YTH_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_YTH_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_YTH_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_YTH_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data group by data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,agency_id;

CREATE MATERIALIZED VIEW public.asr_race_yth_count_state AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                agy.state_abbr as state_abbr,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_YTH_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_YTH_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_YTH_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_YTH_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_YTH_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_YTH_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_YTH_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_YTH_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_YTH_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_YTH_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_YTH_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_YTH_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME;

CREATE MATERIALIZED VIEW public.asr_race_yth_count_region AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                agy.region_name as region_name,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_YTH_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_YTH_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_YTH_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_YTH_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_YTH_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_YTH_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_YTH_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_YTH_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_YTH_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_YTH_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_YTH_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_YTH_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,region_name,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,region_name,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME;

CREATE MATERIALIZED VIEW public.asr_race_yth_count_national AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_YTH_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_YTH_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_YTH_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_YTH_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_YTH_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_YTH_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_YTH_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_YTH_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_YTH_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_YTH_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_YTH_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_YTH_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME;
