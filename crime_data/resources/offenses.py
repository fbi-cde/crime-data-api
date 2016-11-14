from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource
from crime_data.common.marshmallow_schemas import ArgumentsSchema


class OffensesList(CdeResource):

    schema = marshmallow_schemas.CrimeTypeSchema(many=True)

    @use_args(ArgumentsSchema)
    def get(self, args):
        self.verify_api_key(args)
        result = cdemodels.CdeCrimeType.query
        return self.with_metadata(result, args)
