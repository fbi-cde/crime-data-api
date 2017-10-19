from webargs.flaskparser import use_args
from itertools import filterfalse
from crime_data.common import marshmallow_schemas, models, lookupmodels
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

class RegionLK(CdeResource):
    schema = marshmallow_schemas.RegionLKSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        result = lookupmodels.RegionLK.query
        return self.with_metadata(result, args)

class StateLK(CdeResource):
    schema = marshmallow_schemas.StateLKSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        result = lookupmodels.StateLK.query
        return self.with_metadata(result, args)

class RegionStateLK(CdeResource):
    schema = marshmallow_schemas.RegionStateLKSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        result = lookupmodels.RegionStateLK.query
        return self.with_metadata(result, args)
