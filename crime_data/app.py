# -*- coding: utf-8 -*-
"""The app module, containing the app factory function."""
import csv
import io
from os import getenv

import flask_restful as restful
from flask import Flask, render_template
from flask_cors import CORS

from werkzeug.contrib.fixers import ProxyFix

from crime_data import commands
from crime_data.common.marshmallow_schemas import ma
from crime_data.common.models import db
from crime_data.common.credentials import get_credential
from crime_data.extensions import (cache, cache_control)
from crime_data.settings import ProdConfig

from crime_data.resources import beta

if __name__ == '__main__':
    app.run(debug=True)  # nosec, this isn't called on production
    #app.wsgi_app = ProxyFix(app.wsgi_app)


def create_app(config_object=ProdConfig):
    """An application factory, as explained here: http://flask.pocoo.org/docs/patterns/appfactories/.

    :param config_object: The configuration object to use.
    """
    app = Flask(__name__)
    app.config.from_object(config_object)
    register_extensions(app)
    register_blueprints(app)
    register_errorhandlers(app)
    register_shellcontext(app)
    register_newrelic(app)
    register_api_endpoints(app)
    register_commands(app)
    db.init_app(app)
    return app


def register_extensions(app):
    """Register Flask extensions."""
    cache.init_app(app)
    db.init_app(app)
    ma.init_app(app)
    cache_control.init_app(app)
    CORS(app)
    return None


def register_blueprints(app):
    """Register Flask blueprints."""
    return None


def register_errorhandlers(app):
    """Register error handlers."""

    def render_error(error):
        """Render error template."""
        # If a HTTPException, pull the `code` attribute; default to 500
        error_code = getattr(error, 'code', 500)
        return render_template('{0}.html'.format(error_code)), error_code

    for errcode in [401, 404, 500]:
        app.errorhandler(errcode)(render_error)
    return None


def register_shellcontext(app):
    """Register shell context objects."""

    def shell_context():
        """Shell context objects."""
        return {'db': db}

    app.shell_context_processor(shell_context)


def register_commands(app):
    """Register Click commands."""
    app.cli.add_command(commands.test)
    app.cli.add_command(commands.lint)
    app.cli.add_command(commands.clean)
    app.cli.add_command(commands.urls)


def register_api_endpoints(app):
    api = restful.Api(app)
    beta.register_api_endpoints(api)


def newrelic_status_endpoint():
    return 'OK'


def register_newrelic(app):
    """Setup New Relic monitoring for the application"""

    app.add_url_rule('/status', 'status', newrelic_status_endpoint)

    try:
        license_key = get_credential('NEW_RELIC_API_KEY')
        import newrelic.agent
        settings = newrelic.agent.global_settings()
        settings.license_key = license_key
        newrelic.agent.initialize()
    except: #nosec
        pass


from flask.helpers import get_debug_flag

from crime_data.settings import DevConfig, ProdConfig

CONFIG = DevConfig if get_debug_flag() else ProdConfig

app = create_app(CONFIG)
app.wsgi_app = ProxyFix(app.wsgi_app)

# Add some static routing
@app.route('/')
def swagger_ui():
    return app.send_static_file('swagger-ui.html')

@app.route('/swagger.json')
def swagger_json():
    return app.send_static_file('swagger.json')
