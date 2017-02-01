declare -a arr_years=("2014")
declare -a arr_states=(39)

# County + Agencies Metadata. Generate only once.
#\copy (SELECT ori, ucr_agency_name from ref_agency) To 'agency.csv' With CSV DELIMITER ',' HEADER;
#\copy (SELECT ori, county_fips_code from ref_county JOIN ref_agency_county ON (ref_agency_county.county_id = ref_county.county_id) JOIN ref_agency ON (ref_agency_county.agency_id = ref_agency.agency_id) ) To 'county.csv' With CSV DELIMITER ',' HEADER;


for i in "${arr_years[@]}"
do
    for j in "${arr_states[@]}"
    do
    cf connect-to-service crime-data-api crime-data-upload-db <<EOF
\copy (SELECT incident_id, ori, race_code, sex_code, age_num, location_name from nibrs_offender_denorm where year='$i' and state_id=$j limit 10000000) To 'offender.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id, ori, race_code, sex_code, age_num, location_name from nibrs_victim_denorm where year='$i' and state_id=$j limit 1000000) To 'victim.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id, ori, offense_name, location_name, weapon_name  from nibrs_offense_denorm where year='$i' and state_id=$j limit 1000000) To 'offense.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id, ori, prop_desc_name from nibrs_property_denorm where year='$i' and state_id=$j limit 1000000) To 'property.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id, ori, incident_date from nibrs_incident_denorm where year='$i' and state_id=$j limit 1000000) To 'incident.csv' With CSV DELIMITER ',' HEADER;
\copy (SELECT incident_id, ori,  arrest_type_name, age_num, sex_code, race_code from nibrs_arrestee_denorm where year='$i' and state_id=$j limit 1000000) To 'arrestee.csv' With CSV DELIMITER ',' HEADER;
EOF
    
    mkdir -p $j-$i
    # TODO. Generate county/agency ONCE, and then 
    cp agency.csv $j-$i
    cp county.csv $j-$i
    mv offender.csv $j-$i
    mv victim.csv $j-$i
    mv offense.csv $j-$i
    
    mv property.csv $j-$i
    mv incident.csv $j-$i
    mv arrestee.csv $j-$i
    ditto  -c -k --sequesterRsrc --keepParent $j-$i $j-$i.zip
    rm -rf $j-$i

    done
done