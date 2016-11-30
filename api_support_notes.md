
Available fields for API
========================

Hopefully these will soon all be visible in https://crime-data-api.fr.cloud.gov/docs/.
However, until then...

/incidents/
-----------

You can filter by any field in the results of an /incidents/ query.

There's a shortcut to getting those available filters for `static/swagger.json`:
uncomment the call to `print_map` in `crime_data/common/cdemodels.py`,
run the app, run a query against it, and copy-and-paste the terminal-window
output into `swagger.json`.

/incidents/count
----------------

You can filter by any field listed in http://localhost:5000/offenses/;
that summary of offenses also contains the available values.

You can also filter by any field in `agencies` or its child tables
(location, etc.); the handiest place to see these fields is in the
results of an `/incidents/` query.

Including `by=field1_name,field2_name,field3_name` in the parameters will group the results by,
and show, those field names.

General filtering rules
=======================

The API supports filtering for

- equality (`fieldname=val`)
- inequality (`fieldname!=val`)
- comparison (`fieldname>=val`, `fieldname>=val`, `fieldname<val`, `fieldname<=val`)

Filters are case-insensitive.

The API does not yet support joining filters with OR or partial-string matches.
Your input in how to prioritize those is valued.


Speed
=====

Filtered queries will be slow unless an index exists on that table.
Currently existing
indexes are in `dba/manual_sql/indexes.sql`.  They are easy to add - disk
space is the only expense - so please request whatever indexes the app
requires!

Pagination
==========

App supports `page` and `per_page` arguments.

Currently the reported `page_count` is a shameless, performance-preserving
lie.  
