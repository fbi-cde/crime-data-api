-- These views create joining tables with the distinct values of certain
-- fields that do not have a clear attached entity withing the CDE.

DROP table IF EXISTS nibrs_years;
DROP materialized view IF EXISTS nibrs_years;
CREATE materialized view nibrs_years AS 
SELECT DISTINCT year from nibrs_offense_denorm;

set work_mem='800MB';
DROP materialized view IF EXISTS nibrs_age_num;
CREATE materialized view nibrs_age_num AS 
SELECT DISTINCT age_num from victim_counts_2014;

DROP materialized view IF EXISTS nibrs_sex_code;
CREATE materialized view nibrs_sex_code AS 
SELECT DISTINCT sex_code from victim_counts_2014;

DROP materialized view IF EXISTS nibrs_num_premises_entered;
CREATE materialized view nibrs_num_premises_entered AS
SELECT DISTINCT num_premises_entered from offense_counts_2014;

DROP materialized view IF EXISTS nibrs_method_entry_code;
CREATE materialized view nibrs_method_entry_code AS
SELECT DISTINCT method_entry_code from offense_counts_2014;

DROP materialized view IF EXISTS nibrs_resident_status_code;
CREATE materialized view nibrs_resident_status_code AS
SELECT DISTINCT resident_status_code from victim_counts_2014;





