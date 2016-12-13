from webargs.flaskparser import use_args
import flask_apispec as swagger

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource
from crime_data.common.marshmallow_schemas import ArgumentsSchema


class OffensesList(CdeResource):

    schema = marshmallow_schemas.CrimeTypeSchema(many=True)

    @use_args(ArgumentsSchema)
    @swagger.use_kwargs(ArgumentsSchema, apply=False, locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.OffensesListResponseSchema, apply=False)
    @swagger.doc(tags=['offenses'],
                 description='Returns a list of all offenses.')
    def get(self, args):
        self.verify_api_key(args)
        result = cdemodels.CdeCrimeType.query
        return self.with_metadata(result, args)
