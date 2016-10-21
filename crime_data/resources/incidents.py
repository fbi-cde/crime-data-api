import os
import re
from datetime import date, datetime

import sqlalchemy as sa
from flask import request
from flask_login import login_required
#from webservices.common.views import ApiResource
from flask_restful import Resource, fields, marshal_with, reqparse
from sqlalchemy import func

from crime_data.common import models
from crime_data.common.base import CdeResource
# from webservices import args
# from webservices import docs
# from webservices import utils
# from webservices import schemas
# from webservices import exceptions
from crime_data.extensions import db

from .helpers import QueryWithAggregates, add_standard_arguments, verify_api_key

# from flask_apispec import doc

OFFENSE_FIELDS = {
    'offense_id': fields.Integer,
    'location': fields.Nested({
        'location_code': fields.String,
        'location_name': fields.String,
    }),
    'method_entry_code': fields.String,  # needs explanation
    'offense_type': fields.Nested({
        'offense_code': fields.String,
        'offense_name': fields.String,
        'crime_against': fields.String,
        'offense_category_name': fields.String,
        # 'attempt_complete_flag': fields.String, - stored as C or U
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
parser.add_argument('incident_hour')
parser.add_argument('crime_against')
parser.add_argument('offense_code')
parser.add_argument('offense_name')
parser.add_argument('offense_category_name')
parser.add_argument('method_entry_code')
parser.add_argument('location_code')
parser.add_argument('location_name')
add_standard_arguments(parser)


class IncidentsList(Resource):

    TABLES_BY_COLUMN = {
        'incident_hour': (models.NibrsIncident, ),
        'method_entry_code': (models.NibrsOffense, ),
        'offense_category_name': (models.NibrsOffense,
                                  models.NibrsOffenseType, ),
        'offense_code': (models.NibrsOffense,
                         models.NibrsOffenseType, ),
        'offense_name': (models.NibrsOffense,
                         models.NibrsOffenseType, ),
        'crime_against': (models.NibrsOffense,
                          models.NibrsOffenseType, ),
        'offense_category_name': (models.NibrsOffense,
                                  models.NibrsOffenseType, ),
        'location_code': (models.NibrsOffense,
                          models.NibrsLocationType, ),
        'location_name': (models.NibrsOffense,
                          models.NibrsLocationType, ),
    }

    @marshal_with(FIELDS)
    def get(self):
        args = parser.parse_args()
        verify_api_key(args)
        result = models.NibrsIncident.query
        joined = set([models.NibrsIncident, ])
        for col, tables in self.TABLES_BY_COLUMN.items():
            if args.get(col):  # TODO: specifying null
                for table in tables:
                    if table not in joined:
                        result = result.join(table)
                        joined.add(table)
                result = result.filter(getattr(tables[-1], col) == args[col])
        return result.paginate(args['page'], args['page_size']).items


class IncidentsDetail(Resource):
    @marshal_with(FIELDS)
    def get(self, nbr):
        args = parser.parse_args()
        verify_api_key(args)
        incident = models.NibrsIncident.query.filter_by(
            incident_number=nbr).first()
        return incident


summary_parser = reqparse.RequestParser()
summary_parser.add_argument('by', default='year')
summary_parser.add_argument('fields')
# no nargs available for multiple use of field names
add_standard_arguments(summary_parser)

SUMM_FIELDS = {
    'year': fields.String,
    'total_actual_count': fields.Integer,
    'report_date': fields.DateTime,
}


class IncidentsCount(CdeResource):

    SPLITTER = re.compile(r"\s*,\s*")

    def get(self):
        args = summary_parser.parse_args()
        verify_api_key(args)
        by = self.SPLITTER.split(args['by'].lower())
        if args['fields']:
            fields = self.SPLITTER.split(args['fields'].lower())
        else:
            fields = []
        result = models.RetaMonthQuery(aggregated=fields, grouped=by)
        return self._stringify(result.qry)
        # This result isn't working with @marshal_with
