# -*- coding: utf-8 -*-
"""The app module, containing the app factory function."""
import csv
import io

import flask_restful as restful
from flask import Flask, render_template
from flask_cors import CORS, cross_origin

import crime_data.resources.agencies
import crime_data.resources.incidents
from crime_data import commands, public, user
from crime_data.assets import assets
from crime_data.common.models import db
from crime_data.extensions import bcrypt, cache, csrf_protect, db, debug_toolbar, login_manager, migrate
from crime_data.settings import ProdConfig

if __name__ == '__main__':
    app.run(debug=True)


def create_app(config_object=ProdConfig):
    """An application factory, as explained here: http://flask.pocoo.org/docs/patterns/appfactories/.

    :param config_object: The configuration object to use.
    """
    app = Flask(__name__)
    app.config.from_object(config_object)
    CORS(app)
    register_extensions(app)
    register_blueprints(app)
    register_errorhandlers(app)
    register_shellcontext(app)
    add_resources(app)
    register_commands(app)
    db.init_app(app)
    return app


def register_extensions(app):
    """Register Flask extensions."""
    assets.init_app(app)
    bcrypt.init_app(app)
    cache.init_app(app)
    db.init_app(app)
    csrf_protect.init_app(app)
    login_manager.init_app(app)
    debug_toolbar.init_app(app)
    migrate.init_app(app, db)
    return None


def register_blueprints(app):
    """Register Flask blueprints."""
    app.register_blueprint(public.views.blueprint)
    app.register_blueprint(user.views.blueprint)
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
        return {'db': db, 'User': user.models.User}

    app.shell_context_processor(shell_context)


def register_commands(app):
    """Register Click commands."""
    app.cli.add_command(commands.test)
    app.cli.add_command(commands.lint)
    app.cli.add_command(commands.clean)
    app.cli.add_command(commands.urls)


def add_resources(app):
    api = restful.Api(app)

    @api.representation('text/csv')
    def output_csv(data, code, headers=None):
        """Curl with -H "Accept: text/csv" """
        outfile = io.StringIO()
        keys = data[0].keys()
        writer = csv.DictWriter(outfile, keys)
        writer.writerows(data)
        outfile.seek(0)
        resp = api.make_response(outfile.read(), code)
        resp.headers.extend(headers or {})
        return resp

    api.add_resource(crime_data.resources.agencies.AgenciesList, '/agencies/')
    api.add_resource(crime_data.resources.agencies.AgenciesDetail,
                     '/agencies/<string:nbr>/')
    api.add_resource(crime_data.resources.incidents.IncidentsList,
                     '/incidents/')
    api.add_resource(crime_data.resources.incidents.IncidentsDetail,
                     '/incidents/<string:nbr>/')
