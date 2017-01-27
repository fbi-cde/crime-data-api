drop materialized view victim_counts;
create materialized view victim_counts as 
    SELECT *, 2014 as year FROM victim_counts_2014 UNION 
    SELECT *, 2013 as year FROM victim_counts_2013 UNION
    SELECT *, 2012 as year FROM victim_counts_2012 UNION 
    SELECT *, 2011 as year FROM victim_counts_2011 UNION 
    SELECT *, 2010 as year FROM victim_counts_2010 UNION
    SELECT *, 2009 as year FROM victim_counts_2009 UNION 
    SELECT *, 2008 as year FROM victim_counts_2008 UNION 
    SELECT *, 2007 as year FROM victim_counts_2007 UNION
    SELECT *, 2006 as year FROM victim_counts_2006 UNION 
    SELECT *, 2005 as year FROM victim_counts_2005 UNION 
    SELECT *, 2004 as year FROM victim_counts_2004 UNION
    SELECT *, 2003 as year FROM victim_counts_2003 UNION 
    SELECT *, 2002 as year FROM victim_counts_2002 UNION 
    SELECT *, 2001 as year FROM victim_counts_2001 UNION
    SELECT *, 2000 as year FROM victim_counts_2000 UNION 
    SELECT *, 1999 as year FROM victim_counts_1999 UNION 
    SELECT *, 1998 as year FROM victim_counts_1998 UNION
    SELECT *, 1997 as year FROM victim_counts_1997 UNION 
    SELECT *, 1996 as year FROM victim_counts_1996 UNION 
    SELECT *, 1995 as year FROM victim_counts_1995 UNION
    SELECT *, 1994 as year FROM victim_counts_1994 UNION 
    SELECT *, 1993 as year FROM victim_counts_1993 UNION 
    SELECT *, 1992 as year FROM victim_counts_1992 UNION
    SELECT *, 1991 as year FROM victim_counts_1991;

drop materialized view offender_counts;
create materialized view offender_counts as 
    SELECT *, 2014 as year FROM offender_counts_2014 UNION 
    SELECT *, 2013 as year FROM offender_counts_2013 UNION
    SELECT *, 2012 as year FROM offender_counts_2012 UNION 
    SELECT *, 2011 as year FROM offender_counts_2011 UNION 
    SELECT *, 2010 as year FROM offender_counts_2010 UNION
    SELECT *, 2009 as year FROM offender_counts_2009 UNION 
    SELECT *, 2008 as year FROM offender_counts_2008 UNION 
    SELECT *, 2007 as year FROM offender_counts_2007 UNION
    SELECT *, 2006 as year FROM offender_counts_2006 UNION 
    SELECT *, 2005 as year FROM offender_counts_2005 UNION 
    SELECT *, 2004 as year FROM offender_counts_2004 UNION
    SELECT *, 2003 as year FROM offender_counts_2003 UNION 
    SELECT *, 2002 as year FROM offender_counts_2002 UNION 
    SELECT *, 2001 as year FROM offender_counts_2001 UNION
    SELECT *, 2000 as year FROM offender_counts_2000 UNION 
    SELECT *, 1999 as year FROM offender_counts_1999 UNION 
    SELECT *, 1998 as year FROM offender_counts_1998 UNION
    SELECT *, 1997 as year FROM offender_counts_1997 UNION 
    SELECT *, 1996 as year FROM offender_counts_1996 UNION 
    SELECT *, 1995 as year FROM offender_counts_1995 UNION
    SELECT *, 1994 as year FROM offender_counts_1994 UNION 
    SELECT *, 1993 as year FROM offender_counts_1993 UNION 
    SELECT *, 1992 as year FROM offender_counts_1992 UNION
    SELECT *, 1991 as year FROM offender_counts_1991;

drop materialized view offense_counts;
create materialized view offense_counts as 
    SELECT * FROM offense_counts_2014 UNION 
    SELECT * FROM offense_counts_2013 UNION
    SELECT * FROM offense_counts_2012 UNION 
    SELECT * FROM offense_counts_2011 UNION 
    SELECT * FROM offense_counts_2010 UNION
    SELECT * FROM offense_counts_2009 UNION 
    SELECT * FROM offense_counts_2008 UNION 
    SELECT * FROM offense_counts_2007 UNION
    SELECT * FROM offense_counts_2006 UNION 
    SELECT * FROM offense_counts_2005 UNION 
    SELECT * FROM offense_counts_2004 UNION
    SELECT * FROM offense_counts_2003 UNION 
    SELECT * FROM offense_counts_2002 UNION 
    SELECT * FROM offense_counts_2001 UNION
    SELECT * FROM offense_counts_2000 UNION 
    SELECT * FROM offense_counts_1999 UNION 
    SELECT * FROM offense_counts_1998 UNION
    SELECT * FROM offense_counts_1997 UNION 
    SELECT * FROM offense_counts_1996 UNION 
    SELECT * FROM offense_counts_1995 UNION
    SELECT * FROM offense_counts_1994 UNION 
    SELECT * FROM offense_counts_1993 UNION 
    SELECT * FROM offense_counts_1992 UNION
    SELECT * FROM offense_counts_1991;

drop materialized view offense_victim_counts;
create materialized view offense_victim_counts as 
    SELECT *, 2014 as year FROM offense_victim_counts_2014 UNION 
    SELECT *, 2013 as year FROM offense_victim_counts_2013 UNION
    SELECT *, 2012 as year FROM offense_victim_counts_2012 UNION 
    SELECT *, 2011 as year FROM offense_victim_counts_2011 UNION 
    SELECT *, 2010 as year FROM offense_victim_counts_2010 UNION
    SELECT *, 2009 as year FROM offense_victim_counts_2009 UNION 
    SELECT *, 2008 as year FROM offense_victim_counts_2008 UNION 
    SELECT *, 2007 as year FROM offense_victim_counts_2007 UNION
    SELECT *, 2006 as year FROM offense_victim_counts_2006 UNION 
    SELECT *, 2005 as year FROM offense_victim_counts_2005 UNION 
    SELECT *, 2004 as year FROM offense_victim_counts_2004 UNION
    SELECT *, 2003 as year FROM offense_victim_counts_2003 UNION 
    SELECT *, 2002 as year FROM offense_victim_counts_2002 UNION 
    SELECT *, 2001 as year FROM offense_victim_counts_2001 UNION
    SELECT *, 2000 as year FROM offense_victim_counts_2000 UNION 
    SELECT *, 1999 as year FROM offense_victim_counts_1999 UNION 
    SELECT *, 1998 as year FROM offense_victim_counts_1998 UNION
    SELECT *, 1997 as year FROM offense_victim_counts_1997 UNION 
    SELECT *, 1996 as year FROM offense_victim_counts_1996 UNION 
    SELECT *, 1995 as year FROM offense_victim_counts_1995 UNION
    SELECT *, 1994 as year FROM offense_victim_counts_1994 UNION 
    SELECT *, 1993 as year FROM offense_victim_counts_1993 UNION 
    SELECT *, 1992 as year FROM offense_victim_counts_1992 UNION
    SELECT *, 1991 as year FROM offense_victim_counts_1991;

drop materialized view offense_offender_counts;
create materialized view offense_offender_counts as 
    SELECT *,2014 as year FROM offense_offender_counts_2014 UNION 
    SELECT *,2013 as year FROM offense_offender_counts_2013 UNION
    SELECT *,2012 as year FROM offense_offender_counts_2012 UNION 
    SELECT *,2011 as year FROM offense_offender_counts_2011 UNION 
    SELECT *,2010 as year FROM offense_offender_counts_2010 UNION
    SELECT *,2009 as year FROM offense_offender_counts_2009 UNION 
    SELECT *,2008 as year FROM offense_offender_counts_2008 UNION 
    SELECT *,2007 as year FROM offense_offender_counts_2007 UNION
    SELECT *,2006 as year FROM offense_offender_counts_2006 UNION 
    SELECT *,2005 as year FROM offense_offender_counts_2005 UNION 
    SELECT *,2004 as year FROM offense_offender_counts_2004 UNION
    SELECT *,2003 as year FROM offense_offender_counts_2003 UNION 
    SELECT *,2002 as year FROM offense_offender_counts_2002 UNION 
    SELECT *,2001 as year FROM offense_offender_counts_2001 UNION
    SELECT *,2000 as year FROM offense_offender_counts_2000 UNION 
    SELECT *,1999 as year FROM offense_offender_counts_1999 UNION 
    SELECT *,1998 as year FROM offense_offender_counts_1998 UNION
    SELECT *,1997 as year FROM offense_offender_counts_1997 UNION 
    SELECT *,1996 as year FROM offense_offender_counts_1996 UNION 
    SELECT *,1995 as year FROM offense_offender_counts_1995 UNION
    SELECT *,1994 as year FROM offense_offender_counts_1994 UNION 
    SELECT *,1993 as year FROM offense_offender_counts_1993 UNION 
    SELECT *,1992 as year FROM offense_offender_counts_1992 UNION
    SELECT *,1991 as year FROM offense_offender_counts_1991;

drop materialized view offense_offense_counts;
create materialized view offense_offense_counts as 
    SELECT * FROM offense_offense_counts_2014 UNION 
    SELECT * FROM offense_offense_counts_2013 UNION
    SELECT * FROM offense_offense_counts_2012 UNION 
    SELECT * FROM offense_offense_counts_2011 UNION 
    SELECT * FROM offense_offense_counts_2010 UNION
    SELECT * FROM offense_offense_counts_2009 UNION 
    SELECT * FROM offense_offense_counts_2008 UNION 
    SELECT * FROM offense_offense_counts_2007 UNION
    SELECT * FROM offense_offense_counts_2006 UNION 
    SELECT * FROM offense_offense_counts_2005 UNION 
    SELECT * FROM offense_offense_counts_2004 UNION
    SELECT * FROM offense_offense_counts_2003 UNION 
    SELECT * FROM offense_offense_counts_2002 UNION 
    SELECT * FROM offense_offense_counts_2001 UNION
    SELECT * FROM offense_offense_counts_2000 UNION 
    SELECT * FROM offense_offense_counts_1999 UNION 
    SELECT * FROM offense_offense_counts_1998 UNION
    SELECT * FROM offense_offense_counts_1997 UNION 
    SELECT * FROM offense_offense_counts_1996 UNION 
    SELECT * FROM offense_offense_counts_1995 UNION
    SELECT * FROM offense_offense_counts_1994 UNION 
    SELECT * FROM offense_offense_counts_1993 UNION 
    SELECT * FROM offense_offense_counts_1992 UNION
    SELECT * FROM offense_offense_counts_1991;