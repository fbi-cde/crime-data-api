from webargs.flaskparser import use_args
import flask_apispec as swagger

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page


class ArsonCountResource(CdeResource):

    tables = cdemodels.ArsonTableFamily()
    is_groupable = True

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @swagger.use_kwargs(marshmallow_schemas.GroupableArgsSchema, apply=False, locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.ArsonCountResponseSchema, apply=False)
    @tuning_page
    def get(self, args):
        return self._get(args)
