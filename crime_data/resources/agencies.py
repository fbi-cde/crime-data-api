import sqlalchemy as sa
import os
# from flask_apispec import doc

# from webservices import args
# from webservices import docs
# from webservices import utils
# from webservices import schemas
# from webservices import exceptions
from crime_data.extensions import db
from crime_data.common import models
#from webservices.common.views import ApiResource
from flask_restful import Resource, fields, marshal_with
from flask_restful import reqparse
from flask_login import login_required
from flask import request


FIELDS = {
  'ori': fields.String,
  'ucr_agency_name': fields.String,
  'ncic_agency_name': fields.String,
  'pub_agency_name': fields.String,
  'judicial_dist_code': fields.String,
  'dormant_year': fields.String,
  'fid_code': fields.String,
  'agency_type': fields.Nested(
    {'agency_type_name': fields.String,}),
}

parser = reqparse.RequestParser()
if os.getenv('VCAP_APPLICATION'):
    parser.add_argument('api_key', required=True, help='Get from Catherine')

class AgenciesList(Resource):

    @marshal_with(FIELDS)
    def get(self):
        args = parser.parse_args()
        if os.getenv('VCAP_APPLICATION'):
            if args['api_key'] != os.getenv('API_KEY'):
                return({'message': 'Ask Catherine for API key'}, 401)
        result = models.RefAgency.query
        return result.paginate(1, 10).items

class AgenciesDetail(Resource):

    @marshal_with(FIELDS)
    def get(self, nbr):
        args = parser.parse_args()
        if os.getenv('VCAP_APPLICATION'):
            if args['api_key'] != os.getenv('API_KEY'):
                return({'message': 'Ask Catherine for API key'}, 401)
        agency = models.RefAgency.query.filter_by(ori=nbr).first()
        return agency
