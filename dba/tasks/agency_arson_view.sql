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
FROM temp_arson_agency_sums a
JOIN cde_agencies c ON c.agency_id=a.agency_id;
