import flask_apispec as swagger
from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource, tuning_page


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
                        locations=["query"],
                        apply=False)
    @swagger.doc(
        tags=['incidents'],
        description=(
            'Returns counts by year for incidents. '
            'Incidents can be grouped for counting with the `by` parameter'))
    @swagger.marshal_with(marshmallow_schemas.IncidentCountSchema, apply=False)
    @tuning_page
    def get(self, args):
        return self._get(args)
