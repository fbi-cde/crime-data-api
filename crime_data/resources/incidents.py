import os

import sqlalchemy as sa
from flask import request
from flask_login import login_required
#from webservices.common.views import ApiResource
from flask_restful import Resource, fields, marshal_with, reqparse
from .helpers import add_standard_arguments, verify_api_key

from crime_data.common import models
# from webservices import args
# from webservices import docs
# from webservices import utils
# from webservices import schemas
# from webservices import exceptions
from crime_data.extensions import db

# from flask_apispec import doc

OFFENSE_FIELDS = {
    'offense_id': fields.Integer,
    'location': fields.Nested({
        'location_code': fields.String,
        'location_name': fields.String,
    }),
    'offense_type': fields.Nested({
        'offense_code': fields.String,
        'offense_name': fields.String,
        'crime_against': fields.String,
        'offense_category_name': fields.String,
    })
}

FIELDS = {
    'incident_number': fields.String,
    'incident_date': fields.DateTime,
    'submission_date': fields.DateTime,
    'incident_hour': fields.Integer,
    'offenses': fields.List(fields.Nested(OFFENSE_FIELDS)),
    'agency': fields.Nested({'ori': fields.String}),
}

parser = reqparse.RequestParser()
parser.add_argument('crime_against')
parser.add_argument('offense_code')
parser.add_argument('offense_name')
parser.add_argument('offense_category_name')
parser.add_argument('location_code')
parser.add_argument('location_name')
add_standard_arguments(parser)

class IncidentsList(Resource):
    @marshal_with(FIELDS)
    def get(self):
        args = parser.parse_args()
        verify_api_key(args)
        result = models.NibrsIncident.query
        if args['offense_code']:
            result = result.join(models.NibrsOffense). \
                join(models.NibrsOffenseType)
            result = result.filter(
                models.NibrsOffenseType.offense_code == args['offense_code'])

        return result.paginate(args['page'], args['page_size']).items


class IncidentsDetail(Resource):
    @marshal_with(FIELDS)
    def get(self, nbr):
        args = parser.parse_args()
        verify_api_key(args)
        incident = models.NibrsIncident.query.filter_by(
            incident_number=nbr).first()
        return incident
