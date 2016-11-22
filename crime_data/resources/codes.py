from webargs.flaskparser import use_args

from crime_data.common import marshmallow_schemas, models
from crime_data.common.base import CdeResource
from crime_data.common.marshmallow_schemas import (ArgumentsSchema,
                                                   NibrsActivityTypeSchema)


class NibrsActivityTypeList(CdeResource):

    schema = marshmallow_schemas.NibrsActivityTypeSchema(many=True)

    @use_args(ArgumentsSchema)
    def get(self, args, output=None):
        output = args['output'] if output is None else output
        codes = models.NibrsActivityType.query
        if output == 'csv':
            return self.as_csv_response(codes, 'nibrs_activity_type', args)
        else:
            return self.with_metadata(codes, args)
