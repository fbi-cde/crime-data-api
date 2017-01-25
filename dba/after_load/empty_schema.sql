--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: arson_month; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE arson_month (
    arson_month_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    month_num smallint NOT NULL,
    data_home character(1) DEFAULT 'T'::bpchar NOT NULL,
    source_flag character(1) NOT NULL,
    reported_flag character(1),
    ddocname character varying(100),
    month_included_in smallint,
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    orig_format character(1),
    update_flag character(1),
    did bigint,
    ff_line_number bigint
);


--
-- Name: COLUMN arson_month.source_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN arson_month.source_flag IS 'This field indicates the source of the data.  R came into the system as a report, I means the data was derived from NIBRS data.';


--
-- Name: arson_month_by_subcat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE arson_month_by_subcat (
    arson_month_id bigint NOT NULL,
    subcategory_id bigint NOT NULL,
    reported_count integer,
    reported_status smallint,
    unfounded_count integer,
    unfounded_status smallint,
    actual_count integer,
    actual_status smallint,
    cleared_count integer,
    cleared_status smallint,
    juvenile_cleared_count integer,
    juvenile_cleared_status smallint,
    uninhabited_count integer,
    uninhabited_status smallint,
    est_damage_value bigint,
    est_damage_value_status smallint
);


--
-- Name: arson_subcategory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE arson_subcategory (
    subcategory_id bigint NOT NULL,
    subcategory_name character varying(100),
    subcategory_code character varying(20),
    subclass_id integer NOT NULL,
    subcat_xml_path character varying(4000)
);


--
-- Name: arson_subclassification; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE arson_subclassification (
    subclass_id smallint NOT NULL,
    subclass_name character varying(100),
    subclass_code character varying(20),
    subclass_xml_path character varying(4000)
);


--
-- Name: asr_age_range; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_age_range (
    age_range_id bigint NOT NULL,
    age_range_name character varying(20),
    age_range_code character varying(20),
    juvenile_flag character(1) NOT NULL,
    ff_sort_order character varying(3),
    age_sex character varying(1),
    xml_code character varying(2001)
);


--
-- Name: asr_age_sex_subcat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_age_sex_subcat (
    asr_month_id bigint NOT NULL,
    offense_subcat_id bigint NOT NULL,
    age_range_id bigint NOT NULL,
    arrest_count integer,
    arrest_status smallint,
    active_flag character(1),
    prepared_date timestamp without time zone,
    report_date timestamp without time zone,
    ff_line_number bigint
);


--
-- Name: asr_ethnicity; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_ethnicity (
    ethnicity_id bigint NOT NULL,
    ethnicity_name character varying(100),
    ethnicity_code character varying(20),
    ff_sort_order character varying(3)
);


--
-- Name: asr_ethnicity_offense; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_ethnicity_offense (
    asr_month_id bigint NOT NULL,
    offense_subcat_id bigint NOT NULL,
    ethnicity_id bigint NOT NULL,
    juvenile_flag character(1) NOT NULL,
    arrest_count integer,
    arrest_status smallint,
    prepared_date timestamp without time zone,
    report_date timestamp without time zone,
    ff_line_number bigint
);


--
-- Name: asr_juvenile_disposition; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_juvenile_disposition (
    asr_month_id bigint NOT NULL,
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    handled_within_dept integer,
    juvenile_court integer,
    welfare_agency integer,
    other_police integer,
    adult_court integer,
    ff_line_number bigint
);


--
-- Name: asr_month; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_month (
    asr_month_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    month_num smallint NOT NULL,
    source_flag character(1) NOT NULL,
    reported_flag character(1),
    orig_format character(1),
    update_flag character(1),
    ff_line_number bigint,
    ddocname character varying(100) DEFAULT 'NULL'::character varying,
    did bigint,
    data_home character(1) DEFAULT 'T'::bpchar NOT NULL
);


--
-- Name: COLUMN asr_month.orig_format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN asr_month.orig_format IS 'This is the format the report was in when it was first submitted to the system.  F for Flat File, W for Web Form, U for IEPDXML Upload, S for IEPDXML Service, B for BPEL, N for null or unavailable, and M for Multiple. When summarizing NIBRS data into the _month tables, a single months data could come from multiple sources.  If so the entry will be M';


--
-- Name: asr_offense; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_offense (
    offense_id bigint NOT NULL,
    offense_cat_id bigint NOT NULL,
    offense_name character varying(100),
    offense_code character varying(20),
    total_flag character(1)
);


--
-- Name: asr_offense_category; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_offense_category (
    offense_cat_id bigint NOT NULL,
    offense_cat_name character varying(100),
    offense_cat_code character varying(20)
);


--
-- Name: asr_offense_subcat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_offense_subcat (
    offense_subcat_id bigint NOT NULL,
    offense_id bigint NOT NULL,
    offense_subcat_name character varying(100),
    offense_subcat_code character varying(20),
    srs_offense_code character(3),
    master_offense_code smallint,
    total_flag character(1),
    adult_juv_flag character(1)
);


--
-- Name: asr_race_offense_subcat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asr_race_offense_subcat (
    asr_month_id bigint NOT NULL,
    offense_subcat_id bigint NOT NULL,
    race_id bigint NOT NULL,
    juvenile_flag character(1) NOT NULL,
    arrest_count integer,
    arrest_status smallint,
    active_flag character(1),
    prepared_date timestamp without time zone,
    report_date timestamp without time zone,
    ff_line_number bigint
);


--
-- Name: crime_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE crime_type (
    crime_type_id smallint NOT NULL,
    crime_type_name character varying(50),
    crime_type_sort_order smallint,
    crime_flag character(1)
);


--
-- Name: ct_arrestee; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ct_arrestee (
    arrestee_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    age smallint,
    sex_code character(1),
    ethnicity_id smallint,
    race_id smallint
);


--
-- Name: ct_incident; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ct_incident (
    incident_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    incident_number character varying(15),
    incident_date timestamp without time zone,
    source_flag character(1) NOT NULL,
    ddocname character varying(100),
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    report_date_flag character(1),
    incident_hour smallint,
    cleared_except_flag character(1),
    update_flag character(1),
    ct_month_id bigint NOT NULL,
    ff_line_number bigint,
    data_home character(1) DEFAULT 'T'::bpchar NOT NULL,
    orig_format character(1),
    unknown_offender character(1),
    did bigint,
    nibrs_incident_id bigint
);


--
-- Name: COLUMN ct_incident.source_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN ct_incident.source_flag IS 'This field indicates the source of the data.  R came into the system as a report, I means the data was derived from NIBRS data.';


--
-- Name: ct_month; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ct_month (
    ct_month_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    month_num smallint NOT NULL,
    data_year smallint NOT NULL,
    reported_status character varying(1),
    reported_count integer,
    update_flag character(1) DEFAULT 'Y'::bpchar,
    ff_line_number bigint,
    ddocname character varying(100) DEFAULT 'NULL'::character varying,
    did bigint,
    data_home character(1) DEFAULT 'T'::bpchar NOT NULL,
    orig_format character(1)
);


--
-- Name: ct_offender; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ct_offender (
    offender_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    age smallint,
    sex_code character(1),
    ethnicity_id smallint,
    race_id smallint
);


--
-- Name: ct_offense; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ct_offense (
    offense_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    offense_type_id bigint NOT NULL,
    location_id bigint NOT NULL,
    ct_offense_flag character(1)
);


--
-- Name: ct_property; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ct_property (
    property_id bigint NOT NULL,
    prop_desc_id smallint NOT NULL,
    incident_id bigint NOT NULL,
    stolen_value bigint,
    recovered_flag character(1),
    date_recovered timestamp without time zone,
    recovered_value bigint
);


--
-- Name: ct_victim; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ct_victim (
    incident_id bigint NOT NULL,
    victim_type_id smallint NOT NULL
);


--
-- Name: ct_weapon; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ct_weapon (
    incident_id bigint NOT NULL,
    weapon_id smallint NOT NULL,
    ct_weapon_id bigint NOT NULL
);


--
-- Name: hc_bias_motivation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hc_bias_motivation (
    offense_id bigint NOT NULL,
    bias_id smallint NOT NULL
);


--
-- Name: hc_incident; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hc_incident (
    incident_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    incident_no character varying(20),
    incident_date timestamp without time zone,
    data_home character(1),
    source_flag character(1),
    ddocname character varying(100),
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    victim_count smallint,
    adult_victim_count smallint,
    incident_status smallint,
    juvenile_victim_count smallint,
    offender_count smallint,
    adult_offender_count smallint,
    juvenile_offender_count smallint,
    offender_race_id smallint,
    offender_ethnicity_id smallint,
    update_flag character(1),
    hc_quarter_id bigint NOT NULL,
    ff_line_number bigint,
    orig_format character(1),
    did bigint,
    nibrs_incident_id bigint
);


--
-- Name: COLUMN hc_incident.source_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN hc_incident.source_flag IS 'This field indicates the source of the data.  R came into the system as a report, I means the data was derived from NIBRS data.';


--
-- Name: hc_offense; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hc_offense (
    offense_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    offense_type_id bigint,
    victim_count smallint,
    location_id bigint,
    nibrs_offense_id bigint
);


--
-- Name: hc_quarter; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hc_quarter (
    agency_id bigint NOT NULL,
    quarter_num smallint NOT NULL,
    data_year smallint NOT NULL,
    reported_status character varying(1),
    reported_count bigint,
    hc_quarter_id bigint NOT NULL,
    update_flag character(1) DEFAULT 'Y'::bpchar,
    orig_format character(1),
    ff_line_number bigint,
    ddocname character varying(100),
    did bigint,
    data_home character(1) DEFAULT 'T'::bpchar NOT NULL
);


--
-- Name: hc_victim; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hc_victim (
    offense_id bigint NOT NULL,
    victim_type_id smallint NOT NULL
);


--
-- Name: ht_month; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ht_month (
    ht_month_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    month_num smallint NOT NULL,
    data_home character(1) DEFAULT 'T'::bpchar NOT NULL,
    source_flag character(1) NOT NULL,
    ddocname character varying(100),
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    prepared_by_user character varying(100),
    prepared_by_email character varying(200),
    orig_format character(1) NOT NULL,
    total_reported_count integer,
    total_unfounded_count integer,
    total_actual_count integer,
    total_cleared_count integer,
    total_juvenile_cleared_count integer,
    update_flag character(1),
    reported_flag character varying(1),
    did bigint,
    ff_line_number bigint
);


--
-- Name: COLUMN ht_month.source_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN ht_month.source_flag IS 'This field indicates the source of the data.  R came into the system as a report, I means the data was derived from NIBRS data.';


--
-- Name: ht_month_offense_subcat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ht_month_offense_subcat (
    ht_month_id bigint NOT NULL,
    offense_subcat_id bigint NOT NULL,
    reported_count integer,
    reported_status smallint,
    unfounded_count integer,
    unfounded_status smallint,
    actual_count integer,
    actual_status smallint,
    cleared_count integer,
    cleared_status smallint,
    juvenile_cleared_count integer,
    juvenile_cleared_status smallint
);


--
-- Name: nibrs_activity_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_activity_type (
    activity_type_id smallint NOT NULL,
    activity_type_code character(2),
    activity_type_name character varying(100)
);


--
-- Name: nibrs_age; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_age (
    age_id smallint NOT NULL,
    age_code character(2),
    age_name character varying(100)
);


--
-- Name: nibrs_arrest_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_arrest_type (
    arrest_type_id smallint NOT NULL,
    arrest_type_code character(1),
    arrest_type_name character varying(100)
);


--
-- Name: nibrs_arrestee; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_arrestee (
    arrestee_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    arrestee_seq_num bigint,
    arrest_num character varying(12),
    arrest_date timestamp without time zone,
    arrest_type_id smallint,
    multiple_indicator character(1),
    offense_type_id bigint NOT NULL,
    age_id smallint NOT NULL,
    age_num smallint,
    sex_code character(1),
    race_id smallint NOT NULL,
    ethnicity_id smallint,
    resident_code character(1),
    under_18_disposition_code character(1),
    clearance_ind character(1),
    ff_line_number bigint,
    age_range_low_num smallint,
    age_range_high_num smallint
);


--
-- Name: nibrs_arrestee_weapon; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_arrestee_weapon (
    arrestee_id bigint NOT NULL,
    weapon_id smallint NOT NULL,
    nibrs_arrestee_weapon_id bigint NOT NULL
);


--
-- Name: nibrs_assignment_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_assignment_type (
    assignment_type_id smallint NOT NULL,
    assignment_type_code character(1),
    assignment_type_name character varying(100)
);


--
-- Name: nibrs_bias_list; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_bias_list (
    bias_id smallint NOT NULL,
    bias_code character(2),
    bias_name character varying(100)
);


--
-- Name: nibrs_bias_motivation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_bias_motivation (
    bias_id smallint NOT NULL,
    offense_id bigint NOT NULL
);


--
-- Name: nibrs_circumstances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_circumstances (
    circumstances_id smallint NOT NULL,
    circumstances_type character(1),
    circumstances_code smallint,
    circumstances_name character varying(100)
);


--
-- Name: nibrs_cleared_except; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_cleared_except (
    cleared_except_id smallint NOT NULL,
    cleared_except_code character(1),
    cleared_except_name character varying(100)
);


--
-- Name: nibrs_criminal_act; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_criminal_act (
    criminal_act_id smallint NOT NULL,
    offense_id bigint NOT NULL
);


--
-- Name: nibrs_criminal_act_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_criminal_act_type (
    criminal_act_id smallint NOT NULL,
    criminal_act_code character(1),
    criminal_act_name character varying(100)
);


--
-- Name: nibrs_drug_measure_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_drug_measure_type (
    drug_measure_type_id smallint NOT NULL,
    drug_measure_code character(2),
    drug_measure_name character varying(100)
);


--
-- Name: nibrs_eds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_eds (
    ddocname character varying(100),
    data_year smallint,
    month_num smallint,
    relative_rec_num integer,
    segment_action_type character(1),
    ori character(9),
    incident_num character(12),
    level character(1),
    offense_code character(3),
    person_seq_num character(3),
    type_prop_loss character(1),
    data_element_num character(3),
    error_num smallint,
    data_field character(12),
    error_msg character(79),
    submission_ser_num integer
);


--
-- Name: nibrs_ethnicity; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_ethnicity (
    ethnicity_id smallint NOT NULL,
    ethnicity_code character(1),
    ethnicity_name character varying(100),
    hc_flag character varying(1) DEFAULT 'Y'::character varying
);


--
-- Name: nibrs_grpb_arrest; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_grpb_arrest (
    grpb_arrest_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    arrest_num character varying(15),
    arrest_date timestamp without time zone,
    arrest_seq_num smallint,
    city character varying(4),
    arrest_type_id smallint,
    offense_type_id bigint,
    age_id smallint,
    sex_code character(1),
    race_id smallint,
    ethnicity_id smallint,
    resident_code character(1),
    under_18_disposition_code character(1),
    age_num smallint,
    arrest_year smallint,
    ff_line_number bigint,
    data_home character varying(1),
    ddocname character varying(100),
    did bigint,
    nibrs_month_id bigint NOT NULL,
    age_range_low_num smallint,
    age_range_high_num smallint
);


--
-- Name: nibrs_grpb_arrest_weapon; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_grpb_arrest_weapon (
    grpb_arrest_id bigint NOT NULL,
    weapon_id smallint NOT NULL,
    nibrs_grpb_arrest_weapon_id bigint NOT NULL
);


--
-- Name: nibrs_incident; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_incident (
    agency_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    nibrs_month_id bigint NOT NULL,
    incident_number character varying(15),
    cargo_theft_flag character(1),
    submission_date timestamp without time zone,
    incident_date timestamp without time zone,
    report_date_flag character(1),
    incident_hour smallint,
    cleared_except_id smallint NOT NULL,
    cleared_except_date timestamp without time zone,
    incident_status smallint,
    data_home character(1),
    ddocname character varying(100),
    orig_format character(1),
    ff_line_number bigint,
    did bigint
);


--
-- Name: COLUMN nibrs_incident.orig_format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN nibrs_incident.orig_format IS 'This is the format the report was in when it was first submitted to the system.  F for Flat File, W for Web Form, U for IEPDXML Upload, S for IEPDXML Service, B for BPEL, N for null or unavailable.';


--
-- Name: nibrs_injury; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_injury (
    injury_id smallint NOT NULL,
    injury_code character(1),
    injury_name character varying(100)
);


--
-- Name: nibrs_justifiable_force; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_justifiable_force (
    justifiable_force_id smallint NOT NULL,
    justifiable_force_code character(1),
    justifiable_force_name character varying(100)
);


--
-- Name: nibrs_location_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_location_type (
    location_id bigint NOT NULL,
    location_code character(2),
    location_name character varying(100)
);


--
-- Name: nibrs_month; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_month (
    nibrs_month_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    month_num smallint NOT NULL,
    data_year smallint NOT NULL,
    reported_status character varying(1),
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    update_flag character(1) DEFAULT 'NULL'::bpchar NOT NULL,
    orig_format character(1) DEFAULT 'NULL'::bpchar NOT NULL,
    ff_line_number bigint,
    data_home character varying(1),
    ddocname character varying(50),
    did bigint
);


--
-- Name: COLUMN nibrs_month.orig_format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN nibrs_month.orig_format IS 'This is the format the report was in when it was first submitted to the system.  F for Flat File, W for Web Form, U for IEPDXML Upload, S for IEPDXML Service, B for BPEL, N for null or unavailable, and M for Multiple. When summarizing NIBRS data into the _month tables, a single months data could come from multiple sources.  If so the entry will be M';


--
-- Name: nibrs_offender; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_offender (
    offender_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    offender_seq_num smallint,
    age_id smallint,
    age_num smallint,
    sex_code character(1),
    race_id smallint,
    ethnicity_id smallint,
    ff_line_number bigint,
    age_range_low_num smallint,
    age_range_high_num smallint
);


--
-- Name: nibrs_offense; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_offense (
    offense_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    offense_type_id bigint NOT NULL,
    attempt_complete_flag character(1),
    location_id bigint NOT NULL,
    num_premises_entered smallint,
    method_entry_code character(1),
    ff_line_number bigint
);


--
-- Name: nibrs_offense_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_offense_type (
    offense_type_id bigint NOT NULL,
    offense_code character varying(5),
    offense_name character varying(100),
    crime_against character varying(100),
    ct_flag character(1),
    hc_flag character(1),
    hc_code character varying(5),
    offense_category_name character varying(100)
);


--
-- Name: nibrs_prop_desc_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_prop_desc_type (
    prop_desc_id smallint NOT NULL,
    prop_desc_code character(2),
    prop_desc_name character varying(100)
);


--
-- Name: nibrs_prop_loss_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_prop_loss_type (
    prop_loss_id smallint NOT NULL,
    prop_loss_name character varying(100)
);


--
-- Name: nibrs_property; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_property (
    property_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    prop_loss_id smallint NOT NULL,
    stolen_count smallint,
    recovered_count smallint,
    ff_line_number bigint
);


--
-- Name: nibrs_property_desc; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_property_desc (
    property_id bigint NOT NULL,
    prop_desc_id smallint NOT NULL,
    property_value bigint,
    date_recovered timestamp without time zone,
    nibrs_prop_desc_id bigint NOT NULL
);


--
-- Name: nibrs_relationship; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_relationship (
    relationship_id smallint NOT NULL,
    relationship_code character(2),
    relationship_name character varying(100)
);


--
-- Name: nibrs_sum_month_temp; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_sum_month_temp (
    nibrs_month_id bigint,
    agency_id bigint,
    month_num smallint,
    data_year smallint,
    reported_status character(1),
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    orig_format character(1),
    ff_line_number bigint,
    data_home character(1),
    ddocname character varying(50),
    did bigint,
    nibrs_ct_flag character(1),
    nibrs_hc_flag character(1),
    nibrs_leoka_flag character(1),
    nibrs_arson_flag character(1),
    nibrs_ht_flag character(1)
);


--
-- Name: nibrs_suspect_using; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_suspect_using (
    suspect_using_id smallint NOT NULL,
    offense_id bigint NOT NULL
);


--
-- Name: nibrs_suspected_drug; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_suspected_drug (
    suspected_drug_type_id smallint NOT NULL,
    property_id bigint NOT NULL,
    est_drug_qty double precision,
    drug_measure_type_id smallint,
    nibrs_suspected_drug_id bigint NOT NULL
);


--
-- Name: nibrs_suspected_drug_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_suspected_drug_type (
    suspected_drug_type_id smallint NOT NULL,
    suspected_drug_code character(1),
    suspected_drug_name character varying(100)
);


--
-- Name: nibrs_using_list; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_using_list (
    suspect_using_id smallint NOT NULL,
    suspect_using_code character(1),
    suspect_using_name character varying(100)
);


--
-- Name: nibrs_victim; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_victim (
    victim_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    victim_seq_num smallint,
    victim_type_id smallint NOT NULL,
    assignment_type_id smallint,
    activity_type_id smallint,
    outside_agency_id bigint,
    age_id smallint,
    age_num smallint,
    sex_code character(1),
    race_id smallint,
    ethnicity_id smallint,
    resident_status_code character(1),
    agency_data_year smallint,
    ff_line_number bigint,
    age_range_low_num smallint,
    age_range_high_num smallint
);


--
-- Name: nibrs_victim_circumstances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_victim_circumstances (
    victim_id bigint NOT NULL,
    circumstances_id smallint NOT NULL,
    justifiable_force_id smallint
);


--
-- Name: nibrs_victim_injury; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_victim_injury (
    victim_id bigint NOT NULL,
    injury_id smallint NOT NULL
);


--
-- Name: nibrs_victim_offender_rel; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_victim_offender_rel (
    victim_id bigint NOT NULL,
    offender_id bigint NOT NULL,
    relationship_id smallint NOT NULL,
    nibrs_victim_offender_id bigint NOT NULL
);


--
-- Name: nibrs_victim_offense; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_victim_offense (
    victim_id bigint NOT NULL,
    offense_id bigint NOT NULL
);


--
-- Name: nibrs_victim_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_victim_type (
    victim_type_id smallint NOT NULL,
    victim_type_code character(1),
    victim_type_name character varying(100)
);


--
-- Name: nibrs_weapon; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_weapon (
    weapon_id smallint NOT NULL,
    offense_id bigint NOT NULL,
    nibrs_weapon_id bigint NOT NULL
);


--
-- Name: nibrs_weapon_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nibrs_weapon_type (
    weapon_id smallint NOT NULL,
    weapon_code character varying(3),
    weapon_name character varying(100),
    shr_flag character(1)
);


--
-- Name: offense_classification; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE offense_classification (
    classification_id smallint NOT NULL,
    classification_name character varying(50),
    class_sort_order smallint
);


--
-- Name: ref_agency; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_agency (
    agency_id bigint NOT NULL,
    ori character(9) NOT NULL,
    legacy_ori character(9) NOT NULL,
    ucr_agency_name character varying(100),
    ncic_agency_name character varying(100),
    pub_agency_name character varying(100),
    agency_type_id smallint NOT NULL,
    special_mailing_group character(1),
    special_mailing_address character(1),
    tribe_id bigint,
    city_id bigint,
    state_id smallint NOT NULL,
    campus_id bigint,
    agency_status character(1) NOT NULL,
    judicial_dist_code character varying(4),
    submitting_agency_id bigint,
    fid_code character(2),
    department_id smallint,
    added_date timestamp without time zone,
    change_timestamp timestamp without time zone,
    change_user character varying(100),
    legacy_notify_agency character(1),
    dormant_year smallint,
    population_family_id smallint DEFAULT 0 NOT NULL,
    field_office_id bigint
);


--
-- Name: ref_agency_county; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_agency_county (
    agency_id bigint NOT NULL,
    county_id bigint NOT NULL,
    metro_div_id bigint NOT NULL,
    core_city_flag character(1),
    data_year smallint NOT NULL,
    population bigint,
    census bigint,
    legacy_county_code character varying(20),
    legacy_msa_code character varying(20),
    source_flag character(1),
    change_timestamp timestamp without time zone,
    change_user character varying(100)
);


--
-- Name: ref_agency_covered_by; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_agency_covered_by (
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    covered_by_agency_id bigint NOT NULL
);


--
-- Name: ref_agency_data_content; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_agency_data_content (
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    reporting_type character(1),
    nibrs_ct_flag character(1),
    nibrs_hc_flag character(1),
    nibrs_leoka_flag character(1),
    nibrs_arson_flag character(1),
    summary_rape_def character(1),
    nibrs_ht_flag character(1)
);


--
-- Name: ref_agency_poc; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_agency_poc (
    poc_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    primary_poc_flag character(1)
);


--
-- Name: ref_agency_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_agency_type (
    agency_type_id smallint NOT NULL,
    agency_type_name character varying(100),
    default_pop_family_id smallint DEFAULT 0 NOT NULL
);


--
-- Name: ref_campus_population; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_campus_population (
    campus_id bigint NOT NULL,
    data_year smallint NOT NULL,
    population bigint,
    source_flag character(1) NOT NULL,
    census bigint,
    change_timestamp timestamp without time zone,
    change_user character varying(100),
    reporting_population bigint
);


--
-- Name: ref_city; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_city (
    city_id bigint NOT NULL,
    state_id smallint NOT NULL,
    city_name character varying(100)
);


--
-- Name: ref_continent; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_continent (
    continent_id smallint NOT NULL,
    continent_desc character varying(50)
);


--
-- Name: ref_country; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_country (
    country_id smallint NOT NULL,
    continent_id smallint NOT NULL,
    country_desc character varying(50)
);


--
-- Name: ref_county; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_county (
    county_id bigint NOT NULL,
    state_id smallint NOT NULL,
    county_name character varying(100),
    county_ansi_code character varying(5),
    county_fips_code character varying(5),
    legacy_county_code character varying(5),
    comments character varying(1000)
);


--
-- Name: ref_county_population; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_county_population (
    county_id bigint NOT NULL,
    data_year smallint NOT NULL,
    population bigint,
    source_flag character(1) NOT NULL,
    change_timestamp timestamp without time zone,
    change_user character varying(100),
    reporting_population bigint
);


--
-- Name: ref_department; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_department (
    department_id smallint NOT NULL,
    department_name character varying(100) NOT NULL,
    active_flag character(1) NOT NULL,
    sort_order smallint
);


--
-- Name: ref_division; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_division (
    division_id smallint NOT NULL,
    region_id smallint NOT NULL,
    division_code character varying(2),
    division_name character varying(100),
    division_desc character varying(100)
);


--
-- Name: ref_field_office; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_field_office (
    field_office_id bigint NOT NULL,
    field_office_code character varying(10),
    field_office_name character varying(100),
    field_office_alpha_code character varying(2),
    field_office_numeric_code character varying(10)
);


--
-- Name: ref_global_location; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_global_location (
    global_location_id bigint NOT NULL,
    country_id smallint NOT NULL,
    global_location_desc character varying(50)
);


--
-- Name: ref_metro_div_population; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_metro_div_population (
    metro_div_id bigint NOT NULL,
    data_year smallint NOT NULL,
    population bigint,
    source_flag character(1) NOT NULL,
    census bigint,
    change_timestamp timestamp without time zone,
    change_user character varying(100),
    reporting_population bigint
);


--
-- Name: ref_metro_division; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_metro_division (
    metro_div_id bigint NOT NULL,
    msa_id bigint NOT NULL,
    metro_div_name character varying(100),
    msa_flag character(1),
    metro_div_omb_code character varying(5),
    legacy_msa_code character varying(5)
);


--
-- Name: ref_msa; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_msa (
    msa_id bigint NOT NULL,
    msa_name character varying(100),
    msa_omb_code character varying(5)
);


--
-- Name: ref_parent_population_group; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_parent_population_group (
    parent_pop_group_id bigint NOT NULL,
    parent_pop_group_code character varying(2),
    parent_pop_group_desc character varying(100),
    publication_name character varying(100),
    population_family_id smallint DEFAULT 0 NOT NULL
);


--
-- Name: ref_poc; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_poc (
    poc_id bigint NOT NULL,
    poc_name character varying(200),
    poc_title character varying(200),
    poc_email character varying(200),
    poc_phone1 character varying(50),
    poc_phone2 character varying(50),
    mailing_address_1 character varying(150),
    mailing_address_2 character varying(150),
    mailing_address_3 character varying(150),
    mailing_address_4 character varying(150),
    state_id smallint,
    zip_code character varying(10),
    city_name character varying(100),
    poc_fax1 character varying(20),
    poc_fax2 character varying(20)
);


--
-- Name: ref_poc_role; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_poc_role (
    poc_role_id smallint NOT NULL,
    poc_role_name character varying(100)
);


--
-- Name: ref_poc_role_assign; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_poc_role_assign (
    poc_id bigint NOT NULL,
    poc_role_id smallint NOT NULL
);


--
-- Name: ref_population_family; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_population_family (
    population_family_id smallint NOT NULL,
    population_family_name character varying(100),
    population_family_desc character varying(200),
    sort_order smallint
);


--
-- Name: ref_population_group; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_population_group (
    population_group_id bigint NOT NULL,
    population_group_code character varying(2),
    population_group_desc character varying(150),
    parent_pop_group_id bigint NOT NULL,
    publication_name character varying(100)
);


--
-- Name: ref_race; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_race (
    race_id smallint NOT NULL,
    race_code character varying(2) NOT NULL,
    race_desc character varying(100) NOT NULL,
    sort_order smallint,
    start_year smallint,
    end_year smallint,
    notes character varying(1000)
);


--
-- Name: ref_region; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_region (
    region_id smallint NOT NULL,
    region_code character varying(2),
    region_name character varying(100),
    region_desc character varying(100)
);


--
-- Name: ref_state; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_state (
    state_id smallint NOT NULL,
    division_id smallint NOT NULL,
    state_name character varying(100),
    state_code character varying(2),
    state_abbr character varying(2),
    state_postal_abbr character varying(2),
    state_fips_code character varying(2),
    state_pub_freq_months smallint
);


--
-- Name: ref_submitting_agency; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_submitting_agency (
    agency_id bigint NOT NULL,
    sai character(9),
    agency_name character varying(150),
    state_id smallint,
    notify_agency character(1),
    agency_email character varying(200),
    agency_website character varying(2000),
    comments character varying(2000)
);


--
-- Name: ref_tribe; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_tribe (
    tribe_id bigint NOT NULL,
    tribe_name character varying(100)
);


--
-- Name: ref_tribe_population; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_tribe_population (
    tribe_id bigint NOT NULL,
    data_year smallint NOT NULL,
    population bigint,
    source_flag character(1) NOT NULL,
    census bigint,
    change_timestamp timestamp without time zone,
    change_user character varying(100),
    reporting_population bigint
);


--
-- Name: ref_university; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_university (
    university_id bigint NOT NULL,
    university_abbr character varying(20),
    university_name character varying(100)
);


--
-- Name: ref_university_campus; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ref_university_campus (
    campus_id bigint NOT NULL,
    university_id bigint NOT NULL,
    campus_name character varying(100)
);


--
-- Name: reta_month; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reta_month (
    reta_month_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    month_num smallint NOT NULL,
    data_home character(1) NOT NULL,
    source_flag character(1) NOT NULL,
    reported_flag character(1) NOT NULL,
    ddocname character varying(100),
    month_included_in smallint,
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    prepared_by_user character varying(100),
    prepared_by_email character varying(200),
    orig_format character(1) NOT NULL,
    total_reported_count integer,
    total_unfounded_count integer,
    total_actual_count integer,
    total_cleared_count integer,
    total_juvenile_cleared_count integer,
    leoka_felony smallint,
    leoka_accident smallint,
    leoka_assault integer,
    leoka_status smallint,
    update_flag character(1),
    did bigint,
    ff_line_number bigint
);


--
-- Name: COLUMN reta_month.source_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reta_month.source_flag IS 'This field indicates the source of the data.  R came into the system as a report, I means the data was derived from NIBRS data.';


--
-- Name: reta_month_offense_subcat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reta_month_offense_subcat (
    reta_month_id bigint NOT NULL,
    offense_subcat_id bigint NOT NULL,
    reported_count integer,
    reported_status smallint,
    unfounded_count integer,
    unfounded_status smallint,
    actual_count integer,
    actual_status smallint,
    cleared_count integer,
    cleared_status smallint,
    juvenile_cleared_count integer,
    juvenile_cleared_status smallint
);


--
-- Name: COLUMN reta_month_offense_subcat.actual_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reta_month_offense_subcat.actual_status IS '0 is for considering data completely, 2 for dont calculate, but do publish, 3 for dont calculate and dont publish, 4 for legacy rape data submitted by an agency that reports using the new rape definitions, 6 for legacy rape data for reporting but not calculation, 7 for legacy rape data not for reporting or calculation';


--
-- Name: reta_offense; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reta_offense (
    offense_id bigint NOT NULL,
    offense_name character varying(100) NOT NULL,
    offense_code character varying(20) NOT NULL,
    offense_xml_path character varying(1000),
    offense_category_id smallint NOT NULL,
    classification_id smallint,
    offense_sort_order bigint
);


--
-- Name: reta_offense_category; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reta_offense_category (
    offense_category_id smallint NOT NULL,
    crime_type_id smallint NOT NULL,
    offense_category_name character varying(50),
    offense_category_sort_order smallint NOT NULL
);


--
-- Name: reta_offense_subcat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reta_offense_subcat (
    offense_subcat_id bigint NOT NULL,
    offense_id bigint NOT NULL,
    offense_subcat_name character varying(100) NOT NULL,
    offense_subcat_code character varying(20) NOT NULL,
    offense_subcat_xml_path character varying(1000),
    offense_subcat_sort_order bigint,
    part character(1),
    crime_index_flag character(1)
);


--
-- Name: shr_circumstances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shr_circumstances (
    circumstances_id smallint NOT NULL,
    circumstances_code character(2) NOT NULL,
    sub_code character(1),
    circumstances_name character varying(100) NOT NULL,
    sub_name character varying(100),
    current_flag character(1)
);


--
-- Name: shr_incident; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shr_incident (
    incident_id bigint NOT NULL,
    shr_month_id bigint NOT NULL,
    homicide_code character(1),
    situation_id smallint NOT NULL,
    incident_num character varying(3),
    incident_status smallint,
    update_flag character(1),
    data_home character varying(1),
    prepared_date timestamp without time zone,
    report_date timestamp without time zone,
    ddocname character varying(100),
    ff_line_number bigint,
    orig_format character(1),
    did bigint,
    nibrs_incident_id bigint
);


--
-- Name: shr_month; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shr_month (
    shr_month_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    month_num smallint NOT NULL,
    data_home character(1) DEFAULT 'T'::bpchar NOT NULL,
    source_flag character(1),
    reported_flag character(1),
    orig_format character(1),
    update_flag character varying(1),
    ff_line_number bigint,
    ddocname character varying(100),
    did bigint
);


--
-- Name: COLUMN shr_month.orig_format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN shr_month.orig_format IS 'This is the format the report was in when it was first submitted to the system.  F for Flat File, W for Web Form, U for IEPDXML Upload, S for IEPDXML Service, B for BPEL, N for null or unavailable, and M for Multiple. When summarizing NIBRS data into the _month tables, a single months data could come from multiple sources.  If so the entry will be M';


--
-- Name: shr_offender; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shr_offender (
    offender_id bigint NOT NULL,
    offender_num character varying(20),
    age_id smallint,
    age_num smallint,
    sex_code character(1),
    race_id bigint,
    ethnicity_id smallint,
    nibrs_offense_id bigint,
    nibrs_offender_id bigint
);


--
-- Name: COLUMN shr_offender.offender_num; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN shr_offender.offender_num IS 'The XML may send this field as something like ''OFFENDER1''';


--
-- Name: shr_offense; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shr_offense (
    offense_id bigint NOT NULL,
    incident_id bigint NOT NULL,
    weapon_id smallint,
    relationship_id smallint,
    circumstances_id smallint,
    victim_id bigint NOT NULL,
    offender_id bigint NOT NULL,
    nibrs_offense_id bigint
);


--
-- Name: shr_relationship; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shr_relationship (
    relationship_id smallint NOT NULL,
    relationship_code character(2),
    relationship_name character varying(100)
);


--
-- Name: shr_situation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shr_situation (
    situation_id smallint NOT NULL,
    situation_code character(1),
    situation_name character varying(100)
);


--
-- Name: shr_victim; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shr_victim (
    victim_id bigint NOT NULL,
    victim_num character varying(20),
    age_id smallint,
    age_num smallint,
    sex_code character(1),
    race_id bigint,
    ethnicity_id smallint,
    nibrs_victim_id bigint,
    nibrs_offense_id bigint
);


--
-- Name: COLUMN shr_victim.victim_num; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN shr_victim.victim_num IS 'This field may come as ''VICTIM1'', so it needed to be a VARCHAR';


--
-- Name: supp_larceny_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supp_larceny_type (
    larceny_type_id bigint NOT NULL,
    larceny_type_name character varying(100) NOT NULL,
    larceny_type_code character varying(20) NOT NULL,
    larceny_xml_name character varying(100)
);


--
-- Name: supp_month; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supp_month (
    supp_month_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    month_num smallint NOT NULL,
    data_home character(1) NOT NULL,
    source_flag character(1),
    reported_flag character(1) NOT NULL,
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    ddocname character varying(100),
    orig_format character(1) NOT NULL,
    mv_stolen_local_rec_local bigint,
    mv_stolen_local_rec_other bigint,
    mv_tot_local_stolen_rec bigint,
    mv_stolen_other_rec_local bigint,
    mv_stolen_status smallint,
    update_flag character(1),
    did bigint,
    ff_line_number bigint
);


--
-- Name: COLUMN supp_month.source_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN supp_month.source_flag IS 'This field indicates the source of the data.  R came into the system as a report, I means the data was derived from NIBRS data.';


--
-- Name: supp_offense; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supp_offense (
    offense_id bigint NOT NULL,
    offense_name character varying(100) NOT NULL,
    offense_code character varying(20) NOT NULL
);


--
-- Name: supp_offense_subcat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supp_offense_subcat (
    offense_subcat_id bigint NOT NULL,
    offense_id bigint NOT NULL,
    offense_subcat_name character varying(100) NOT NULL,
    offense_subcat_code character varying(20) NOT NULL,
    offense_subcat_xml_name character varying(100)
);


--
-- Name: supp_prop_by_offense_subcat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supp_prop_by_offense_subcat (
    supp_month_id bigint NOT NULL,
    offense_subcat_id bigint NOT NULL,
    actual_count integer,
    actual_status smallint,
    stolen_value bigint,
    stolen_value_status smallint
);


--
-- Name: supp_property_by_type_value; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supp_property_by_type_value (
    supp_month_id bigint NOT NULL,
    prop_type_id bigint NOT NULL,
    stolen_value bigint,
    stolen_value_status smallint,
    recovered_value bigint,
    recovered_value_status smallint
);


--
-- Name: supp_property_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supp_property_type (
    prop_type_id bigint NOT NULL,
    prop_type_name character varying(100) NOT NULL,
    prop_type_code character varying(20) NOT NULL,
    prop_type_code_num smallint NOT NULL
);


--
-- Name: arson_month_agency_id_data_year_month_num_data_home_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY arson_month
    ADD CONSTRAINT arson_month_agency_id_data_year_month_num_data_home_key UNIQUE (agency_id, data_year, month_num, data_home);


--
-- Name: arson_month_by_subcat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY arson_month_by_subcat
    ADD CONSTRAINT arson_month_by_subcat_pkey PRIMARY KEY (arson_month_id, subcategory_id);


--
-- Name: arson_month_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY arson_month
    ADD CONSTRAINT arson_month_pkey PRIMARY KEY (arson_month_id);


--
-- Name: arson_subcategory_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY arson_subcategory
    ADD CONSTRAINT arson_subcategory_pkey PRIMARY KEY (subcategory_id);


--
-- Name: arson_subcategory_subcategory_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY arson_subcategory
    ADD CONSTRAINT arson_subcategory_subcategory_code_key UNIQUE (subcategory_code);


--
-- Name: arson_subclassification_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY arson_subclassification
    ADD CONSTRAINT arson_subclassification_pkey PRIMARY KEY (subclass_id);


--
-- Name: arson_subclassification_subclass_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY arson_subclassification
    ADD CONSTRAINT arson_subclassification_subclass_code_key UNIQUE (subclass_code);


--
-- Name: asr_age_range_age_range_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_age_range
    ADD CONSTRAINT asr_age_range_age_range_code_key UNIQUE (age_range_code);


--
-- Name: asr_age_range_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_age_range
    ADD CONSTRAINT asr_age_range_pkey PRIMARY KEY (age_range_id);


--
-- Name: asr_age_sex_subcat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_age_sex_subcat
    ADD CONSTRAINT asr_age_sex_subcat_pkey PRIMARY KEY (asr_month_id, offense_subcat_id, age_range_id);


--
-- Name: asr_ethnicity_ethnicity_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_ethnicity
    ADD CONSTRAINT asr_ethnicity_ethnicity_code_key UNIQUE (ethnicity_code);


--
-- Name: asr_ethnicity_offense_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_ethnicity_offense
    ADD CONSTRAINT asr_ethnicity_offense_pkey PRIMARY KEY (asr_month_id, offense_subcat_id, ethnicity_id, juvenile_flag);


--
-- Name: asr_ethnicity_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_ethnicity
    ADD CONSTRAINT asr_ethnicity_pkey PRIMARY KEY (ethnicity_id);


--
-- Name: asr_juvenile_disposition_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_juvenile_disposition
    ADD CONSTRAINT asr_juvenile_disposition_pkey PRIMARY KEY (asr_month_id);


--
-- Name: asr_month_agency_id_data_year_month_num_data_home_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_month
    ADD CONSTRAINT asr_month_agency_id_data_year_month_num_data_home_key UNIQUE (agency_id, data_year, month_num, data_home);


--
-- Name: asr_month_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_month
    ADD CONSTRAINT asr_month_pkey PRIMARY KEY (asr_month_id);


--
-- Name: asr_offense_category_offense_cat_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_offense_category
    ADD CONSTRAINT asr_offense_category_offense_cat_code_key UNIQUE (offense_cat_code);


--
-- Name: asr_offense_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_offense_category
    ADD CONSTRAINT asr_offense_category_pkey PRIMARY KEY (offense_cat_id);


--
-- Name: asr_offense_offense_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_offense
    ADD CONSTRAINT asr_offense_offense_code_key UNIQUE (offense_code);


--
-- Name: asr_offense_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_offense
    ADD CONSTRAINT asr_offense_pkey PRIMARY KEY (offense_id);


--
-- Name: asr_offense_subcat_offense_subcat_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_offense_subcat
    ADD CONSTRAINT asr_offense_subcat_offense_subcat_code_key UNIQUE (offense_subcat_code);


--
-- Name: asr_offense_subcat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_offense_subcat
    ADD CONSTRAINT asr_offense_subcat_pkey PRIMARY KEY (offense_subcat_id);


--
-- Name: asr_race_offense_subcat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asr_race_offense_subcat
    ADD CONSTRAINT asr_race_offense_subcat_pkey PRIMARY KEY (asr_month_id, offense_subcat_id, race_id, juvenile_flag);


--
-- Name: crime_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY crime_type
    ADD CONSTRAINT crime_type_pkey PRIMARY KEY (crime_type_id);


--
-- Name: ct_arrestee_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ct_arrestee
    ADD CONSTRAINT ct_arrestee_pkey PRIMARY KEY (arrestee_id);


--
-- Name: ct_incident_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ct_incident
    ADD CONSTRAINT ct_incident_pkey PRIMARY KEY (incident_id);


--
-- Name: ct_month_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ct_month
    ADD CONSTRAINT ct_month_pkey PRIMARY KEY (ct_month_id);


--
-- Name: ct_offender_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ct_offender
    ADD CONSTRAINT ct_offender_pkey PRIMARY KEY (offender_id);


--
-- Name: ct_offense_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ct_offense
    ADD CONSTRAINT ct_offense_pkey PRIMARY KEY (offense_id);


--
-- Name: ct_property_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ct_property
    ADD CONSTRAINT ct_property_pkey PRIMARY KEY (property_id);


--
-- Name: ct_victim_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ct_victim
    ADD CONSTRAINT ct_victim_pkey PRIMARY KEY (incident_id, victim_type_id);


--
-- Name: ct_weapon_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ct_weapon
    ADD CONSTRAINT ct_weapon_pkey PRIMARY KEY (ct_weapon_id);


--
-- Name: hc_bias_motivation_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hc_bias_motivation
    ADD CONSTRAINT hc_bias_motivation_pkey PRIMARY KEY (offense_id, bias_id);


--
-- Name: hc_incident_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hc_incident
    ADD CONSTRAINT hc_incident_pkey PRIMARY KEY (incident_id);


--
-- Name: hc_offense_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hc_offense
    ADD CONSTRAINT hc_offense_pkey PRIMARY KEY (offense_id);


--
-- Name: hc_quarter_agency_id_quarter_num_data_year_data_home_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hc_quarter
    ADD CONSTRAINT hc_quarter_agency_id_quarter_num_data_year_data_home_key UNIQUE (agency_id, quarter_num, data_year, data_home);


--
-- Name: hc_quarter_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hc_quarter
    ADD CONSTRAINT hc_quarter_pkey PRIMARY KEY (hc_quarter_id);


--
-- Name: hc_victim_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hc_victim
    ADD CONSTRAINT hc_victim_pkey PRIMARY KEY (offense_id, victim_type_id);


--
-- Name: ht_month_agency_id_data_year_month_num_data_home_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ht_month
    ADD CONSTRAINT ht_month_agency_id_data_year_month_num_data_home_key UNIQUE (agency_id, data_year, month_num, data_home);


--
-- Name: ht_month_offense_subcat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ht_month_offense_subcat
    ADD CONSTRAINT ht_month_offense_subcat_pkey PRIMARY KEY (offense_subcat_id, ht_month_id);


--
-- Name: ht_month_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ht_month
    ADD CONSTRAINT ht_month_pkey PRIMARY KEY (ht_month_id);


--
-- Name: nibrs_activity_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_activity_type
    ADD CONSTRAINT nibrs_activity_type_pkey PRIMARY KEY (activity_type_id);


--
-- Name: nibrs_age_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_age
    ADD CONSTRAINT nibrs_age_pkey PRIMARY KEY (age_id);


--
-- Name: nibrs_arrest_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_arrest_type
    ADD CONSTRAINT nibrs_arrest_type_pkey PRIMARY KEY (arrest_type_id);


--
-- Name: nibrs_arrestee_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_pkey PRIMARY KEY (arrestee_id);


--
-- Name: nibrs_arrestee_weapon_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_arrestee_weapon
    ADD CONSTRAINT nibrs_arrestee_weapon_pkey PRIMARY KEY (nibrs_arrestee_weapon_id);


--
-- Name: nibrs_assignment_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_assignment_type
    ADD CONSTRAINT nibrs_assignment_type_pkey PRIMARY KEY (assignment_type_id);


--
-- Name: nibrs_bias_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_bias_list
    ADD CONSTRAINT nibrs_bias_list_pkey PRIMARY KEY (bias_id);


--
-- Name: nibrs_bias_motivation_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_bias_motivation
    ADD CONSTRAINT nibrs_bias_motivation_pkey PRIMARY KEY (bias_id, offense_id);


--
-- Name: nibrs_circumstances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_circumstances
    ADD CONSTRAINT nibrs_circumstances_pkey PRIMARY KEY (circumstances_id);


--
-- Name: nibrs_cleared_except_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_cleared_except
    ADD CONSTRAINT nibrs_cleared_except_pkey PRIMARY KEY (cleared_except_id);


--
-- Name: nibrs_criminal_act_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_criminal_act
    ADD CONSTRAINT nibrs_criminal_act_pkey PRIMARY KEY (criminal_act_id, offense_id);


--
-- Name: nibrs_criminal_act_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_criminal_act_type
    ADD CONSTRAINT nibrs_criminal_act_type_pkey PRIMARY KEY (criminal_act_id);


--
-- Name: nibrs_drug_measure_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_drug_measure_type
    ADD CONSTRAINT nibrs_drug_measure_type_pkey PRIMARY KEY (drug_measure_type_id);


--
-- Name: nibrs_ethnicity_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_ethnicity
    ADD CONSTRAINT nibrs_ethnicity_pkey PRIMARY KEY (ethnicity_id);


--
-- Name: nibrs_grpb_arrest_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_grpb_arrest
    ADD CONSTRAINT nibrs_grpb_arrest_pkey PRIMARY KEY (grpb_arrest_id);


--
-- Name: nibrs_grpb_arrest_weapon_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_grpb_arrest_weapon
    ADD CONSTRAINT nibrs_grpb_arrest_weapon_pkey PRIMARY KEY (nibrs_grpb_arrest_weapon_id);


--
-- Name: nibrs_incident_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_incident
    ADD CONSTRAINT nibrs_incident_pkey PRIMARY KEY (incident_id);


--
-- Name: nibrs_injury_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_injury
    ADD CONSTRAINT nibrs_injury_pkey PRIMARY KEY (injury_id);


--
-- Name: nibrs_justifiable_force_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_justifiable_force
    ADD CONSTRAINT nibrs_justifiable_force_pkey PRIMARY KEY (justifiable_force_id);


--
-- Name: nibrs_location_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_location_type
    ADD CONSTRAINT nibrs_location_type_pkey PRIMARY KEY (location_id);


--
-- Name: nibrs_month_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_month
    ADD CONSTRAINT nibrs_month_pkey PRIMARY KEY (nibrs_month_id);


--
-- Name: nibrs_offender_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_pkey PRIMARY KEY (offender_id);


--
-- Name: nibrs_offense_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_offense
    ADD CONSTRAINT nibrs_offense_pkey PRIMARY KEY (offense_id);


--
-- Name: nibrs_offense_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_offense_type
    ADD CONSTRAINT nibrs_offense_type_pkey PRIMARY KEY (offense_type_id);


--
-- Name: nibrs_prop_desc_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_prop_desc_type
    ADD CONSTRAINT nibrs_prop_desc_type_pkey PRIMARY KEY (prop_desc_id);


--
-- Name: nibrs_prop_loss_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_prop_loss_type
    ADD CONSTRAINT nibrs_prop_loss_type_pkey PRIMARY KEY (prop_loss_id);


--
-- Name: nibrs_property_desc_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_property_desc
    ADD CONSTRAINT nibrs_property_desc_pkey PRIMARY KEY (nibrs_prop_desc_id);


--
-- Name: nibrs_property_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_property
    ADD CONSTRAINT nibrs_property_pkey PRIMARY KEY (property_id);


--
-- Name: nibrs_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_relationship
    ADD CONSTRAINT nibrs_relationship_pkey PRIMARY KEY (relationship_id);


--
-- Name: nibrs_suspect_using_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_suspect_using
    ADD CONSTRAINT nibrs_suspect_using_pkey PRIMARY KEY (suspect_using_id, offense_id);


--
-- Name: nibrs_suspected_drug_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_suspected_drug
    ADD CONSTRAINT nibrs_suspected_drug_pkey PRIMARY KEY (nibrs_suspected_drug_id);


--
-- Name: nibrs_suspected_drug_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_suspected_drug_type
    ADD CONSTRAINT nibrs_suspected_drug_type_pkey PRIMARY KEY (suspected_drug_type_id);


--
-- Name: nibrs_using_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_using_list
    ADD CONSTRAINT nibrs_using_list_pkey PRIMARY KEY (suspect_using_id);


--
-- Name: nibrs_victim_circumstances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_victim_circumstances
    ADD CONSTRAINT nibrs_victim_circumstances_pkey PRIMARY KEY (victim_id, circumstances_id);


--
-- Name: nibrs_victim_injury_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_victim_injury
    ADD CONSTRAINT nibrs_victim_injury_pkey PRIMARY KEY (victim_id, injury_id);


--
-- Name: nibrs_victim_offender_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_victim_offender_rel
    ADD CONSTRAINT nibrs_victim_offender_rel_pkey PRIMARY KEY (nibrs_victim_offender_id);


--
-- Name: nibrs_victim_offense_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_victim_offense
    ADD CONSTRAINT nibrs_victim_offense_pkey PRIMARY KEY (victim_id, offense_id);


--
-- Name: nibrs_victim_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_pkey PRIMARY KEY (victim_id);


--
-- Name: nibrs_victim_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_victim_type
    ADD CONSTRAINT nibrs_victim_type_pkey PRIMARY KEY (victim_type_id);


--
-- Name: nibrs_weapon_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_weapon
    ADD CONSTRAINT nibrs_weapon_pkey PRIMARY KEY (nibrs_weapon_id);


--
-- Name: nibrs_weapon_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nibrs_weapon_type
    ADD CONSTRAINT nibrs_weapon_type_pkey PRIMARY KEY (weapon_id);


--
-- Name: offense_classification_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY offense_classification
    ADD CONSTRAINT offense_classification_pkey PRIMARY KEY (classification_id);


--
-- Name: ref_agency_county_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_agency_county
    ADD CONSTRAINT ref_agency_county_pkey PRIMARY KEY (agency_id, county_id, metro_div_id, data_year);


--
-- Name: ref_agency_covered_by_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_agency_covered_by
    ADD CONSTRAINT ref_agency_covered_by_pkey PRIMARY KEY (agency_id, data_year);


--
-- Name: ref_agency_data_content_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_agency_data_content
    ADD CONSTRAINT ref_agency_data_content_pkey PRIMARY KEY (agency_id, data_year);


--
-- Name: ref_agency_ori_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_ori_key UNIQUE (ori);


--
-- Name: ref_agency_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_pkey PRIMARY KEY (agency_id);


--
-- Name: ref_agency_poc_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_agency_poc
    ADD CONSTRAINT ref_agency_poc_pkey PRIMARY KEY (agency_id, poc_id);


--
-- Name: ref_agency_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_agency_type
    ADD CONSTRAINT ref_agency_type_pkey PRIMARY KEY (agency_type_id);


--
-- Name: ref_campus_population_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_campus_population
    ADD CONSTRAINT ref_campus_population_pkey PRIMARY KEY (campus_id, data_year);


--
-- Name: ref_city_city_name_state_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_city
    ADD CONSTRAINT ref_city_city_name_state_id_key UNIQUE (city_name, state_id);


--
-- Name: ref_city_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_city
    ADD CONSTRAINT ref_city_pkey PRIMARY KEY (city_id);


--
-- Name: ref_continent_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_continent
    ADD CONSTRAINT ref_continent_pkey PRIMARY KEY (continent_id);


--
-- Name: ref_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_country
    ADD CONSTRAINT ref_country_pkey PRIMARY KEY (country_id);


--
-- Name: ref_county_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_county
    ADD CONSTRAINT ref_county_pkey PRIMARY KEY (county_id);


--
-- Name: ref_county_population_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_county_population
    ADD CONSTRAINT ref_county_population_pkey PRIMARY KEY (county_id, data_year);


--
-- Name: ref_department_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_department
    ADD CONSTRAINT ref_department_pkey PRIMARY KEY (department_id);


--
-- Name: ref_division_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_division
    ADD CONSTRAINT ref_division_pkey PRIMARY KEY (division_id);


--
-- Name: ref_field_office_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_field_office
    ADD CONSTRAINT ref_field_office_pkey PRIMARY KEY (field_office_id);


--
-- Name: ref_global_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_global_location
    ADD CONSTRAINT ref_global_location_pkey PRIMARY KEY (global_location_id);


--
-- Name: ref_metro_div_population_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_metro_div_population
    ADD CONSTRAINT ref_metro_div_population_pkey PRIMARY KEY (metro_div_id, data_year);


--
-- Name: ref_metro_division_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_metro_division
    ADD CONSTRAINT ref_metro_division_pkey PRIMARY KEY (metro_div_id);


--
-- Name: ref_msa_msa_name_msa_omb_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_msa
    ADD CONSTRAINT ref_msa_msa_name_msa_omb_code_key UNIQUE (msa_name, msa_omb_code);


--
-- Name: ref_msa_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_msa
    ADD CONSTRAINT ref_msa_pkey PRIMARY KEY (msa_id);


--
-- Name: ref_parent_population_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_parent_population_group
    ADD CONSTRAINT ref_parent_population_group_pkey PRIMARY KEY (parent_pop_group_id);


--
-- Name: ref_poc_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_poc
    ADD CONSTRAINT ref_poc_pkey PRIMARY KEY (poc_id);


--
-- Name: ref_poc_role_assign_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_poc_role_assign
    ADD CONSTRAINT ref_poc_role_assign_pkey PRIMARY KEY (poc_id, poc_role_id);


--
-- Name: ref_poc_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_poc_role
    ADD CONSTRAINT ref_poc_role_pkey PRIMARY KEY (poc_role_id);


--
-- Name: ref_population_family_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_population_family
    ADD CONSTRAINT ref_population_family_pkey PRIMARY KEY (population_family_id);


--
-- Name: ref_population_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_population_group
    ADD CONSTRAINT ref_population_group_pkey PRIMARY KEY (population_group_id);


--
-- Name: ref_race_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_race
    ADD CONSTRAINT ref_race_pkey PRIMARY KEY (race_id);


--
-- Name: ref_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_region
    ADD CONSTRAINT ref_region_pkey PRIMARY KEY (region_id);


--
-- Name: ref_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_state
    ADD CONSTRAINT ref_state_pkey PRIMARY KEY (state_id);


--
-- Name: ref_submitting_agency_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_submitting_agency
    ADD CONSTRAINT ref_submitting_agency_pkey PRIMARY KEY (agency_id);


--
-- Name: ref_tribe_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_tribe
    ADD CONSTRAINT ref_tribe_pkey PRIMARY KEY (tribe_id);


--
-- Name: ref_tribe_population_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_tribe_population
    ADD CONSTRAINT ref_tribe_population_pkey PRIMARY KEY (tribe_id, data_year);


--
-- Name: ref_tribe_tribe_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_tribe
    ADD CONSTRAINT ref_tribe_tribe_name_key UNIQUE (tribe_name);


--
-- Name: ref_university_campus_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_university_campus
    ADD CONSTRAINT ref_university_campus_pkey PRIMARY KEY (campus_id);


--
-- Name: ref_university_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_university
    ADD CONSTRAINT ref_university_pkey PRIMARY KEY (university_id);


--
-- Name: ref_university_university_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ref_university
    ADD CONSTRAINT ref_university_university_name_key UNIQUE (university_name);


--
-- Name: reta_month_agency_id_data_year_month_num_data_home_source_f_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reta_month
    ADD CONSTRAINT reta_month_agency_id_data_year_month_num_data_home_source_f_key UNIQUE (agency_id, data_year, month_num, data_home, source_flag);


--
-- Name: reta_month_offense_subcat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reta_month_offense_subcat
    ADD CONSTRAINT reta_month_offense_subcat_pkey PRIMARY KEY (offense_subcat_id, reta_month_id);


--
-- Name: reta_month_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reta_month
    ADD CONSTRAINT reta_month_pkey PRIMARY KEY (reta_month_id);


--
-- Name: reta_offense_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reta_offense_category
    ADD CONSTRAINT reta_offense_category_pkey PRIMARY KEY (offense_category_id);


--
-- Name: reta_offense_offense_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reta_offense
    ADD CONSTRAINT reta_offense_offense_code_key UNIQUE (offense_code);


--
-- Name: reta_offense_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reta_offense
    ADD CONSTRAINT reta_offense_pkey PRIMARY KEY (offense_id);


--
-- Name: reta_offense_subcat_offense_subcat_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reta_offense_subcat
    ADD CONSTRAINT reta_offense_subcat_offense_subcat_code_key UNIQUE (offense_subcat_code);


--
-- Name: reta_offense_subcat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reta_offense_subcat
    ADD CONSTRAINT reta_offense_subcat_pkey PRIMARY KEY (offense_subcat_id);


--
-- Name: shr_circumstances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_circumstances
    ADD CONSTRAINT shr_circumstances_pkey PRIMARY KEY (circumstances_id);


--
-- Name: shr_incident_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_incident
    ADD CONSTRAINT shr_incident_pkey PRIMARY KEY (incident_id);


--
-- Name: shr_incident_shr_month_id_incident_num_data_home_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_incident
    ADD CONSTRAINT shr_incident_shr_month_id_incident_num_data_home_key UNIQUE (shr_month_id, incident_num, data_home);


--
-- Name: shr_month_agency_id_data_year_month_num_data_home_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_month
    ADD CONSTRAINT shr_month_agency_id_data_year_month_num_data_home_key UNIQUE (agency_id, data_year, month_num, data_home);


--
-- Name: shr_month_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_month
    ADD CONSTRAINT shr_month_pkey PRIMARY KEY (shr_month_id);


--
-- Name: shr_offender_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_offender
    ADD CONSTRAINT shr_offender_pkey PRIMARY KEY (offender_id);


--
-- Name: shr_offense_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_offense
    ADD CONSTRAINT shr_offense_pkey PRIMARY KEY (offense_id);


--
-- Name: shr_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_relationship
    ADD CONSTRAINT shr_relationship_pkey PRIMARY KEY (relationship_id);


--
-- Name: shr_situation_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_situation
    ADD CONSTRAINT shr_situation_pkey PRIMARY KEY (situation_id);


--
-- Name: shr_victim_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shr_victim
    ADD CONSTRAINT shr_victim_pkey PRIMARY KEY (victim_id);


--
-- Name: supp_larceny_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supp_larceny_type
    ADD CONSTRAINT supp_larceny_type_pkey PRIMARY KEY (larceny_type_id);


--
-- Name: supp_month_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supp_month
    ADD CONSTRAINT supp_month_pkey PRIMARY KEY (supp_month_id);


--
-- Name: supp_offense_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supp_offense
    ADD CONSTRAINT supp_offense_pkey PRIMARY KEY (offense_id);


--
-- Name: supp_offense_subcat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supp_offense_subcat
    ADD CONSTRAINT supp_offense_subcat_pkey PRIMARY KEY (offense_subcat_id);


--
-- Name: supp_prop_by_offense_subcat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supp_prop_by_offense_subcat
    ADD CONSTRAINT supp_prop_by_offense_subcat_pkey PRIMARY KEY (supp_month_id, offense_subcat_id);


--
-- Name: supp_property_by_type_value_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supp_property_by_type_value
    ADD CONSTRAINT supp_property_by_type_value_pkey PRIMARY KEY (prop_type_id, supp_month_id);


--
-- Name: supp_property_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supp_property_type
    ADD CONSTRAINT supp_property_type_pkey PRIMARY KEY (prop_type_id);


--
-- Name: aass_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX aass_month ON asr_age_sex_subcat USING btree (asr_month_id);


--
-- Name: agency_county_county_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX agency_county_county_ix ON ref_agency_county USING btree (county_id);


--
-- Name: agency_uni_campus_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX agency_uni_campus_ix ON ref_agency USING btree (campus_id);


--
-- Name: arson_mon_subcat_ami_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX arson_mon_subcat_ami_idx ON arson_month_by_subcat USING btree (arson_month_id);


--
-- Name: arson_month_by_subcat_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX arson_month_by_subcat_idx ON arson_month_by_subcat USING btree (subcategory_id);


--
-- Name: arson_month_ddocname_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX arson_month_ddocname_idx ON arson_month USING btree (ddocname);


--
-- Name: arson_month_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX arson_month_did_idx ON arson_month USING btree (did);


--
-- Name: arson_month_update_flag_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX arson_month_update_flag_idx ON arson_month USING btree (update_flag);


--
-- Name: arson_subcategory_subclass_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX arson_subcategory_subclass_ix ON arson_subcategory USING btree (subclass_id);


--
-- Name: asr_age_range_index1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_age_range_index1 ON asr_age_range USING btree (age_range_name);


--
-- Name: asr_age_sex_sub_off_sub_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_age_sex_sub_off_sub_ix ON asr_age_sex_subcat USING btree (offense_subcat_id);


--
-- Name: asr_age_sex_subcat_index1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_age_sex_subcat_index1 ON asr_age_sex_subcat USING btree (asr_month_id, offense_subcat_id);


--
-- Name: asr_age_sex_subcat_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_age_sex_subcat_status ON asr_age_sex_subcat USING btree (arrest_status);


--
-- Name: asr_age_sexv1_asr_age_range_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_age_sexv1_asr_age_range_ix ON asr_age_sex_subcat USING btree (age_range_id);


--
-- Name: asr_eth_off_eth_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_eth_off_eth_type_ix ON asr_ethnicity_offense USING btree (ethnicity_id);


--
-- Name: asr_eth_off_subcat_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_eth_off_subcat_ix ON asr_ethnicity_offense USING btree (offense_subcat_id);


--
-- Name: asr_month_data_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_month_data_year ON asr_month USING btree (data_year);


--
-- Name: asr_month_ddoc_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_month_ddoc_idx ON asr_month USING btree (ddocname);


--
-- Name: asr_month_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_month_did_idx ON asr_month USING btree (did);


--
-- Name: asr_off_subcat_offense_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_off_subcat_offense_ix ON asr_offense_subcat USING btree (offense_id);


--
-- Name: asr_offense_cat_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_offense_cat_ix ON asr_offense USING btree (offense_cat_id);


--
-- Name: asr_offense_subcat_master_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_offense_subcat_master_idx ON asr_offense_subcat USING btree (master_offense_code);


--
-- Name: asr_offense_subcat_srs_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_offense_subcat_srs_idx ON asr_offense_subcat USING btree (srs_offense_code);


--
-- Name: asr_race_off_sub_off_sub_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_race_off_sub_off_sub_ix ON asr_race_offense_subcat USING btree (offense_subcat_id);


--
-- Name: asr_race_off_sub_ref_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asr_race_off_sub_ref_race_ix ON asr_race_offense_subcat USING btree (race_id);


--
-- Name: city_state_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX city_state_ix ON ref_city USING btree (state_id);


--
-- Name: ct_arrestee_incident_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_arrestee_incident_ix ON ct_arrestee USING btree (incident_id);


--
-- Name: ct_arrestee_nibrs_eth_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_arrestee_nibrs_eth_ix ON ct_arrestee USING btree (ethnicity_id);


--
-- Name: ct_arrestee_nibrs_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_arrestee_nibrs_race_ix ON ct_arrestee USING btree (race_id);


--
-- Name: ct_incident_agency_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_incident_agency_ix ON ct_incident USING btree (agency_id);


--
-- Name: ct_incident_ct_month_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_incident_ct_month_ix ON ct_incident USING btree (ct_month_id);


--
-- Name: ct_incident_ddoc_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_incident_ddoc_idx ON ct_incident USING btree (ddocname);


--
-- Name: ct_incident_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_incident_did_idx ON ct_incident USING btree (did);


--
-- Name: ct_incident_upd_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_incident_upd_idx ON ct_incident USING btree (update_flag);


--
-- Name: ct_month_agency_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_month_agency_ix ON ct_month USING btree (agency_id);


--
-- Name: ct_month_ddoc_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_month_ddoc_idx ON ct_month USING btree (ddocname);


--
-- Name: ct_month_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_month_did_idx ON ct_month USING btree (did);


--
-- Name: ct_offender_incident_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_offender_incident_ix ON ct_offender USING btree (incident_id);


--
-- Name: ct_offender_nibrs_eth_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_offender_nibrs_eth_ix ON ct_offender USING btree (ethnicity_id);


--
-- Name: ct_offender_nibrs_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_offender_nibrs_race_ix ON ct_offender USING btree (race_id);


--
-- Name: ct_offense_ct_incident_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_offense_ct_incident_ix ON ct_offense USING btree (incident_id);


--
-- Name: ct_offense_nibrs_loc_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_offense_nibrs_loc_type_ix ON ct_offense USING btree (location_id);


--
-- Name: ct_offense_nibrs_off_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_offense_nibrs_off_type_ix ON ct_offense USING btree (offense_type_id);


--
-- Name: ct_property_ct_incident_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_property_ct_incident_ix ON ct_property USING btree (incident_id);


--
-- Name: ct_property_prop_desc_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_property_prop_desc_type_ix ON ct_property USING btree (prop_desc_id);


--
-- Name: ct_vic_nibrs_vic_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_vic_nibrs_vic_type_ix ON ct_victim USING btree (victim_type_id);


--
-- Name: ct_weap_nibrs_weap_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_weap_nibrs_weap_type_ix ON ct_weapon USING btree (weapon_id);


--
-- Name: ct_weapon_ct_incident_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ct_weapon_ct_incident_ix ON ct_weapon USING btree (incident_id);


--
-- Name: division_region_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX division_region_ix ON ref_division USING btree (region_id);


--
-- Name: hc_bias_mot_bias_list_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_bias_mot_bias_list_ix ON hc_bias_motivation USING btree (bias_id);


--
-- Name: hc_bias_motiv_off_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_bias_motiv_off_idx ON hc_bias_motivation USING btree (offense_id);


--
-- Name: hc_incident_agency_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_incident_agency_ix ON hc_incident USING btree (agency_id);


--
-- Name: hc_incident_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_incident_did_idx ON hc_incident USING btree (did);


--
-- Name: hc_incident_nibrs_eth_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_incident_nibrs_eth_ix ON hc_incident USING btree (offender_ethnicity_id);


--
-- Name: hc_incident_nibrs_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_incident_nibrs_race_ix ON hc_incident USING btree (offender_race_id);


--
-- Name: hc_incident_qtr_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_incident_qtr_idx ON hc_incident USING btree (hc_quarter_id);


--
-- Name: hc_incident_upd_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_incident_upd_idx ON hc_incident USING btree (update_flag);


--
-- Name: hc_off_nibrs_loc_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_off_nibrs_loc_type_ix ON hc_offense USING btree (location_id);


--
-- Name: hc_off_nibrs_off_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_off_nibrs_off_type_ix ON hc_offense USING btree (offense_type_id);


--
-- Name: hc_offense_incident_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_offense_incident_idx ON hc_offense USING btree (incident_id);


--
-- Name: hc_quarter_ddoc_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_quarter_ddoc_idx ON hc_quarter USING btree (ddocname);


--
-- Name: hc_vic_nibrs_vic_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hc_vic_nibrs_vic_type_ix ON hc_victim USING btree (victim_type_id);


--
-- Name: ht_month_ddocname_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ht_month_ddocname_idx ON ht_month USING btree (ddocname);


--
-- Name: ht_month_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ht_month_did_idx ON ht_month USING btree (did);


--
-- Name: ht_month_off_sub_month_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ht_month_off_sub_month_ix ON ht_month_offense_subcat USING btree (ht_month_id);


--
-- Name: ht_month_update_flag_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ht_month_update_flag_idx ON ht_month USING btree (update_flag);


--
-- Name: metro_division_msa_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX metro_division_msa_ix ON ref_metro_division USING btree (msa_id);


--
-- Name: ni_incnum_agency; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ni_incnum_agency ON nibrs_incident USING btree (agency_id, incident_number);


--
-- Name: nibrs_arr_weapon_arrestee_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_arr_weapon_arrestee_id ON nibrs_arrestee_weapon USING btree (arrestee_id);


--
-- Name: nibrs_arrest_weap_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_arrest_weap_type_ix ON nibrs_arrestee_weapon USING btree (weapon_id);


--
-- Name: nibrs_arrestee_age_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_arrestee_age_ix ON nibrs_arrestee USING btree (age_id);


--
-- Name: nibrs_arrestee_arrest_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_arrestee_arrest_type_ix ON nibrs_arrestee USING btree (arrest_type_id);


--
-- Name: nibrs_arrestee_ethnicity_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_arrestee_ethnicity_ix ON nibrs_arrestee USING btree (ethnicity_id);


--
-- Name: nibrs_arrestee_inc_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_arrestee_inc_id ON nibrs_arrestee USING btree (incident_id);


--
-- Name: nibrs_arrestee_nibrs_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_arrestee_nibrs_race_ix ON nibrs_arrestee USING btree (race_id);


--
-- Name: nibrs_arrestee_offense_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_arrestee_offense_type_ix ON nibrs_arrestee USING btree (offense_type_id);


--
-- Name: nibrs_bias_motiv_off_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_bias_motiv_off_id ON nibrs_bias_motivation USING btree (offense_id);


--
-- Name: nibrs_criminal_act_off_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_criminal_act_off_id ON nibrs_criminal_act USING btree (offense_id);


--
-- Name: nibrs_grpb_ar_age_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_ar_age_ix ON nibrs_grpb_arrest USING btree (age_id);


--
-- Name: nibrs_grpb_ar_eth_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_ar_eth_ix ON nibrs_grpb_arrest USING btree (ethnicity_id);


--
-- Name: nibrs_grpb_ar_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_ar_race_ix ON nibrs_grpb_arrest USING btree (race_id);


--
-- Name: nibrs_grpb_ar_weap_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_ar_weap_type_ix ON nibrs_grpb_arrest_weapon USING btree (weapon_id);


--
-- Name: nibrs_grpb_arrest_dh_ddoc_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_arrest_dh_ddoc_idx ON nibrs_grpb_arrest USING btree (data_home, ddocname);


--
-- Name: nibrs_grpb_arrest_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_arrest_did_idx ON nibrs_grpb_arrest USING btree (did);


--
-- Name: nibrs_grpb_arrest_index1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_arrest_index1 ON nibrs_grpb_arrest USING btree (agency_id, arrest_num, arrest_date, arrest_seq_num);


--
-- Name: nibrs_grpb_arrest_nm_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_arrest_nm_idx ON nibrs_grpb_arrest USING btree (nibrs_month_id);


--
-- Name: nibrs_grpb_arrest_weapon_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_arrest_weapon_idx ON nibrs_grpb_arrest_weapon USING btree (grpb_arrest_id);


--
-- Name: nibrs_grpb_datahome_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_datahome_idx ON nibrs_grpb_arrest USING btree (data_home);


--
-- Name: nibrs_grpb_ddoc_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_grpb_ddoc_idx ON nibrs_grpb_arrest USING btree (ddocname);


--
-- Name: nibrs_incident_clear_ex_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_incident_clear_ex_ix ON nibrs_incident USING btree (cleared_except_id);


--
-- Name: nibrs_incident_datahome_temp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_incident_datahome_temp ON nibrs_incident USING btree (data_home);


--
-- Name: nibrs_incident_ddocname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_incident_ddocname ON nibrs_incident USING btree (ddocname);


--
-- Name: nibrs_incident_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_incident_did_idx ON nibrs_incident USING btree (did);


--
-- Name: nibrs_incident_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_incident_idx1 ON nibrs_incident USING btree (agency_id, incident_date, incident_number, data_home);


--
-- Name: nibrs_incident_incid_agency; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_incident_incid_agency ON nibrs_incident USING btree (agency_id, incident_id);


--
-- Name: nibrs_incident_index1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_incident_index1 ON nibrs_incident USING btree (nibrs_month_id);


--
-- Name: nibrs_incident_index2; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_incident_index2 ON nibrs_incident USING btree (incident_number);


--
-- Name: nibrs_incident_status_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_incident_status_idx ON nibrs_incident USING btree (incident_status);


--
-- Name: nibrs_month_datahome_temp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_month_datahome_temp ON nibrs_month USING btree (data_home);


--
-- Name: nibrs_month_ddoc_dh_nmid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_month_ddoc_dh_nmid ON nibrs_month USING btree (nibrs_month_id, ddocname, data_home);


--
-- Name: nibrs_month_ddoc_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_month_ddoc_idx ON nibrs_month USING btree (ddocname);


--
-- Name: nibrs_month_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_month_did_idx ON nibrs_month USING btree (did);


--
-- Name: nibrs_month_un; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX nibrs_month_un ON nibrs_month USING btree (agency_id, month_num, data_year, data_home);


--
-- Name: nibrs_offender_age_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_offender_age_ix ON nibrs_offender USING btree (age_id);


--
-- Name: nibrs_offender_ethnicity_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_offender_ethnicity_ix ON nibrs_offender USING btree (ethnicity_id);


--
-- Name: nibrs_offender_inc_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_offender_inc_id ON nibrs_offender USING btree (incident_id);


--
-- Name: nibrs_offender_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_offender_race_ix ON nibrs_offender USING btree (race_id);


--
-- Name: nibrs_offense_loc_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_offense_loc_type_ix ON nibrs_offense USING btree (location_id);


--
-- Name: nibrs_offense_off_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_offense_off_type_ix ON nibrs_offense USING btree (offense_type_id);


--
-- Name: nibrs_offense_x1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_offense_x1 ON nibrs_offense USING btree (incident_id);


--
-- Name: nibrs_prop_desc_date_rec_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_prop_desc_date_rec_ix ON nibrs_property_desc USING btree (date_recovered);


--
-- Name: nibrs_property_desc_desc_id_in; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_property_desc_desc_id_in ON nibrs_property_desc USING btree (prop_desc_id);


--
-- Name: nibrs_property_loss_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_property_loss_type_ix ON nibrs_property USING btree (prop_loss_id);


--
-- Name: nibrs_property_property_id_in; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_property_property_id_in ON nibrs_property_desc USING btree (property_id);


--
-- Name: nibrs_property_x1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_property_x1 ON nibrs_property USING btree (incident_id);


--
-- Name: nibrs_sum_month_temp_amyh; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_sum_month_temp_amyh ON nibrs_sum_month_temp USING btree (agency_id, month_num, data_year, data_home);


--
-- Name: nibrs_sum_month_temp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_sum_month_temp_id ON nibrs_sum_month_temp USING btree (nibrs_month_id);


--
-- Name: nibrs_susp_drug_meas_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_susp_drug_meas_type_ix ON nibrs_suspected_drug USING btree (drug_measure_type_id);


--
-- Name: nibrs_susp_drug_prop_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_susp_drug_prop_id ON nibrs_suspected_drug USING btree (property_id);


--
-- Name: nibrs_susp_drug_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_susp_drug_type_ix ON nibrs_suspected_drug USING btree (suspected_drug_type_id);


--
-- Name: nibrs_suspect_using_code_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_suspect_using_code_idx ON nibrs_using_list USING btree (suspect_using_code);


--
-- Name: nibrs_suspect_using_off_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_suspect_using_off_id ON nibrs_suspect_using USING btree (offense_id);


--
-- Name: nibrs_vic_circ_nibrs_circ_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_vic_circ_nibrs_circ_ix ON nibrs_victim_circumstances USING btree (circumstances_id);


--
-- Name: nibrs_vic_injury_nibrs_inj_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_vic_injury_nibrs_inj_ix ON nibrs_victim_injury USING btree (injury_id);


--
-- Name: nibrs_victim_act_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_act_type_ix ON nibrs_victim USING btree (activity_type_id);


--
-- Name: nibrs_victim_age_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_age_ix ON nibrs_victim USING btree (age_id);


--
-- Name: nibrs_victim_assign_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_assign_type_ix ON nibrs_victim USING btree (assignment_type_id);


--
-- Name: nibrs_victim_circ_just_hom_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_circ_just_hom_ix ON nibrs_victim_circumstances USING btree (justifiable_force_id);


--
-- Name: nibrs_victim_ethnicity_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_ethnicity_ix ON nibrs_victim USING btree (ethnicity_id);


--
-- Name: nibrs_victim_off_rel_rel_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_off_rel_rel_ix ON nibrs_victim_offender_rel USING btree (relationship_id);


--
-- Name: nibrs_victim_offender_rel_off; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_offender_rel_off ON nibrs_victim_offender_rel USING btree (offender_id);


--
-- Name: nibrs_victim_offender_rel_vic; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_offender_rel_vic ON nibrs_victim_offender_rel USING btree (victim_id);


--
-- Name: nibrs_victim_offense_off_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_offense_off_id ON nibrs_victim_offense USING btree (offense_id);


--
-- Name: nibrs_victim_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_race_ix ON nibrs_victim USING btree (race_id);


--
-- Name: nibrs_victim_x1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victim_x1 ON nibrs_victim USING btree (incident_id);


--
-- Name: nibrs_victims_vic_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_victims_vic_type_ix ON nibrs_victim USING btree (victim_type_id);


--
-- Name: nibrs_weap_weap_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_weap_weap_type_ix ON nibrs_weapon USING btree (weapon_id);


--
-- Name: nibrs_weapon_off_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nibrs_weapon_off_id ON nibrs_weapon USING btree (offense_id);


--
-- Name: offense_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX offense_ix ON reta_offense_subcat USING btree (offense_id);


--
-- Name: pop_grp_parent_pop_grp_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX pop_grp_parent_pop_grp_ix ON ref_population_group USING btree (parent_pop_group_id);


--
-- Name: ra_state_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ra_state_id ON ref_agency USING btree (state_id);


--
-- Name: ref_agency_city_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_city_ix ON ref_agency USING btree (city_id);


--
-- Name: ref_agency_county_met_div_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_county_met_div_ix ON ref_agency_county USING btree (metro_div_id);


--
-- Name: ref_agency_cov_agency_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_cov_agency_ix ON ref_agency_covered_by USING btree (covered_by_agency_id);


--
-- Name: ref_agency_data_content_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_data_content_idx ON ref_agency_data_content USING btree (agency_id, data_year, reporting_type);


--
-- Name: ref_agency_data_content_idx2; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_data_content_idx2 ON ref_agency_data_content USING btree (agency_id, data_year, reporting_type, nibrs_ct_flag, nibrs_hc_flag, nibrs_leoka_flag, nibrs_arson_flag);


--
-- Name: ref_agency_data_content_idx3; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_data_content_idx3 ON ref_agency_data_content USING btree (agency_id, data_year, reporting_type, summary_rape_def);


--
-- Name: ref_agency_department_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_department_ix ON ref_agency USING btree (department_id);


--
-- Name: ref_agency_field_office_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_field_office_idx ON ref_agency USING btree (field_office_id);


--
-- Name: ref_agency_poc_poc_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_poc_poc_ix ON ref_agency_poc USING btree (poc_id);


--
-- Name: ref_agency_poc_primary_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_poc_primary_idx ON ref_agency_poc USING btree (agency_id, poc_id, primary_poc_flag);


--
-- Name: ref_agency_pop_family_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_pop_family_idx ON ref_agency USING btree (population_family_id);


--
-- Name: ref_agency_short_ori_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_short_ori_idx ON ref_agency USING btree ("substring"((legacy_ori)::text, 0, 7));


--
-- Name: ref_agency_sub_agency_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_sub_agency_ix ON ref_agency USING btree (submitting_agency_id);


--
-- Name: ref_agency_tribe_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_tribe_ix ON ref_agency USING btree (tribe_id);


--
-- Name: ref_agency_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_type_ix ON ref_agency USING btree (agency_type_id);


--
-- Name: ref_agency_type_pop_fam_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_agency_type_pop_fam_ix ON ref_agency_type USING btree (default_pop_family_id);


--
-- Name: ref_country_continent_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_country_continent_ix ON ref_country USING btree (continent_id);


--
-- Name: ref_county_state_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_county_state_ix ON ref_county USING btree (state_id);


--
-- Name: ref_global_loc_country_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_global_loc_country_ix ON ref_global_location USING btree (country_id);


--
-- Name: ref_parent_pop_grp_pop_fam_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_parent_pop_grp_pop_fam_ix ON ref_parent_population_group USING btree (population_family_id);


--
-- Name: ref_poc_role_role_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_poc_role_role_ix ON ref_poc_role_assign USING btree (poc_role_id);


--
-- Name: ref_poc_state_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_poc_state_ix ON ref_poc USING btree (state_id);


--
-- Name: ref_race_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX ref_race_code ON ref_race USING btree (race_code);


--
-- Name: ref_race_sort_order; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_race_sort_order ON ref_race USING btree (sort_order);


--
-- Name: ref_sub_agency_state_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_sub_agency_state_ix ON ref_submitting_agency USING btree (state_id);


--
-- Name: ref_submitting_agency_sai_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_submitting_agency_sai_idx ON ref_submitting_agency USING btree (sai);


--
-- Name: ref_uni_campus_uni_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ref_uni_campus_uni_ix ON ref_university_campus USING btree (university_id);


--
-- Name: reta_month_data_year_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX reta_month_data_year_idx ON reta_month USING btree (data_year);


--
-- Name: reta_month_ddocname_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX reta_month_ddocname_idx ON reta_month USING btree (ddocname);


--
-- Name: reta_month_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX reta_month_did_idx ON reta_month USING btree (did);


--
-- Name: reta_month_upd_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX reta_month_upd_idx ON reta_month USING btree (update_flag DESC);


--
-- Name: reta_offense_cat_crime_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX reta_offense_cat_crime_type_ix ON reta_offense_category USING btree (crime_type_id);


--
-- Name: reta_offense_category_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX reta_offense_category_ix ON reta_offense USING btree (offense_category_id);


--
-- Name: reta_offense_class_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX reta_offense_class_ix ON reta_offense USING btree (classification_id);


--
-- Name: rmos_reta_month_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX rmos_reta_month_id_idx ON reta_month_offense_subcat USING btree (reta_month_id);


--
-- Name: shr_incident_ddocname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_incident_ddocname ON shr_incident USING btree (ddocname);


--
-- Name: shr_incident_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_incident_did_idx ON shr_incident USING btree (did);


--
-- Name: shr_incident_situaton_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_incident_situaton_ix ON shr_incident USING btree (situation_id);


--
-- Name: shr_incident_xmonth_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_incident_xmonth_id ON shr_incident USING btree (shr_month_id);


--
-- Name: shr_month_ddoc_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_month_ddoc_idx ON shr_month USING btree (ddocname);


--
-- Name: shr_month_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_month_did_idx ON shr_month USING btree (did);


--
-- Name: shr_off_weap_type_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_off_weap_type_ix ON shr_offense USING btree (weapon_id);


--
-- Name: shr_offender_age_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_offender_age_ix ON shr_offender USING btree (age_id);


--
-- Name: shr_offender_ethnicity_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_offender_ethnicity_ix ON shr_offender USING btree (ethnicity_id);


--
-- Name: shr_offender_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_offender_race_ix ON shr_offender USING btree (race_id);


--
-- Name: shr_offense_circ_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_offense_circ_ix ON shr_offense USING btree (circumstances_id);


--
-- Name: shr_offense_incident_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_offense_incident_idx ON shr_offense USING btree (incident_id);


--
-- Name: shr_offense_offender_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_offense_offender_idx ON shr_offense USING btree (offender_id);


--
-- Name: shr_offense_rel_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_offense_rel_ix ON shr_offense USING btree (relationship_id);


--
-- Name: shr_offense_victim_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_offense_victim_idx ON shr_offense USING btree (victim_id);


--
-- Name: shr_victim_age_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_victim_age_ix ON shr_victim USING btree (age_id);


--
-- Name: shr_victim_asr_race_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_victim_asr_race_ix ON shr_victim USING btree (race_id);


--
-- Name: shr_victim_ethnicity_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX shr_victim_ethnicity_ix ON shr_victim USING btree (ethnicity_id);


--
-- Name: state_division_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX state_division_ix ON ref_state USING btree (division_id);


--
-- Name: supp_month_ddocname_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX supp_month_ddocname_idx ON supp_month USING btree (ddocname);


--
-- Name: supp_month_did_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX supp_month_did_idx ON supp_month USING btree (did);


--
-- Name: supp_month_un; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX supp_month_un ON supp_month USING btree (agency_id, data_year, month_num, data_home);


--
-- Name: supp_month_upd_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX supp_month_upd_idx ON supp_month USING btree (update_flag);


--
-- Name: supp_off_subcat_off_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX supp_off_subcat_off_ix ON supp_offense_subcat USING btree (offense_id);


--
-- Name: supp_prop_by_off_subcat_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX supp_prop_by_off_subcat_ix ON supp_prop_by_offense_subcat USING btree (offense_subcat_id);


--
-- Name: supp_prop_by_type_val_fk_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX supp_prop_by_type_val_fk_month ON supp_property_by_type_value USING btree (supp_month_id);


--
-- Name: agency_county_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency_county
    ADD CONSTRAINT agency_county_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: agency_county_county_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency_county
    ADD CONSTRAINT agency_county_county_fk FOREIGN KEY (county_id) REFERENCES ref_county(county_id);


--
-- Name: agency_state_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT agency_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);


--
-- Name: agency_uni_campus_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT agency_uni_campus_fk FOREIGN KEY (campus_id) REFERENCES ref_university_campus(campus_id);


--
-- Name: arson_mon_by_subcat_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY arson_month_by_subcat
    ADD CONSTRAINT arson_mon_by_subcat_fk FOREIGN KEY (subcategory_id) REFERENCES arson_subcategory(subcategory_id);


--
-- Name: arson_mon_by_subcat_month_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY arson_month_by_subcat
    ADD CONSTRAINT arson_mon_by_subcat_month_fk FOREIGN KEY (arson_month_id) REFERENCES arson_month(arson_month_id) ON DELETE CASCADE;


--
-- Name: arson_month_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY arson_month
    ADD CONSTRAINT arson_month_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: arson_subcategory_subclass_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY arson_subcategory
    ADD CONSTRAINT arson_subcategory_subclass_fk FOREIGN KEY (subclass_id) REFERENCES arson_subclassification(subclass_id);


--
-- Name: asr_age_sex_sub_off_sub_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_age_sex_subcat
    ADD CONSTRAINT asr_age_sex_sub_off_sub_fk FOREIGN KEY (offense_subcat_id) REFERENCES asr_offense_subcat(offense_subcat_id);


--
-- Name: asr_age_sexv1_asr_age_range_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_age_sex_subcat
    ADD CONSTRAINT asr_age_sexv1_asr_age_range_fk FOREIGN KEY (age_range_id) REFERENCES asr_age_range(age_range_id);


--
-- Name: asr_age_sexv1_asr_month_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_age_sex_subcat
    ADD CONSTRAINT asr_age_sexv1_asr_month_fk FOREIGN KEY (asr_month_id) REFERENCES asr_month(asr_month_id) ON DELETE CASCADE;


--
-- Name: asr_eth_off_eth_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_ethnicity_offense
    ADD CONSTRAINT asr_eth_off_eth_type_fk FOREIGN KEY (ethnicity_id) REFERENCES asr_ethnicity(ethnicity_id);


--
-- Name: asr_eth_off_month_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_ethnicity_offense
    ADD CONSTRAINT asr_eth_off_month_fk FOREIGN KEY (asr_month_id) REFERENCES asr_month(asr_month_id) ON DELETE CASCADE;


--
-- Name: asr_eth_off_subcat_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_ethnicity_offense
    ADD CONSTRAINT asr_eth_off_subcat_fk FOREIGN KEY (offense_subcat_id) REFERENCES asr_offense_subcat(offense_subcat_id);


--
-- Name: asr_juvenile_dis_month_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_juvenile_disposition
    ADD CONSTRAINT asr_juvenile_dis_month_fk FOREIGN KEY (asr_month_id) REFERENCES asr_month(asr_month_id) ON DELETE CASCADE;


--
-- Name: asr_month_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_month
    ADD CONSTRAINT asr_month_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: asr_off_subcat_offense_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_offense_subcat
    ADD CONSTRAINT asr_off_subcat_offense_fk FOREIGN KEY (offense_id) REFERENCES asr_offense(offense_id);


--
-- Name: asr_offense_cat_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_offense
    ADD CONSTRAINT asr_offense_cat_fk FOREIGN KEY (offense_cat_id) REFERENCES asr_offense_category(offense_cat_id);


--
-- Name: asr_race_off_sub_off_sub_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_race_offense_subcat
    ADD CONSTRAINT asr_race_off_sub_off_sub_fk FOREIGN KEY (offense_subcat_id) REFERENCES asr_offense_subcat(offense_subcat_id);


--
-- Name: asr_race_off_sub_ref_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_race_offense_subcat
    ADD CONSTRAINT asr_race_off_sub_ref_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);


--
-- Name: asr_race_off_subcat_month_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asr_race_offense_subcat
    ADD CONSTRAINT asr_race_off_subcat_month_fk FOREIGN KEY (asr_month_id) REFERENCES asr_month(asr_month_id) ON DELETE CASCADE;


--
-- Name: city_state_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_city
    ADD CONSTRAINT city_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);


--
-- Name: ct_arrestee_incident_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_arrestee
    ADD CONSTRAINT ct_arrestee_incident_fk FOREIGN KEY (incident_id) REFERENCES ct_incident(incident_id) ON DELETE CASCADE;


--
-- Name: ct_arrestee_nibrs_eth_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_arrestee
    ADD CONSTRAINT ct_arrestee_nibrs_eth_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);


--
-- Name: ct_arrestee_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_arrestee
    ADD CONSTRAINT ct_arrestee_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);


--
-- Name: ct_incident_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_incident
    ADD CONSTRAINT ct_incident_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: ct_incident_ct_month_fk1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_incident
    ADD CONSTRAINT ct_incident_ct_month_fk1 FOREIGN KEY (ct_month_id) REFERENCES ct_month(ct_month_id) ON DELETE CASCADE;


--
-- Name: ct_month_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_month
    ADD CONSTRAINT ct_month_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: ct_offender_incident_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_offender
    ADD CONSTRAINT ct_offender_incident_fk FOREIGN KEY (incident_id) REFERENCES ct_incident(incident_id) ON DELETE CASCADE;


--
-- Name: ct_offender_nibrs_eth_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_offender
    ADD CONSTRAINT ct_offender_nibrs_eth_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);


--
-- Name: ct_offender_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_offender
    ADD CONSTRAINT ct_offender_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);


--
-- Name: ct_offense_ct_incident_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_offense
    ADD CONSTRAINT ct_offense_ct_incident_fk FOREIGN KEY (incident_id) REFERENCES ct_incident(incident_id) ON DELETE CASCADE;


--
-- Name: ct_offense_nibrs_loc_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_offense
    ADD CONSTRAINT ct_offense_nibrs_loc_type_fk FOREIGN KEY (location_id) REFERENCES nibrs_location_type(location_id);


--
-- Name: ct_offense_nibrs_off_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_offense
    ADD CONSTRAINT ct_offense_nibrs_off_type_fk FOREIGN KEY (offense_type_id) REFERENCES nibrs_offense_type(offense_type_id);


--
-- Name: ct_property_ct_incident_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_property
    ADD CONSTRAINT ct_property_ct_incident_fk FOREIGN KEY (incident_id) REFERENCES ct_incident(incident_id) ON DELETE CASCADE;


--
-- Name: ct_property_prop_desc_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_property
    ADD CONSTRAINT ct_property_prop_desc_type_fk FOREIGN KEY (prop_desc_id) REFERENCES nibrs_prop_desc_type(prop_desc_id);


--
-- Name: ct_vic_nibrs_vic_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_victim
    ADD CONSTRAINT ct_vic_nibrs_vic_type_fk FOREIGN KEY (victim_type_id) REFERENCES nibrs_victim_type(victim_type_id);


--
-- Name: ct_victim_ct_incident_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_victim
    ADD CONSTRAINT ct_victim_ct_incident_fk FOREIGN KEY (incident_id) REFERENCES ct_incident(incident_id) ON DELETE CASCADE;


--
-- Name: ct_weap_nibrs_weap_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_weapon
    ADD CONSTRAINT ct_weap_nibrs_weap_type_fk FOREIGN KEY (weapon_id) REFERENCES nibrs_weapon_type(weapon_id);


--
-- Name: ct_weapon_ct_incident_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ct_weapon
    ADD CONSTRAINT ct_weapon_ct_incident_fk FOREIGN KEY (incident_id) REFERENCES ct_incident(incident_id) ON DELETE CASCADE;


--
-- Name: division_region_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_division
    ADD CONSTRAINT division_region_fk FOREIGN KEY (region_id) REFERENCES ref_region(region_id);


--
-- Name: hc_bias_mot_bias_list_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_bias_motivation
    ADD CONSTRAINT hc_bias_mot_bias_list_fk FOREIGN KEY (bias_id) REFERENCES nibrs_bias_list(bias_id);


--
-- Name: hc_bias_motn_off_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_bias_motivation
    ADD CONSTRAINT hc_bias_motn_off_fk FOREIGN KEY (offense_id) REFERENCES hc_offense(offense_id) ON DELETE CASCADE;


--
-- Name: hc_inc_off_inc_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_offense
    ADD CONSTRAINT hc_inc_off_inc_fk FOREIGN KEY (incident_id) REFERENCES hc_incident(incident_id) ON DELETE CASCADE;


--
-- Name: hc_incident_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_incident
    ADD CONSTRAINT hc_incident_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: hc_incident_nibrs_eth_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_incident
    ADD CONSTRAINT hc_incident_nibrs_eth_fk FOREIGN KEY (offender_ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);


--
-- Name: hc_incident_quarter_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_incident
    ADD CONSTRAINT hc_incident_quarter_fk FOREIGN KEY (hc_quarter_id) REFERENCES hc_quarter(hc_quarter_id) ON DELETE CASCADE;


--
-- Name: hc_incident_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_incident
    ADD CONSTRAINT hc_incident_race_fk FOREIGN KEY (offender_race_id) REFERENCES ref_race(race_id);


--
-- Name: hc_off_nibrs_loc_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_offense
    ADD CONSTRAINT hc_off_nibrs_loc_type_fk FOREIGN KEY (location_id) REFERENCES nibrs_location_type(location_id);


--
-- Name: hc_off_nibrs_off_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_offense
    ADD CONSTRAINT hc_off_nibrs_off_type_fk FOREIGN KEY (offense_type_id) REFERENCES nibrs_offense_type(offense_type_id);


--
-- Name: hc_quarter_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_quarter
    ADD CONSTRAINT hc_quarter_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: hc_vic_nibrs_vic_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_victim
    ADD CONSTRAINT hc_vic_nibrs_vic_type_fk FOREIGN KEY (victim_type_id) REFERENCES nibrs_victim_type(victim_type_id);


--
-- Name: hc_victim_hc_off_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hc_victim
    ADD CONSTRAINT hc_victim_hc_off_fk FOREIGN KEY (offense_id) REFERENCES hc_offense(offense_id) ON DELETE CASCADE;


--
-- Name: ht_month_off_sub_month_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ht_month_offense_subcat
    ADD CONSTRAINT ht_month_off_sub_month_fk FOREIGN KEY (ht_month_id) REFERENCES ht_month(ht_month_id) ON DELETE CASCADE;


--
-- Name: ht_month_off_sub_off_sub_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ht_month_offense_subcat
    ADD CONSTRAINT ht_month_off_sub_off_sub_fk FOREIGN KEY (offense_subcat_id) REFERENCES reta_offense_subcat(offense_subcat_id);


--
-- Name: ht_month_ref_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ht_month
    ADD CONSTRAINT ht_month_ref_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: metro_division_msa_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_metro_division
    ADD CONSTRAINT metro_division_msa_fk FOREIGN KEY (msa_id) REFERENCES ref_msa(msa_id);


--
-- Name: nibrs_arrest_weap_arrest_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_arrestee_weapon
    ADD CONSTRAINT nibrs_arrest_weap_arrest_fk FOREIGN KEY (arrestee_id) REFERENCES nibrs_arrestee(arrestee_id) ON DELETE CASCADE;


--
-- Name: nibrs_arrest_weap_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_arrestee_weapon
    ADD CONSTRAINT nibrs_arrest_weap_type_fk FOREIGN KEY (weapon_id) REFERENCES nibrs_weapon_type(weapon_id);


--
-- Name: nibrs_arrestee_age_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);


--
-- Name: nibrs_arrestee_arrest_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_arrest_type_fk FOREIGN KEY (arrest_type_id) REFERENCES nibrs_arrest_type(arrest_type_id);


--
-- Name: nibrs_arrestee_ethnicity_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);


--
-- Name: nibrs_arrestee_inc_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_inc_fk FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;


--
-- Name: nibrs_arrestee_offense_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_offense_type_fk FOREIGN KEY (offense_type_id) REFERENCES nibrs_offense_type(offense_type_id);


--
-- Name: nibrs_arrestee_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_arrestee
    ADD CONSTRAINT nibrs_arrestee_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);


--
-- Name: nibrs_bias_mot_list_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_bias_motivation
    ADD CONSTRAINT nibrs_bias_mot_list_fk FOREIGN KEY (bias_id) REFERENCES nibrs_bias_list(bias_id);


--
-- Name: nibrs_bias_mot_offense_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_bias_motivation
    ADD CONSTRAINT nibrs_bias_mot_offense_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;


--
-- Name: nibrs_criminal_act_offense_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_criminal_act
    ADD CONSTRAINT nibrs_criminal_act_offense_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;


--
-- Name: nibrs_criminal_act_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_criminal_act
    ADD CONSTRAINT nibrs_criminal_act_type_fk FOREIGN KEY (criminal_act_id) REFERENCES nibrs_criminal_act_type(criminal_act_id);


--
-- Name: nibrs_grpb_ar_age_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_grpb_arrest
    ADD CONSTRAINT nibrs_grpb_ar_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);


--
-- Name: nibrs_grpb_ar_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_grpb_arrest
    ADD CONSTRAINT nibrs_grpb_ar_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: nibrs_grpb_ar_eth_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_grpb_arrest
    ADD CONSTRAINT nibrs_grpb_ar_eth_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);


--
-- Name: nibrs_grpb_ar_weap_ar_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_grpb_arrest_weapon
    ADD CONSTRAINT nibrs_grpb_ar_weap_ar_fk FOREIGN KEY (grpb_arrest_id) REFERENCES nibrs_grpb_arrest(grpb_arrest_id) ON DELETE CASCADE;


--
-- Name: nibrs_grpb_ar_weap_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_grpb_arrest_weapon
    ADD CONSTRAINT nibrs_grpb_ar_weap_type_fk FOREIGN KEY (weapon_id) REFERENCES nibrs_weapon_type(weapon_id);


--
-- Name: nibrs_grpb_arrest_nm_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_grpb_arrest
    ADD CONSTRAINT nibrs_grpb_arrest_nm_id FOREIGN KEY (nibrs_month_id) REFERENCES nibrs_month(nibrs_month_id) ON DELETE CASCADE;


--
-- Name: nibrs_grpb_arrest_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_grpb_arrest
    ADD CONSTRAINT nibrs_grpb_arrest_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);


--
-- Name: nibrs_incident_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_incident
    ADD CONSTRAINT nibrs_incident_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: nibrs_incident_clear_ex_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_incident
    ADD CONSTRAINT nibrs_incident_clear_ex_fk FOREIGN KEY (cleared_except_id) REFERENCES nibrs_cleared_except(cleared_except_id);


--
-- Name: nibrs_incident_month_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_incident
    ADD CONSTRAINT nibrs_incident_month_fk FOREIGN KEY (nibrs_month_id) REFERENCES nibrs_month(nibrs_month_id) ON DELETE CASCADE;


--
-- Name: nibrs_month_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_month
    ADD CONSTRAINT nibrs_month_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: nibrs_offender_age_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);


--
-- Name: nibrs_offender_ethnicity_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);


--
-- Name: nibrs_offender_nibrs_inci_fk1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_nibrs_inci_fk1 FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;


--
-- Name: nibrs_offender_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_offender
    ADD CONSTRAINT nibrs_offender_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);


--
-- Name: nibrs_offense_inc_fk1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_offense
    ADD CONSTRAINT nibrs_offense_inc_fk1 FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;


--
-- Name: nibrs_offense_loc_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_offense
    ADD CONSTRAINT nibrs_offense_loc_type_fk FOREIGN KEY (location_id) REFERENCES nibrs_location_type(location_id);


--
-- Name: nibrs_offense_off_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_offense
    ADD CONSTRAINT nibrs_offense_off_type_fk FOREIGN KEY (offense_type_id) REFERENCES nibrs_offense_type(offense_type_id);


--
-- Name: nibrs_prop_desc_prop_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_property_desc
    ADD CONSTRAINT nibrs_prop_desc_prop_fk FOREIGN KEY (property_id) REFERENCES nibrs_property(property_id) ON DELETE CASCADE;


--
-- Name: nibrs_prop_desc_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_property_desc
    ADD CONSTRAINT nibrs_prop_desc_type_fk FOREIGN KEY (prop_desc_id) REFERENCES nibrs_prop_desc_type(prop_desc_id);


--
-- Name: nibrs_property_inc_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_property
    ADD CONSTRAINT nibrs_property_inc_fk FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;


--
-- Name: nibrs_property_loss_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_property
    ADD CONSTRAINT nibrs_property_loss_type_fk FOREIGN KEY (prop_loss_id) REFERENCES nibrs_prop_loss_type(prop_loss_id);


--
-- Name: nibrs_susp_drug_meas_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_suspected_drug
    ADD CONSTRAINT nibrs_susp_drug_meas_type_fk FOREIGN KEY (drug_measure_type_id) REFERENCES nibrs_drug_measure_type(drug_measure_type_id);


--
-- Name: nibrs_susp_drug_prop_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_suspected_drug
    ADD CONSTRAINT nibrs_susp_drug_prop_fk FOREIGN KEY (property_id) REFERENCES nibrs_property(property_id) ON DELETE CASCADE;


--
-- Name: nibrs_susp_drug_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_suspected_drug
    ADD CONSTRAINT nibrs_susp_drug_type_fk FOREIGN KEY (suspected_drug_type_id) REFERENCES nibrs_suspected_drug_type(suspected_drug_type_id);


--
-- Name: nibrs_suspect_using_list_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_suspect_using
    ADD CONSTRAINT nibrs_suspect_using_list_fk FOREIGN KEY (suspect_using_id) REFERENCES nibrs_using_list(suspect_using_id);


--
-- Name: nibrs_suspect_using_off_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_suspect_using
    ADD CONSTRAINT nibrs_suspect_using_off_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;


--
-- Name: nibrs_vic_circ_nibrs_circ_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_circumstances
    ADD CONSTRAINT nibrs_vic_circ_nibrs_circ_fk FOREIGN KEY (circumstances_id) REFERENCES nibrs_circumstances(circumstances_id);


--
-- Name: nibrs_vic_circ_nibrs_vic_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_circumstances
    ADD CONSTRAINT nibrs_vic_circ_nibrs_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;


--
-- Name: nibrs_vic_injury_nibrs_inj_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_injury
    ADD CONSTRAINT nibrs_vic_injury_nibrs_inj_fk FOREIGN KEY (injury_id) REFERENCES nibrs_injury(injury_id);


--
-- Name: nibrs_vic_injury_nibrs_vic_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_injury
    ADD CONSTRAINT nibrs_vic_injury_nibrs_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;


--
-- Name: nibrs_vic_off_nibrs_off_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_offense
    ADD CONSTRAINT nibrs_vic_off_nibrs_off_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;


--
-- Name: nibrs_vic_off_nibrs_vic_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_offense
    ADD CONSTRAINT nibrs_vic_off_nibrs_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;


--
-- Name: nibrs_victim_act_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_act_type_fk FOREIGN KEY (activity_type_id) REFERENCES nibrs_activity_type(activity_type_id);


--
-- Name: nibrs_victim_age_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);


--
-- Name: nibrs_victim_assign_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_assign_type_fk FOREIGN KEY (assignment_type_id) REFERENCES nibrs_assignment_type(assignment_type_id);


--
-- Name: nibrs_victim_circ_just_hom_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_circumstances
    ADD CONSTRAINT nibrs_victim_circ_just_hom_fk FOREIGN KEY (justifiable_force_id) REFERENCES nibrs_justifiable_force(justifiable_force_id);


--
-- Name: nibrs_victim_ethnicity_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);


--
-- Name: nibrs_victim_inc_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_inc_fk FOREIGN KEY (incident_id) REFERENCES nibrs_incident(incident_id) ON DELETE CASCADE;


--
-- Name: nibrs_victim_off_rel_off_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_offender_rel
    ADD CONSTRAINT nibrs_victim_off_rel_off_fk FOREIGN KEY (offender_id) REFERENCES nibrs_offender(offender_id) ON DELETE CASCADE;


--
-- Name: nibrs_victim_off_rel_rel_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_offender_rel
    ADD CONSTRAINT nibrs_victim_off_rel_rel_fk FOREIGN KEY (relationship_id) REFERENCES nibrs_relationship(relationship_id);


--
-- Name: nibrs_victim_off_rel_vic_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim_offender_rel
    ADD CONSTRAINT nibrs_victim_off_rel_vic_fk FOREIGN KEY (victim_id) REFERENCES nibrs_victim(victim_id) ON DELETE CASCADE;


--
-- Name: nibrs_victim_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victim_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);


--
-- Name: nibrs_victims_vic_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_victim
    ADD CONSTRAINT nibrs_victims_vic_type_fk FOREIGN KEY (victim_type_id) REFERENCES nibrs_victim_type(victim_type_id);


--
-- Name: nibrs_weap_off_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_weapon
    ADD CONSTRAINT nibrs_weap_off_fk FOREIGN KEY (offense_id) REFERENCES nibrs_offense(offense_id) ON DELETE CASCADE;


--
-- Name: nibrs_weap_weap_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nibrs_weapon
    ADD CONSTRAINT nibrs_weap_weap_type_fk FOREIGN KEY (weapon_id) REFERENCES nibrs_weapon_type(weapon_id);


--
-- Name: offense_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reta_offense_subcat
    ADD CONSTRAINT offense_fk FOREIGN KEY (offense_id) REFERENCES reta_offense(offense_id);


--
-- Name: pop_grp_parent_pop_grp_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_population_group
    ADD CONSTRAINT pop_grp_parent_pop_grp_fk FOREIGN KEY (parent_pop_group_id) REFERENCES ref_parent_population_group(parent_pop_group_id);


--
-- Name: ref_agency_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency_covered_by
    ADD CONSTRAINT ref_agency_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: ref_agency_city_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_city_fk FOREIGN KEY (city_id) REFERENCES ref_city(city_id);


--
-- Name: ref_agency_county_met_div_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency_county
    ADD CONSTRAINT ref_agency_county_met_div_fk FOREIGN KEY (metro_div_id) REFERENCES ref_metro_division(metro_div_id);


--
-- Name: ref_agency_cov_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency_covered_by
    ADD CONSTRAINT ref_agency_cov_agency_fk FOREIGN KEY (covered_by_agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: ref_agency_data_content_ag_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency_data_content
    ADD CONSTRAINT ref_agency_data_content_ag_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: ref_agency_department_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_department_fk FOREIGN KEY (department_id) REFERENCES ref_department(department_id);


--
-- Name: ref_agency_field_office_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_field_office_fk FOREIGN KEY (field_office_id) REFERENCES ref_field_office(field_office_id);


--
-- Name: ref_agency_poc_poc_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency_poc
    ADD CONSTRAINT ref_agency_poc_poc_fk FOREIGN KEY (poc_id) REFERENCES ref_poc(poc_id);


--
-- Name: ref_agency_pop_family_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_pop_family_fk FOREIGN KEY (population_family_id) REFERENCES ref_population_family(population_family_id);


--
-- Name: ref_agency_sub_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_sub_agency_fk FOREIGN KEY (submitting_agency_id) REFERENCES ref_submitting_agency(agency_id);


--
-- Name: ref_agency_tribe_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_tribe_fk FOREIGN KEY (tribe_id) REFERENCES ref_tribe(tribe_id);


--
-- Name: ref_agency_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency
    ADD CONSTRAINT ref_agency_type_fk FOREIGN KEY (agency_type_id) REFERENCES ref_agency_type(agency_type_id);


--
-- Name: ref_agency_type_pop_fam_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_agency_type
    ADD CONSTRAINT ref_agency_type_pop_fam_fk FOREIGN KEY (default_pop_family_id) REFERENCES ref_population_family(population_family_id);


--
-- Name: ref_campus_pop_campus_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_campus_population
    ADD CONSTRAINT ref_campus_pop_campus_fk FOREIGN KEY (campus_id) REFERENCES ref_university_campus(campus_id);


--
-- Name: ref_country_continent_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_country
    ADD CONSTRAINT ref_country_continent_fk FOREIGN KEY (continent_id) REFERENCES ref_continent(continent_id);


--
-- Name: ref_county_pop_county_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_county_population
    ADD CONSTRAINT ref_county_pop_county_fk FOREIGN KEY (county_id) REFERENCES ref_county(county_id);


--
-- Name: ref_county_state_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_county
    ADD CONSTRAINT ref_county_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);


--
-- Name: ref_global_loc_country_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_global_location
    ADD CONSTRAINT ref_global_loc_country_fk FOREIGN KEY (country_id) REFERENCES ref_country(country_id);


--
-- Name: ref_metro_div_pop_metro_div_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_metro_div_population
    ADD CONSTRAINT ref_metro_div_pop_metro_div_fk FOREIGN KEY (metro_div_id) REFERENCES ref_metro_division(metro_div_id);


--
-- Name: ref_parent_pop_grp_pop_fam_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_parent_population_group
    ADD CONSTRAINT ref_parent_pop_grp_pop_fam_fk FOREIGN KEY (population_family_id) REFERENCES ref_population_family(population_family_id);


--
-- Name: ref_poc_role_poc_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_poc_role_assign
    ADD CONSTRAINT ref_poc_role_poc_fk FOREIGN KEY (poc_id) REFERENCES ref_poc(poc_id);


--
-- Name: ref_poc_role_role_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_poc_role_assign
    ADD CONSTRAINT ref_poc_role_role_fk FOREIGN KEY (poc_role_id) REFERENCES ref_poc_role(poc_role_id);


--
-- Name: ref_poc_state_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_poc
    ADD CONSTRAINT ref_poc_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);


--
-- Name: ref_sub_agency_state_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_submitting_agency
    ADD CONSTRAINT ref_sub_agency_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);


--
-- Name: ref_tribe_pop_tribe_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_tribe_population
    ADD CONSTRAINT ref_tribe_pop_tribe_fk FOREIGN KEY (tribe_id) REFERENCES ref_tribe(tribe_id);


--
-- Name: ref_uni_campus_uni_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_university_campus
    ADD CONSTRAINT ref_uni_campus_uni_fk FOREIGN KEY (university_id) REFERENCES ref_university(university_id);


--
-- Name: reta_mon_off_off_subcat_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reta_month_offense_subcat
    ADD CONSTRAINT reta_mon_off_off_subcat_fk FOREIGN KEY (offense_subcat_id) REFERENCES reta_offense_subcat(offense_subcat_id);


--
-- Name: reta_mon_off_subcat_mon_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reta_month_offense_subcat
    ADD CONSTRAINT reta_mon_off_subcat_mon_fk FOREIGN KEY (reta_month_id) REFERENCES reta_month(reta_month_id) ON DELETE CASCADE;


--
-- Name: reta_offense_cat_crime_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reta_offense_category
    ADD CONSTRAINT reta_offense_cat_crime_type_fk FOREIGN KEY (crime_type_id) REFERENCES crime_type(crime_type_id);


--
-- Name: reta_offense_category_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reta_offense
    ADD CONSTRAINT reta_offense_category_fk FOREIGN KEY (offense_category_id) REFERENCES reta_offense_category(offense_category_id);


--
-- Name: reta_offense_class_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reta_offense
    ADD CONSTRAINT reta_offense_class_fk FOREIGN KEY (classification_id) REFERENCES offense_classification(classification_id);


--
-- Name: return_a_month_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reta_month
    ADD CONSTRAINT return_a_month_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: shr_incident_month_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_incident
    ADD CONSTRAINT shr_incident_month_fk FOREIGN KEY (shr_month_id) REFERENCES shr_month(shr_month_id) ON DELETE CASCADE;


--
-- Name: shr_incident_situaton_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_incident
    ADD CONSTRAINT shr_incident_situaton_fk FOREIGN KEY (situation_id) REFERENCES shr_situation(situation_id);


--
-- Name: shr_month_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_month
    ADD CONSTRAINT shr_month_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: shr_off_weap_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_offense
    ADD CONSTRAINT shr_off_weap_type_fk FOREIGN KEY (weapon_id) REFERENCES nibrs_weapon_type(weapon_id);


--
-- Name: shr_offender_age_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_offender
    ADD CONSTRAINT shr_offender_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);


--
-- Name: shr_offender_ethnicity_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_offender
    ADD CONSTRAINT shr_offender_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);


--
-- Name: shr_offender_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_offender
    ADD CONSTRAINT shr_offender_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);


--
-- Name: shr_offense_circ_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_offense
    ADD CONSTRAINT shr_offense_circ_fk FOREIGN KEY (circumstances_id) REFERENCES shr_circumstances(circumstances_id);


--
-- Name: shr_offense_incident_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_offense
    ADD CONSTRAINT shr_offense_incident_fk FOREIGN KEY (incident_id) REFERENCES shr_incident(incident_id) ON DELETE CASCADE;


--
-- Name: shr_offense_offender_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_offense
    ADD CONSTRAINT shr_offense_offender_fk FOREIGN KEY (offender_id) REFERENCES shr_offender(offender_id);


--
-- Name: shr_offense_rel_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_offense
    ADD CONSTRAINT shr_offense_rel_fk FOREIGN KEY (relationship_id) REFERENCES shr_relationship(relationship_id);


--
-- Name: shr_offense_victim_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_offense
    ADD CONSTRAINT shr_offense_victim_fk FOREIGN KEY (victim_id) REFERENCES shr_victim(victim_id);


--
-- Name: shr_victim_age_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_victim
    ADD CONSTRAINT shr_victim_age_fk FOREIGN KEY (age_id) REFERENCES nibrs_age(age_id);


--
-- Name: shr_victim_ethnicity_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_victim
    ADD CONSTRAINT shr_victim_ethnicity_fk FOREIGN KEY (ethnicity_id) REFERENCES nibrs_ethnicity(ethnicity_id);


--
-- Name: shr_victim_race_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shr_victim
    ADD CONSTRAINT shr_victim_race_fk FOREIGN KEY (race_id) REFERENCES ref_race(race_id);


--
-- Name: state_division_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ref_state
    ADD CONSTRAINT state_division_fk FOREIGN KEY (division_id) REFERENCES ref_division(division_id);


--
-- Name: supp_month_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supp_month
    ADD CONSTRAINT supp_month_agency_fk FOREIGN KEY (agency_id) REFERENCES ref_agency(agency_id);


--
-- Name: supp_off_subcat_off_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supp_offense_subcat
    ADD CONSTRAINT supp_off_subcat_off_fk FOREIGN KEY (offense_id) REFERENCES supp_offense(offense_id);


--
-- Name: supp_prop_by_off_mon_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supp_prop_by_offense_subcat
    ADD CONSTRAINT supp_prop_by_off_mon_fk FOREIGN KEY (supp_month_id) REFERENCES supp_month(supp_month_id) ON DELETE CASCADE;


--
-- Name: supp_prop_by_off_subcat_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supp_prop_by_offense_subcat
    ADD CONSTRAINT supp_prop_by_off_subcat_fk FOREIGN KEY (offense_subcat_id) REFERENCES supp_offense_subcat(offense_subcat_id);


--
-- Name: supp_prop_by_type_mon_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supp_property_by_type_value
    ADD CONSTRAINT supp_prop_by_type_mon_fk FOREIGN KEY (supp_month_id) REFERENCES supp_month(supp_month_id) ON DELETE CASCADE;


--
-- Name: supp_prop_by_type_prop_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supp_property_by_type_value
    ADD CONSTRAINT supp_prop_by_type_prop_type_fk FOREIGN KEY (prop_type_id) REFERENCES supp_property_type(prop_type_id);


--
-- PostgreSQL database dump complete
--

