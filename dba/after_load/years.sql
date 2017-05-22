-- DROP TABLE IF EXISTS nibrs_years CASCADE;
-- CREATE TABLE nibrs_years
-- (
--     year int PRIMARY KEY
-- );

-- DO
-- $do$
-- DECLARE
--    arr integer[] := array[2014,2013,2012,2011,2010,2009,2008,2007,2006,2005,2004,2003,2002,2001,2000,1999,1998,1997,1996,1995,1994,1993,1992,1991];
--    i integer;
-- BEGIN
--    FOREACH i IN ARRAY arr
--    LOOP
--     RAISE NOTICE 'Inserting year: %', i;
--     EXECUTE 'INSERT INTO nibrs_years (year) VALUES (' || i || ');';
--    END LOOP;
-- END
-- $do$;

DROP table IF EXISTS nibrs_years;
DROP materialized view IF EXISTS nibrs_years;
CREATE materialized view nibrs_years AS 
SELECT DISTINCT year from nibrs_offense_denorm;
