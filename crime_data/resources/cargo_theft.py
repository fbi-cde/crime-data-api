import flask_apispec as swagger
from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource, tuning_page

# Template
# variable => [prop_desc_name, location_name, victim_type_name, offense_name]
import decimal

def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)


class CargoTheftsCountStates(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    #schema = marshmallow_schemas.IncidentCountSchema()

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
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
        model = cdemodels.CargoTheftCountView(variable, args['year'], state_id)
        results = model.query(args)
        
        return self.with_metadata(results.fetchall(), args)

class CargoTheftsCountCounties(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
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
        model = cdemodels.CargoTheftCountView(variable, args['year'], None, county_id)
        results = model.query(args)
        
        return self.with_metadata(results.fetchall(), args)

class CargoTheftsCountNational(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
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
    def get(self, args, variable):
        self.verify_api_key(args)
        model = cdemodels.CargoTheftCountView(variable, args['year'])
        results = model.query(args)
        
        return self.with_metadata(results.fetchall(), args)