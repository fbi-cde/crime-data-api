-- You will have to run each step of this manually on the server
DROP TABLE IF EXISTS reta_estimated_csv;

CREATE TABLE reta_estimated_csv
(
year smallint NOT NULL,
state_abbr character varying(2),
population bigint,
violent_crime bigint,
homicide bigint,
rape_legacy bigint,
rape_revised bigint,
robbery bigint,
aggravated_assault bigint,
property_crime bigint,
burglary bigint,
larceny bigint,
motor_vehicle_theft bigint,
caveats text
);

\COPY reta_estimated_csv FROM 'estimated_1995_2015.csv' DELIMITER ',' HEADER CSV;

DROP TABLE IF EXISTS reta_estimated;

CREATE TABLE reta_estimated
(
  estimate_id SERIAL PRIMARY KEY,
  year smallint NOT NULL,
  state_id smallint REFERENCES ref_state (state_id),
  state_abbr character varying(2),
  population bigint,
  violent_crime bigint,
  homicide bigint,
  rape_legacy bigint,
  rape_revised bigint,
  robbery bigint,
  aggravated_assault bigint,
  property_crime bigint,
  burglary bigint,
  larceny bigint,
  motor_vehicle_theft bigint,
  caveats text,
  UNIQUE (year, state_id)
);

INSERT INTO reta_estimated(year, state_id, state_abbr, population, violent_crime, homicide, rape_legacy, rape_revised, robbery, aggravated_assault, property_crime, burglary, larceny, motor_vehicle_theft, caveats)
SELECT
ret.year,
rs.state_id,
ret.state_abbr,
ret.population,
ret.violent_crime,
ret.homicide,
ret.rape_legacy,
ret.rape_revised,
ret.robbery,
ret.aggravated_assault,
ret.property_crime,
ret.burglary,
ret.larceny,
ret.motor_vehicle_theft,
ret.caveats
FROM reta_estimated_csv ret
LEFT OUTER JOIN ref_state rs ON rs.state_postal_abbr=ret.state_abbr;

DROP TABLE reta_estimated_csv;
