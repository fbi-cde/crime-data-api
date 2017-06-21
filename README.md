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

Before running shell commands, set the `FLASK_APP` and `FLASK_DEBUG` environment variables :

```
export FLASK_APP=/path/to/autoapp.py
export FLASK_DEBUG=1
```

Then run the following commands to bootstrap your environment :

```
git clone https://github.com/18F/crime-data-api
cd crime-data-api
pip install -r requirements/dev.txt
flask run
```

You will see a pretty welcome screen.

Once you have installed your DBMS, run the following to create your app’s database tables and perform the initial migration :

```
flask db init
flask db migrate
flask db upgrade
flask run
```

You can find the Swagger UI API documentation page at [http://127.0.0.1:5000/static/libs/swagger/index.html?url=/static/crime-data-api-swagger.yaml](http://127.0.0.1:5000/static/libs/swagger/index.html?url=/static/crime-data-api-swagger.yaml)

Deployment
----------
The app is continuously deployed to [cloud.gov](https://www.cloud.gov) with [CircleCI](https://circleci.com/gh/18F/crime-data-api) with every commit to `master`.

Tagged releases must be deployed manually using the `manifests/demo.yml` manifest file. You can use the following set of steps once you have authenticated with cloud.gov:

0. `git checkout <<version tag>>` - i.e. `git checkout v2017-04-12`
0. `cf push -f manifests/demo.yml`

In production environments, make sure the `FLASK_DEBUG` environment variable is unset or is set to `0`, so that `ProdConfig` is used.

Shell
-----

To open the interactive shell, run :

```
flask shell
```

By default, you will have access to the flask `app`.

Running Tests
-------------

```
export CRIME\_DATA\_SECRET=’something-really-secret’
```

Before running shell commands, set the `FLASK_APP` and `FLASK_DEBUG` environment variables :

    export FLASK_APP=/path/to/autoapp.py
    export FLASK_DEBUG=1

Then run the following commands to bootstrap your environment :

```
git clone https://github.com/18f/crime-data-api
cd crime-data-api
pip install -r requirements/dev.txt
flask run
```

You will see a pretty welcome screen.

Once you have installed your DBMS, run the following to create your app’s database tables and perform the initial migration :

```
flask db init
flask db migrate
flask db upgrade
flask run
```

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
