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

-- DROP TRIGGER IF EXISTS agency_classification_view_insert_state_partition ON agency_classification_view;
-- CREATE TRIGGER agency_classification_view_insert_state_partition
-- BEFORE INSERT ON agency_classification_view
-- FOR EACH ROW EXECUTE PROCEDURE create_state_partition_and_insert();

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
FROM temp_agency_sums_by_classification a
JOIN cde_agencies c ON c.agency_id=a.agency_id;
