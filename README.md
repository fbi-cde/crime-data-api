crime_data_api
================

[![Build status](https://circleci.com/gh/18F/crime-data-api.svg?style=svg)](https://circleci.com/gh/18F/crime-data-api)
[![Code Climate status](https://codeclimate.com/github/18F/crime-data-api.svg)](https://codeclimate.com/github/18F/crime-data-api)
[![Test Coverage](https://codeclimate.com/github/18F/crime-data-api/badges/coverage.svg)](https://codeclimate.com/github/18F/crime-data-api/coverage)
[![Dependency Status](https://gemnasium.com/18F/crime-data-api.svg)](https://gemnasium.com/18F/crime-data-api)

This project is the back end for the Crime Data
Explorer
[18f/crime-data-explorer](https://github.com/18f/crime-data-explorer). The
Crime Data Explorer is a website that allows law enforcement and the
general public to more easily access uniform crime data. The FBI
collects this data from state and local law enforcement agencies and
publishes it in the form of annual reports. This API allows users to
look at multiple years of data as well as other information only
provided as a master file from the FBI.

This project is a Python flask app that uses SqlAlchemy to wrap a
Postgres database.

The Sample Database
-------------------

The full database of UCR crime data is too large to include in this
repository or as a download -- over many hundreds of gigabytes in size
-- comprising many tables that are linked together by primary and
foreign key constraints. Instead, this project includes a small
excerpt of the database that mainly comprises only data for Rhode
Island in 2014. This slice means that API endpoints will return some
data and that we can run our tests, but you will have to load the full
database to see more data.

See the section of "Loading the Full Database" for information about
loading the full database and the tasks we run after loading to add
additional data and derive new tables.

Note: if you have a full database running somewhere on cloud.gov or
the like, it's possible to setup a SSH tunnel to use that database
instead. It's recommended you don't do this for development though.

Quickstart
----------

First, let's set some environment variables that will be useful. You
might want to define these within a `.env` file that can be used by
`autoenv`

``` sh
export FLASK_APP=/path/to/autoapp.py
export FLASK_DEBUG=1
export CRIME_DATA_API_DB_URL="postgres:///crime_data_api_dev"
export APP_NAME=crime-data
```

You can run the following commands to bootstrap your environment and
load the testing database into Postgres:

``` sh
git clone https://github.com/18F/crime-data-api
cd crime-data-api
pip install -r requirements/dev.txt
createdb crime_data_api_dev
psql crime_data_api_dev < dba/crime_data_api_test.sql
flask run
```

You can then find the Swagger UI API documentation page
at [http://127.0.0.1:5000/](http://127.0.0.1:5000/). To test out the
API, make a request
to [http://127.0.0.1:5000/agencies](http://127.0.0.1:5000/agencies)

Deployment
----------

The app is continuously deployed to [cloud.gov](https://www.cloud.gov)
with [CircleCI](https://circleci.com/gh/18F/crime-data-api) with every
commit to `master`.

Tagged releases must be deployed manually using the
`manifests/demo.yml` manifest file. You can use the following set of
steps once you have authenticated with cloud.gov:

0. `git checkout <<version tag>>` - i.e. `git checkout v2017-04-12`
0. `cf push -f manifests/demo.yml`

In production environments, make sure the `FLASK_DEBUG` environment
variable is unset or is set to `0`, so that `ProdConfig` is used.

Shell
-----

To open the interactive shell, run :

``` sh
flask shell
```

By default, you will have access to the flask `app`.

Running Tests
-------------

Tests are written in the [py.test](https://docs.pytest.org/en/latest/)
testing framework, with additional support
from
[webtest](http://docs.pylonsproject.org/projects/webtest/en/latest/)
for functional testing of the API. As part of its testing, it also
will output coverage statistics for the tests.


Swagger
-------

To make it easier to see what the APIs can do, this project includes
endpoints the return [Swagger](http://swagger.io/) documentation for
the API. These documents are not yet complete or consistent and can
not yet be used to automatically generate API clients or to validate
API responses. But they do let you test out the API and see roughly
what the valid behavior is.

Unlike some other project that dynamically generate their Swagger from
decorations applied to methods, we are using a static swagger.json
file for this project. This means that developers will have to update
the swagger file for any new methods or changes to the responses for
existing methods. This is admittedly not immediately convenient, but
it lets us treat the swagger.json file as a contract of what the API
responses should be and use that for functional tests to ensure our
responses conform to what is described.

We are using the [flex](https://github.com/pipermerriam/flex) Swagger
validator in functional tests to verify they match Swagger. To add,
modify your functional test to be like the following

``` python
from flex.core import validate_api_call

def TestCountsEndpoint:
    def test_counts_matches_swagger(self, testapp, swagger):
        res = testapp.get('/counts')
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
```

The `swagger` fixture in py.test loads the
`crime_data/static/swagger.json` into a Flex object so we can use it
for validating that requests and responses match what is in the
Swagger schema.


Using The Full Database
-----------------------

If you have loaded a full database from the FBI into production, there
are still some other steps that you must run to use the data with the
CDE. This is because the CDE does not use many of the tables within
the UCR database directly, but instead has its own tables that are
derived from and supplement the default database. There are several
general types of such tables used by the CDE API:

1. Additional data tables are necessary to load in some data that is
   not provided within the UCR database itself. For instance,
   estimated crime counts for the nation and state, crime figures for
   the territories and corrected cargo theft incidents are all
   examples of external tables that are also loaded into the database.
2. Denormalized tables pull together data from multiple tables into a
   single record. The UCR database is in a highly normalized format
   that mitigates redundancy to reduce error, but it requires the
   database to join across dozens of tables to return the results of
   any API call, which is not performant.
3. Aggregate tables collect monthly statistics in Return A and related
   reports from agencies and add them at the annual level. Similarly,
   we create annual counts from related monthly reports like arson as
   well as a few incident-level reports like hate crimes or cargo
   theft.
4. NIBRS counts are a special type of aggregate tables that assemble
   ETL rollups of crime counts for specific dimensions within NIBRS
   incidents and related tables. So for instance, this table can tell
   you the annual counts by race_code or sex of all victims of
   aggravated assault for a given agency, or the general locations
   where crimes occur in a state. Because they are both specialized
   and could be large, there are many distinct tables for this
   information and different API endpoints for accessing them.

For a more detailed view of what tables are added to the stock UCR
database, see the related document CDE_TABLES.md. The important thing
here is how to load them. We have a script called `after_load.sh` that
can be run to generate the necessary CDE tables. It's meant to be
idempotent and can be run multiple times safely. Some tables may take
a long time to build. Note that the script will output a fair amount
of debugging text under normal operation.

To run the after_load tasks, first you need to set an environment
variable with a database URL with the location of the production
database. I find the easiest way to do this is to setup a tunnel using
the [cf-service-connect](https://github.com/18F/cf-service-connect)
plugin, which you must install to do this. You can then run it with
the name of an running app service and the name of its database to get
a list of connection values.

``` sh
cf connect-to-service --no-client crime-data-api crime-data-upload-db
export CRIME_DATA_API_DB_URL=postgres://USERNAME:PASSWORD@localhost:PORT/DBNAME
```

and in another terminal running `psql $CRIME_DATA_API_DB_URL` to
connect to the database through the tunnel. Make sure of course that
you aren't doing any of these steps to a production database serving
API requests to the public, since this operations will certainly cause
some rolling errors and downtime (best to work with a snapshot).

Anyhow, to augment the default UCR database with CDE tables, you need
to run the following steps.

``` sh
cd dba/after_load/ext
./load_external.sh
cd ../../
./after_load.sh
```

Note that while the load scripts are generally idempotent, the
external data includes renaming the existing cargo theft tables to
preserve them before loading revised data. This may spit out an error
if you attempt to run again.

Also, please note that the after_load.sh runs a bunch of queries that
might be quite slow. It might be better to run the commands inside
individually if you have a lower-powered DB instance.

Regenerating Data Downloads
---------------------------

In addition to the standard interface, the Crime Data Explorer has a
page
for
[pregenerated data downloads](https://crime-data-explorer.fr.cloud.gov/downloads-and-docs) for
datasets that supplement the data in the explorer. These are generated using SQL commands against the database and are uploaded to the S3 bucket that is attached to the application as an application. To regenerate these files, you can run.

``` sh
cd sql
./generate-csv-reports.sh
```

This will run the queries to save CSV files locally and then upload
them to S3. Maybe comment out the lines for the S3 CP if you want to
just test out the CSV generation.

Updating Police Agency Names
----------------------------

The master list of edited police names is located in
`dba/after_load/ext/agency_name_edits.csv`. To update the names of
agencies, make changes to the `edited_agency_name` column in the
CSV. Then do the following with an open tunnel to the production
database.

``` sh
cd dba/after_load/ext
psql $CRIME_DATA_API_DB_URL < update_agency_names.sql
```

This will load in the agencies CSV from your machine than update a few
tables where the agency name is displayed. Don't be alarmed if the
same number of rows is not updated in every table, since some agencies
may not be in various derived tables or may be present multiple times
in others.

Don't forget to check in your changes to the agency_name_edits.csv and
file a pull request when you are done.

Security Scans
--------------

This repository uses the [bandit](https://github.com/openstack/bandit)
tool to run automated static analysis of the project code for
potential vulnerabilities. These are run automatically as part of
continuous integration to identify potential vulnerabilities when they
are introduced in pull requests.

You can run bandit locally with the following command:

``` shell
bandit -r .
```

In some cases, bandit will identify false positives, code that looks
like it could be a security vulnerability but that will likely never
be triggered in a production environment. To disable reporting of
these vulnerabilities, you can append a `#nosec` comment on the line
of code where the vulnerability was identified.
