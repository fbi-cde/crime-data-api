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


class IncidentsList(CdeResource):

    schema = marshmallow_schemas.NibrsIncidentSchema(many=False) 
    _serialize = CdeResource._serialize_from_representation
    tables = cdemodels.IncidentTableFamily()
    # Enable fast counting.
    fast_count = True

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)


class IncidentsDetail(CdeResource):

    schema = marshmallow_schemas.NibrsIncidentSchema(many=True)

    # Enable fast counting.
    fast_count = True

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, id):
        self.verify_api_key(args)
        incidents = models.NibrsIncident.query.filter_by(incident_id=id)
        return self.with_metadata(incidents, args)


class IncidentsCount(CdeResource):
    tables = cdemodels.IncidentCountTableFamily()
    is_groupable = True

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)


class CachedIncidentsCount(CdeResource):

    tables = newmodels.RetaMonthOffenseSubcatSummary
    schema = marshmallow_schemas.CachedIncidentCountSchema(many=True)

    def postprocess_filters(self, filters, args):
        explorer_offenses = [x for x in filters if x[0] == 'explorer_offense']

        if explorer_offenses:
            eo = explorer_offenses[0]
            mapped = [ExplorerOffenseMapping(x).reta_offense for x in eo[2]]
            filters = [x for x in filters if x[0] != 'explorer_offense']
            filters.append(('offense', eo[1], mapped))

        group_by_column_names = [c.strip() for c in args.get('by').split(',')]
        filters = newmodels.RetaMonthOffenseSubcatSummary.determine_grouping(filters, group_by_column_names, self.schema)
        return filters

    def use_filters(self, filters):
        "Ensure that filtered fields appear in serialization"
        filtered_names = [f[0] for f in filters]
        for (field_name, field) in self.schema.fields.items():
            if field_name in newmodels.RetaMonthOffenseSubcatSummary.grouping_sets:
                field.load_only = field_name not in filtered_names

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)


class AgenciesSumsState(CdeResource):
    '''''
    Agency Suboffense Sums by (year, agency) - Only agencies reporting all 12 months.
    '''''
    schema = marshmallow_schemas.AgencySumsSchema(many=True)

    @use_args(marshmallow_schemas.OffenseCountViewArgs)
    @tuning_page
    def get(self, args, state_abbr = None, agency_ori = None):
        self.verify_api_key(args)
        model = newmodels.AgencySums()
        if 'year' in args:
            year = args['year']
        agency_sums = model.get(state = state_abbr, agency = agency_ori, year = year)
        filename = 'agency_sums_state'
        return self.render_response(self.schema.dump(agency_sums).data, args, csv_filename=filename)


class AgenciesSumsCounty(CdeResource):
    '''''
    Agency Suboffense Sums by (year, agency) - Only agencies reporting all 12 months.
    '''''
    schema = marshmallow_schemas.AgencySumsSchema(many=True)

    @use_args(marshmallow_schemas.OffenseCountViewArgsYear)
    @tuning_page
    def get(self, args, state_abbr = None, county_fips_code = None, agency_ori = None):
        '''''
        Year is a required field atm.
        '''''
        self.verify_api_key(args)
        model = newmodels.AgencySums()
        year = None
        if 'year' in args:
            year = args['year']
        agency_sums = model.get(agency = agency_ori, year =  year, county = county_fips_code, state=state_abbr)
        filename = 'agency_sums_county'
        return self.render_response(self.schema.dump(agency_sums).data, args, csv_filename=filename)


class CachedIncidentsAgenciesCount(CdeResource):
    '''''
    Agency Offense counts by year.
    '''''
    schema = marshmallow_schemas.CachedAgencyIncidentCountSchema(many=True)

    @use_args(marshmallow_schemas.OffenseCountViewArgs)
    @tuning_page
    def get(self, args, state_abbr = None, agency_ori = None):
        self.verify_api_key(args)
        model = newmodels.RetaMonthAgencySubcatSummary()
        year = None
        if 'year' in args:
            year = args['year']
        reta_offenses = model.get(state = state_abbr, agency = agency_ori, year = year)
        filename = 'agency_sums'
        return self.render_response(self.schema.dump(reta_offenses).data, args, csv_filename=filename)
