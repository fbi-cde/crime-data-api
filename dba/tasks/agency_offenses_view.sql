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
FROM temp_agency_sums_by_offense a
JOIN cde_agencies c ON c.agency_id=a.agency_id
JOIN reta_offense ro ON ro.offense_id = a.offense_id;

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
FROM temp_agency_sums_aggravated a
JOIN cde_agencies c ON c.agency_id=a.agency_id;


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
