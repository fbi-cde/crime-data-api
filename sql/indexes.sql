-- Index names are used to make this script idempotent (you can safely re-run it)
-- Some index names seem inconsistent.  Cleanup would be good.

-- Indexes corresponding to foreign keys
CREATE INDEX nibrs_incident_clear_ex_ix ON nibrs_incident(cleared_except_id);
CREATE INDEX nibrs_incident_index1 ON nibrs_incident(nibrs_month_id);
CREATE INDEX nibrs_offense_loc_type_ix ON nibrs_offense(location_id);
CREATE INDEX nibrs_offense_off_type_ix ON nibrs_offense(offense_type_id);
CREATE INDEX nibrs_offender_age_ix ON nibrs_offender(age_id);
CREATE INDEX nibrs_offender_ethnicity_ix ON nibrs_offender(ethnicity_id);
CREATE INDEX nibrs_offender_race_ix ON nibrs_offender(race_id);
CREATE INDEX nibrs_victim_act_type_ix ON nibrs_victim(activity_type_id);
CREATE INDEX nibrs_victim_age_ix ON nibrs_victim(age_id);
CREATE INDEX nibrs_victim_assign_type_ix ON nibrs_victim(assignment_type_id);
CREATE INDEX nibrs_victim_ethnicity_ix ON nibrs_victim(ethnicity_id);
CREATE INDEX nibrs_victim_race_ix ON nibrs_victim(race_id);
CREATE INDEX nibrs_victims_vic_type_ix ON nibrs_victim(victim_type_id);
CREATE INDEX nibrs_property_property_id_in ON nibrs_property_desc(property_id);
CREATE INDEX nibrs_property_desc_desc_id_in ON nibrs_property_desc(prop_desc_id);
CREATE INDEX nibrs_property_loss_type_ix ON nibrs_property(prop_loss_id);
CREATE INDEX nibrs_victim_offense_off_id ON nibrs_victim_offense(offense_id);
CREATE INDEX rmos_reta_month_id_idx ON reta_month_offense_subcat(reta_month_id);
CREATE INDEX nibrs_arrestee_age_ix ON nibrs_arrestee(age_id);
CREATE INDEX nibrs_arrestee_arrest_type_ix ON nibrs_arrestee(arrest_type_id);
CREATE INDEX nibrs_arrestee_ethnicity_ix ON nibrs_arrestee(ethnicity_id);
CREATE INDEX nibrs_arrestee_offense_type_ix ON nibrs_arrestee(offense_type_id);
CREATE INDEX nibrs_arrestee_nibrs_race_ix ON nibrs_arrestee(race_id);
CREATE INDEX nibrs_victim_offender_rel_off ON nibrs_victim_offender_rel(offender_id);
CREATE INDEX nibrs_victim_off_rel_rel_ix ON nibrs_victim_offender_rel(relationship_id);
CREATE INDEX nibrs_victim_offender_rel_vic ON nibrs_victim_offender_rel(victim_id);
CREATE INDEX nibrs_susp_drug_meas_type_ix ON nibrs_suspected_drug(drug_measure_type_id);
CREATE INDEX nibrs_susp_drug_prop_id ON nibrs_suspected_drug(property_id);
CREATE INDEX nibrs_arr_weapon_arrestee_id ON nibrs_arrestee_weapon(arrestee_id);
CREATE INDEX nibrs_arrest_weap_type_ix ON nibrs_arrestee_weapon(weapon_id);
CREATE INDEX nibrs_vic_injury_nibrs_inj_ix ON nibrs_victim_injury(injury_id);
CREATE INDEX nibrs_month_agency_id_idx ON nibrs_month(agency_id);
CREATE INDEX reta_month_agency_id_idx ON reta_month(agency_id);

-- Searchable text files need lowercased indexes
CREATE INDEX reta_offense_category_lower_idx ON reta_offense_category (LOWER(offense_category_name));
CREATE INDEX offense_classification_lower_idx ON offense_classification (LOWER(classification_name));
CREATE INDEX reta_offense_lower_idx ON reta_offense (LOWER(offense_name));
CREATE INDEX reta_offense_subcat_lower_idx ON reta_offense_subcat (LOWER(offense_subcat_name));
CREATE INDEX ref_state_lower_idx ON ref_state (LOWER (state_abbr));
CREATE INDEX ref_city_lower_idx ON ref_city (LOWER (city_name));

-- assorted
CREATE INDEX reta_offense_class_ix ON reta_offense (classification_id);
CREATE INDEX ra_state_id ON ref_agency (state_id);
CREATE INDEX ref_agency_city_ix ON ref_agency (city_id);
CREATE INDEX nibrs_incident_agency_id_idx ON nibrs_incident(agency_id);
