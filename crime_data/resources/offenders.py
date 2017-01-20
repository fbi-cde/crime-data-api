import flask_apispec as swagger
from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource, tuning_page

# Template
# variables => [location_type, offense_type, property_type, age, sex, race]

def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)

import json

class OffendersCountStates(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @swagger.use_kwargs(marshmallow_schemas.ViewCountArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        params={'state_id': {'description': 'The state ID from ref_state'},
                'variable': {'description': 'A variable to group by',
                             'enum': marshmallow_schemas.OFFENDER_COUNT_VARIABLE_ENUM}},
        tags=['offenders'],
        description=(
            'Returns counts by year for offenders. '
            'Offender Incidents - By State'))
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

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @swagger.use_kwargs(marshmallow_schemas.ViewCountArgs,
                        locations=["query"],
                        apply=False)
    @swagger.doc(
        params={'county_id': {'description': 'The county ID from ref_county'},
                'variable': {'description': 'A variable to group by',
                             'enum': marshmallow_schemas.OFFENDER_COUNT_VARIABLE_ENUM}},
        tags=['offenders'],
        description=(
            'Returns counts by year for offenders. '
            'Offender Incidents - By county'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, county_id, variable):
        self.verify_api_key(args)
        model = cdemodels.OffenderCountView(args['year'], variable, None, county_id)
        results = model.query(args)
        
        return self.with_metadata(results.fetchall(), args)

