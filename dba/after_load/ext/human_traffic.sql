DROP TABLE IF EXISTS ht_incident_csv;

CREATE TABLE ht_agency_csv
(
  ori text,
  months_reported smallint,
  sex_acts integer,
  sex_acts_cleared integer,
  sex_acts_juvenile_cleared integer,
  servitude integer,
  servitude_cleared integer,
  servitude_juvenile_cleared integer
);

DROP TABLE IF EXISTS ht_agency;

CREATE TABLE ht_agency
(
  id serial PRIMARY KEY,
  year smallint,
  ori text,
  agency_id bigint,
  agency_name text,
  population bigint,
  state_id integer,
  state_abbr text,
  months_reported smallint,
  sex_acts integer,
  sex_acts_cleared integer,
  sex_acts_juvenile_cleared integer,
  servitude integer,
  servitude_cleared integer,
  servitude_juvenile_cleared integer
);

\COPY ht_agency_csv FROM 'ht_2013.csv' DELIMITER ',' HEADER CSV;

INSERT INTO ht_agency(year, ori, agency_id, agency_name, population, state_id, state_abbr, months_reported, sex_acts, sex_acts_cleared, sex_acts_juvenile_cleared, servitude, servitude_cleared, servitude_juvenile_cleared)
SELECT
      2013 AS year,
      csv.ori || '00' AS ori,
      c.agency_id AS agency_id,
      c.agency_name AS agency_name,
      rap.population AS population,
      c.state_id AS state_id,
      c.state_abbr AS state_abbr,
      csv.months_reported,
      csv.sex_acts,
      csv.sex_acts_cleared,
      csv.sex_acts_juvenile_cleared,
      csv.servitude,
      csv.servitude_cleared,
      csv.servitude_juvenile_cleared
      FROM ht_agency_csv csv
      LEFT OUTER JOIN cde_agencies c ON c.ori = (csv.ori || '00')
      LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id=c.agency_id AND rap.data_year = 2013;

TRUNCATE TABLE ht_agency_csv;
\COPY ht_agency_csv FROM 'ht_2014.csv' DELIMITER ',' HEADER CSV;

INSERT INTO ht_agency(year, ori, agency_id, agency_name, population, state_id, state_abbr, months_reported, sex_acts, sex_acts_cleared, sex_acts_juvenile_cleared, servitude, servitude_cleared, servitude_juvenile_cleared)
SELECT
2014 AS year,
csv.ori || '00' AS ori,
c.agency_id AS agency_id,
c.agency_name AS agency_name,
rap.population AS population,
c.state_id AS state_id,
c.state_abbr AS state_abbr,
csv.months_reported,
csv.sex_acts,
csv.sex_acts_cleared,
csv.sex_acts_juvenile_cleared,
csv.servitude,
csv.servitude_cleared,
csv.servitude_juvenile_cleared
FROM ht_agency_csv csv
LEFT OUTER JOIN cde_agencies c ON c.ori = (csv.ori || '00')
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id=c.agency_id AND rap.data_year = 2014;

TRUNCATE TABLE ht_agency_csv;
\COPY ht_agency_csv FROM 'ht_2015.csv' DELIMITER ',' HEADER CSV;

INSERT INTO ht_agency(year, ori, agency_id, agency_name, population, state_id, state_abbr, months_reported, sex_acts, sex_acts_cleared, sex_acts_juvenile_cleared, servitude, servitude_cleared, servitude_juvenile_cleared)
SELECT
2015 AS year,
csv.ori || '00' AS ori,
c.agency_id AS agency_id,
c.agency_name AS agency_name,
rap.population AS population,
c.state_id AS state_id,
c.state_abbr AS state_abbr,
csv.months_reported,
csv.sex_acts,
csv.sex_acts_cleared,
csv.sex_acts_juvenile_cleared,
csv.servitude,
csv.servitude_cleared,
csv.servitude_juvenile_cleared
FROM ht_agency_csv csv
LEFT OUTER JOIN cde_agencies c ON c.ori = (csv.ori || '00')
LEFT OUTER JOIN ref_agency_population rap ON rap.agency_id=c.agency_id AND rap.data_year = 2015;

DROP TABLE ht_agency_csv;

DROP SEQUENCE IF EXISTS htcubeseq CASCADE;
CREATE SEQUENCE htcubeseq;

DROP TABLE IF EXISTS ht_summary;
CREATE TABLE ht_summary AS
SELECT
NEXTVAL('htcubeseq') AS ht_summary_id,
GROUPING(
year,
state_id,
state_abbr,
agency_id,
ori,
agency_name
) AS grouping_bitmap,
SUM(population) AS population,
COUNT(DISTINCT agency_id) AS agencies,
SUM(months_reported) AS months_reported,
SUM(sex_acts) AS sex_acts,
SUM(sex_acts_cleared) AS sex_acts_cleared,
SUM(sex_acts_juvenile_cleared) AS sex_acts_juvenile_cleared,
SUM(servitude) AS servitude,
SUM(servitude_cleared) AS servitude_cleared,
SUM(servitude_juvenile_cleared) AS servitude_juvenile_cleared,
year,
state_id,
state_abbr,
agency_id,
ori,
agency_name
FROM ht_agency
WHERE state_abbr NOT IN ('AS', 'CZ', 'GU', 'MP', 'PR', 'VI')
GROUP BY CUBE (year, (state_id, state_abbr), (agency_id, ori, agency_name));
