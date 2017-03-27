from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page


class ArsonCountResource(CdeResource):

    tables = cdemodels.ArsonTableFamily()
    is_groupable = True

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @swagger.use_kwargs(marshmallow_schemas.GroupableArgsSchema, apply=False, locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.ArsonCountResponseSchema, apply=False)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)
