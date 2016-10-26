import os
import re
from datetime import date, datetime

import sqlalchemy as sa
from flask import abort, request
from flask_login import login_required
#from webservices.common.views import ApiResource
from flask_restful import Resource, fields, marshal_with, reqparse
from sqlalchemy import func
from webargs import fields
from webargs.flaskparser import use_args

from crime_data.common import marshmallow_schemas, models
from crime_data.common.base import CdeResource
from crime_data.common.marshmallow_schemas import (
    ArgumentsSchema, IncidentArgsSchema, IncidentCountArgsSchema,
    NibrsIncidentSchema)
# from webservices import args
# from webservices import docs
# from webservices import utils
# from webservices import schemas
# from webservices import exceptions
from crime_data.extensions import db

from .helpers import (QueryWithAggregates, add_standard_arguments,
                      verify_api_key, with_metadata)


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

    @use_args(IncidentArgsSchema)
    def get(self, args):
        # TODO: apply "fields" arg
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

    @use_args(ArgumentsSchema)
    def get(self, args, nbr):
        verify_api_key(args)
        incidents = models.NibrsIncident.query.filter_by(incident_number=nbr)
        return with_metadata(incidents, args, schema=self.schema)


class IncidentsCount(CdeResource):

    SPLITTER = re.compile(r"\s*,\s*")

    @use_args(IncidentCountArgsSchema)
    def get(self, args):
        verify_api_key(args)
        by = self.SPLITTER.split(args['by'].lower()
                                 )  # TODO: can post-process in schema?
        if args.get('fields'):
            fields = self.SPLITTER.split(args['fields'].lower())
        else:
            fields = []
        result = models.RetaMonthQuery(aggregated=fields, grouped=by)
        return with_metadata(result.qry, args)
