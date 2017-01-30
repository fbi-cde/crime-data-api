import decimal
import flask_apispec as swagger
from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page

# Template
# variable => [prop_desc_name, location_name, victim_type_name, offense_name]


def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)


class CargoTheftsCountStates(CdeResource):

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
                             'enum': cdemodels.CargoTheftCountView.VARIABLES}},
        tags=['cargo theft'],
        description=(
            'Returns counts by year for offenders. '
            'Offender Incidents - By State'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, state_id=None, state_abbr=None, variable=None):
        self.verify_api_key(args)
        model = cdemodels.CargoTheftCountView(variable, year=args['year'], state_id=state_id, state_abbr=state_abbr)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)


class CargoTheftsCountCounties(CdeResource):

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
                             'enum': cdemodels.CargoTheftCountView.VARIABLES}},
        tags=['cargo theft'],
        description=(
            'Returns counts by year for offenders. '
            'Offender Incidents - By county'))
    @swagger.marshal_with(marshmallow_schemas.CargoTheftCountViewResponseSchema, apply=False)
    @tuning_page
    def get(self, args, county_id, variable):
        self.verify_api_key(args)
        model = cdemodels.CargoTheftCountView(variable, year=args['year'], county_id=county_id)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)


class CargoTheftsCountNational(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @swagger.use_kwargs(marshmallow_schemas.IncidentViewCountArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        params={'variable': {'description': 'A variable to group by',
                             'enum': cdemodels.CargoTheftCountView.VARIABLES}},
        tags=['cargo theft'],
        description=(
            'Returns counts by year for offenders. '
            'Offender Incidents - By county'))
    @swagger.marshal_with(marshmallow_schemas.CargoTheftCountViewResponseSchema, apply=False)
    @tuning_page
    def get(self, args, variable):
        self.verify_api_key(args)
        model = cdemodels.CargoTheftCountView(variable, year=args['year'])
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)


class CargoTheftOffenseSubcounts(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.OffenseCountViewArgs)
    @swagger.use_kwargs(marshmallow_schemas.OffenseCountViewArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        params={'state_id': {'description': 'The ID for a state to limit the query to'},
                'variable': {'description': 'A variable to group by',
                             'enum': cdemodels.OffenseCargoTheftCountView.VARIABLES}},
        tags=['cargo theft'],
        description=(
             'Returns counts by year for victims. '
             'Victim Incidents - By county'))
    @swagger.marshal_with(marshmallow_schemas.OffenseCargoTheftCountViewResponseSchema, apply=False)
    @tuning_page
    def get(self, args, variable, state_id=None, state_abbr=None):
        self.verify_api_key(args)
        model = cdemodels.OffenseCargoTheftCountView(variable,
                                                     year=args.get('year', None),
                                                     offense_name=args.get('offense_name', None),
                                                     state_id=state_id,
                                                     state_abbr=state_abbr)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)
