from webargs.flaskparser import use_args
from itertools import filterfalse
from crime_data.common import cdemodels, marshmallow_schemas, models, newmodels
from crime_data.common.base import CdeResource, tuning_page, ExplorerOffenseMapping
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from flask import jsonify

def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)


class AgenciesSumsState(CdeResource):
    '''''
    Agency Suboffense Sums by (year, agency) - Only agencies reporting all 12 months.
    '''''
    schema = marshmallow_schemas.AgencySumsSchema(many=True)
    fast_count = True

    @use_args(marshmallow_schemas.OffenseCountViewArgs)
    @tuning_page
    def get(self, args, state_abbr = None, agency_ori = None):
        self.verify_api_key(args)
        model = newmodels.AgencySums()
        year = args.get('year', None)
        explorer_offense = args.get('explorer_offense', None)
        agency_sums = model.get(state = state_abbr, agency = agency_ori, year = year, explorer_offense = explorer_offense)
        filename = 'agency_sums_state'
        return self.render_response(agency_sums, args, csv_filename=filename)


class AgenciesSumsCounty(CdeResource):
    '''''
    Agency Suboffense Sums by (year, agency) - Only agencies reporting all 12 months.
    '''''
    schema = marshmallow_schemas.AgencySumsSchema(many=True)
    fast_count = True

    @use_args(marshmallow_schemas.OffenseCountViewArgsYear)
    @tuning_page
    def get(self, args, state_abbr = None, county_fips_code = None, agency_ori = None):
        '''''
        Year is a required field atm.
        '''''
        self.verify_api_key(args)
        model = newmodels.AgencySums()
        year = args.get('year', None)
        explorer_offense = args.get('explorer_offense', None)
        agency_sums = model.get(agency = agency_ori, year =  year, county = county_fips_code, state=state_abbr, explorer_offense=explorer_offense)
        filename = 'agency_sums_county'
        return self.render_response(agency_sums, args, csv_filename=filename)


class AgenciesOffensesCount(CdeResource):
    '''''
    Agency Offense counts by year.
    '''''
    schema = marshmallow_schemas.AgencyOffensesSchema(many=True)
    fast_count = True

    @use_args(marshmallow_schemas.OffenseCountViewArgs)
    @tuning_page
    def get(self, args, state_abbr = None, agency_ori = None):
        self.verify_api_key(args)
        year = args.get('year', None)
        explorer_offense = args.get('explorer_offense', None)
        agency_sums = None

        # ugh
        if explorer_offense == 'violent' or explorer_offense == 'property':
            agency_sums = newmodels.AgencyClassificationCounts().get(state = state_abbr, agency = agency_ori, year = year, classification = explorer_offense)
        else:
            agency_sums = newmodels.AgencyOffenseCounts().get(state = state_abbr, agency = agency_ori, year = year, explorer_offense = explorer_offense)
        filename = 'agency_offenses_state'
        return self.render_response(agency_sums, args, csv_filename=filename)


class AgenciesOffensesCountyCount(CdeResource):
    '''''
    Agency Offense counts by year.
    '''''
    schema = marshmallow_schemas.AgencyOffensesSchema(many=True)
    fast_count = True

    @use_args(marshmallow_schemas.OffenseCountViewArgsYear)
    @tuning_page
    def get(self, args, state_abbr = None, county_fips_code = None, agency_ori = None):
        '''''
        Year is a required field atm.
        '''''
        self.verify_api_key(args)
        model = newmodels.AgencyOffenseCounts()
        year = args.get('year', None)
        explorer_offense = args.get('explorer_offense', None)
        agency_sums = model.get(agency = agency_ori, year =  year, county = county_fips_code, state=state_abbr, explorer_offense=explorer_offense)
        filename = 'agency_sums_county'
        return self.render_response(agency_sums, args, csv_filename=filename)
