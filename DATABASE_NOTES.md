# Database Notes

This file contains some notes on how the Crime Data Explorer database
is structured and provides tips on how to safely and effectively query
the database.

## The Default Database Structure

The FBI database has a lot of tables. A **lot** of tables. This is
because the database currently includes data from at least many
different datasets:

- The Summary or "Return A" Reports of monthly crime statistics
- The NIBRS reports of individual crime incidents
- The hate crimes database
- The cargo theft database
- The human trafficking database
- Arson data
- Agency staffing and demographics
- Law Enforcement Officers Killed or Assaulted

While some of these datasets share a few tables (nearly all use the
same `ref_agency` table for listing agencies and several use the NIBRS
definitions of offenses), they are generally orthogonal from each
other and
in
[fifth normal form](https://en.wikipedia.org/wiki/Fifth_normal_form). This
means there are a lot of tables and that most queries involve many
joins among those table.

## Optimizations After Load

There are several optimizations we run on the database after
loading. Because some queries would involve many joins over large
tables (NIBRS has millions of rows), it makes sense to precompute
aggregates as well as cache representations. These operations are only
run once when a new data dump is provided by the FBI.

All optimizations can be run by calling the `dba/after_load.sh`
script. This script is idempotent and can be run multiple times
without harm. Note though that some operations can take a long time on
a full FBI database. This script runs several distinct steps.

### Data Scrubbing

The first step is to null out certain fields that contain information
that could potentially be sensitive. The data itself is not
confidential, but it contains some metadata like agency points of
contact or who last edited a particular entry that might seem like
PII, so we remove them. We also scrub fields like `ff_line_number` and
`did` that refer back to original police station documents.

To see a reckoning of all columns and how safe they are, see
the [safe_columns.txt](dba/after_load/safe_columns.txt)

### Ret A Summaries

The Return A contain a reckoning of how many crimes were counted for a
given offense in a given month by a given agency. To make it easier to
report trends at the state level, we use the Postgresql cubes to
create the following new table:

- **reta_cube_rollup**: a rollup of counts for offenses and
  subcategories at the state level

### Cached Representations

NIBRS incidents include a variety of nested one-to-many relationships
and many joins. For instance, an incident may include many offenses,
many victims, many locations, and many offenders. Building the JSON
representation for a single NIBRS incident is quite slow and can bog
down the application. Since these incidents do not regularly change,
it makes sense to prebuild JSON structures for all NIBRS
incidents. This lets us return the same JSON without a lot of DB
queries and also allows for users to potentially query NIBRS via
postgres' support for JSON fields rather than using database joins.

It can be quite slow to build these representations on a full-size
database. This optimization adds one table:

- **nibrs_incident_representation** - some basic NIBRS index
  information and a text column with a precomputed JSON representation

### The CountView tables

NIBRS provides incredibly detailed data for individual incidents. In
addition, it does not require agencies to do the "hierarchy rule" for
reporting offenses (ie, if a crime is a murder and a robbery, just
report it as a murder). This means it is a more accurate view of
crimes (specifically lesser crimes) in a given state. It's slow to run
aggregate queries against the dataset, so there are several
count_views table that collect data for specific fields at different
levels of geography. So, if you wanted to see what the racial
breakdown of victims of crime in Ohio was in 2014, you could look at
the `victim_counts` table for all rows where `year=2014, state_id=39,
county_id IS NULL, race_code IS NOT NULL`. There are several distinct
materialized views that are used for these calculations:

- **offender_counts**: aggregations of offenders
- **victim counts**: aggregations of victims
- **ct_counts**: cargo theft-specific data
- **hc_counts**: hate crime motivation counts
- **offense_counts**: aggregations of offenses
- **offender_offenses_counts**: sub-aggregations of offenses grouped by offender attributes
- **victim_offenses_counts**: sub-aggregations of offenses grouped by victim attributes

## How To Query The Database

Because the FBI database is so heavily normalized, it can be a bit
unclear where to start. This is not a typical RESTful application,
with limited numbers of tables that map neatly to resources. There are
several reasons why a Django-style ORM wouldn't work for this project:

- Many tables use multiple primary key columns (and do not necessarily
  have a since ID column with autoincrement)
- Many tables require 10-20 joins to make them comprehensible
- Some API endpoints support a filter UI that allows users to narrow
  queries by providing values for specific columns in the returned
  data. This is different from the usual ORM resource-driven approach.

That said, we're not creating raw SQL strings to run against the
database since that would be monstrous. Instead, this project uses a
more complicated but also more powerful ORM layer.

### SQLAlchemy is the ORM

We are using [SQLAlchemy](http://www.sqlalchemy.org/) as an ORM layer
above the database. For a listing of all tables and data about their
columns, look at the [models.py](crime_data/common/models.py)
file. This file has been automatically generated by database
reflection.

The [cdemodels.py](crime_data/common/cdemodels.py) files specifies
models that wrap the basic SQL Alchemy models with additional
logic. This is also where we define `TableFamily` classes that use
SQLAlchemy to build the necessary joins across multiple tables. Since
this uses SQLAlchemy's methods for database queries, it avoids some
issues with SQL injection.

SQL Alchemy passes all queries against the database to
the [psycopg2](http://initd.org/psycopg/docs/index.html) library. This
library does have protection against SQL injection, but it does not
work you include SQL parameters via string interpolation before
running the query. Any calls to `execute(sql)` must be sure to pass
parameters via the second argument `execute(sql, params)` and let
psycopg do the interpolation safely. There are a few places (ie, the
CountViews) where our code calls `execute` directly, but in those
cases, it passes in the parameters rather than performing string
interpolation beforehand.

### Marshmallow Is the Serialization Layer

To help with producing proper JSON, we use
the [Marshmallow](https://marshmallow.readthedocs.io/en/latest/)
library for serializing data into JSON. This library can also be used
for deserializing input into databases, but we only use it for
outputting the JSON. In addition, we have defined some Marshmallow
schema solely for documenting query parameters or output structures in
our Swagger JSON.
