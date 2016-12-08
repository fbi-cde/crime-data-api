crime_data_api
================

A flasky app.

[![Build status](https://circleci.com/gh/18F/crime-data-api.svg?style=svg)](https://circleci.com/gh/18F/crime-data-api)
[![Code Climate status](https://codeclimate.com/github/18F/crime-data-api.svg)](https://codeclimate.com/github/18F/crime-data-api)
[![Test Coverage](https://codeclimate.com/github/18F/crime-data-api/badges/coverage.svg)](https://codeclimate.com/github/18F/crime-data-api/coverage)
[![Dependency Status](https://gemnasium.com/18F/crime-data-api.svg)](https://gemnasium.com/18F/crime-data-api)

Quickstart
----------

First, set your app’s secret key as an environment variable. For example, add the following to `.bashrc` or `.bash_profile`.

```
export CRIME_DATA_SECRET='something-really-secret'
```

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
