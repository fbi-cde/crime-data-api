crime-data-api
==============

RESTful API service providing data and statistics on crime

.. image:: https://img.shields.io/travis/catherinedevlin/crime_data_api.svg?branch=master
     :target: https://travis-ci.org/catherinedevlin/crime_data_api
     :alt: Build Status
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


:License: CC0


Settings
--------

Moved to settings_.

.. _settings: http://cookiecutter-django.readthedocs.io/en/latest/settings.html

Basic Commands
--------------

Setting Up Your Users
^^^^^^^^^^^^^^^^^^^^^

* To create a **normal user account**, just go to Sign Up and fill out the form. Once you submit it, you'll see a "Verify Your E-mail Address" page. Go to your console to see a simulated email verification message. Copy the link into your browser. Now the user's email should be verified and ready to go.

* To create an **superuser account**, use this command::

    $ python manage.py createsuperuser

For convenience, you can keep your normal user logged in on Chrome and your superuser logged in on Firefox (or similar), so that you can see how the site behaves for both kinds of users.

Test coverage
^^^^^^^^^^^^^

To run the tests, check your test coverage, and generate an HTML coverage report::

    $ coverage run manage.py test
    $ coverage html
    $ open htmlcov/index.html

Running tests with py.test
~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  $ py.test

Live reloading and Sass CSS compilation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Moved to `Live reloading and SASS compilation`_.

.. _`Live reloading and SASS compilation`: http://cookiecutter-django.readthedocs.io/en/latest/live-reloading-and-sass-compilation.html





Deployment
----------

The following details how to deploy this application.



Docker
^^^^^^

See detailed `cookiecutter-django Docker documentation`_.

.. _`cookiecutter-django Docker documentation`: http://cookiecutter-django.readthedocs.io/en/latest/deployment-with-docker.html

