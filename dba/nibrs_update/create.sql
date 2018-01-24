-- nibrs_incident (This one could take awhile - grab some popcorn)
DROP TABLE IF EXISTS nibrs_incident_csv;
CREATE TABLE nibrs_incident_csv (
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

DROP TABLE IF EXISTS nibrs_month_csv;
CREATE TABLE nibrs_month_csv (
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

DROP TABLE IF EXISTS nibrs_arrestee_csv;
CREATE TABLE nibrs_arrestee_csv (
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

DROP TABLE IF EXISTS nibrs_arrestee_weapon_csv;
CREATE TABLE nibrs_arrestee_weapon_csv (
arrestee_id bigint NOT NULL,
weapon_id smallint NOT NULL,
nibrs_arrestee_weapon_id bigint NOT NULL
);

DROP TABLE IF EXISTS nibrs_bias_motivation_csv;
CREATE TABLE nibrs_bias_motivation_csv (
bias_id smallint NOT NULL,
offense_id bigint NOT NULL
);

DROP TABLE IF EXISTS nibrs_criminal_act_csv;
CREATE TABLE nibrs_criminal_act_csv (
criminal_act_id smallint NOT NULL,
offense_id bigint NOT NULL
);

DROP TABLE IF EXISTS nibrs_offense_csv;
CREATE TABLE nibrs_offense_csv (
offense_id bigint NOT NULL,
incident_id bigint NOT NULL,
offense_type_id bigint NOT NULL,
attempt_complete_flag character(1),
location_id bigint NOT NULL,
num_premises_entered smallint,
method_entry_code character(1),
ff_line_number bigint
);

DROP TABLE IF EXISTS nibrs_offender_csv;
CREATE TABLE nibrs_offender_csv (
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

DROP TABLE IF EXISTS nibrs_property_csv;
CREATE TABLE nibrs_property_csv (
property_id bigint NOT NULL,
incident_id bigint NOT NULL,
prop_loss_id smallint NOT NULL,
stolen_count smallint,
recovered_count smallint,
ff_line_number bigint
);

DROP TABLE IF EXISTS nibrs_property_desc_csv;
CREATE TABLE nibrs_property_desc_csv (
property_id bigint NOT NULL,
prop_desc_id smallint NOT NULL,
property_value bigint,
date_recovered timestamp without time zone,
nibrs_prop_desc_id bigint NOT NULL
);

DROP TABLE IF EXISTS nibrs_suspected_drug_csv;
CREATE TABLE nibrs_suspected_drug_csv (
suspected_drug_type_id smallint NOT NULL,
property_id bigint NOT NULL,
est_drug_qty double precision,
drug_measure_type_id smallint,
nibrs_suspected_drug_id bigint NOT NULL
);

DROP TABLE IF EXISTS nibrs_suspect_using_csv;
CREATE TABLE nibrs_suspect_using_csv (
suspect_using_id smallint NOT NULL,
offense_id bigint NOT NULL
);

DROP TABLE IF EXISTS nibrs_victim_csv;
CREATE TABLE nibrs_victim_csv (
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
ff_line_number bigint,
age_range_low_num smallint,
age_range_high_num smallint
);

DROP TABLE IF EXISTS nibrs_victim_circumstances_csv;
CREATE TABLE nibrs_victim_circumstances_csv (
victim_id bigint NOT NULL,
circumstances_id smallint NOT NULL,
justifiable_force_id smallint
);

DROP TABLE IF EXISTS nibrs_victim_injury_csv;
CREATE TABLE nibrs_victim_injury_csv (
victim_id bigint NOT NULL,
injury_id smallint NOT NULL
);

DROP TABLE IF EXISTS nibrs_victim_offense_csv;
CREATE TABLE nibrs_victim_offense_csv (
victim_id bigint NOT NULL,
offense_id bigint NOT NULL
);

DROP TABLE IF EXISTS nibrs_victim_offender_rel_csv;
CREATE TABLE nibrs_victim_offender_rel_csv (
victim_id bigint NOT NULL,
offender_id bigint NOT NULL,
relationship_id smallint NOT NULL,
nibrs_victim_offender_id bigint NOT NULL
);

DROP TABLE IF EXISTS nibrs_weapon_csv;
CREATE TABLE nibrs_weapon_csv (
weapon_id smallint NOT NULL,
offense_id bigint NOT NULL,
nibrs_weapon_id bigint NOT NULL
);
