SET work_mem='2GB';
SET synchronous_commit TO OFF;

DROP TABLE IF EXISTS temp_agency_sums CASCADE;
CREATE TABLE temp_agency_sums (
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
    INSERT INTO temp_agency_sums (data_year, agency_id, offense_subcat_id, reported, unfounded, actual, cleared, juvenile_cleared)
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
    JOIN temp_agency_reporting ar ON ar.agency_id=rm.agency_id AND ar.data_year=rm.data_year
    WHERE ar.reported IS TRUE
    GROUP BY rm.data_year, rm.agency_id, ros.offense_subcat_id;
   END LOOP;
END
$do$;
