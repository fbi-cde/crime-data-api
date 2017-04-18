-- You will have to run each step of this manually on the server
DROP TABLE IF EXISTS reta_estimated_temp;

CREATE TABLE reta_estimated_temp
(
  year smallint NOT NULL,
  state_id bigint,
  state_abbr character varying(2),
  population bigint,
  violent_crime bigint,
  homicide bigint,
  rape_legacy bigint,
  rape bigint,
  robbery bigint,
  aggravated_assault bigint,
  property_crime bigint,
  burglary bigint,
  larceny bigint,
  motor_vehicle_theft bigint,
  caveats text
)
WITH (
     OIDS = FALSE
);

\COPY reta_estimated_temp FROM 'estimated_1995_2015.csv' DELIMITER ',' HEADER CSV;

UPDATE reta_estimated_temp
SET state_id=ref_state.state_id FROM ref_state WHERE ref_state.state_postal_abbr=reta_estimated_temp.state_abbr;

ALTER TABLE ONLY reta_estimated_temp
ADD CONSTRAINT reta_estimated_pkey PRIMARY KEY (year, state_id);

ALTER TABLE ONLY reta_estimated_temp
ADD CONSTRAINT reta_estimated_state_fk FOREIGN KEY (state_id) REFERENCES ref_state(state_id);

DROP TABLE IF EXISTS reta_estimated CASCADE;
ALTER TABLE reta_estimated_temp RENAME TO reta_estimated;
