import os

import sqlalchemy as sa
from flask import request
from flask_login import login_required
#from webservices.common.views import ApiResource
from flask_restful import Resource, fields, marshal_with, reqparse
from . import helpers
import json
from crime_data.common import cdemodels as models
from crime_data.common.base import CdeResource

# from webservices import args
# from webservices import docs
# from webservices import utils
# from webservices import schemas
# from webservices import exceptions
from crime_data.extensions import db
from flask import request
from flask_login import login_required
#from webservices.common.views import ApiResource
from flask_restful import Resource, fields, marshal_with, reqparse

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


#from crime_data.common.cdemodels import *
#db.session.query(cdeRefAgency).join(cdeNibrsMonth, cdeRefAgency.agency_id == cdeNibrsMonth.agency_id).all()
parser = reqparse.RequestParser()
helpers.add_standard_arguments(parser)

parser.add_argument('by', default='year')
parser.add_argument('fields')

class AgenciesList(CdeResource):
    @marshal_with(FIELDS)
    def get(self):
        args = parser.parse_args()
        helpers.verify_api_key(args)
        result = models.CdeRefAgency.query
        return result.paginate(args['page'], args['page_size']).items

class AgenciesDetail(CdeResource):
    @marshal_with(FIELDS)
    def get(self, nbr):
        args = parser.parse_args()
        helpers.verify_api_key(args)
        agency = models.CdeRefAgency.query.filter_by(ori=nbr).first()
        return agency

class AgenciesNibrsCount(CdeResource):

    def get(self, ori=None, filters=None):
        '''''
        Get Incident Count by Agency ID/ORI.
        '''''

        results = []

        counts = models.CdeNibrsIncident.get_nibrs_incident_by_ori(ori, filters)

        if counts:
            for r in counts:
                as_dict = self._as_dict(('count', 'ori', 'agency_id'), r)
                results.append(as_dict)

        return results








