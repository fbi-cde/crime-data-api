# -*- coding: utf-8 -*-
"""Defines fixtures available to all tests."""

import pytest
from webtest import TestApp

from crime_data.app import create_app
from crime_data.database import db as _db
from crime_data.settings import TestConfig
from sqlalchemy.orm import scoped_session, sessionmaker

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
