SET work_mem='4096MB';
drop materialized view offense_victim_counts_2014 CASCADE;
create materialized view offense_victim_counts_2014 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2014' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2013 CASCADE;
create materialized view offense_victim_counts_2013 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2013' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);

SET work_mem='4096MB';
drop materialized view offense_victim_counts_2012 CASCADE;
create materialized view offense_victim_counts_2012 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,resident_status_code,offender_relationship,circumstance_name,year,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2012' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);

SET work_mem='4096MB';
drop materialized view offense_victim_counts_2011 CASCADE;
create materialized view offense_victim_counts_2011 as select count(victim_id),ethnicity,resident_status_code,offender_relationship,circumstance_name,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,resident_status_code,offender_relationship,circumstance_name,year,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2011' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);

SET work_mem='4096MB';
drop materialized view offense_victim_counts_2010 CASCADE;
create materialized view offense_victim_counts_2010 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2010' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2009 CASCADE;
create materialized view offense_victim_counts_2009 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2009' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2008 CASCADE;
create materialized view offense_victim_counts_2008 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2008' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2007 CASCADE;
create materialized view offense_victim_counts_2007 as select count(victim_id),ethnicity,resident_status_code,offender_relationship,circumstance_name,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,resident_status_code,offender_relationship,circumstance_name,year,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2007' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2006 CASCADE;
create materialized view offense_victim_counts_2006 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2006' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2005 CASCADE;
create materialized view offense_victim_counts_2005 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2005' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2004 CASCADE;
create materialized view offense_victim_counts_2004 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2004' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2003 CASCADE;
create materialized view offense_victim_counts_2003 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2003' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2002 CASCADE;
create materialized view offense_victim_counts_2002 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,offense_name,resident_status_code,offender_relationship,circumstance_name, sex_code, state_id from nibrs_victim_denorm where year = '2002' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2001 CASCADE;
create materialized view offense_victim_counts_2001 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '2001' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_2000 CASCADE;
create materialized view offense_victim_counts_2000 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,offense_name,resident_status_code,offender_relationship,circumstance_name, sex_code, state_id from nibrs_victim_denorm where year = '2000' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_1999 CASCADE;
create materialized view offense_victim_counts_1999 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '1999' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_1998 CASCADE;
create materialized view offense_victim_counts_1998 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,offense_name,resident_status_code,offender_relationship,circumstance_name, sex_code, state_id from nibrs_victim_denorm where year = '1998' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_1997 CASCADE;
create materialized view offense_victim_counts_1997 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '1997' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_1996 CASCADE;
create materialized view offense_victim_counts_1996 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '1996' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);
SET work_mem='4096MB';
drop materialized view offense_victim_counts_1995 CASCADE;
create materialized view offense_victim_counts_1995 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '1995' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);

SET work_mem='4096MB';
drop materialized view offense_victim_counts_1994 CASCADE;
create materialized view offense_victim_counts_1994 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '1994' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);

SET work_mem='4096MB';
drop materialized view offense_victim_counts_1993 CASCADE;
create materialized view offense_victim_counts_1993 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '1993' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);

SET work_mem='4096MB';
drop materialized view offense_victim_counts_1992 CASCADE;
create materialized view offense_victim_counts_1992 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '1992' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);

SET work_mem='4096MB';
drop materialized view offense_victim_counts_1991 CASCADE;
create materialized view offense_victim_counts_1991 as select count(victim_id),resident_status_code,offender_relationship,circumstance_name,ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(victim_id), ethnicity, age_num,race_code,year,resident_status_code,offender_relationship,circumstance_name,offense_name, sex_code, state_id from nibrs_victim_denorm where year = '1991' and state_id is not null) as temp
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
    (year, state_id, offense_name, circumstance_name)
);