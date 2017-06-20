DO
$do$
DECLARE
   arr integer[] := array[2014,2013,2012,2011,2010,2009,2008,2007,2006,2005,2004,2003,2002,2001,2000,1999,1998,1997,1996,1995,1994,1993,1992,1991];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
--    EXECUTE 'CREATE TABLE IF NOT EXISTS nibrs_offense_denorm_' || i::TEXT || ' () INHERITS (nibrs_offense_denorm)';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view IF EXISTS  offense_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offense_counts_' || i::TEXT || ' as select count(offense_id), ori, offense_name,weapon_name, method_entry_code, num_premises_entered,location_name, state_id 
    from ( 
        SELECT DISTINCT(offense_id), ref_agency.ori, offense_name, weapon_name, method_entry_code, num_premises_entered,location_name, nibrs_offense_denorm_' || i::TEXT || '.state_id, year from nibrs_offense_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_offense_denorm_' || i::TEXT || '.agency_id 
        where year::integer = ' || i || ' 
        ) as temp
    GROUP BY GROUPING SETS (
        (year, offense_name),
        (year, weapon_name),
        (year, method_entry_code),
        (year, num_premises_entered),
        (year, location_name),
        (year, state_id, offense_name),
        (year, state_id, weapon_name),
        (year, state_id, method_entry_code),
        (year, state_id, num_premises_entered),
        (year, state_id, location_name),
        (year, ori, offense_name),
        (year, ori, weapon_name),
        (year, ori, method_entry_code),
        (year, ori, num_premises_entered),
        (year, ori, location_name)
    );';
   END LOOP;
END
$do$;

drop materialized view  IF EXISTS offense_counts CASCADE;
create materialized view offense_counts as 
    SELECT *,2014 as year  FROM offense_counts_2014 UNION 
    SELECT *,2013 as year  FROM offense_counts_2013 UNION
    SELECT *,2012 as year  FROM offense_counts_2012 UNION 
    SELECT *,2011 as year  FROM offense_counts_2011 UNION 
    SELECT *,2010 as year  FROM offense_counts_2010 UNION
    SELECT *,2009 as year  FROM offense_counts_2009 UNION 
    SELECT *,2008 as year  FROM offense_counts_2008 UNION 
    SELECT *,2007 as year  FROM offense_counts_2007 UNION
    SELECT *,2006 as year  FROM offense_counts_2006 UNION 
    SELECT *,2005 as year  FROM offense_counts_2005 UNION 
    SELECT *,2004 as year  FROM offense_counts_2004 UNION
    SELECT *,2003 as year  FROM offense_counts_2003 UNION 
    SELECT *,2002 as year  FROM offense_counts_2002 UNION 
    SELECT *,2001 as year  FROM offense_counts_2001 UNION
    SELECT *,2000 as year  FROM offense_counts_2000 UNION 
    SELECT *,1999 as year  FROM offense_counts_1999 UNION 
    SELECT *,1998 as year  FROM offense_counts_1998 UNION
    SELECT *,1997 as year  FROM offense_counts_1997 UNION 
    SELECT *,1996 as year  FROM offense_counts_1996 UNION 
    SELECT *,1995 as year  FROM offense_counts_1995 UNION
    SELECT *,1994 as year  FROM offense_counts_1994 UNION 
    SELECT *,1993 as year  FROM offense_counts_1993 UNION 
    SELECT *,1992 as year  FROM offense_counts_1992 UNION
    SELECT *,1991 as year  FROM offense_counts_1991;

CREATE INDEX offense_counts_state_year_id_idx ON offense_counts (state_id, year);
CREATE INDEX offense_counts_ori_year_idx ON offense_counts (ori, year);
