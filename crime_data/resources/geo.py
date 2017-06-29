from flask import jsonify
from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE, DEFAULT_SURROGATE_AGE
from marshmallow import fields
from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource, tuning_page, cache_for


class StateDetail(CdeResource):
    schema = marshmallow_schemas.StateDetailResponseSchema()

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache_for(DEFAULT_MAX_AGE, DEFAULT_SURROGATE_AGE)
    @tuning_page
    def get(self, args, id):
        self.verify_api_key(args)
        state = cdemodels.CdeRefState.get(abbr=id).one()
        return jsonify(self.schema.dump(state).data)


class CountyDetail(CdeResource):
    schema = marshmallow_schemas.CountyDetailResponseSchema()

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache_for(DEFAULT_MAX_AGE, DEFAULT_SURROGATE_AGE)
    @tuning_page
    def get(self, args, fips):
        self.verify_api_key(args)
        county = cdemodels.CdeRefCounty.get(fips=fips).one()
        return jsonify(self.schema.dump(county).data)
