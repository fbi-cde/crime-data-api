from webargs.flaskparser import use_args
from itertools import filterfalse
from crime_data.common import marshmallow_schemas, cdemodels, lookupmodels
from crime_data.common.base import CdeResource, tuning_page, ExplorerOffenseMapping
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from flask import jsonify
from crime_data.common.marshmallow_schemas import ArgumentsSchema

class ASRMaleByAgeCount(CdeResource):
    schema = marshmallow_schemas.ASRMaleByAgeCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        result = cdemodels.ASRMaleByAgeCount.query
        return self.with_metadata(result, args)

class ASRFemaleByAgeCount(CdeResource):
    schema = marshmallow_schemas.ASRFemaleByAgeCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        result = cdemodels.ASRFemaleByAgeCount.query
        return self.with_metadata(result, args)

class ASRRaceCount(CdeResource):
    schema = marshmallow_schemas.ASRRaceCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        result = cdemodels.ASRRaceCount.query
        return self.with_metadata(result, args)

class ASRRaceYouthCount(CdeResource):
    schema = marshmallow_schemas.ASRRaceYouthCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        result = cdemodels.ASRRaceYouthCount.query
        return self.with_metadata(result, args)
