from webargs.flaskparser import use_args
from itertools import filterfalse
from crime_data.common import cdemodels, marshmallow_schemas, models, newmodels
from crime_data.common.base import CdeResource, tuning_page, ExplorerOffenseMapping
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from flask import jsonify
from crime_data.common.marshmallow_schemas import ArgumentsSchema

class Region(CdeResource):
    schema = marshmallow_schemas.RefRegionSchema(many=True)

    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        result = models.RefRegion.query
        return self.with_metadata(result, args)
