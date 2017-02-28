# -*- coding: utf-8 -*-
"""Extensions module. Each extension is initialized in the app factory located in app.py."""
from flask_caching import Cache
from flask_debugtoolbar import DebugToolbarExtension
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from flask.ext.cachecontrol import FlaskCacheControl

db = SQLAlchemy()
migrate = Migrate()
cache = Cache()
debug_toolbar = DebugToolbarExtension()
cache_control = FlaskCacheControl()

# Going to go with 7 minutes because it's prime
DEFAULT_MAX_AGE = 420
