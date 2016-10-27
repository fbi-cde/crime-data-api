import re

from marshmallow import Schema
from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource
from crime_data.common.marshmallow_schemas import (
    ArgumentsSchema, IncidentArgsSchema, IncidentCountArgsSchema)


class IncidentsList(CdeResource):

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
        self.verify_api_key(args)
        result = models.NibrsIncident.query
        joined = set([models.NibrsIncident, ])
        for col, tables in self.TABLES_BY_COLUMN.items():
            if args.get(col):  # TODO: specifying null
                for table in tables:
                    if table not in joined:
                        result = result.join(table)
                        joined.add(table)
                result = result.filter(getattr(tables[-1], col) == args[col])
        return self.with_metadata(result, args)


class IncidentsDetail(CdeResource):

    schema = marshmallow_schemas.NibrsIncidentSchema(many=True)

    @use_args(ArgumentsSchema)
    def get(self, args, nbr):
        self.verify_api_key(args)
        incidents = models.NibrsIncident.query.filter_by(incident_number=nbr)
        return self.with_metadata(incidents, args)


class IncidentsCount(CdeResource):

    SPLITTER = re.compile(r"\s*,\s*")

    @use_args(IncidentCountArgsSchema)
    def get(self, args):
        self.verify_api_key(args)
        by = self.SPLITTER.split(
            args['by'].lower())  # TODO: can post-process in schema?
        if args.get('fields'):
            fields = self.SPLITTER.split(args['fields'].lower())
        else:
            fields = []
        result = cdemodels.RetaMonthQuery(aggregated=fields, grouped=by)
        print(result.qry)
        return self.with_metadata(result, args)
