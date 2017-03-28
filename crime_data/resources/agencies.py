import re

from flask_restful import fields, marshal_with, reqparse
from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache

from crime_data.common import cdemodels, models, newmodels
from crime_data.common import marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import (
    AgenciesIncidentArgsSchema, AgenciesRetaArgsSchema, RefAgencySchema,
    ArgumentsSchema)


class AgenciesResource(CdeResource):
    schema = marshmallow_schemas.RefAgencySchema(many=True)


class AgenciesList(AgenciesResource):
    @use_args(marshmallow_schemas.RefAgencySchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        result = cdemodels.CdeRefAgency.get()
        return self.with_metadata(result, args)


class AgenciesDetail(AgenciesResource):
    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, nbr):
        self.verify_api_key(args)
        agency = cdemodels.CdeRefAgency.get(nbr)
        return self.with_metadata(agency, args)
