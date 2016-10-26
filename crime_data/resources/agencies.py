import os

import sqlalchemy as sa
from flask import request
from flask_login import login_required
#from webservices.common.views import ApiResource
from flask_restful import Resource, fields, marshal_with, reqparse

from crime_data.common import models
# from webservices import args
# from webservices import docs
# from webservices import utils
# from webservices import schemas
# from webservices import exceptions
from crime_data.extensions import db

from . import helpers

# from flask_apispec import doc

FIELDS = {
    'ori': fields.String,
    'ucr_agency_name': fields.String,
    'ncic_agency_name': fields.String,
    'pub_agency_name': fields.String,
    'judicial_dist_code': fields.String,
    'dormant_year': fields.String,
    'fid_code': fields.String,
    'agency_type': fields.Nested({'agency_type_name': fields.String, }),
}

parser = reqparse.RequestParser()
helpers.add_standard_arguments(parser)


class AgenciesList(Resource):
    @marshal_with(FIELDS)
    def get(self):
        args = parser.parse_args()
        helpers.verify_api_key(args)
        result = models.RefAgency.query
        return result.paginate(args['page'], args['per_page']).items


class AgenciesDetail(Resource):
    @marshal_with(FIELDS)
    def get(self, nbr):
        args = parser.parse_args()
        helpers.verify_api_key(args)
        agency = models.RefAgency.query.filter_by(ori=nbr).first()
        return agency
