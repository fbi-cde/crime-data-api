SET work_mem='2GB';
SET synchronous_commit TO OFF;

DROP TABLE IF EXISTS agency_reporting;
CREATE TABLE agency_reporting AS
SELECT rm.data_year,
rm.agency_id,
bool_and(CASE WHEN rm.reported_flag = 'Y' THEN TRUE ELSE FALSE END) AS reported
FROM reta_month rm
GROUP BY rm.data_year, rm.agency_id;

DROP TABLE IF EXISTS covering_counts;
CREATE TABLE covering_counts AS
SELECT data_year, covered_by_agency_id, COUNT(agency_id) AS count
FROM ref_agency_covered_by_flat
GROUP BY covered_by_agency_id, data_year;

DROP TABLE IF EXISTS agency_sums CASCADE;
CREATE TABLE agency_sums (
 id SERIAL PRIMARY KEY,
 data_year smallint NOT NULL,
 agency_id bigint NOT NULL, 
 offense_subcat_id bigint NOT NULL,
 reported integer, 
 unfounded integer,
 actual integer,
 cleared integer,
 juvenile_cleared integer
);

DO
$do$
DECLARE
   arr integer[] := array[0, 11, 12, 20, 21, 22, 23, 24, 25, 30, 31, 32, 33, 34, 40, 41, 42, 43, 44, 45, 50, 51, 52, 53, 60, 70, 71, 72, 73, 80, 81, 82];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    RAISE NOTICE 'Executing Inserts for offense_subcat_id: %', i;
    SET work_mem='3GB';
    INSERT INTO agency_sums (data_year, agency_id, offense_subcat_id, reported, unfounded, actual, cleared, juvenile_cleared)  
    SELECT rm.data_year,
    rm.agency_id,
    ros.offense_subcat_id,
    SUM(rmos.reported_count) AS reported,
    SUM(rmos.unfounded_count) AS unfounded,
    SUM(rmos.actual_count) AS actual,
    SUM(rmos.cleared_count) AS cleared,
    SUM(rmos.juvenile_cleared_count) AS juvenile_cleared 
    FROM (SELECT * from reta_month_offense_subcat where offense_subcat_id=i AND reta_month_offense_subcat.actual_status NOT IN (2, 3, 4)) rmos
    JOIN reta_offense_subcat ros ON (rmos.offense_subcat_id = ros.offense_subcat_id)
    JOIN reta_month rm ON (rmos.reta_month_id = rm.reta_month_id)
    JOIN agency_reporting ar ON ar.agency_id=rm.agency_id AND ar.data_year=rm.data_year
    WHERE ar.reported IS TRUE
    GROUP BY rm.data_year, rm.agency_id, ros.offense_subcat_id;
   END LOOP;
END
$do$;


drop table agency_sums_view CASCADE;

DROP function IF EXISTS create_state_partition_and_insert() CASCADE;
CREATE OR REPLACE FUNCTION create_state_partition_and_insert() RETURNS trigger AS
  $BODY$
    DECLARE
      partition_state TEXT;
      partition TEXT;
    BEGIN
      partition_state := lower(NEW.state_postal_abbr);
      partition := TG_RELNAME || '_' || partition_state;
      IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=lower(partition)) THEN
        RAISE NOTICE 'A partition has been created %', partition;
        EXECUTE 'CREATE TABLE IF NOT EXISTS ' || partition || ' (check (lower(state_postal_abbr) = lower(''' || NEW.state_postal_abbr || '''))) INHERITS (' || TG_RELNAME || ');';
      END IF;
      EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').* RETURNING agency_id;';
      RETURN NULL;
    END;
  $BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

create TABLE agency_sums_view (
 id bigint,
 year smallint NOT NULL,
 agency_id bigint NOT NULL, 
 offense_id bigint NOT NULL,
 offense_subcat_id bigint NOT NULL,
 offense_code varchar(20),
 offense_name text,
 reported integer, 
 unfounded integer,
 actual integer,
 cleared integer,
 juvenile_cleared integer,
 ori text,
 ucr_agency_name text,
 ncic_agency_name text,
 pub_agency_name text,
 offense_subcat_name text,
 offense_subcat_code text,
 state_postal_abbr varchar(2)
);

DROP TRIGGER IF EXISTS agency_sums_view_insert_state_partition ON agency_sums_view;
CREATE TRIGGER agency_sums_view_insert_state_partition
BEFORE INSERT ON agency_sums_view
FOR EACH ROW EXECUTE PROCEDURE create_state_partition_and_insert();


INSERT INTO agency_sums_view(id, year, agency_id, offense_subcat_id, offense_id, offense_code, offense_name, reported, unfounded, actual, cleared, juvenile_cleared,ori,pub_agency_name,offense_subcat_name,offense_subcat_code,state_postal_abbr)
  SELECT 
    asums.id,
    asums.data_year as year,
    asums.agency_id,
    asums.offense_subcat_id,
    ro.offense_id,
    ro.offense_code,
    ro.offense_name,
    asums.reported,
    asums.unfounded,
    asums.actual,
    asums.cleared,
    asums.juvenile_cleared,
    ag.ori,
    ag.pub_agency_name,
    ros.offense_subcat_name,
    ros.offense_subcat_code,
    rs.state_postal_abbr
  from agency_sums asums 
  JOIN ref_agency ag ON (asums.agency_id = ag.agency_id)
  JOIN reta_offense_subcat ros ON (asums.offense_subcat_id = ros.offense_subcat_id)
  JOIN reta_offense ro ON ros.offense_id=ro.offense_id
  JOIN ref_state rs ON (rs.state_id  = ag.state_id);

DROP TABLE IF EXISTS agency_sums_by_offense;
CREATE table agency_sums_by_offense (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL,
offense_id bigint NOT NULL,
reported integer,
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer
);

INSERT INTO agency_sums_by_offense(data_year, agency_id, offense_id, reported, unfounded, actual, cleared, juvenile_cleared)
SELECT
a.data_year,
a.agency_id,
ro.offense_id,
SUM(a.reported) AS reported,
SUM(a.unfounded) AS unfounded,
SUM(a.actual) AS actual,
SUM(a.cleared) AS cleared,
SUM(a.juvenile_cleared) AS juvenile_cleared
FROM agency_sums a
JOIN reta_offense_subcat ros ON a.offense_subcat_id = ros.offense_subcat_id
JOIN reta_offense ro ON ro.offense_id = ros.offense_id
GROUP by a.data_year, a.agency_id, ro.offense_id;

DROP TABLE IF EXISTS agency_offenses_view CASCADE;
create TABLE agency_offenses_view (
 id SERIAL,
 year smallint NOT NULL,
 agency_id bigint NOT NULL, 
 offense_id integer,
 offense_code varchar(20),
 offense_name text,
 reported integer, 
 unfounded integer,
 actual integer,
 cleared integer,
 juvenile_cleared integer,
 ori text,
 pub_agency_name text,
 state_postal_abbr varchar(2)
);

DROP TRIGGER IF EXISTS agency_offenses_view_insert_state_partition ON agency_offenses_view;
CREATE TRIGGER agency_offenses_view_insert_state_partition
BEFORE INSERT ON agency_offenses_view
FOR EACH ROW EXECUTE PROCEDURE create_state_partition_and_insert();

INSERT INTO agency_offenses_view(year, agency_id, offense_id, offense_code, offense_name, reported, unfounded, actual, cleared, juvenile_cleared, ori, pub_agency_name, state_postal_abbr)
  SELECT 
    a.data_year,
    a.agency_id,
    a.offense_id,
    ro.offense_code,
    ro.offense_name,
    a.reported,
    a.unfounded,
    a.actual,
    a.cleared,
    a.juvenile_cleared,
    c.ori,
    c.agency_name,
    c.state_abbr
FROM agency_sums_by_offense a
JOIN cde_agencies c ON c.agency_id=a.agency_id
JOIN reta_offense ro ON ro.offense_id = a.offense_id;

DROP TABLE IF EXISTS agency_sums_aggravated;
CREATE table agency_sums_aggravated (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL,
reported integer,
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer
);

INSERT INTO agency_sums_aggravated(data_year, agency_id, reported, unfounded, actual, cleared, juvenile_cleared)
SELECT
a.data_year,
a.agency_id,
SUM(a.reported) AS reported,
SUM(a.unfounded) AS unfounded,
SUM(a.actual) AS actual,
SUM(a.cleared) AS cleared,
SUM(a.juvenile_cleared) AS juvenile_cleared
FROM agency_sums a
JOIN reta_offense_subcat ros ON a.offense_subcat_id = ros.offense_subcat_id
JOIN reta_offense ro ON ro.offense_id = ros.offense_id
WHERE a.offense_subcat_id IN (40, 41, 42, 43, 44)
GROUP by a.data_year, a.agency_id, ro.offense_id;

INSERT INTO agency_offenses_view(year, agency_id, offense_id, offense_code, offense_name, reported, unfounded, actual, cleared, juvenile_cleared, ori, pub_agency_name, state_postal_abbr)
SELECT
a.data_year,
a.agency_id,
40 as offense_id,
'X_AGG' AS offense_code,
'Aggravated Assault' as offense_name,
a.reported,
a.unfounded,
a.actual,
a.cleared,
a.juvenile_cleared,
c.ori,
c.agency_name,
c.state_abbr
FROM agency_sums_aggravated a
JOIN cde_agencies c ON c.agency_id=a.agency_id;

DROP TABLE agency_sums_aggravated;
DROP TABLE agency_sums_by_offense;

-- classifications grouping
DROP TABLE IF EXISTS agency_sums_by_classification;
CREATE table agency_sums_by_classification (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL,
classification TEXT NOT NULL,
reported integer,
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer
);

INSERT INTO agency_sums_by_classification(data_year, agency_id, classification, reported, unfounded, actual, cleared, juvenile_cleared)
SELECT
a.data_year,
a.agency_id,
oc.classification_name AS classification,
SUM(a.reported) AS reported,
SUM(a.unfounded) AS unfounded,
SUM(a.actual) AS actual,
SUM(a.cleared) AS cleared,
SUM(a.juvenile_cleared) AS juvenile_cleared
FROM agency_sums a
JOIN reta_offense_subcat ros ON a.offense_subcat_id = ros.offense_subcat_id
JOIN reta_offense ro ON ro.offense_id = ros.offense_id
JOIN offense_classification oc ON oc.classification_id = ro.classification_id
WHERE a.offense_subcat_id <> 45
GROUP by a.data_year, a.agency_id, oc.classification_name;

DROP TABLE IF EXISTS agency_classification_view CASCADE;
create TABLE agency_classification_view (
 id SERIAL,
 year smallint NOT NULL,
 agency_id bigint NOT NULL,
 classification text,
 reported integer,
 unfounded integer,
 actual integer,
 cleared integer,
 juvenile_cleared integer,
 ori text,
 pub_agency_name text,
 state_postal_abbr varchar(2)
);

DROP TRIGGER IF EXISTS agency_classification_view_insert_state_partition ON agency_classification_view;
CREATE TRIGGER agency_classification_view_insert_state_partition
BEFORE INSERT ON agency_classification_view
FOR EACH ROW EXECUTE PROCEDURE create_state_partition_and_insert();

INSERT INTO agency_classification_view(year, agency_id, classification, reported, unfounded, actual, cleared, juvenile_cleared, ori, pub_agency_name, state_postal_abbr)
  SELECT
    a.data_year,
    a.agency_id,
    a.classification,
    a.reported,
    a.unfounded,
    a.actual,
    a.cleared,
    a.juvenile_cleared,
    c.ori,
    c.agency_name,
    c.state_abbr
FROM agency_sums_by_classification a
JOIN cde_agencies c ON c.agency_id=a.agency_id;

DROP TABLE agency_sums_by_classification;

----- Add arson to agency sums
DROP TABLE IF EXISTS arson_agency_reporting;
CREATE TABLE arson_agency_reporting AS
SELECT rm.data_year,
rm.agency_id,
SUM(CASE WHEN rm.reported_flag = 'Y' THEN 1 ELSE 0 END) AS months_reported
FROM arson_month rm
GROUP BY rm.data_year, rm.agency_id;

DROP TABLE IF EXISTS arson_agency_sums CASCADE;
CREATE TABLE arson_agency_sums (
id SERIAL PRIMARY KEY,
data_year smallint NOT NULL,
agency_id bigint NOT NULL, 
reported integer, 
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer,
uninhabited bigint,
est_damage_value bigint
);

INSERT INTO arson_agency_sums (data_year, agency_id, reported, unfounded, actual, cleared, juvenile_cleared, uninhabited, est_damage_value)  
SELECT am.data_year,
am.agency_id,
SUM(ambs.reported_count) AS reported,
SUM(ambs.unfounded_count) AS unfounded,
SUM(ambs.actual_count) AS actual,
SUM(ambs.cleared_count) AS cleared,
SUM(ambs.juvenile_cleared_count) AS juvenile_cleared,
SUM(ambs.uninhabited_count) AS uninhabited,
SUM(ambs.est_damage_value) AS est_damage_value
FROM arson_month_by_subcat ambs
JOIN arson_month am ON ambs.arson_month_id = am.arson_month_id
JOIN arson_agency_reporting rep ON rep.agency_id=am.agency_id AND rep.data_year=am.data_year
WHERE rep.months_reported = 12
AND ambs.actual_status = 0
GROUP BY am.data_year, am.agency_id;

DROP TABLE IF EXISTS agency_arson_view CASCADE;

create TABLE agency_arson_view (
id SERIAL PRIMARY KEY,
year smallint NOT NULL,
agency_id bigint NOT NULL, 
reported integer, 
unfounded integer,
actual integer,
cleared integer,
juvenile_cleared integer,
uninhabited integer,
est_damage_value bigint,
ori text,
pub_agency_name text,
state_postal_abbr text
);

INSERT INTO agency_arson_view(year, agency_id, reported, unfounded, actual, cleared, juvenile_cleared, uninhabited, est_damage_value, ori, pub_agency_name, state_postal_abbr)
SELECT
a.data_year,
a.agency_id,
a.reported,
a.unfounded,
a.actual,
a.cleared,
a.juvenile_cleared,
a.uninhabited,
a.est_damage_value,
c.ori,
c.agency_name,
c.state_abbr
FROM arson_agency_sums a
JOIN cde_agencies c ON c.agency_id=a.agency_id;

DROP TABLE arson_agency_sums;
DROP TABLE arson_agency_reporting;

--- Add arsons to the offense table
INSERT INTO agency_offenses_view(year, agency_id, offense_id, offense_code, offense_name, reported, unfounded, actual, cleared, juvenile_cleared, ori, pub_agency_name, state_postal_abbr)
SELECT
  a.year,
  a.agency_id,
  NULL as offense_id,
  'X_ARS' as offense_code,
  'Arson' as offense_name,
  a.reported,
  a.unfounded,
  a.actual,
  a.cleared,
  a.juvenile_cleared,
  a.ori,
  a.pub_agency_name,
  a.state_postal_abbr
FROM agency_arson_view a;
