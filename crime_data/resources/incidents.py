from webargs.flaskparser import use_args
from flask_apispec import marshal_with, doc

from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource, tuning_page


def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)


class IncidentsList(CdeResource):

    schema = marshmallow_schemas.NibrsIncidentSchema(many=True)
    tables = cdemodels.IncidentTableFamily()
    # Enable fast counting.
    fast_count = True

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @doc(tags=['incidents'],
         description="Return all matching incidents. Queries can drill down on specific values for fields within the incidents record.")
    @marshal_with(marshmallow_schemas.IncidentsListResponseSchema)
    @tuning_page
    def get(self, args):
        return self._get(args)


class IncidentsDetail(CdeResource):

    schema = marshmallow_schemas.NibrsIncidentSchema(many=True)
    # Enable fast counting.
    fast_count = True

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @marshal_with(marshmallow_schemas.IncidentsDetailResponseSchema)
    @doc(tags=['incidents'],
         description="Return the specific record for a single incident")
    @tuning_page
    def get(self, args, nbr):
        self.verify_api_key(args)
        incidents = models.NibrsIncident.query.filter_by(incident_number=nbr)
        return self.with_metadata(incidents, args)


class IncidentsCount(CdeResource):
    tables = cdemodels.IncidentCountTableFamily()
    is_groupable = True

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @doc(tags=['incidents'],
         description="Returns counts by year for incidents. Incidents can be grouped for counting with the `by` parameter")
    @tuning_page
    def get(self, args):
        return self._get(args)
