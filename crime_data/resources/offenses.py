from webargs.flaskparser import use_args
import flask_apispec as swagger

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import ArgumentsSchema


def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)

class OffensesList(CdeResource):

    schema = marshmallow_schemas.CrimeTypeSchema(many=True)

    @use_args(ArgumentsSchema)
    @swagger.use_kwargs(ArgumentsSchema, apply=False, locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.OffensesListResponseSchema, apply=False)
    @swagger.doc(tags=['offenses'],
                 description='Returns a list of all offenses.')
    def get(self, args):
        self.verify_api_key(args)
        result = cdemodels.CdeCrimeType.query
        return self.with_metadata(result, args)


class OffensesCountNational(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    # schema = marshmallow_schemas.IncidentCountSchema()

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @swagger.use_kwargs(marshmallow_schemas.ViewCountArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        tags=['offenses'],
        params={'variable': {'description': 'A variable to group by',
                             'enum': marshmallow_schemas.OFFENSE_COUNT_VARIABLE_ENUM}},
        description=(
            'Returns counts by year for offenses. '
            'Offense incidents - Nationwide'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, variable):
        self.verify_api_key(args)
        model = cdemodels.OffenseCountView(args['year'], variable)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)


class OffensesCountStates(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    # schema = marshmallow_schemas.IncidentCountSchema()

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @swagger.use_kwargs(marshmallow_schemas.ViewCountArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        tags=['offenses'],
        params={'state_id': {'description': 'The state ID from ref_county'},
                'variable': {'description': 'A variable to group by',
                             'enum': marshmallow_schemas.OFFENSE_COUNT_VARIABLE_ENUM}},
        description=(
            'Returns counts by year for offenses. '
            'Offense incidents - By State'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, state_id, variable):
        self.verify_api_key(args)
        model = cdemodels.OffenseCountView(args['year'], variable, state_id)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)


class OffensesCountCounties(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @swagger.use_kwargs(marshmallow_schemas.ViewCountArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        params={'county_id': {'description': 'The county ID from ref_county'},
                'variable': {'description': 'A variable to group by',
                             'enum': marshmallow_schemas.OFFENSE_COUNT_VARIABLE_ENUM}},
        tags=['offenses'],
        description=(
             'Returns counts by year for offenses. '
             'Offense Incidents - By county'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, county_id, variable):
        self.verify_api_key(args)
        model = cdemodels.OffenseCountView(args['year'], variable, None, county_id)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)