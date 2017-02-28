import flask_apispec as swagger
from webargs.flaskparser import use_args
from itertools import filterfalse
from crime_data.common import cdemodels, marshmallow_schemas, models, newmodels
from crime_data.common.base import CdeResource, tuning_page, ExplorerOffenseMapping
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache

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
    @swagger.doc(
        tags=['incidents'],
        description=(
            'Return all matching incidents. Queries can drill down '
            'on specific values for fields within the incidents record.'))
    @swagger.use_kwargs(marshmallow_schemas.ArgumentsSchema,
                        apply=False,
                        locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.IncidentsListResponseSchema,
                          apply=False)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)


class IncidentsDetail(CdeResource):

    schema = marshmallow_schemas.NibrsIncidentSchema(many=True)

    # Enable fast counting.
    fast_count = True

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @swagger.use_kwargs(marshmallow_schemas.ArgumentsSchema,
                        apply=False,
                        locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.IncidentsDetailResponseSchema,
                          apply=False)
    @swagger.doc(
        tags=['incidents'],
        description='Return the specific record for a single incident')
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
    @swagger.use_kwargs(marshmallow_schemas.GroupableArgsSchema,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        tags=['incidents'],
        description=(
            'Returns counts by year for incidents. '
            'Incidents can be grouped for counting with the `by` parameter'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
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
    @swagger.use_kwargs(marshmallow_schemas.GroupableArgsSchema,
                        locations=['query'],
                        apply=False)
    @swagger.doc(
        tags=['incidents'],
        description=(
            'Returns counts by year for incidents. '
            'Incidents can be grouped for counting with the `by` parameter'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)
