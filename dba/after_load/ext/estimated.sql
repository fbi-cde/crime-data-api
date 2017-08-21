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

-- asr_estimated
DROP TABLE IF EXISTS asr_estimated_csv;
CREATE TABLE asr_estimated_csv
(
year smallint NOT NULL,
total_arrests bigint,
homicide bigint,
rape bigint,
robbery bigint,
aggravated_assault bigint,
burglary bigint,
larceny bigint,
motor_vehicle_theft bigint,
arson bigint,
violent_crime bigint,
property_crime bigint,
other_assault bigint,
forgery bigint,
fraud bigint,
embezzlement bigint,
stolen_property bigint,
vandalism bigint,
weapons bigint,
prostitution bigint,
other_sex_offenses bigint,
drug_abuse bigint,
gambling bigint,
against_family bigint,
dui bigint,
liquor_laws bigint,
drunkenness bigint,
disorderly_conduct bigint,
vagrancy bigint,
other bigint,
suspicion bigint,
curfew_loitering bigint
);

\COPY asr_estimated_csv FROM 'asr_estimated.csv' DELIMITER ',' HEADER CSV;

DROP TABLE IF EXISTS asr_national;

CREATE TABLE asr_national
(
  id serial PRIMARY KEY,
  year smallint NOT NULL,
  population bigint,
  total_arrests bigint,
  homicide bigint,
  rape bigint,
  robbery bigint,
  aggravated_assault bigint,
  burglary bigint,
  larceny bigint,
  motor_vehicle_theft bigint,
  arson bigint,
  violent_crime bigint,
  property_crime bigint,
  other_assault bigint,
  forgery bigint,
  fraud bigint,
  embezzlement bigint,
  stolen_property bigint,
  vandalism bigint,
  weapons bigint,
  prostitution bigint,
  other_sex_offenses bigint,
  drug_abuse bigint,
  gambling bigint,
  against_family bigint,
  dui bigint,
  liquor_laws bigint,
  drunkenness bigint,
  disorderly_conduct bigint,
  vagrancy bigint,
  other bigint,
  suspicion bigint,
  curfew_loitering bigint
);

INSERT INTO asr_national(year, population, total_arrests , homicide, rape, robbery, aggravated_assault, burglary, larceny, motor_vehicle_theft, arson, violent_crime, property_crime, other_assault, forgery, fraud, embezzlement, stolen_property, vandalism, weapons, prostitution, other_sex_offenses, drug_abuse, gambling, against_family, dui, liquor_laws, drunkenness, disorderly_conduct, vagrancy, other, suspicion, curfew_loitering)
SELECT
c.year,
r.population,
c.total_arrests,
c.homicide,
c.rape,
c.robbery,
c.aggravated_assault,
c.burglary,
c.larceny,
c.motor_vehicle_theft,
c.arson,
c.violent_crime,
c.property_crime,
c.other_assault,
c.forgery,
c.fraud,
c.embezzlement,
c.stolen_property,
c.vandalism,
c.weapons,
c.prostitution,
c.other_sex_offenses,
c.drug_abuse,
c.gambling,
c.against_family,
c.dui,
c.liquor_laws,
c.drunkenness,
c.disorderly_conduct,
c.vagrancy,
c.other,
c.suspicion,
c.curfew_loitering
FROM asr_estimated_csv c
LEFT OUTER JOIN reta_estimated r ON r.year=c.year
WHERE r.state_id IS NULL;

DROP TABLE asr_estimated_csv;
