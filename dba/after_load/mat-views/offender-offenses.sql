DROP function IF EXISTS create_offense_code_partition_and_insert() CASCADE;
CREATE OR REPLACE FUNCTION create_offense_code_partition_and_insert() RETURNS trigger AS
$BODY$
DECLARE
offense_code TEXT;
partition TEXT;
BEGIN
offense_code := lower(NEW.offense_code);
partition := TG_RELNAME || '_' || offense_code;
IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=lower(partition)) THEN
  RAISE NOTICE 'A partition has been created %',  partition;
  EXECUTE 'CREATE TABLE ' || partition || ' (check (offense_code = ''' || NEW.offense_code || ''')) INHERITS (' || TG_RELNAME || ');';
END IF;
EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').* RETURNING id;';
RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


DROP TABLE IF EXISTS offense_offender_counts_states_temp CASCADE;
CREATE TABLE offense_offender_counts_states_temp(
   id SERIAL PRIMARY KEY,
   year int,
   count int,
   ethnicity varchar(100),
   age_num int,
   race_code varchar(2),
   sex_code varchar(1),
   offense_code varchar(10),
   offense_name text,
   state_id int,
   state_abbr varchar(2)
);

DROP TABLE IF EXISTS offense_offender_counts_ori_temp CASCADE;
CREATE TABLE offense_offender_counts_ori_temp(
id SERIAL PRIMARY KEY,
year int,
count int,
ori char(9),
ethnicity varchar(100),
age_num int,
race_code varchar(2),
sex_code varchar(1),
offense_code varchar(10),
offense_name text,
state_id int,
state_abbr varchar(2)
);

CREATE TRIGGER offense_offender_states_partition_insert_trigger
BEFORE INSERT ON offense_offender_counts_states_temp
FOR EACH ROW EXECUTE PROCEDURE create_offense_code_partition_and_insert();

CREATE TRIGGER offense_offender_ori_partition_insert_trigger
BEFORE INSERT ON offense_offender_counts_ori_temp
FOR EACH ROW EXECUTE PROCEDURE create_offense_code_partition_and_insert();

DO
$do$
DECLARE
   arr integer[] := array[2016,2015,2014,2013,2012,2011,2010,2009,2008,2007,2006,2005,2004,2003,2002,2001,2000,1999,1998,1997,1996,1995,1994,1993,1992,1991];
   i integer;
   denorm_table TEXT;
BEGIN
   FOREACH i IN ARRAY arr
   LOOP
    SET work_mem='2GB';
    denorm_table := 'nibrs_offender_denorm_' || i::TEXT;
    IF EXISTS(SELECT relname FROM pg_class WHERE relname=denorm_table) THEN
        EXECUTE 'INSERT INTO offense_offender_counts_states_temp(year, count, ethnicity, offense_code, offense_name, state_id, state_abbr, race_code, age_num, sex_code)
         SELECT ' || i || ' as year, COUNT(offender_id), ethnicity, offense_code, offense_name, state_id, state_postal_abbr, race_code, age_num, sex_code 
         from (
         SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year, nibrs_offense_type.offense_code, nibrs_offense_type.offense_name, sex_code, nibrs_offender_denorm_' || i::TEXT || '.state_id, state_postal_abbr from ' || denorm_table || '
        JOIN ref_state ON ref_state.state_id = ' || denorm_table || '.state_id
        JOIN nibrs_offense ON nibrs_offense.incident_id = ' || denorm_table ||'.incident_id
        JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = nibrs_offense.offense_type_id 
        where year::integer = ' || i || ' and ' || denorm_table || '.state_id is not null
    ) as temp 
    GROUP BY GROUPING SETS (
        (year, offense_code, offense_name, race_code),
        (year, offense_code, offense_name, sex_code),
        (year, offense_code, offense_name, age_num),
        (year, offense_code, offense_name, ethnicity),
        (year, state_id, state_postal_abbr, offense_code, offense_name, race_code),
        (year, state_id, state_postal_abbr, offense_code, offense_name, sex_code),
        (year, state_id, state_postal_abbr, offense_code, offense_name, age_num),
        (year, state_id, state_postal_abbr, offense_code, offense_name, ethnicity));';

        EXECUTE 'DELETE FROM offense_offender_counts_states_temp WHERE year=' || i || ' AND race_code IS NULL AND sex_code IS NULL AND age_num IS NULL AND ethnicity IS NULL ';

        EXECUTE 'INSERT INTO offense_offender_counts_states_temp(year, count, offense_code, offense_name, state_id, state_abbr)
                 SELECT ' || i || ' AS year, COUNT(offender_id), offense_code, nibrs_offense_type.offense_name, ref_state.state_id, state_postal_abbr
                 FROM ' || denorm_table || ' JOIN nibrs_offense ON nibrs_offense.incident_id = ' || denorm_table ||'.incident_id
                 JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = nibrs_offense.offense_type_id
                 JOIN ref_state ON ref_state.state_id = ' || denorm_table || '.state_id AND year::integer = ' || i || '
                 GROUP BY year, offense_code, nibrs_offense_type.offense_name, ref_state.state_id, state_postal_abbr';

        EXECUTE 'INSERT INTO offense_offender_counts_ori_temp(year, count, ori, ethnicity, offense_code, offense_name, state_id, state_abbr, race_code, age_num, sex_code)
        SELECT ' || i || ' as year, COUNT(offender_id), ori, ethnicity, offense_code, offense_name, state_id, state_postal_abbr, race_code, age_num, sex_code 
    from (
        SELECT DISTINCT(offender_id), ref_agency.ori, ethnicity, age_num,race_code,year, nibrs_offense_type.offense_code, nibrs_offense_type.offense_name, sex_code, nibrs_offender_denorm_' || i::TEXT || '.state_id, state_postal_abbr from ' || denorm_table || ' 
        JOIN ref_agency ON ref_agency.agency_id = ' || denorm_table || '.agency_id
        JOIN ref_state ON ref_state.state_id = ' || denorm_table || '.state_id
        JOIN nibrs_offense ON nibrs_offense.incident_id = ' || denorm_table ||'.incident_id
        JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = nibrs_offense.offense_type_id 
        where year::integer = ' || i || ' and ' || denorm_table || '.state_id is not null
    ) as temp 
    GROUP BY GROUPING SETS (
        (year, ori, offense_code, offense_name, race_code, state_id, state_postal_abbr),
        (year, ori, offense_code, offense_name, sex_code, state_id, state_postal_abbr),
        (year, ori, offense_code, offense_name, age_num, state_id, state_postal_abbr),
        (year, ori, offense_code, offense_name, ethnicity, state_id, state_postal_abbr)
        );';

        EXECUTE 'DELETE FROM offense_offender_counts_ori_temp WHERE year=' || i || ' AND race_code IS NULL AND sex_code IS NULL AND age_num IS NULL AND ethnicity IS NULL ';

        EXECUTE 'INSERT INTO offense_offender_counts_ori_temp(count, year, ori, offense_code, offense_name, state_id, state_abbr)
          SELECT COUNT(offender_id), ' || i || ' AS year,  ref_agency.ori, offense_code, nibrs_offense_type.offense_name, ref_state.state_id, state_postal_abbr
          FROM ' || denorm_table || ' JOIN ref_agency ON ref_agency.agency_id = ' || denorm_table || '.agency_id 
          JOIN ref_state ON ref_state.state_id = ' || denorm_table || '.state_id
          JOIN nibrs_offense ON nibrs_offense.incident_id = ' || denorm_table ||'.incident_id
          JOIN nibrs_offense_type ON nibrs_offense_type.offense_type_id = nibrs_offense.offense_type_id
          GROUP BY year, ref_agency.ori, offense_code, nibrs_offense_type.offense_name, ref_state.state_id, state_postal_abbr';
        END IF;
  END LOOP; 
END
$do$;

-- explain analyze select count(offender_id), ori,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
--     from (
--         SELECT DISTINCT(offender_id), ref_agency.ori, ethnicity, age_num,race_code,year,offense_name, sex_code, nibrs_offender_denorm_1991.state_id from nibrs_offender_denorm_1991 
--         JOIN ref_agency ON ref_agency.agency_id = nibrs_offender_denorm_1991.agency_id 
--         where year::integer = 1991 and nibrs_offender_denorm_1991.state_id is not null
--     ) as temp 
--     GROUP BY GROUPING SETS (
--         (year, offense_name, race_code),
--         (year, offense_name, sex_code),
--         (year, offense_name, age_num),
--         (year, offense_name, ethnicity),
--         (year, state_id, offense_name, race_code),
--         (year, state_id, offense_name, sex_code),
--         (year, state_id, offense_name, age_num),
--         (year, state_id, offense_name, ethnicity),
--         (year, ori, offense_name, race_code),
--         (year, ori, offense_name, sex_code),
--         (year, ori, offense_name, age_num),
--         (year, ori, offense_name, ethnicity)
--     );

-- drop materialized view IF EXISTS  offense_offender_counts_states;
-- create materialized view offense_offender_counts_states as 
--     SELECT *,2014 as year FROM offense_offender_counts_2014 WHERE ori IS NULL  UNION 
--     SELECT *,2013 as year FROM offense_offender_counts_2013 WHERE ori IS NULL  UNION
--     SELECT *,2012 as year FROM offense_offender_counts_2012 WHERE ori IS NULL  UNION 
--     SELECT *,2011 as year FROM offense_offender_counts_2011 WHERE ori IS NULL  UNION 
--     SELECT *,2010 as year FROM offense_offender_counts_2010 WHERE ori IS NULL  UNION
--     SELECT *,2009 as year FROM offense_offender_counts_2009 WHERE ori IS NULL  UNION 
--     SELECT *,2008 as year FROM offense_offender_counts_2008 WHERE ori IS NULL  UNION 
--     SELECT *,2007 as year FROM offense_offender_counts_2007 WHERE ori IS NULL  UNION
--     SELECT *,2006 as year FROM offense_offender_counts_2006 WHERE ori IS NULL  UNION 
--     SELECT *,2005 as year FROM offense_offender_counts_2005 WHERE ori IS NULL  UNION 
--     SELECT *,2004 as year FROM offense_offender_counts_2004 WHERE ori IS NULL  UNION
--     SELECT *,2003 as year FROM offense_offender_counts_2003 WHERE ori IS NULL  UNION 
--     SELECT *,2002 as year FROM offense_offender_counts_2002 WHERE ori IS NULL  UNION 
--     SELECT *,2001 as year FROM offense_offender_counts_2001 WHERE ori IS NULL  UNION
--     SELECT *,2000 as year FROM offense_offender_counts_2000 WHERE ori IS NULL  UNION 
--     SELECT *,1999 as year FROM offense_offender_counts_1999 WHERE ori IS NULL  UNION 
--     SELECT *,1998 as year FROM offense_offender_counts_1998 WHERE ori IS NULL  UNION
--     SELECT *,1997 as year FROM offense_offender_counts_1997 WHERE ori IS NULL  UNION 
--     SELECT *,1996 as year FROM offense_offender_counts_1996 WHERE ori IS NULL  UNION 
--     SELECT *,1995 as year FROM offense_offender_counts_1995 WHERE ori IS NULL  UNION
--     SELECT *,1994 as year FROM offense_offender_counts_1994 WHERE ori IS NULL  UNION 
--     SELECT *,1993 as year FROM offense_offender_counts_1993 WHERE ori IS NULL  UNION 
--     SELECT *,1992 as year FROM offense_offender_counts_1992 WHERE ori IS NULL  UNION
--     SELECT *,1991 as year FROM offense_offender_counts_1991 WHERE ori IS NULL ;


-- drop materialized view IF EXISTS  offense_offender_counts_ori;
-- create materialized view offense_offender_counts_ori as 
--     SELECT *,2014 as year FROM offense_offender_counts_2014 WHERE ori IS NOT NULL  UNION 
--     SELECT *,2013 as year FROM offense_offender_counts_2013 WHERE ori IS NOT NULL  UNION
--     SELECT *,2012 as year FROM offense_offender_counts_2012 WHERE ori IS NOT NULL  UNION 
--     SELECT *,2011 as year FROM offense_offender_counts_2011 WHERE ori IS NOT NULL  UNION 
--     SELECT *,2010 as year FROM offense_offender_counts_2010 WHERE ori IS NOT NULL  UNION
--     SELECT *,2009 as year FROM offense_offender_counts_2009 WHERE ori IS NOT NULL  UNION 
--     SELECT *,2008 as year FROM offense_offender_counts_2008 WHERE ori IS NOT NULL  UNION 
--     SELECT *,2007 as year FROM offense_offender_counts_2007 WHERE ori IS NOT NULL  UNION
--     SELECT *,2006 as year FROM offense_offender_counts_2006 WHERE ori IS NOT NULL  UNION 
--     SELECT *,2005 as year FROM offense_offender_counts_2005 WHERE ori IS NOT NULL  UNION 
--     SELECT *,2004 as year FROM offense_offender_counts_2004 WHERE ori IS NOT NULL  UNION
--     SELECT *,2003 as year FROM offense_offender_counts_2003 WHERE ori IS NOT NULL  UNION 
--     SELECT *,2002 as year FROM offense_offender_counts_2002 WHERE ori IS NOT NULL  UNION 
--     SELECT *,2001 as year FROM offense_offender_counts_2001 WHERE ori IS NOT NULL  UNION
--     SELECT *,2000 as year FROM offense_offender_counts_2000 WHERE ori IS NOT NULL  UNION 
--     SELECT *,1999 as year FROM offense_offender_counts_1999 WHERE ori IS NOT NULL  UNION 
--     SELECT *,1998 as year FROM offense_offender_counts_1998 WHERE ori IS NOT NULL  UNION
--     SELECT *,1997 as year FROM offense_offender_counts_1997 WHERE ori IS NOT NULL  UNION 
--     SELECT *,1996 as year FROM offense_offender_counts_1996 WHERE ori IS NOT NULL  UNION 
--     SELECT *,1995 as year FROM offense_offender_counts_1995 WHERE ori IS NOT NULL  UNION
--     SELECT *,1994 as year FROM offense_offender_counts_1994 WHERE ori IS NOT NULL  UNION 
--     SELECT *,1993 as year FROM offense_offender_counts_1993 WHERE ori IS NOT NULL  UNION 
--     SELECT *,1992 as year FROM offense_offender_counts_1992 WHERE ori IS NOT NULL  UNION
--     SELECT *,1991 as year FROM offense_offender_counts_1991 WHERE ori IS NOT NULL ;

-- DROP INDEX offense_offender_counts_state_id_idx;
-- DROP INDEX offense_offender_counts_ori_idx;
-- CREATE INDEX offense_offender_counts_state_id_idx ON offense_offender_counts_states (state_id, year, offense_name);
-- CREATE INDEX offense_offender_counts_ori_idx ON offense_offender_counts_ori (ori, year, offense_name);

