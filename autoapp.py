# -*- coding: utf-8 -*-
"""Create an application instance."""
from flask.helpers import get_debug_flag

from crime_data.app import create_app
from crime_data.settings import DevConfig, ProdConfig

CONFIG = DevConfig if get_debug_flag() else ProdConfig

app = create_app(CONFIG)

# This lets you see the /__sqltap__ debugging console on develop
if get_debug_flag():
    import sqltap.wsgi
    app.wsgi_app = sqltap.wsgi.SQLTapMiddleware(app.wsgi_app)
