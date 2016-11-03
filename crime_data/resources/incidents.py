import re

from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import (ArgumentsSchema,
                                                   IncidentCountArgsSchema)

from flask import make_response

def _is_string(col):
    col0 = list(col.base_columns)[0]
    return issubclass(col0.type.python_type, str)


class IncidentsList(CdeResource):

    schema = marshmallow_schemas.NibrsIncidentSchema(many=True)
    tables = cdemodels.IncidentTableFamily()

    @use_args(ArgumentsSchema)
    @tuning_page
    def get(self, args):
        # TODO: apply "fields" arg

        self.verify_api_key(args)
        filters = self.filters(args)
        qry = self.tables.filtered(filters)
        if args['output'] == 'csv':
            output = make_response(self.output_serialize(self.with_metadata(qry, args), self.schema))
            output.headers["Content-Disposition"] = "attachment; filename=incidents.csv"
            output.headers["Content-type"] = "text/csv"
            return output
        return self.with_metadata(qry, args)


class IncidentsDetail(CdeResource):

    schema = marshmallow_schemas.NibrsIncidentSchema(many=True)

    @use_args(ArgumentsSchema)
    @tuning_page
    def get(self, args, nbr):
        self.verify_api_key(args)
        incidents = models.NibrsIncident.query.filter_by(incident_number=nbr)
        return self.with_metadata(incidents, args)


class IncidentsCount(CdeResource):

    schema = marshmallow_schemas.SummarySchema(many=True)

    SPLITTER = re.compile(r"\s*,\s*")

    @use_args(IncidentCountArgsSchema)
    @tuning_page
    def get(self, args):
        self.verify_api_key(args)
        by = self.SPLITTER.split(
            args['by'].lower())  # TODO: can post-process in schema?
        filters = list(self.filters(args))
        result = cdemodels.RetaQuery(by, filters)
        return self.with_metadata(result, args)
