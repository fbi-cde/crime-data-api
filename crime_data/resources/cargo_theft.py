import decimal
from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page

# Template
# variable => [prop_desc_name, location_name, victim_type_name, offense_name]


def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)


class CargoTheftsCountStates(CdeResource):
    schema = False
    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, state_id=None, state_abbr=None, variable=None):
        self.verify_api_key(args)
        model = cdemodels.CargoTheftCountView(variable, year=args['year'], state_id=state_id, state_abbr=state_abbr)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args, self.schema), 200, {'Surrogate-Control':3600}


class CargoTheftsCountAgencies(CdeResource):
    schema = False
    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, ori, variable):
        self.verify_api_key(args)
        model = cdemodels.CargoTheftCountView(variable, year=args['year'], ori=ori)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args, self.schema), 200, {'Surrogate-Control':3600}


class CargoTheftsCountNational(CdeResource):
    schema = False
    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.IncidentViewCountArgs)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, variable):
        self.verify_api_key(args)
        model = cdemodels.CargoTheftCountView(variable, year=args['year'])
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args, self.schema), 200, {'Surrogate-Control':3600}


class CargoTheftOffenseSubcounts(CdeResource):
    schema = False
    def _stringify(self, data):
        # Override stringify function to fit our needs.
        return [dict(r) for r in data]

    @use_args(marshmallow_schemas.OffenseCountViewArgs)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, variable, state_id=None, state_abbr=None, ori=None):
        self.verify_api_key(args)
        model = cdemodels.OffenseCargoTheftCountView(variable,
                                                     year=args.get('year', None),
                                                     ori=ori,
                                                     offense_name=args.get('offense_name', None),
                                                     explorer_offense=args.get('explorer_offense', None),
                                                     state_id=state_id,
                                                     state_abbr=state_abbr)
        results = model.query(args)
        return self.with_metadata(results.fetchall(), args, self.schema), 200, {'Surrogate-Control':3600}
