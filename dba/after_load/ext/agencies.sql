DROP TABLE IF EXISTS icpsr_2012;
CREATE TABLE icpsr_2012 (
ori character(9) PRIMARY KEY,
zip character(5),
lat numeric,
lng numeric
);

\COPY icpsr_2012 FROM 'icpsr_2012.csv' DELIMITER ',' HEADER CSV;

DROP TABLE IF EXISTS agency_name_edits;
CREATE TABLE agency_name_edits (
  ori character(9),
  agency_type_name text,
  edited_flag text,
  edited_name text,
  pub_agency_name text,
  icpsr_name text
);

\COPY agency_name_edits FROM 'agency_name_edits.csv' DELIMITER ',' HEADER CSV;
