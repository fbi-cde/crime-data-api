from flask import jsonify
import flask_apispec as swagger
from webargs.flaskparser import use_args

from marshmallow import fields
from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource, tuning_page


class StateDetail(CdeResource):
    schema = marshmallow_schemas.StateDetailResponseSchema()

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @swagger.use_kwargs(marshmallow_schemas.ApiKeySchema, apply=False, locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.StateDetailResponseSchema, apply=False)
    @swagger.doc(tags=['geo'],
                 params={'state_id': {'description': 'A state postal abbreviation'}},
                 description=['Returns basic information about a state and lists counties in the state'])
    def get(self, args, id):
        self.verify_api_key(args)
        state = cdemodels.CdeRefState.get(abbr=id).one()
        return jsonify(self.schema.dump(state).data)


class CountyDetail(CdeResource):
    schema = marshmallow_schemas.CountyDetailResponseSchema()

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @swagger.use_kwargs(marshmallow_schemas.ApiKeySchema, apply=False, locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.CountyDetailResponseSchema, apply=False)
    @swagger.doc(tags=['geo'], description='Demographic details for a county')
    def get(self, args, fips):
        self.verify_api_key(args)
        county = cdemodels.CdeRefCounty.get(fips=fips).one()
        return jsonify(self.schema.dump(county).data)
