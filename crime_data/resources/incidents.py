import os
import re
from datetime import date, datetime

import sqlalchemy as sa
from crime_data.common import models, marshmallow_schemas
from crime_data.common.base import CdeResource
# from webservices import args
# from webservices import docs
# from webservices import utils
# from webservices import schemas
# from webservices import exceptions
from crime_data.extensions import db
from flask import abort, request
from flask_login import login_required
#from webservices.common.views import ApiResource
from flask_restful import Resource, fields, marshal_with, reqparse
from sqlalchemy import func

from .helpers import (QueryWithAggregates, add_standard_arguments,
                      verify_api_key, with_metadata)


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
    
    schema = marshmallow_schemas.NibrsIncidentSchema(many=True)

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
        return with_metadata(result, args, schema=self.schema)


class IncidentsDetail(Resource):
    
    schema = marshmallow_schemas.NibrsIncidentSchema(many=True) 
    
    def get(self, nbr):
        args = parser.parse_args()
        verify_api_key(args)
        incidents = models.NibrsIncident.query.filter_by(
            incident_number=nbr)
        return with_metadata(incidents, args, schema=self.schema)


summary_parser = reqparse.RequestParser()
summary_parser.add_argument('by', default='year')
summary_parser.add_argument('fields')
# no nargs available for multiple use of field names
add_standard_arguments(summary_parser)


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
        return with_metadata(result.qry, args)
        # This result isn't working with @marshal_with
