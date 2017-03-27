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


# Add some static routing
@app.route('/')
def swagger_ui():
    return app.send_static_file('swagger-ui.html')

@app.route('/swagger.json')
def swagger_json():
    return app.send_static_file('swagger.json')
