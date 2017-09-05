declare -a arr_years=("2020" "2019" "2018" "2017" "2016")
declare -a arr_states=("10" "48" "25" "7" "38" "34" "43" "47" "21" "15" "18" "2" "35" "41" "37" "6" "11" "36" "14" "3" "5" "28" "20" "16" "40" "8" "1" "13" "42" "46" "17" "12" "23" "26" "33" "24" "45" "44" "39")

declare -a arr_state_map_full=(["10"]="GA" ["41"]="TN" ["16"]="KY" ["33"]="ND" ["6"]="CT" ["42"]="TX" ["43"]="UT" ["34"]="OH" ["21"]="MI" ["1"]="AL" ["23"]="MS" ["3"]="AR" ["37"]="PA" ["2"]="AZ" ["14"]="IA" ["5"]="CO" ["12"]="IL" ["39"]="SC" ["48"]="WI" ["11"]="ID" ["24"]="MO" ["36"]="OR" ["18"]="ME" ["20"]="MA" ["45"]="VA" ["47"]="WV" ["7"]="DE" ["28"]="NH" ["25"]="MT" ["17"]="LA" ["35"]="OK" ["8"]="DC" ["13"]="IN" ["46"]="WA" ["15"]="KS" ["44"]="VT" ["26"]="NE" ["38"]="RI" ["40"]="SD")

for i in "${arr_years[@]}"
    do
    mkdir -p nibrs-$i

    for k in "${arr_states[@]}"
    do

    cf connect-to-service crime-data-api crime-data-upload-db <<EOF
SET work_mem='3GB';
\copy (SELECT incident_id as incident_key, ori, race_code, sex_code, age_num, location_name from nibrs_offender_denorm where year='$i' and state_code::integer=$k) To 'offender.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id as incident_key, ori, race_code, sex_code, age_num, ethnicity, location_name from nibrs_victim_denorm where year='$i' and state_code::integer=$k) To 'victim.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id as incident_key, ori, offense_name, offense_id, location_name, weapon_name, bias_name, attempt_complete_flag, suspected_using from nibrs_offense_denorm where year='$i' and state_code::integer=$k) To 'offense.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id as incident_key, ori, prop_desc_name, date_recovered, property_value, stolen_count, drug_measure_name, drug_measure_code, est_drug_qty from nibrs_property_denorm where year='$i' and state_code::integer=$k) To 'property.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id as incident_key, ori, COALESCE(to_char(incident_date, 'MM/DD/YYYY HH24:MI:SS'),'') as incident_date from nibrs_incident_denorm where year='$i' and state_code::integer=$k) To 'incident.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id as incident_key, ori, arrest_type_name, age_num, sex_code, race_code, arrest_type_code, COALESCE(to_char(arrest_date, 'MM/DD/YYYY HH24:MI:SS'),'') as arrest_date, ethnicity, clearance_ind, under_18_disposition_code, resident_status  from nibrs_arrestee_denorm where year='$i' and state_code::integer=$k) To 'arrestee.csv' With CSV DELIMITER ',' HEADER;
EOF
    
    mkdir -p ${arr_state_map_full[$k]}-$i
    # TODO. Generate county/agency ONCE, and then 
    mv offender.csv ${arr_state_map_full[$k]}-$i
    mv victim.csv ${arr_state_map_full[$k]}-$i
    mv offense.csv ${arr_state_map_full[$k]}-$i
    mv property.csv ${arr_state_map_full[$k]}-$i
    mv incident.csv ${arr_state_map_full[$k]}-$i
    mv arrestee.csv ${arr_state_map_full[$k]}-$i
    ditto  -c -k --sequesterRsrc --keepParent ${arr_state_map_full[$k]}-$i ${arr_state_map_full[$k]}-$i.zip
    rm -rf ${arr_state_map_full[$k]}-$i

    done
    mv *.zip nibrs-$i
    cp NIBRS_README.txt nibrs-$i
    cp NIBRS_DATA_DICT.csv nibrs-$i
done

#\copy (select data_year,state_postal_abbr, sum(leoka_assault) as assault, sum(leoka_felony) as felony, sum(leoka_accident) as accident from reta_month JOIN ref_agency on (reta_month.agency_id = ref_agency.agency_id) JOIN ref_state ON (ref_agency.state_id = ref_state.state_id) group by data_year, state_postal_abbr) To 'leoka_assaults_full.csv' With CSV DELIMITER ',' HEADER;

    cf connect-to-service crime-data-api crime-data-upload-db <<EOF
SET work_mem='3GB';
\copy (select ref_state.state_postal_abbr, LM.DATA_YEAR, sum(LM.LEOKA_FELONY) as felony, sum(LM.LEOKA_ACCIDENT) as accident from LKASUM_MONTH LM JOIN ref_agency RA ON RA.agency_id = LM.agency_id join ref_state on (RA.state_id = ref_state.state_id) GROUP BY data_year, ref_state.state_postal_abbr ) To 'lka_sum_full.csv' with CSV DELIMITER ',' HEADER;

CREATE TEMP TABLE pe_temp AS SELECT qe.state_postal_abbr as state_postal_abbr, qe.data_year as data_year, qe.officer_count as officer_count, round( ( (qe.officer_count / population) * 1000)::numeric, 2) as officer_rate_per_1000,
     qe.civilian_count as civilian_count, round( ( (qe.civilian_count / population) * 1000)::numeric, 2) as civilian_rate_per_1000,
     population from (SELECT
        (SELECT state_postal_abbr from ref_state where ref_agency.state_id = ref_state.state_id limit 1) as state_postal_abbr,
        (SELECT population from ref_state_population where ref_agency.state_id = ref_state_population.state_id and pe_employee_data.data_year = ref_state_population.data_year limit 1) as population,
        pe_employee_data.data_year,
        SUM(COALESCE(male_officer) + COALESCE(female_officer)) as officer_count,
        SUM( COALESCE(female_civilian) + COALESCE(male_civilian) ) as civilian_count
        from pe_employee_data JOIN ref_agency ON (pe_employee_data.agency_id = ref_agency.agency_id
    ) GROUP BY ref_agency.state_id, pe_employee_data.data_year) qe where qe.population > 0 and qe.data_year > 1970 order by qe.data_year, qe.state_postal_abbr desc;

\copy ( SELECT * from pe_temp ) To 'pe_employee_data.csv' With CSV DELIMITER ',' HEADER;

\copy (SELECT ref_state.state_postal_abbr, year, prop_desc_name as property_type, stolen_value, recovered_value from ct_counts JOIN ref_state ON (ref_state.state_id = ct_counts.state_id) WHERE ct_counts.state_id IS NOT NULL and ori IS NULL) To 'cargo_theft.csv' with CSV DELIMITER ',' HEADER;

\copy (select year, state_name, total_agencies, participating_agencies, round(CAST(participation_rate*100 AS NUMERIC), 2) participation_pct, nibrs_participating_agencies, round(CAST(nibrs_participation_rate*100 AS NUMERIC), 2) nibrs_participation_pct, covered_agencies, ROUND(CAST(covered_rate*100 AS NUMERIC), 2) AS covered_pct, total_population, participating_population nibrs_participating_population from participation_rates WHERE state_id IS NOT NULL and county_id IS NULL ORDER by year DESC, state_name) TO 'ucr_participation.csv' with CSV DELIMITER ',' HEADER;

\copy (SELECT year, rs.state_name, t.state_abbr, locality, population, violent_crime, homicide, rape_legacy, rape_revised, robbery, aggravated_assault, property_crime, burglary, larceny, motor_vehicle_theft, arson, caveats from reta_territories t JOIN ref_state rs ON rs.state_postal_abbr=t.state_abbr order by state_name, locality, year) To 'territories.csv' with CSV DELIMITER ',' HEADER;

\copy (SELECT ori, legacy_ori, agency_name, agency_type_id, agency_type_name, city_name, state_abbr, primary_county, primary_county_fips, submitting_sai, submitting_name, submitting_state_abbr, start_year, dormant_year, current_year, revised_rape_start, population, population_group_code, population_group_desc, suburban_area_flag, core_city_flag, months_reported, nibrs_months_reported, past_10_years_reported, covered_by_ori, covered_by_name, staffing_year, total_officers, total_civilians from cde_agencies order by state_abbr, agency_name) To 'agencies.csv' with CSV DELIMITER ',' HEADER;

\copy (SELECT year, state_name, state_postal_abbr, population, agencies, round((CAST(months_reported AS numeric)/agencies), 2) avg_months_reported, sex_acts, sex_acts_cleared, sex_acts_juvenile_cleared, servitude, servitude_cleared, servitude_juvenile_cleared from ht_summary
       JOIN ref_state ON ref_state.state_postal_abbr=ht_summary.state_abbr
       WHERE year IS NOT NULL AND ori IS NULL ORDER by year, state_name) To 'human_trafficking.csv' with CSV DELIMITER ',' HEADER;

\copy (select * from asr_juvenile_crosstab where state_abbr IS NULL and year >= 1994 order by year DESC, offense_code) TO 'asr_national_juvenile.csv' with CSV DELIMITER ',' HEADER;
\copy (select * from asr_adult_crosstab where state_abbr IS NULL and year >= 1994 order by year DESC, offense_code) TO 'asr_national_adults.csv' with CSV DELIMITER ',' HEADER;
\copy (select * from asr_drug_crosstab where state_abbr IS NULL and year >= 1994 ORDER by year DESC) TO 'asr_national_drug.csv' with CSV DELIMITER ',' HEADER;
\copy (SELECT * from asr_national ORDER by year DESC) TO 'arrests_national.csv' with CSV DELIMITER ',' HEADER;
EOF

export S3_CREDENTIALS="`cf service-key fbi-cde-s3  colin-key | tail -n +2`"
export AWS_ACCESS_KEY_ID=`echo "${S3_CREDENTIALS}" | jq -r .access_key_id`
export AWS_SECRET_ACCESS_KEY=`echo "${S3_CREDENTIALS}" | jq -r .secret_access_key`
export BUCKET_NAME=`echo "${S3_CREDENTIALS}" | jq -r .bucket`
export AWS_DEFAULT_REGION=`echo "${S3_CREDENTIALS}" | jq -r '.region'`
aws s3 cp cargo_theft.csv s3://${BUCKET_NAME}/cargo_theft.csv
aws s3 cp lka_sum_full.csv s3://${BUCKET_NAME}/leoka.csv
aws s3 cp pe_employee_data.csv s3://${BUCKET_NAME}/pe_employee_data.csv
aws s3 cp ucr_participation.csv s3://${BUCKET_NAME}/ucr_participation.csv
aws s3 cp agencies.csv s3://${BUCKET_NAME}/agencies.csv
aws s3 cp territories.csv s3://${BUCKET_NAME}/territories.csv
aws s3 cp human_trafficking.csv s3://${BUCKET_NAME}/human_trafficking.csv
aws s3 cp asr_national_juvenile.csv s3://${BUCKET_NAME}/arrests_national_juvenile.csv
aws s3 cp asr_national_adults.csv s3://${BUCKET_NAME}/arrests_national_adults.csv
aws s3 cp asr_national_drug.csv s3://${BUCKET_NAME}/arrests_national_drug.csv
aws s3 cp arrests_national.csv s3://${BUCKET_NAME}/arrests_national.csv


for i in "${arr_years[@]}"
    aws s3 cp --recursive nibrs-$i/ s3://${BUCKET_NAME}/$i
done



