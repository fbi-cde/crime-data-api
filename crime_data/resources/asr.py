from webargs.flaskparser import use_args
from itertools import filterfalse
from crime_data.common import marshmallow_schemas, cdemodels, lookupmodels, munger
from crime_data.common.base import CdeResource, tuning_page, ExplorerOffenseMapping
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from flask import jsonify
from crime_data.common.marshmallow_schemas import ArgumentsSchema

class ASRMaleByAgeCount(CdeResource):
    schema = marshmallow_schemas.ASRMaleByAgeCountAgencySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, level=None, level_value=None):
        self.verify_api_key(args)
        if level == 'agency':
            result = cdemodels.ASRMaleByAgeCountAgency.get(level_value)
        elif level == 'state':
            self.schema = marshmallow_schemas.ASRMaleByAgeCountStateSchema(many=True)
            result = cdemodels.ASRMaleByAgeCountState.get(level_value)
        elif level == 'region':
            self.schema = marshmallow_schemas.ASRMaleByAgeCountRegionSchema(many=True)
            result = cdemodels.ASRMaleByAgeCountRegion.get(level_value)
        else:
            self.schema = marshmallow_schemas.ASRMaleByAgeCountNationalSchema(many=True)
            result = cdemodels.ASRMaleByAgeCountNational.query
        return self.with_metadata(result, args)

class ASRFemaleByAgeCount(CdeResource):
    schema = marshmallow_schemas.ASRFemaleByAgeCountAgencySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, level=None, level_value=None):
        self.verify_api_key(args)
        if level == 'agency':
            result = cdemodels.ASRFemaleByAgeCountAgency.get(level_value)
        elif level == 'state':
            self.schema = marshmallow_schemas.ASRFemaleByAgeCountStateSchema(many=True)
            result = cdemodels.ASRFemaleByAgeCountState.get(level_value)
        elif level == 'region':
            self.schema = marshmallow_schemas.ASRFemaleByAgeCountRegionSchema(many=True)
            result = cdemodels.ASRFemaleByAgeCountRegion.get(level_value)
        else:
            self.schema = marshmallow_schemas.ASRFemaleByAgeCountNationalSchema(many=True)
            result = cdemodels.ASRFemaleByAgeCountNational.query
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
