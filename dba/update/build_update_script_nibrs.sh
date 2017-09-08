echo "

\set ON_ERROR_STOP on;


-----

-- Update NIBRS aggregations.

-- 

--------------
-- HATE CRIME
--------------
SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates Hate Crime stats.

drop materialized view  IF EXISTS hc_counts_states_new;
create materialized view hc_counts_states_new as select count(incident_id), bias_name, year, state_id 
from ( SELECT DISTINCT(hc_incident.incident_id), bias_name, state_id, EXTRACT(YEAR FROM hc_incident.incident_date) as year from hc_incident 
    LEFT OUTER JOIN hc_offense ON hc_incident.incident_id = hc_offense.incident_id 
    LEFT OUTER JOIN hc_bias_motivation ON hc_offense.offense_id = hc_bias_motivation.offense_id 
    LEFT OUTER JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = hc_offense.offense_type_id 
    LEFT OUTER JOIN nibrs_bias_list ON nibrs_bias_list.bias_id = hc_bias_motivation.bias_id 
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = hc_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, bias_name),
    (year, state_id, bias_name)
);

drop materialized view  IF EXISTS hc_counts_ori_new;
create materialized view hc_counts_ori_new as select count(incident_id), ori, bias_name, year  
from ( SELECT DISTINCT(hc_incident.incident_id), ref_agency.ori, bias_name, EXTRACT(YEAR FROM hc_incident.incident_date) as year from hc_incident 
    LEFT OUTER JOIN hc_offense ON hc_incident.incident_id = hc_offense.incident_id 
    LEFT OUTER JOIN hc_bias_motivation ON hc_offense.offense_id = hc_bias_motivation.offense_id 
    LEFT OUTER JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = hc_offense.offense_type_id 
    LEFT OUTER JOIN nibrs_bias_list ON nibrs_bias_list.bias_id = hc_bias_motivation.bias_id 
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = hc_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, bias_name)
);

drop materialized view  IF EXISTS offense_hc_counts_states_new;
create materialized view offense_hc_counts_states_new as select count(incident_id), offense_name, bias_name, year, state_id 
from ( SELECT DISTINCT(hc_incident.incident_id), bias_name, offense_name, state_id, EXTRACT(YEAR FROM hc_incident.incident_date) as year from hc_incident 
    LEFT OUTER JOIN hc_offense ON hc_incident.incident_id = hc_offense.incident_id 
    LEFT OUTER JOIN hc_bias_motivation ON hc_offense.offense_id = hc_bias_motivation.offense_id 
    LEFT OUTER JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = hc_offense.offense_type_id 
    LEFT OUTER JOIN nibrs_bias_list ON nibrs_bias_list.bias_id = hc_bias_motivation.bias_id 
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = hc_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, offense_name, bias_name),
    (year, state_id, offense_name, bias_name)
);

drop materialized view  IF EXISTS offense_hc_counts_ori_new;
create materialized view offense_hc_counts_ori_new as select count(incident_id), ori, offense_name, bias_name, year  
from ( SELECT DISTINCT(hc_incident.incident_id), ref_agency.ori, bias_name, offense_name, EXTRACT(YEAR FROM hc_incident.incident_date) as year from hc_incident 
    LEFT OUTER JOIN hc_offense ON hc_incident.incident_id = hc_offense.incident_id 
    LEFT OUTER JOIN hc_bias_motivation ON hc_offense.offense_id = hc_bias_motivation.offense_id 
    LEFT OUTER JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = hc_offense.offense_type_id 
    LEFT OUTER JOIN nibrs_bias_list ON nibrs_bias_list.bias_id = hc_bias_motivation.bias_id 
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = hc_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, offense_name, bias_name)
);




---------
-- CARGO THEFT
---------
SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates CT stats.
drop materialized view IF EXISTS ct_counts_states_new;
create materialized view ct_counts_states_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, state_id,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    state_id, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id

    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id

    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, prop_desc_name),
    (year, location_name),
    (year, victim_type_name),
    (year, offense_name),
    
    (year, state_id, prop_desc_name),
    (year, state_id, location_name),
    (year, state_id, victim_type_name),
    (year, state_id, offense_name)
);

drop materialized view IF EXISTS  ct_counts_ori_new;
create materialized view ct_counts_ori_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, ori,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    ref_agency.ori, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id

    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id

    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, prop_desc_name),
    (year, ori, location_name),
    (year, ori, victim_type_name),
    (year, ori, offense_name)
);

SET work_mem='2GB'; -- Go Super Saiyan.

-- Generates CT stats.
create materialized view offense_ct_counts_states_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, state_id,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    state_id, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id

    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, offense_name, prop_desc_name),
    (year, offense_name, location_name),
    (year, offense_name, victim_type_name),

    (year, state_id, offense_name, prop_desc_name),
    (year, state_id, offense_name, location_name),
    (year, state_id, offense_name, victim_type_name)
);

create materialized view offense_ct_counts_ori_new as select  count(incident_id), sum(stolen_value) as stolen_value, sum(recovered_value) as recovered_value,  year, ori,  location_name,  offense_name, victim_type_name, prop_desc_name
from ( 
    SELECT DISTINCT(ct_incident.incident_id), 
    ref_agency.ori, 
    location_name,
    offense_name,
    victim_type_name,
    ct_property.stolen_value::numeric as stolen_value,
    ct_property.recovered_value::numeric as recovered_value,
    prop_desc_name,
    EXTRACT(YEAR FROM ct_incident.incident_date) as year 
    from ct_incident 
    LEFT OUTER JOIN ct_offense ON ct_incident.incident_id = ct_offense.incident_id 
    LEFT OUTER JOIN nibrs_offense_type ON ct_offense.offense_type_id = nibrs_offense_type.offense_type_id 
    LEFT OUTER JOIN nibrs_location_type ON ct_offense.location_id = nibrs_location_type.location_id
    LEFT OUTER JOIN ct_victim ON ct_victim.incident_id = ct_incident.incident_id 
    LEFT OUTER JOIN nibrs_victim_type ON ct_victim.victim_type_id = nibrs_victim_type.victim_type_id
    LEFT OUTER JOIN ct_property ON ct_incident.incident_id = ct_property.incident_id
    LEFT OUTER JOIN nibrs_prop_desc_type ON nibrs_prop_desc_type.prop_desc_id = ct_property.prop_desc_id
    LEFT OUTER JOIN ref_agency ON ref_agency.agency_id = ct_incident.agency_id
     ) as temp 
GROUP BY GROUPING SETS (
    (year, ori, offense_name, prop_desc_name),
    (year, ori, offense_name, location_name),
    (year, ori, offense_name, victim_type_name)
);

--------------
-- OFFENDERS
--------------

DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    EXECUTE 'drop materialized view IF EXISTS offender_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offender_counts_' || i::TEXT || ' as select count(offender_id),ethnicity, prop_desc_name,offense_name, state_id, race_code,location_name, age_num, sex_code, ori  
    from ( 
        SELECT DISTINCT(offender_id), ethnicity, age_code, age_num,race_code,year,prop_desc_name,offense_name,location_name, sex_code, nibrs_offender_denorm_' || i::TEXT || '.state_id,ref_agency.ori from nibrs_offender_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_offender_denorm_' || i::TEXT || '.agency_id 
        where year::integer = ' || i || ' 
        ) as temp
    GROUP BY GROUPING SETS (
        (year, race_code),
        (year, sex_code),
        (year, age_num),
        (year, location_name), 
        (year, offense_name),
        (year, prop_desc_name),
        (year, ethnicity),

        (year, state_id, race_code),
        (year, state_id, sex_code),
        (year, state_id, age_num),
        (year, state_id, location_name), 
        (year, state_id, offense_name),
        (year, state_id, prop_desc_name),
        (year, state_id, ethnicity),

        (year, ori, race_code),
        (year, ori, sex_code),
        (year, ori, age_num),
        (year, ori, location_name), 
        (year, ori, offense_name),
        (year, ori, prop_desc_name),
        (year, ori, ethnicity)
    );';
   END LOOP;
END
$do$;

drop materialized view  IF EXISTS offender_counts_states_temp;
create materialized view offender_counts_states_temp as 
    SELECT *, $YEAR as year FROM offender_counts_$YEAR WHERE ori IS NULL UNION 
    SELECT *, 2015 as year FROM offender_counts_2015 WHERE ori IS NULL UNION 
    SELECT *, 2014 as year FROM offender_counts_2014 WHERE ori IS NULL UNION 
    SELECT *, 2013 as year FROM offender_counts_2013 WHERE ori IS NULL  UNION 
    SELECT *, 2012 as year FROM offender_counts_2012 WHERE ori IS NULL  UNION 
    SELECT *, 2011 as year FROM offender_counts_2011 WHERE ori IS NULL  UNION 
    SELECT *, 2010 as year FROM offender_counts_2010 WHERE ori IS NULL  UNION
    SELECT *, 2009 as year FROM offender_counts_2009 WHERE ori IS NULL  UNION 
    SELECT *, 2008 as year FROM offender_counts_2008 WHERE ori IS NULL  UNION 
    SELECT *, 2007 as year FROM offender_counts_2007 WHERE ori IS NULL  UNION
    SELECT *, 2006 as year FROM offender_counts_2006 WHERE ori IS NULL  UNION 
    SELECT *, 2005 as year FROM offender_counts_2005 WHERE ori IS NULL  UNION 
    SELECT *, 2004 as year FROM offender_counts_2004 WHERE ori IS NULL  UNION
    SELECT *, 2003 as year FROM offender_counts_2003 WHERE ori IS NULL  UNION 
    SELECT *, 2002 as year FROM offender_counts_2002 WHERE ori IS NULL  UNION 
    SELECT *, 2001 as year FROM offender_counts_2001 WHERE ori IS NULL  UNION
    SELECT *, 2000 as year FROM offender_counts_2000 WHERE ori IS NULL  UNION 
    SELECT *, 1999 as year FROM offender_counts_1999 WHERE ori IS NULL  UNION 
    SELECT *, 1998 as year FROM offender_counts_1998 WHERE ori IS NULL  UNION
    SELECT *, 1997 as year FROM offender_counts_1997 WHERE ori IS NULL  UNION 
    SELECT *, 1996 as year FROM offender_counts_1996 WHERE ori IS NULL  UNION 
    SELECT *, 1995 as year FROM offender_counts_1995 WHERE ori IS NULL  UNION
    SELECT *, 1994 as year FROM offender_counts_1994 WHERE ori IS NULL  UNION 
    SELECT *, 1993 as year FROM offender_counts_1993 WHERE ori IS NULL  UNION 
    SELECT *, 1992 as year FROM offender_counts_1992 WHERE ori IS NULL  UNION
    SELECT *, 1991 as year FROM offender_counts_1991 WHERE ori IS NULL ;

drop materialized view  IF EXISTS offender_counts_ori_temp;
create materialized view offender_counts_ori_temp as 
    SELECT *, $YEAR as year FROM offender_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *, 2015 as year FROM offender_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *, 2014 as year FROM offender_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *, 2013 as year FROM offender_counts_2013 WHERE ori IS NOT NULL  UNION
    SELECT *, 2012 as year FROM offender_counts_2012 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2011 as year FROM offender_counts_2011 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2010 as year FROM offender_counts_2010 WHERE ori IS NOT NULL  UNION
    SELECT *, 2009 as year FROM offender_counts_2009 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2008 as year FROM offender_counts_2008 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2007 as year FROM offender_counts_2007 WHERE ori IS NOT NULL  UNION
    SELECT *, 2006 as year FROM offender_counts_2006 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2005 as year FROM offender_counts_2005 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2004 as year FROM offender_counts_2004 WHERE ori IS NOT NULL  UNION
    SELECT *, 2003 as year FROM offender_counts_2003 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2002 as year FROM offender_counts_2002 WHERE ori IS NOT NULL  UNION 
    SELECT *, 2001 as year FROM offender_counts_2001 WHERE ori IS NOT NULL  UNION
    SELECT *, 2000 as year FROM offender_counts_2000 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1999 as year FROM offender_counts_1999 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1998 as year FROM offender_counts_1998 WHERE ori IS NOT NULL  UNION
    SELECT *, 1997 as year FROM offender_counts_1997 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1996 as year FROM offender_counts_1996 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1995 as year FROM offender_counts_1995 WHERE ori IS NOT NULL  UNION
    SELECT *, 1994 as year FROM offender_counts_1994 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1993 as year FROM offender_counts_1993 WHERE ori IS NOT NULL  UNION 
    SELECT *, 1992 as year FROM offender_counts_1992 WHERE ori IS NOT NULL  UNION
    SELECT *, 1991 as year FROM offender_counts_1991 WHERE ori IS NOT NULL ;

CREATE INDEX CONCURRENTLY offender_counts_state_year_id_idx ON offender_counts_states (state_id, year);
CREATE INDEX CONCURRENTLY offender_counts_ori_year_idx ON offender_counts_ori (ori, year);

--------------
-- OFFENDER - OFFENSES
--------------
DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view  IF EXISTS offense_offender_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offense_offender_counts_' || i::TEXT || ' as select count(offender_id), ori,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
    from (
        SELECT DISTINCT(offender_id), ref_agency.ori, ethnicity, age_num,race_code,year,offense_name, sex_code, nibrs_offender_denorm_' || i::TEXT || '.state_id from nibrs_offender_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_offender_denorm_' || i::TEXT || '.agency_id 
        where year::integer = ' || i || ' and nibrs_offender_denorm_' || i::TEXT || '.state_id is not null
    ) as temp 
    GROUP BY GROUPING SETS (
        (year, offense_name, race_code),
        (year, offense_name, sex_code),
        (year, offense_name, age_num),
        (year, offense_name, ethnicity),
        (year, state_id, offense_name, race_code),
        (year, state_id, offense_name, sex_code),
        (year, state_id, offense_name, age_num),
        (year, state_id, offense_name, ethnicity),
        (year, ori, offense_name, race_code),
        (year, ori, offense_name, sex_code),
        (year, ori, offense_name, age_num),
        (year, ori, offense_name, ethnicity)
    );';
   END LOOP;
END
$do$;

drop materialized view IF EXISTS  offense_offender_counts_states_temp;
create materialized view offense_offender_counts_states_temp as 
    SELECT *,$YEAR as year FROM offense_offender_counts_$YEAR WHERE ori IS NULL  UNION 
    SELECT *,2015 as year FROM offense_offender_counts_2015 WHERE ori IS NULL  UNION 
    SELECT *,2014 as year FROM offense_offender_counts_2014 WHERE ori IS NULL  UNION 
    SELECT *,2013 as year FROM offense_offender_counts_2013 WHERE ori IS NULL  UNION 
    SELECT *,2012 as year FROM offense_offender_counts_2012 WHERE ori IS NULL  UNION 
    SELECT *,2011 as year FROM offense_offender_counts_2011 WHERE ori IS NULL  UNION 
    SELECT *,2010 as year FROM offense_offender_counts_2010 WHERE ori IS NULL  UNION
    SELECT *,2009 as year FROM offense_offender_counts_2009 WHERE ori IS NULL  UNION 
    SELECT *,2008 as year FROM offense_offender_counts_2008 WHERE ori IS NULL  UNION 
    SELECT *,2007 as year FROM offense_offender_counts_2007 WHERE ori IS NULL  UNION
    SELECT *,2006 as year FROM offense_offender_counts_2006 WHERE ori IS NULL  UNION 
    SELECT *,2005 as year FROM offense_offender_counts_2005 WHERE ori IS NULL  UNION 
    SELECT *,2004 as year FROM offense_offender_counts_2004 WHERE ori IS NULL  UNION
    SELECT *,2003 as year FROM offense_offender_counts_2003 WHERE ori IS NULL  UNION 
    SELECT *,2002 as year FROM offense_offender_counts_2002 WHERE ori IS NULL  UNION 
    SELECT *,2001 as year FROM offense_offender_counts_2001 WHERE ori IS NULL  UNION
    SELECT *,2000 as year FROM offense_offender_counts_2000 WHERE ori IS NULL  UNION 
    SELECT *,1999 as year FROM offense_offender_counts_1999 WHERE ori IS NULL  UNION 
    SELECT *,1998 as year FROM offense_offender_counts_1998 WHERE ori IS NULL  UNION
    SELECT *,1997 as year FROM offense_offender_counts_1997 WHERE ori IS NULL  UNION 
    SELECT *,1996 as year FROM offense_offender_counts_1996 WHERE ori IS NULL  UNION 
    SELECT *,1995 as year FROM offense_offender_counts_1995 WHERE ori IS NULL  UNION
    SELECT *,1994 as year FROM offense_offender_counts_1994 WHERE ori IS NULL  UNION 
    SELECT *,1993 as year FROM offense_offender_counts_1993 WHERE ori IS NULL  UNION 
    SELECT *,1992 as year FROM offense_offender_counts_1992 WHERE ori IS NULL  UNION
    SELECT *,1991 as year FROM offense_offender_counts_1991 WHERE ori IS NULL ;


drop materialized view IF EXISTS  offense_offender_counts_ori_temp;
create materialized view offense_offender_counts_ori_temp as 
    SELECT *,$YEAR as year FROM offense_offender_counts_$YEAR WHERE ori IS NOT NULL  UNION 
    SELECT *,2015 as year FROM offense_offender_counts_2015 WHERE ori IS NOT NULL  UNION 
    SELECT *,2014 as year FROM offense_offender_counts_2014 WHERE ori IS NOT NULL  UNION 
    SELECT *,2013 as year FROM offense_offender_counts_2013 WHERE ori IS NOT NULL  UNION 
    SELECT *,2012 as year FROM offense_offender_counts_2012 WHERE ori IS NOT NULL  UNION 
    SELECT *,2011 as year FROM offense_offender_counts_2011 WHERE ori IS NOT NULL  UNION 
    SELECT *,2010 as year FROM offense_offender_counts_2010 WHERE ori IS NOT NULL  UNION
    SELECT *,2009 as year FROM offense_offender_counts_2009 WHERE ori IS NOT NULL  UNION 
    SELECT *,2008 as year FROM offense_offender_counts_2008 WHERE ori IS NOT NULL  UNION 
    SELECT *,2007 as year FROM offense_offender_counts_2007 WHERE ori IS NOT NULL  UNION
    SELECT *,2006 as year FROM offense_offender_counts_2006 WHERE ori IS NOT NULL  UNION 
    SELECT *,2005 as year FROM offense_offender_counts_2005 WHERE ori IS NOT NULL  UNION 
    SELECT *,2004 as year FROM offense_offender_counts_2004 WHERE ori IS NOT NULL  UNION
    SELECT *,2003 as year FROM offense_offender_counts_2003 WHERE ori IS NOT NULL  UNION 
    SELECT *,2002 as year FROM offense_offender_counts_2002 WHERE ori IS NOT NULL  UNION 
    SELECT *,2001 as year FROM offense_offender_counts_2001 WHERE ori IS NOT NULL  UNION
    SELECT *,2000 as year FROM offense_offender_counts_2000 WHERE ori IS NOT NULL  UNION 
    SELECT *,1999 as year FROM offense_offender_counts_1999 WHERE ori IS NOT NULL  UNION 
    SELECT *,1998 as year FROM offense_offender_counts_1998 WHERE ori IS NOT NULL  UNION
    SELECT *,1997 as year FROM offense_offender_counts_1997 WHERE ori IS NOT NULL  UNION 
    SELECT *,1996 as year FROM offense_offender_counts_1996 WHERE ori IS NOT NULL  UNION 
    SELECT *,1995 as year FROM offense_offender_counts_1995 WHERE ori IS NOT NULL  UNION
    SELECT *,1994 as year FROM offense_offender_counts_1994 WHERE ori IS NOT NULL  UNION 
    SELECT *,1993 as year FROM offense_offender_counts_1993 WHERE ori IS NOT NULL  UNION 
    SELECT *,1992 as year FROM offense_offender_counts_1992 WHERE ori IS NOT NULL  UNION
    SELECT *,1991 as year FROM offense_offender_counts_1991 WHERE ori IS NOT NULL ;

--------------
-- VICTIMS
--------------
DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    -- necessary when run on test DB slice
    EXECUTE 'CREATE TABLE IF NOT EXISTS nibrs_victim_denorm_' || i::TEXT || ' () INHERITS (nibrs_victim_denorm)';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view IF EXISTS victim_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view victim_counts_' || i::TEXT || ' as select count(victim_id), ori,resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code,location_name ,prop_desc_name
    from ( 
        SELECT DISTINCT(victim_id), ref_agency.ori, ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, nibrs_victim_denorm_' || i::TEXT || '.state_id,location_name,prop_desc_name 
        from nibrs_victim_denorm_' || i::TEXT || '  
        JOIN ref_agency ON ref_agency.agency_id = nibrs_victim_denorm_' || i::TEXT || '.agency_id
        where year::integer = ' || i || '  and nibrs_victim_denorm_' || i::TEXT || '.state_id is not null
        ) as temp
    GROUP BY GROUPING SETS (
        (year, race_code),
        (year, sex_code),
        (year, age_num),
        (year, location_name), 
        (year, offense_name),
        (year, prop_desc_name),
        (year, resident_status_code), 
        (year, offender_relationship),
        (year, circumstance_name),
        (year, ethnicity),
        (year, state_id, race_code),
        (year, state_id, sex_code),
        (year, state_id, age_num),
        (year, state_id, location_name), 
        (year, state_id, offense_name),
        (year, state_id, prop_desc_name),
        (year, state_id, resident_status_code), 
        (year, state_id, offender_relationship),
        (year, state_id, circumstance_name),
        (year, state_id, ethnicity),
        (year, ori, race_code),
        (year, ori, sex_code),
        (year, ori, age_num),
        (year, ori, location_name), 
        (year, ori, offense_name),
        (year, ori, prop_desc_name),
        (year, ori, resident_status_code), 
        (year, ori, offender_relationship),
        (year, ori, circumstance_name),
        (year, ori, ethnicity)
    );';
   END LOOP;
END
$do$;

create materialized view victim_counts_states_temp as 
    SELECT *, $YEAR as year FROM victim_counts_$YEAR WHERE ori IS NULL UNION  
    SELECT *, 2015 as year FROM victim_counts_2015 WHERE ori IS NULL UNION 
    SELECT *, 2014 as year FROM victim_counts_2014 WHERE ori IS NULL UNION 
    SELECT *, 2013 as year FROM victim_counts_2013 WHERE ori IS NULL UNION 
    SELECT *, 2012 as year FROM victim_counts_2012 WHERE ori IS NULL UNION 
    SELECT *, 2011 as year FROM victim_counts_2011 WHERE ori IS NULL UNION 
    SELECT *, 2010 as year FROM victim_counts_2010 WHERE ori IS NULL UNION 
    SELECT *, 2009 as year FROM victim_counts_2009 WHERE ori IS NULL UNION 
    SELECT *, 2008 as year FROM victim_counts_2008 WHERE ori IS NULL UNION 
    SELECT *, 2007 as year FROM victim_counts_2007 WHERE ori IS NULL UNION 
    SELECT *, 2006 as year FROM victim_counts_2006 WHERE ori IS NULL UNION 
    SELECT *, 2005 as year FROM victim_counts_2005 WHERE ori IS NULL UNION 
    SELECT *, 2004 as year FROM victim_counts_2004 WHERE ori IS NULL UNION 
    SELECT *, 2003 as year FROM victim_counts_2003 WHERE ori IS NULL UNION 
    SELECT *, 2002 as year FROM victim_counts_2002 WHERE ori IS NULL UNION 
    SELECT *, 2001 as year FROM victim_counts_2001 WHERE ori IS NULL UNION 
    SELECT *, 2000 as year FROM victim_counts_2000 WHERE ori IS NULL UNION 
    SELECT *, 1999 as year FROM victim_counts_1999 WHERE ori IS NULL UNION 
    SELECT *, 1998 as year FROM victim_counts_1998 WHERE ori IS NULL UNION 
    SELECT *, 1997 as year FROM victim_counts_1997 WHERE ori IS NULL UNION 
    SELECT *, 1996 as year FROM victim_counts_1996 WHERE ori IS NULL UNION 
    SELECT *, 1995 as year FROM victim_counts_1995 WHERE ori IS NULL UNION 
    SELECT *, 1994 as year FROM victim_counts_1994 WHERE ori IS NULL UNION 
    SELECT *, 1993 as year FROM victim_counts_1993 WHERE ori IS NULL UNION 
    SELECT *, 1992 as year FROM victim_counts_1992 WHERE ori IS NULL UNION 
    SELECT *, 1991 as year FROM victim_counts_1991 WHERE ori IS NULL;

create materialized view victim_counts_ori_temp as 
    SELECT *, $YEAR as year FROM victim_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *, 2015 as year FROM victim_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *, 2014 as year FROM victim_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *, 2013 as year FROM victim_counts_2013 WHERE ori IS NOT NULL UNION
    SELECT *, 2012 as year FROM victim_counts_2012 WHERE ori IS NOT NULL UNION 
    SELECT *, 2011 as year FROM victim_counts_2011 WHERE ori IS NOT NULL UNION 
    SELECT *, 2010 as year FROM victim_counts_2010 WHERE ori IS NOT NULL UNION
    SELECT *, 2009 as year FROM victim_counts_2009 WHERE ori IS NOT NULL UNION 
    SELECT *, 2008 as year FROM victim_counts_2008 WHERE ori IS NOT NULL UNION 
    SELECT *, 2007 as year FROM victim_counts_2007 WHERE ori IS NOT NULL UNION
    SELECT *, 2006 as year FROM victim_counts_2006 WHERE ori IS NOT NULL UNION 
    SELECT *, 2005 as year FROM victim_counts_2005 WHERE ori IS NOT NULL UNION 
    SELECT *, 2004 as year FROM victim_counts_2004 WHERE ori IS NOT NULL UNION
    SELECT *, 2003 as year FROM victim_counts_2003 WHERE ori IS NOT NULL UNION 
    SELECT *, 2002 as year FROM victim_counts_2002 WHERE ori IS NOT NULL UNION 
    SELECT *, 2001 as year FROM victim_counts_2001 WHERE ori IS NOT NULL UNION
    SELECT *, 2000 as year FROM victim_counts_2000 WHERE ori IS NOT NULL UNION 
    SELECT *, 1999 as year FROM victim_counts_1999 WHERE ori IS NOT NULL UNION 
    SELECT *, 1998 as year FROM victim_counts_1998 WHERE ori IS NOT NULL UNION
    SELECT *, 1997 as year FROM victim_counts_1997 WHERE ori IS NOT NULL UNION 
    SELECT *, 1996 as year FROM victim_counts_1996 WHERE ori IS NOT NULL UNION 
    SELECT *, 1995 as year FROM victim_counts_1995 WHERE ori IS NOT NULL UNION
    SELECT *, 1994 as year FROM victim_counts_1994 WHERE ori IS NOT NULL UNION 
    SELECT *, 1993 as year FROM victim_counts_1993 WHERE ori IS NOT NULL UNION 
    SELECT *, 1992 as year FROM victim_counts_1992 WHERE ori IS NOT NULL UNION
    SELECT *, 1991 as year FROM victim_counts_1991 WHERE ori IS NOT NULL;

--------------
-- VICTIMS - OFFENSES
--------------

DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view  IF EXISTS offense_victim_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offense_victim_counts_' || i::TEXT || ' as select count(victim_id), ori,resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
    from ( 
        SELECT DISTINCT(victim_id), ref_agency.ori, ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, nibrs_victim_denorm_' || i::TEXT || '.state_id from nibrs_victim_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_victim_denorm_' || i::TEXT || '.agency_id
        where year::integer = ' || i || '  and nibrs_victim_denorm_' || i::TEXT || '.state_id is not null
        ) as temp
    GROUP BY GROUPING SETS (
        (year, offense_name, race_code),
        (year, offense_name, sex_code),
        (year, offense_name, age_num),
        (year, offense_name, ethnicity),
        (year, offense_name, resident_status_code),
        (year, offense_name, offender_relationship),
        (year, offense_name, circumstance_name),
        (year, state_id, offense_name, race_code),
        (year, state_id, offense_name, sex_code),
        (year, state_id, offense_name, age_num),
        (year, state_id, offense_name, ethnicity),
        (year, state_id, offense_name, resident_status_code),
        (year, state_id, offense_name, offender_relationship),
        (year, state_id, offense_name, circumstance_name),
        (year, ori, offense_name, race_code),
        (year, ori, offense_name, sex_code),
        (year, ori, offense_name, age_num),
        (year, ori, offense_name, ethnicity),
        (year, ori, offense_name, resident_status_code),
        (year, ori, offense_name, offender_relationship),
        (year, ori, offense_name, circumstance_name)
    );';
   END LOOP;
END
$do$;

create materialized view offense_victim_counts_states_temp as 
SELECT *, $YEAR as year FROM offense_victim_counts_$YEAR WHERE ori IS NULL UNION 
SELECT *, 2015 as year FROM offense_victim_counts_2015 WHERE ori IS NULL UNION 
SELECT *, 2014 as year FROM offense_victim_counts_2014 WHERE ori IS NULL UNION 
SELECT *, 2013 as year FROM offense_victim_counts_2013 WHERE ori IS NULL UNION
SELECT *, 2012 as year FROM offense_victim_counts_2012 WHERE ori IS NULL UNION 
SELECT *, 2011 as year FROM offense_victim_counts_2011 WHERE ori IS NULL UNION 
SELECT *, 2010 as year FROM offense_victim_counts_2010 WHERE ori IS NULL UNION
SELECT *, 2009 as year FROM offense_victim_counts_2009 WHERE ori IS NULL UNION 
SELECT *, 2008 as year FROM offense_victim_counts_2008 WHERE ori IS NULL UNION 
SELECT *, 2007 as year FROM offense_victim_counts_2007 WHERE ori IS NULL UNION
SELECT *, 2006 as year FROM offense_victim_counts_2006 WHERE ori IS NULL UNION 
SELECT *, 2005 as year FROM offense_victim_counts_2005 WHERE ori IS NULL UNION 
SELECT *, 2004 as year FROM offense_victim_counts_2004 WHERE ori IS NULL UNION
SELECT *, 2003 as year FROM offense_victim_counts_2003 WHERE ori IS NULL UNION 
SELECT *, 2002 as year FROM offense_victim_counts_2002 WHERE ori IS NULL UNION 
SELECT *, 2001 as year FROM offense_victim_counts_2001 WHERE ori IS NULL UNION
SELECT *, 2000 as year FROM offense_victim_counts_2000 WHERE ori IS NULL UNION 
SELECT *, 1999 as year FROM offense_victim_counts_1999 WHERE ori IS NULL UNION 
SELECT *, 1998 as year FROM offense_victim_counts_1998 WHERE ori IS NULL UNION
SELECT *, 1997 as year FROM offense_victim_counts_1997 WHERE ori IS NULL UNION 
SELECT *, 1996 as year FROM offense_victim_counts_1996 WHERE ori IS NULL UNION 
SELECT *, 1995 as year FROM offense_victim_counts_1995 WHERE ori IS NULL UNION
SELECT *, 1994 as year FROM offense_victim_counts_1994 WHERE ori IS NULL UNION 
SELECT *, 1993 as year FROM offense_victim_counts_1993 WHERE ori IS NULL UNION 
SELECT *, 1992 as year FROM offense_victim_counts_1992 WHERE ori IS NULL UNION
SELECT *, 1991 as year FROM offense_victim_counts_1991 WHERE ori IS NULL;

create materialized view offense_victim_counts_ori_temp as 
    SELECT *, $YEAR as year FROM offense_victim_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *, 2015 as year FROM offense_victim_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *, 2014 as year FROM offense_victim_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *, 2013 as year FROM offense_victim_counts_2013 WHERE ori IS NOT NULL UNION
    SELECT *, 2012 as year FROM offense_victim_counts_2012 WHERE ori IS NOT NULL UNION 
    SELECT *, 2011 as year FROM offense_victim_counts_2011 WHERE ori IS NOT NULL UNION 
    SELECT *, 2010 as year FROM offense_victim_counts_2010 WHERE ori IS NOT NULL UNION
    SELECT *, 2009 as year FROM offense_victim_counts_2009 WHERE ori IS NOT NULL UNION 
    SELECT *, 2008 as year FROM offense_victim_counts_2008 WHERE ori IS NOT NULL UNION 
    SELECT *, 2007 as year FROM offense_victim_counts_2007 WHERE ori IS NOT NULL UNION
    SELECT *, 2006 as year FROM offense_victim_counts_2006 WHERE ori IS NOT NULL UNION 
    SELECT *, 2005 as year FROM offense_victim_counts_2005 WHERE ori IS NOT NULL UNION 
    SELECT *, 2004 as year FROM offense_victim_counts_2004 WHERE ori IS NOT NULL UNION
    SELECT *, 2003 as year FROM offense_victim_counts_2003 WHERE ori IS NOT NULL UNION 
    SELECT *, 2002 as year FROM offense_victim_counts_2002 WHERE ori IS NOT NULL UNION 
    SELECT *, 2001 as year FROM offense_victim_counts_2001 WHERE ori IS NOT NULL UNION
    SELECT *, 2000 as year FROM offense_victim_counts_2000 WHERE ori IS NOT NULL UNION 
    SELECT *, 1999 as year FROM offense_victim_counts_1999 WHERE ori IS NOT NULL UNION 
    SELECT *, 1998 as year FROM offense_victim_counts_1998 WHERE ori IS NOT NULL UNION
    SELECT *, 1997 as year FROM offense_victim_counts_1997 WHERE ori IS NOT NULL UNION 
    SELECT *, 1996 as year FROM offense_victim_counts_1996 WHERE ori IS NOT NULL UNION 
    SELECT *, 1995 as year FROM offense_victim_counts_1995 WHERE ori IS NOT NULL UNION
    SELECT *, 1994 as year FROM offense_victim_counts_1994 WHERE ori IS NOT NULL UNION 
    SELECT *, 1993 as year FROM offense_victim_counts_1993 WHERE ori IS NOT NULL UNION 
    SELECT *, 1992 as year FROM offense_victim_counts_1992 WHERE ori IS NOT NULL UNION
    SELECT *, 1991 as year FROM offense_victim_counts_1991 WHERE ori IS NOT NULL;

--------------
-- OFFENSES
--------------

DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    -- needed when run locally
    EXECUTE 'CREATE TABLE IF NOT EXISTS nibrs_offense_denorm_' || i::TEXT || ' () INHERITS (nibrs_offense_denorm)';
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


create materialized view offense_counts_states_temp as 
    SELECT *,$YEAR as year  FROM offense_counts_$YEAR WHERE ori IS NULL UNION 
    SELECT *,2015 as year  FROM offense_counts_2015 WHERE ori IS NULL UNION 
    SELECT *,2014 as year  FROM offense_counts_2014 WHERE ori IS NULL UNION 
    SELECT *,2013 as year  FROM offense_counts_2013 WHERE ori IS NULL UNION 
    SELECT *,2012 as year  FROM offense_counts_2012 WHERE ori IS NULL UNION 
    SELECT *,2011 as year  FROM offense_counts_2011 WHERE ori IS NULL UNION 
    SELECT *,2010 as year  FROM offense_counts_2010 WHERE ori IS NULL UNION 
    SELECT *,2009 as year  FROM offense_counts_2009 WHERE ori IS NULL UNION 
    SELECT *,2008 as year  FROM offense_counts_2008 WHERE ori IS NULL UNION 
    SELECT *,2007 as year  FROM offense_counts_2007 WHERE ori IS NULL UNION 
    SELECT *,2006 as year  FROM offense_counts_2006 WHERE ori IS NULL UNION 
    SELECT *,2005 as year  FROM offense_counts_2005 WHERE ori IS NULL UNION 
    SELECT *,2004 as year  FROM offense_counts_2004 WHERE ori IS NULL UNION 
    SELECT *,2003 as year  FROM offense_counts_2003 WHERE ori IS NULL UNION 
    SELECT *,2002 as year  FROM offense_counts_2002 WHERE ori IS NULL UNION 
    SELECT *,2001 as year  FROM offense_counts_2001 WHERE ori IS NULL UNION 
    SELECT *,2000 as year  FROM offense_counts_2000 WHERE ori IS NULL UNION 
    SELECT *,1999 as year  FROM offense_counts_1999 WHERE ori IS NULL UNION 
    SELECT *,1998 as year  FROM offense_counts_1998 WHERE ori IS NULL UNION 
    SELECT *,1997 as year  FROM offense_counts_1997 WHERE ori IS NULL UNION 
    SELECT *,1996 as year  FROM offense_counts_1996 WHERE ori IS NULL UNION 
    SELECT *,1995 as year  FROM offense_counts_1995 WHERE ori IS NULL UNION 
    SELECT *,1994 as year  FROM offense_counts_1994 WHERE ori IS NULL UNION 
    SELECT *,1993 as year  FROM offense_counts_1993 WHERE ori IS NULL UNION 
    SELECT *,1992 as year  FROM offense_counts_1992 WHERE ori IS NULL UNION 
    SELECT *,1991 as year  FROM offense_counts_1991 WHERE ori IS NULL;

create materialized view offense_counts_ori_temp as 
    SELECT *,$YEAR as year  FROM offense_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *,2015 as year  FROM offense_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *,2014 as year  FROM offense_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *,2013 as year  FROM offense_counts_2013 WHERE ori IS NOT NULL UNION
    SELECT *,2012 as year  FROM offense_counts_2012 WHERE ori IS NOT NULL UNION 
    SELECT *,2011 as year  FROM offense_counts_2011 WHERE ori IS NOT NULL UNION 
    SELECT *,2010 as year  FROM offense_counts_2010 WHERE ori IS NOT NULL UNION
    SELECT *,2009 as year  FROM offense_counts_2009 WHERE ori IS NOT NULL UNION 
    SELECT *,2008 as year  FROM offense_counts_2008 WHERE ori IS NOT NULL UNION 
    SELECT *,2007 as year  FROM offense_counts_2007 WHERE ori IS NOT NULL UNION
    SELECT *,2006 as year  FROM offense_counts_2006 WHERE ori IS NOT NULL UNION 
    SELECT *,2005 as year  FROM offense_counts_2005 WHERE ori IS NOT NULL UNION 
    SELECT *,2004 as year  FROM offense_counts_2004 WHERE ori IS NOT NULL UNION
    SELECT *,2003 as year  FROM offense_counts_2003 WHERE ori IS NOT NULL UNION 
    SELECT *,2002 as year  FROM offense_counts_2002 WHERE ori IS NOT NULL UNION 
    SELECT *,2001 as year  FROM offense_counts_2001 WHERE ori IS NOT NULL UNION
    SELECT *,2000 as year  FROM offense_counts_2000 WHERE ori IS NOT NULL UNION 
    SELECT *,1999 as year  FROM offense_counts_1999 WHERE ori IS NOT NULL UNION 
    SELECT *,1998 as year  FROM offense_counts_1998 WHERE ori IS NOT NULL UNION
    SELECT *,1997 as year  FROM offense_counts_1997 WHERE ori IS NOT NULL UNION 
    SELECT *,1996 as year  FROM offense_counts_1996 WHERE ori IS NOT NULL UNION 
    SELECT *,1995 as year  FROM offense_counts_1995 WHERE ori IS NOT NULL UNION
    SELECT *,1994 as year  FROM offense_counts_1994 WHERE ori IS NOT NULL UNION 
    SELECT *,1993 as year  FROM offense_counts_1993 WHERE ori IS NOT NULL UNION 
    SELECT *,1992 as year  FROM offense_counts_1992 WHERE ori IS NOT NULL UNION
    SELECT *,1991 as year  FROM offense_counts_1991 WHERE ori IS NOT NULL;

--------------
-- OFFENSE - OFFENSES
--------------
DO
$do$
DECLARE
   arr integer[] := array[$YEAR];
   i integer;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    RAISE NOTICE 'Dropping view for year: %', i;
    EXECUTE 'drop materialized view IF EXISTS  offense_offense_counts_' || i::TEXT || ' CASCADE';
    RAISE NOTICE 'Creating view for year: %', i;
    EXECUTE 'create materialized view offense_offense_counts_' || i::TEXT || ' as select count(offense_id), ori, offense_name,weapon_name, method_entry_code, num_premises_entered,location_name, state_id 
    from ( 
        SELECT DISTINCT(offense_id), ref_agency.ori, offense_name, weapon_name, method_entry_code, num_premises_entered,location_name, nibrs_offense_denorm_' || i::TEXT || '.state_id, year from nibrs_offense_denorm_' || i::TEXT || ' 
        JOIN ref_agency ON ref_agency.agency_id = nibrs_offense_denorm_' || i::TEXT || '.agency_id 
        where year::integer = ' || i || ' 
        ) as temp
    GROUP BY GROUPING SETS (
        (year, offense_name, weapon_name),
        (year, offense_name, method_entry_code),
        (year, offense_name, num_premises_entered),
        (year, offense_name, location_name),
        (year, state_id, offense_name, weapon_name),
        (year, state_id, offense_name, method_entry_code),
        (year, state_id, offense_name, num_premises_entered),
        (year, state_id, offense_name, location_name),
        (year, ori, offense_name, weapon_name),
        (year, ori, offense_name, method_entry_code),
        (year, ori, offense_name, num_premises_entered),
        (year, ori, offense_name, location_name)
    );';
   END LOOP;
END
$do$;

create materialized view offense_offense_counts_states_temp as 
    SELECT *,$YEAR as year FROM offense_offense_counts_$YEAR WHERE ori IS NULL UNION 
    SELECT *,2015 as year FROM offense_offense_counts_2015 WHERE ori IS NULL UNION 
    SELECT *,2014 as year FROM offense_offense_counts_2014 WHERE ori IS NULL UNION 
    SELECT *,2013 as year  FROM offense_offense_counts_2013 WHERE ori IS NULL UNION 
    SELECT *,2012 as year  FROM offense_offense_counts_2012 WHERE ori IS NULL UNION 
    SELECT *,2011 as year  FROM offense_offense_counts_2011 WHERE ori IS NULL UNION 
    SELECT *,2010 as year  FROM offense_offense_counts_2010 WHERE ori IS NULL UNION 
    SELECT *,2009 as year  FROM offense_offense_counts_2009 WHERE ori IS NULL UNION 
    SELECT *,2008 as year  FROM offense_offense_counts_2008 WHERE ori IS NULL UNION 
    SELECT *,2007 as year  FROM offense_offense_counts_2007 WHERE ori IS NULL UNION 
    SELECT *,2006 as year  FROM offense_offense_counts_2006 WHERE ori IS NULL UNION 
    SELECT *,2005 as year  FROM offense_offense_counts_2005 WHERE ori IS NULL UNION 
    SELECT *,2004 as year  FROM offense_offense_counts_2004 WHERE ori IS NULL UNION 
    SELECT *,2003 as year  FROM offense_offense_counts_2003 WHERE ori IS NULL UNION 
    SELECT *,2002 as year  FROM offense_offense_counts_2002 WHERE ori IS NULL UNION 
    SELECT *,2001 as year  FROM offense_offense_counts_2001 WHERE ori IS NULL UNION 
    SELECT *,2000 as year  FROM offense_offense_counts_2000 WHERE ori IS NULL UNION 
    SELECT *,1999 as year  FROM offense_offense_counts_1999 WHERE ori IS NULL UNION 
    SELECT *,1998 as year  FROM offense_offense_counts_1998 WHERE ori IS NULL UNION 
    SELECT *,1997 as year  FROM offense_offense_counts_1997 WHERE ori IS NULL UNION 
    SELECT *,1996 as year  FROM offense_offense_counts_1996 WHERE ori IS NULL UNION 
    SELECT *,1995 as year  FROM offense_offense_counts_1995 WHERE ori IS NULL UNION 
    SELECT *,1994 as year  FROM offense_offense_counts_1994 WHERE ori IS NULL UNION 
    SELECT *,1993 as year  FROM offense_offense_counts_1993 WHERE ori IS NULL UNION 
    SELECT *,1992 as year  FROM offense_offense_counts_1992 WHERE ori IS NULL UNION 
    SELECT *,1991 as year  FROM offense_offense_counts_1991 WHERE ori IS NULL;



create materialized view offense_offense_counts_ori_temp as 
    SELECT *,$YEAR as year FROM offense_offense_counts_$YEAR WHERE ori IS NOT NULL UNION 
    SELECT *,2015 as year FROM offense_offense_counts_2015 WHERE ori IS NOT NULL UNION 
    SELECT *,2014 as year FROM offense_offense_counts_2014 WHERE ori IS NOT NULL UNION 
    SELECT *,2013 as year  FROM offense_offense_counts_2013 WHERE ori IS NOT NULL UNION 
    SELECT *,2012 as year  FROM offense_offense_counts_2012 WHERE ori IS NOT NULL UNION 
    SELECT *,2011 as year  FROM offense_offense_counts_2011 WHERE ori IS NOT NULL UNION 
    SELECT *,2010 as year  FROM offense_offense_counts_2010 WHERE ori IS NOT NULL UNION 
    SELECT *,2009 as year  FROM offense_offense_counts_2009 WHERE ori IS NOT NULL UNION 
    SELECT *,2008 as year  FROM offense_offense_counts_2008 WHERE ori IS NOT NULL UNION 
    SELECT *,2007 as year  FROM offense_offense_counts_2007 WHERE ori IS NOT NULL UNION 
    SELECT *,2006 as year  FROM offense_offense_counts_2006 WHERE ori IS NOT NULL UNION 
    SELECT *,2005 as year  FROM offense_offense_counts_2005 WHERE ori IS NOT NULL UNION 
    SELECT *,2004 as year  FROM offense_offense_counts_2004 WHERE ori IS NOT NULL UNION 
    SELECT *,2003 as year  FROM offense_offense_counts_2003 WHERE ori IS NOT NULL UNION 
    SELECT *,2002 as year  FROM offense_offense_counts_2002 WHERE ori IS NOT NULL UNION 
    SELECT *,2001 as year  FROM offense_offense_counts_2001 WHERE ori IS NOT NULL UNION 
    SELECT *,2000 as year  FROM offense_offense_counts_2000 WHERE ori IS NOT NULL UNION 
    SELECT *,1999 as year  FROM offense_offense_counts_1999 WHERE ori IS NOT NULL UNION 
    SELECT *,1998 as year  FROM offense_offense_counts_1998 WHERE ori IS NOT NULL UNION 
    SELECT *,1997 as year  FROM offense_offense_counts_1997 WHERE ori IS NOT NULL UNION 
    SELECT *,1996 as year  FROM offense_offense_counts_1996 WHERE ori IS NOT NULL UNION 
    SELECT *,1995 as year  FROM offense_offense_counts_1995 WHERE ori IS NOT NULL UNION 
    SELECT *,1994 as year  FROM offense_offense_counts_1994 WHERE ori IS NOT NULL UNION 
    SELECT *,1993 as year  FROM offense_offense_counts_1993 WHERE ori IS NOT NULL UNION 
    SELECT *,1992 as year  FROM offense_offense_counts_1992 WHERE ori IS NOT NULL UNION 
    SELECT *,1991 as year  FROM offense_offense_counts_1991 WHERE ori IS NOT NULL;

"
