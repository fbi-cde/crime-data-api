-- Indexes corresponding to foreign keys
CREATE INDEX ON nibrs_incident(cleared_except_id);
CREATE INDEX ON nibrs_incident(nibrs_month_id);
CREATE INDEX ON nibrs_offense(location_id);
CREATE INDEX ON nibrs_offense(offense_type_id);
CREATE INDEX ON nibrs_offender(age_id);
CREATE INDEX ON nibrs_offender(ethnicity_id);
CREATE INDEX ON nibrs_offender(race_id);
CREATE INDEX ON nibrs_victim(activity_type_id);
CREATE INDEX ON nibrs_victim(age_id);
CREATE INDEX ON nibrs_victim(assignment_type_id);
CREATE INDEX ON nibrs_victim(ethnicity_id);
CREATE INDEX ON nibrs_victim(race_id);
CREATE INDEX ON nibrs_victim(victim_type_id);
CREATE INDEX ON nibrs_property_desc(property_id);
CREATE INDEX ON nibrs_property_desc(prop_desc_id);
CREATE INDEX ON nibrs_property(prop_loss_id);
CREATE INDEX ON nibrs_victim_offense(offense_id);
CREATE INDEX ON reta_month_offense_subcat(reta_month_id);
CREATE INDEX ON nibrs_arrestee(age_id);
CREATE INDEX ON nibrs_arrestee(arrest_type_id);
CREATE INDEX ON nibrs_arrestee(ethnicity_id);
CREATE INDEX ON nibrs_arrestee(offense_type_id);
CREATE INDEX ON nibrs_arrestee(race_id);
CREATE INDEX ON nibrs_victim_offender_rel(offender_id);
CREATE INDEX ON nibrs_victim_offender_rel(relationship_id);
CREATE INDEX ON nibrs_victim_offender_rel(victim_id);
CREATE INDEX ON nibrs_suspected_drug(drug_measure_type_id);
CREATE INDEX ON nibrs_suspected_drug(property_id);
CREATE INDEX ON nibrs_arrestee_weapon(arrestee_id);
CREATE INDEX ON nibrs_arrestee_weapon(weapon_id);
CREATE INDEX ON nibrs_victim_injury(injury_id);
CREATE INDEX ON nibrs_month(agency_id);
CREATE INDEX ON reta_month(agency_id);

-- Searchable text files need lowercased indexes
CREATE INDEX ON reta_offense_category (LOWER(offense_category_name));
CREATE INDEX ON offense_classification (LOWER(classification_name));
CREATE INDEX ON reta_offense (classification_id);
CREATE INDEX ON reta_offense (LOWER(offense_name));
CREATE INDEX ON reta_offense_subcat (LOWER(offense_subcat_name));
CREATE INDEX ON ref_state (LOWER (state_abbr));
CREATE INDEX ON ref_city (LOWER (city_name));

-- assorted
CREATE INDEX ON reta_offense (classification_id);
CREATE INDEX ON ref_agency (state_id);
CREATE INDEX ON ref_agency (city_id);
CREATE INDEX ON nibrs_incident(agency_id);
