crime-data-api
==============

RESTful API service providing data and statistics on crime

.. image:: https://img.shields.io/travis/18F/crime-data-api.svg?branch=master
     :target: https://travis-ci.org/18F/crime-data-api
     :alt: Build Status
.. image:: https://coveralls.io/repos/github/18F/crime-data-api.svg?branch=master
     :target: https://coveralls.io/github/18F/crime-data-api?branch=master
     :alt: Coverage status
.. image:: https://codeclimate.com/github/18F/crime-data-api.svg
     :target: https://codeclimate.com/github/18F/crime-data-api
     :alt: Code Climate status


:License: CC0

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

    git clone https://github.com/18F/crime-data-api
    cd crime-data-api
    pip install -r requirements/dev.txt
    npm install && npm run swagger
    flask run

You will see a pretty welcome screen.

Once you have installed your DBMS, run the following to create your app's
database tables and perform the initial migration ::

    flask db init
    flask db migrate
    flask db upgrade
    flask run

You can find the Swagger UI API documentation page at ``http://127.0.0.1:5000/static/libs/swagger/index.html?url=/static/crime-data-api-swagger.yaml``

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
