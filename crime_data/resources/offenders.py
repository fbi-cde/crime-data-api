import json
import flask_apispec as swagger
from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page, ExplorerOffenseMapping

# Template
# variables => [location_type, offense_type, property_type, age, sex, race]


def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)


class OffendersCountNational(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @swagger.use_kwargs(marshmallow_schemas.ViewCountYearRequiredArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        params={'variable': {'description': 'A variable to group by',
                             'enum': cdemodels.OffenderCountView.VARIABLES}},
        tags=['offenders'],
        description=(
            'Returns national counts by year for offenders. '
            'Offender Incidents - national'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, variable):
        self.verify_api_key(args)
        model = cdemodels.OffenderCountView(variable, year=args['year'])
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)


class OffendersCountStates(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @swagger.use_kwargs(marshmallow_schemas.ViewCountYearRequiredArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        params={'state_id': {'description': 'The state ID from ref_state'},
                'variable': {'description': 'A variable to group by',
                             'enum': cdemodels.OffenderCountView.VARIABLES}},
        tags=['offenders'],
        description=(
            'Returns counts by year for offenders. '
            'Offender Incidents - By State'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, state_id=None, state_abbr=None, variable=None):
        self.verify_api_key(args)
        model = cdemodels.OffenderCountView(variable, year=args['year'], state_id=state_id, state_abbr=state_abbr)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)

class OffendersCountCounties(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @swagger.use_kwargs(marshmallow_schemas.ViewCountYearRequiredArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        params={'county_id': {'description': 'The county ID from ref_county'},
                'variable': {'description': 'A variable to group by',
                             'enum': cdemodels.OffenderCountView.VARIABLES}},
        tags=['offenders'],
        description=(
            'Returns counts by year for offenders. '
            'Offender Incidents - By county'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args, county_id, variable):
        self.verify_api_key(args)
        model = cdemodels.OffenderCountView(variable, year=args['year'], county_id=county_id)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)


class OffenderOffenseSubcounts(CdeResource):

    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.OffenseCountViewArgs)
    @swagger.use_kwargs(marshmallow_schemas.OffenseCountViewArgs,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        params={'state_id': {'description': 'The ID for a state to limit the query to'},
                'explorer_offense': {'description': 'A offense class used by the explorer',
                                     'enum': ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys()},
                'variable': {'description': 'A variable to group by',
                             'enum': cdemodels.OffenseOffenderCountView.VARIABLES}},
        tags=['offenders'],
        description=(
             'Returns counts by year for victims. '
             'Victim Incidents - By county'))
    @swagger.marshal_with(marshmallow_schemas.OffenseCountViewResponseSchema, apply=False)
    @tuning_page
    def get(self, args, variable, state_id=None):
        self.verify_api_key(args)
        model = cdemodels.OffenseOffenderCountView(variable,
                                                   year=args.get('year', None),
                                                   offense_name=args.get('offense_name', None),
                                                   explorer_offense=args.get('explorer_offense', None),
                                                   state_id=state_id)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args)
