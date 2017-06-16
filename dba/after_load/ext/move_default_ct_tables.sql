ALTER TABLE ct_arrestee RENAME TO ct_arrestee_bad;
ALTER TABLE ct_incident RENAME to ct_incident_bad;
ALTER TABLE ct_offense RENAME TO ct_offense_bad;
ALTER TABLE ct_offender RENAME to ct_offender_bad;
ALTER TABLE ct_property RENAME to ct_property_bad;
ALTER TABLE ct_victim RENAME to ct_victim_bad;
ALTER TABLE ct_month RENAME to ct_month_bad;

-- Remake the tables for us to match what was there before. Fields
-- annotated with empty will never by populated by our loading script
CREATE TABLE ct_arrestee (
    arrestee_id serial NOT NULL PRIMARY KEY,
    incident_id bigint NOT NULL,
    age smallint,
    sex_code character(1),
    ethnicity_id smallint,
    race_id smallint
);

CREATE TABLE ct_incident (
    incident_id serial NOT NULL PRIMARY KEY,
    agency_id bigint NOT NULL,
    data_year smallint NOT NULL,
    incident_number character varying(15),
    incident_date timestamp without time zone,
    source_flag character(1) NOT NULL,
    ddocname character varying(100),  -- empty
    report_date timestamp without time zone,
    prepared_date timestamp without time zone,
    report_date_flag character(1),
    incident_hour smallint,
    cleared_except_flag character(1),
    update_flag character(1),
    ct_month_id bigint,
    ff_line_number bigint,  -- empty
    data_home character(1) DEFAULT 'T'::bpchar NOT NULL,
    orig_format character(1),
    unknown_offender character(2),
    did bigint,  -- empty
    nibrs_incident_id bigint  --empty
);

COMMENT ON COLUMN ct_incident.source_flag IS 'This field indicates the source of the data.  R came into the system as a report, I means the data was derived from NIBRS data.';

CREATE TABLE ct_offense (
    offense_id serial NOT NULL PRIMARY KEY,
    incident_id bigint NOT NULL,
    offense_type_id bigint NOT NULL,
    location_id bigint NOT NULL,
    ct_offense_flag character(1)
);

CREATE TABLE ct_offender (
    offender_id serial NOT NULL,
    incident_id bigint NOT NULL,
    age smallint,
    sex_code character(1),
    ethnicity_id smallint,
    race_id smallint
);

CREATE TABLE ct_property (
    property_id serial NOT NULL PRIMARY KEY,
    prop_desc_id smallint NOT NULL,
    incident_id bigint NOT NULL,
    stolen_value bigint,
    recovered_flag character(1),
    date_recovered timestamp without time zone,
    recovered_value bigint
);

CREATE TABLE ct_victim (
    incident_id serial NOT NULL,
    victim_type_id smallint NOT NULL
);

ALTER TABLE ONLY ct_victim
    ADD CONSTRAINT ct_victim_pkey PRIMARY KEY (incident_id, victim_type_id);

-- indices
CREATE INDEX ct_arrestee_incident_ix ON ct_arrestee USING btree (incident_id);
CREATE INDEX ct_arrestee_nibrs_eth_ix ON ct_arrestee USING btree (ethnicity_id);
CREATE INDEX ct_arrestee_nibrs_race_ix ON ct_arrestee USING btree (race_id);
CREATE INDEX ct_incident_agency_ix ON ct_incident USING btree (agency_id);
CREATE INDEX ct_incident_ct_month_ix ON ct_incident USING btree (ct_month_id);
CREATE INDEX ct_month_agency_ix ON ct_month USING btree (agency_id);
CREATE INDEX ct_offender_incident_ix ON ct_offender USING btree (incident_id);
CREATE INDEX ct_offender_nibrs_eth_ix ON ct_offender USING btree (ethnicity_id);
CREATE INDEX ct_offender_nibrs_race_ix ON ct_offender USING btree (race_id);
CREATE INDEX ct_offense_ct_incident_ix ON ct_offense USING btree (incident_id);
CREATE INDEX ct_offense_nibrs_loc_type_ix ON ct_offense USING btree (location_id);
CREATE INDEX ct_offense_nibrs_off_type_ix ON ct_offense USING btree (offense_type_id);
CREATE INDEX ct_property_ct_incident_ix ON ct_property USING btree (incident_id);
CREATE INDEX ct_property_prop_desc_type_ix ON ct_property USING btree (prop_desc_id);
CREATE INDEX ct_vic_nibrs_vic_type_ix ON ct_victim USING btree (victim_type_id);
CREATE INDEX ct_weap_nibrs_weap_type_ix ON ct_weapon USING btree (weapon_id);
CREATE INDEX ct_weapon_ct_incident_ix ON ct_weapon USING btree (incident_id);
