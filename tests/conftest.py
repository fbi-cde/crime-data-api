# -*- coding: utf-8 -*-
"""Defines fixtures available to all tests."""

import os
import pytest
from webtest import TestApp
import flex.core as flex

from crime_data.app import create_app
from crime_data.database import db as _db
from crime_data.settings import TestConfig

@pytest.yield_fixture(scope='function')
def app():
    """An application for the tests."""
    _app = create_app(TestConfig)
    ctx = _app.test_request_context()
    ctx.push()

    yield _app

    ctx.pop()


@pytest.fixture(scope='function')
def testapp(app):
    """A Webtest app."""
    return TestApp(app)


@pytest.yield_fixture(scope='function')
def rollback(app):
    """A database for the tests."""
    _db.app = app
    _db.session.begin(subtransactions=True)

    yield _db

    # Explicitly close DB connection
    _db.session.rollback()

# We will need one of these for each version of API we are supporting
@pytest.yield_fixture(scope='session')
def swagger_beta():
    """Load the swagger specification in a JSON schema object"""
    # Need to clear the basePath to run tests locally
    swagger_path = os.path.abspath(os.path.join(TestConfig.APP_DIR, 'resources', 'beta', 'swagger.json'))
    raw_schema = flex.load_source(swagger_path)
    raw_schema.pop('basePath', None)
    schema = flex.parse(raw_schema)
    yield schema
