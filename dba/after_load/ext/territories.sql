DROP TABLE IF EXISTS reta_territories_csv;

CREATE TABLE reta_territories_csv (
year smallint NOT NULL,
state_name text,
state_abbr character varying(2),
locality text,
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
arson bigint,
caveats text
);

\COPY reta_territories_csv FROM 'territories.csv' DELIMITER ',' HEADER CSV;

DROP TABLE IF EXISTS reta_territories;

CREATE TABLE reta_territories
(
  territory_id serial PRIMARY KEY NOT NULL,
  year smallint NOT NULL,
  state_id smallint REFERENCES ref_state(state_id),
  state_abbr character varying(2),
  locality text,
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
  arson bigint,
  caveats text,
  UNIQUE (year, state_id, locality)
);

INSERT INTO reta_territories(year, state_id, state_abbr, locality, population, violent_crime, homicide, rape_legacy, rape_revised, robbery, aggravated_assault, property_crime, burglary, larceny, motor_vehicle_theft, arson, caveats)
SELECT
ret.year,
rs.state_id,
ret.state_abbr,
ret.locality,
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
ret.arson,
ret.caveats
FROM reta_territories_csv ret
JOIN ref_state rs ON rs.state_postal_abbr = ret.state_abbr;

DROP TABLE reta_territories_csv;
