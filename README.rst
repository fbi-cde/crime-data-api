===============================
crime_data_api
===============================

A flasky app.

<<<<<<< HEAD
.. image:: https://circleci.com/gh/18F/crime-data-api.svg?style=svg
    :target: https://circleci.com/gh/18F/crime-data-api
    :alt: Build status
.. image:: https://coveralls.io/repos/github/catherinedevlin/crime_data_api.svg?branch=master
     :target: https://coveralls.io/github/catherinedevlin/crime_data_api?branch=master
     :alt: Coverage status
.. image:: https://codeclimate.com/github/catherinedevlin/crime_data_api.svg
     :target: https://codeclimate.com/github/catherinedevlin/crime_data_api
     :alt: Code Climate status
.. image:: https://continua11y.18f.gov/catherinedevlin/crime_data_api?branch=master
     :target: https://continua11y.18f.gov/catherinedevlin/crime_data_api
     :alt: Accessibility status
.. image:: https://img.shields.io/badge/built%20with-Cookiecutter%20Django-ff69b4.svg
     :target: https://github.com/pydanny/cookiecutter-django/
     :alt: Built with Cookiecutter Django

Quickstart
----------

First, set your app's secret key as an environment variable. For example,
add the following to ``.bashrc`` or ``.bash_profile``.

.. code-block:: bash

    export CRIME_DATA_SECRET='something-really-secret'

Before running shell commands, set the ``FLASK_APP`` and ``FLASK_DEBUG``
environment variables ::

    export FLASK_APP=/path/to/autoapp.py
    export FLASK_DEBUG=1

Then run the following commands to bootstrap your environment ::

    git clone https://github.com/catherinedevlin/crime_data
    cd crime_data
    pip install -r requirements/dev.txt
    bower install
    flask run

You will see a pretty welcome screen.

Once you have installed your DBMS, run the following to create your app's
database tables and perform the initial migration ::

    flask db init
    flask db migrate
    flask db upgrade
    flask run


Deployment
----------

In your production environment, make sure the ``FLASK_DEBUG`` environment
variable is unset or is set to ``0``, so that ``ProdConfig`` is used.


Shell
-----

To open the interactive shell, run ::

    flask shell

By default, you will have access to the flask ``app``.


Running Tests
-------------

To run all tests, run ::

    flask test


Migrations
----------

Whenever a database migration needs to be made. Run the following commands ::

    flask db migrate

This will generate a new migration script. Then run ::

    flask db upgrade

To apply the migration.

For a full migration command reference, run ``flask db --help``.
