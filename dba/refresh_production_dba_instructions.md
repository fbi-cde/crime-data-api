Refreshing the production database
==================================

The production database will be static between new deliveries of data,
which may happen as rarely as annually.  A series of manual steps will
convert the

(This document is a *stub* and, as of yet, very incomplete.  For now
  we're using it to record steps that shouldn't be forgotten.)

1. Convert to PostgreSQL
1. Run `sql/functions.sql` to add necessary stored procedures
1. Run `sql/indexes.sql`
1. Run `dba/scrub_private_for_prod.sql` to remove data that could expose PII  
1. Run `pg_dump` to generate a PostgreSQL dumpfile
1. [upload](upload.md) dumpfile to an S3 bucket
1. use `cf import-data` to pull the dumpfile into the RDS instance
