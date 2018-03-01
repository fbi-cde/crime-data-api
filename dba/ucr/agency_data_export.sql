select distinct RDAY.YEARLY_AGENCY_ID,
        RDAY.AGENCY_ID,                     -- Internal agency ID. Generated from AGENCY_ID_SEQ.
        RDAY.DATA_YEAR,
        RDAY.ORI,
        RDAY.LEGACY_ORI,
        RDAY.COVERED_BY_LEGACY_ORI,
        RDAY.DIRECT_CONTRIBUTOR_FLAG,
        RDAY.DORMANT_FLAG,
        RDAY.DORMANT_YEAR,
        RDAY.REPORTING_TYPE,
        RDAY.UCR_AGENCY_NAME,
        RDAY.NCIC_AGENCY_NAME,
        RDAY.PUB_AGENCY_NAME,
        RDAY.PUB_AGENCY_UNIT,
        RDAY.AGENCY_STATUS,
        RDAY.STATE_ID,
        RDAY.STATE_NAME,
        RDAY.STATE_ABBR,
        RDAY.STATE_POSTAL_ABBR,
        RDAY.DIVISION_CODE,
        RDAY.DIVISION_NAME,
        RDAY.REGION_CODE,
        RDAY.REGION_NAME,
        RDAY.REGION_DESC,
        RDAY.AGENCY_TYPE_NAME,
        RDAY.POPULATION,
        RDAY.SUBMITTING_AGENCY_ID,
        RDAY.SAI,
        RDAY.SUBMITTING_AGENCY_NAME,
        RDAY.SUBURBAN_AREA_FLAG,
        RDAY.POPULATION_GROUP_ID,
        RDAY.POPULATION_GROUP_CODE,
        RDAY.POPULATION_GROUP_DESC,
        RDAY.PARENT_POP_GROUP_CODE,
        RDAY.PARENT_POP_GROUP_DESC,
        RDAY.MIP_FLAG,
        RDAY.POP_SORT_ORDER,
        RDAY.SUMMARY_RAPE_DEF,
        RDAY.PE_REPORTED_FLAG,
        RDAY.PE_OFFICER_COUNT,
        RDAY.PE_CIVILIAN_COUNT,
        PED.MALE_OFFICER,                   --Number of full time male officers
        PED.MALE_CIVILIAN,                  --Number of full time male civilian employees
        PED.MALE_TOTAL,
        PED.FEMALE_OFFICER,                 --Number of full time female officers
        PED.FEMALE_CIVILIAN,                --Number of full time female civilian employees
        PED.FEMALE_TOTAL,
        PED.OFFICER_RATE,                   --Number of officers per 1,000 people should be calculated
        PED.EMPLOYEE_RATE,                  --Number of employees per 1,000 people should be calculated
        RDAY.NIBRS_CERT_DATE,
        RDAY.NIBRS_START_DATE,
        RDAY.NIBRS_LEOKA_START_DATE,
        RDAY.NIBRS_CT_START_DATE,
        RDAY.NIBRS_MULTI_BIAS_START_DATE,
        RDAY.NIBRS_OFF_ETH_START_DATE,
        RDAY.COVERED_FLAG,
        RDAY.COUNTY_NAME,
        RDAY.MSA_NAME,
        RDAY.PUBLISHABLE_FLAG,
        (CASE WHEN RDAY.agency_id = RM.agency_id and RDAY.data_year = RM.data_year AND RM.reported_flag = 'Y' then 'Y' else 'N' END) as participated,
        (CASE WHEN RDAY.agency_id = NM.agency_id and RDAY.data_year = NM.data_year AND (NM.REPORTED_STATUS = 'I' or NM.REPORTED_STATUS = 'Z') then 'Y' else 'N' END) as nibrs_participated
from REF_DIM_AGENCY_YEARLY RDAY
left join PE_EMPLOYEE_DATA PED on RDAY.AGENCY_ID = PED.AGENCY_ID and RDAY.DATA_YEAR = PED.DATA_YEAR
left join RETA_MONTH RM on RDAY.AGENCY_ID = RM.AGENCY_ID and RDAY.DATA_YEAR = RM.DATA_YEAR
left join NIBRS_MONTH NM on RDAY.AGENCY_ID = NM.AGENCY_ID and RDAY.DATA_YEAR = NM.DATA_YEAR
order by RDAY.AGENCY_ID;