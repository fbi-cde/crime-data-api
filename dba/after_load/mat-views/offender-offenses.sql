drop materialized view offense_offender_counts_2014;
create materialized view offense_offender_counts_2014 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2014' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2013;
create materialized view offense_offender_counts_2013 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2013' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2012;
create materialized view offense_offender_counts_2012 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2012' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2011;
create materialized view offense_offender_counts_2011 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2011' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2010;
create materialized view offense_offender_counts_2010 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2010' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2009;
create materialized view offense_offender_counts_2009 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2009' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2008;
create materialized view offense_offender_counts_2008 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2008' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2007;
create materialized view offense_offender_counts_2007 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2007' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2006;
create materialized view offense_offender_counts_2006 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2006' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2005;
create materialized view offense_offender_counts_2005 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2005' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2004;
create materialized view offense_offender_counts_2004 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2004' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2003;
create materialized view offense_offender_counts_2003 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2003' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2002;
create materialized view offense_offender_counts_2002 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2002' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2001;
create materialized view offense_offender_counts_2001 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2001' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_2000;
create materialized view offense_offender_counts_2000 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '2000' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_1999;
create materialized view offense_offender_counts_1999 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '1999' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_1998;
create materialized view offense_offender_counts_1998 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '1998' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_1997;
create materialized view offense_offender_counts_1997 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '1997' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_1996;
create materialized view offense_offender_counts_1996 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '1996' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_1995;
create materialized view offense_offender_counts_1995 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '1995' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_1994;
create materialized view offense_offender_counts_1994 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '1994' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_1993;
create materialized view offense_offender_counts_1993 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '1993' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_1992;
create materialized view offense_offender_counts_1992 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '1992' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);

drop materialized view offense_offender_counts_1991;
create materialized view offense_offender_counts_1991 as select count(offender_id),ethnicity,offense_name, state_id, race_code, age_num, sex_code 
from ( SELECT DISTINCT(offender_id), ethnicity, age_num,race_code,year,offense_name, sex_code, state_id from nibrs_offender_denorm where year = '1991' and state_id is not null) as temp
GROUP BY GROUPING SETS (
    (year, offense_name, race_code),
    (year, offense_name, sex_code),
    (year, offense_name, age_num),
    (year, offense_name, ethnicity),
    (year, state_id, offense_name, race_code),
    (year, state_id, offense_name, sex_code),
    (year, state_id, offense_name, age_num),
    (year, state_id, offense_name, ethnicity)
);