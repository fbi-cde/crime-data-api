Available fields for API
========================

The Crime Data API is what powers the CDE website (whose code is
at
[crime-data-explorer](https://github.com/fbi-cde/crime-data-explorer). All
API requests require an API key which can be provided to you securely
by a FBI CDE team member.

All API endpoints are documented in Swagger, and interactive
documentation can be found at [https://crime-data-api.fr.cloud.gov/swagger-ui/](https://crime-data-api.fr.cloud.gov/swagger-ui/)

Note that this documentation is still not feature-complete. Many
fields are missing descriptions and the documentation will focus
primarily on what the frontend developers on the FBI project need
before making the documentation more accessible. This document is a
supplement to the Swagger documentation with some general notes about
API usage.

/incidents/
-----------

This is the endpoint used to query specific records from NIBRS. It
should not be used to aggregate NIBRS statistics.

You can filter by any field in the results of an `/incidents/` query by
appending values to the query string in the API call. The
`/meta/incidents` API endpoint returns a list of fields that can be
filtered on. In some cases, fields might be codes within the FBI
database (ie, `state_id` or `offense_type_code`). To get a list of
those possible values, look for one of the endpoints listed in the
`/codes/` API endpoint.


/incidents/count
----------------

This is the endpoint used to query specific records from SRS aka
"Return A" records. It should not be used to aggregate NIBRS
statistics.

You can filter by any field in the results of an `/incidents/count` query by
appending values to the query string in the API call. The
`/meta/incidents/count` API endpoint returns a list of fields that can be
filtered on. In some cases, fields might be codes within the FBI
database (ie, `state_id` or `offense_type_code`). To get a list of
those possible values, look for one of the endpoints listed in the
`/codes/` API endpoint.

You can also filter by any field in `agencies` or its child tables
(location, etc.); the handiest place to see these fields is in the
results of an `/incidents/` query.

Including `by=field1_name,field2_name,field3_name` in the parameters will group the results by,
and show, those field names.

Other Endpoints
---------------

The `/incidents` and `/incidents/count` endpoints are essentially
broad by design, so that they could be used to explore future
directions for the front-end interface. This does not make them
especially performant however, and as the CDE frontend is built, we
will develop more specific and efficient endpoints for elements on the
CDE pages. Your best bet is to refer to the Swagger UI for the most
up-to-date listing on all the methods.

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

App supports `page` and `per_page` arguments. Note that for large
queries, the total results returned will be a rough estimate for
performance reasons. This means that if we were to paginate over all
records, the total nimber of pages might be less or more than the
reported number of pages. Queries that are estimated to return less
than a 1000 records are then precisely counted so that will not be an
issue for them.
