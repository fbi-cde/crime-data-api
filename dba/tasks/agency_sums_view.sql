drop table agency_sums_view CASCADE;
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

-- Do we need this?
-- DROP TRIGGER IF EXISTS agency_sums_view_insert_state_partition ON agency_sums_view;
-- CREATE TRIGGER agency_sums_view_insert_state_partition
-- BEFORE INSERT ON agency_sums_view
-- FOR EACH ROW EXECUTE PROCEDURE create_state_partition_and_insert();

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
from temp_agency_sums asums
JOIN ref_agency ag ON (asums.agency_id = ag.agency_id)
JOIN reta_offense_subcat ros ON (asums.offense_subcat_id = ros.offense_subcat_id)
JOIN reta_offense ro ON ros.offense_id=ro.offense_id
JOIN ref_state rs ON (rs.state_id  = ag.state_id);
