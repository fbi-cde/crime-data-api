import flask_apispec as swagger
from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource, tuning_page

# Template
# variables = [location_type, offense_type, property_type, age, sex, race]

# /offenders/count/states/<variable>/?year=...
# /offenders/count/states/<state>/<variable>/?year=...
# /offenders/count/counties/<variable>/?year=...
# /offenders/count/counties/<county>/<variable>/?year=...

def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)

import json

class OffendersCountStates(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    #schema = marshmallow_schemas.IncidentCountSchema()

    @use_args(marshmallow_schemas.IncidentViewCountArgsYear)
    # @swagger.use_kwargs(marshmallow_schemas.IncidentViewCountArgs,
    #                     locations=["query"],
    #                     apply=False)
    # @swagger.doc(
    #     tags=['offenders'],
    #     description=(
    #         'Returns counts by year for offenders. '
    #         'Offender Incidents - By State'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, state_id, variable):
        self.verify_api_key(args)
        model = cdemodels.OffenderCountView(args['year'], variable, state_id)
        results = model.query(args)
        
        return self.with_metadata(results.fetchall(), args)

class OffendersCountCounties(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgsYear)
    # @swagger.use_kwargs(marshmallow_schemas.IncidentViewCountArgs,
    #                     locations=["query"],
    #                     apply=False)
    # @swagger.doc(
    #     tags=['offenders'],
    #     description=(
    #         'Returns counts by year for offenders. '
    #         'Offender Incidents - By county'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, county_id, variable):
        self.verify_api_key(args)
        model = cdemodels.OffenderCountView(args['year'], variable, None, county_id)
        results = model.query(args)
        
        return self.with_metadata(results.fetchall(), args)
