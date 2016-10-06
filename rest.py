import os
import http

from flask import abort
from flask import request
from flask import jsonify
from flask import url_for
from flask import redirect
# from flask import render_template
from flask import Flask
from flask import Blueprint

import flask_cors as cors
import flask_restful as restful

# from raven.contrib.flask import Sentry
# from werkzeug.contrib.fixers import ProxyFix
import sqlalchemy as sa

# from webargs.flaskparser import FlaskParser
# from flask_apispec import FlaskApiSpec

from crime_data.common.base import db
from crime_data.resources import agencies

app = Flask(__name__)
app.debug = True
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgres:///crime_data_api'
app.config['APISPEC_FORMAT_RESPONSE'] = None
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
# app.config['SQLALCHEMY_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS'] = bool(
#     env.get_credential('SQLA_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS', '')
# )
# app.config['SQLALCHEMY_FOLLOWER_TASKS'] = [
#     'webservices.tasks.download.export_query',
# ]
# app.config['SQLALCHEMY_FOLLOWERS'] = [
#     sa.create_engine(follower.strip())
#     for follower in env.get_credential('SQLA_FOLLOWERS', '').split(',')
#     if follower.strip()
# ]
# app.config['SQLALCHEMY_ECHO'] = True
db.init_app(app)
cors.CORS(app)

#v1 = Blueprint('v0.1', __name__, url_prefix='/v0.1')
api = restful.Api(app)

api.add_resource(agencies.AgenciesList, '/agencies/')

if __name__ == '__main__':
    app.run(debug=True)
