import re

from flask_restful import fields, marshal_with, reqparse
from webargs.flaskparser import use_args
from flask_apispec import marshal_with, doc

from crime_data.common import cdemodels as models
from crime_data.common import marshmallow_schemas
from crime_data.common.base import CdeResource
from crime_data.common.marshmallow_schemas import (
    AgenciesIncidentArgsSchema, AgenciesRetaArgsSchema, RefAgencySchema,
    ArgumentsSchema)


class AgenciesResource(CdeResource):

    schema = marshmallow_schemas.RefAgencySchema(many=True)


class AgenciesList(AgenciesResource):
    @use_args(marshmallow_schemas.RefAgencySchema)
    @marshal_with(marshmallow_schemas.AgenciesListResponseSchema)
    @doc(tags=["agencies"],
         description="Returns a paginated list of all agencies")
    def get(self, args):
        self.verify_api_key(args)
        result = models.CdeRefAgency.get()
        return self.with_metadata(result, args)


class AgenciesDetail(AgenciesResource):
    @use_args(marshmallow_schemas.ArgumentsSchema)
    @doc(tags=["agencies"],
         description="Returns information on a single agency")
    @marshal_with(marshmallow_schemas.AgenciesDetailResponseSchema)
    def get(self, args, nbr):
        self.verify_api_key(args)
        agency = models.CdeRefAgency.get(nbr)
        return self.with_metadata(agency, args)
