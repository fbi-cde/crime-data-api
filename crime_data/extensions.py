# -*- coding: utf-8 -*-
"""Extensions module. Each extension is initialized in the app factory located in app.py."""
from flask_caching import Cache
from flask_debugtoolbar import DebugToolbarExtension
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy as SQLAlchemyBase
from sqlalchemy.pool import NullPool
from flask import make_response, request

class SQLAlchemy(SQLAlchemyBase):
  def apply_driver_hacks(self, app, info, options):
    super(SQLAlchemy, self).apply_driver_hacks(app, info, options)
    # A DB pool is unnescessary.
    options['poolclass'] = NullPool 
    options.pop('pool_size', None)

db = SQLAlchemy()
migrate = Migrate()
cache = Cache()
debug_toolbar = DebugToolbarExtension()

# Going to go with 7 minutes because it's prime
DEFAULT_MAX_AGE = 420
DEFAULT_SURROGATE_AGE = 3600
