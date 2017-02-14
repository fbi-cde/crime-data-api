import re

from flask_restful import fields, marshal_with, reqparse
from webargs.flaskparser import use_args
import flask_apispec as swagger

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
    @swagger.use_kwargs(marshmallow_schemas.RefAgencySchema, apply=False, locations=['query'])
    @swagger.marshal_with(marshmallow_schemas.AgenciesListResponseSchema, apply=False)
    @swagger.doc(tags=['agencies'],
                 description='Returns a paginated list of all agencies')
    def get(self, args):
        self.verify_api_key(args)
        result = cdemodels.CdeRefAgency.get()
        return self.with_metadata(result, args)


class AgenciesDetail(AgenciesResource):
    @use_args(marshmallow_schemas.ArgumentsSchema)
    @swagger.use_kwargs(marshmallow_schemas.ArgumentsSchema, apply=False, locations=['query'])
    @swagger.doc(tags=['agencies'],
                 description='Returns information on a single agency')
    @swagger.marshal_with(marshmallow_schemas.AgenciesDetailResponseSchema, apply=False)
    def get(self, args, nbr):
        self.verify_api_key(args)
        agency = cdemodels.CdeRefAgency.get(nbr)
        return self.with_metadata(agency, args)


class AgenciesParticipation(CdeResource):

    schema = marshmallow_schemas.AgencyParticipationSchema(many=True)
    tables = newmodels.AgencyAnnualParticipation
    is_groupable = False

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @swagger.use_kwargs(marshmallow_schemas.ArgumentsSchema, apply=False, locations=['query'])
    @swagger.doc(tags=['agencies', 'participation'],
                 description='Returns data on agency participation. May be filtered by agency fields')
    @swagger.marshal_with(marshmallow_schemas.AgenciesParticipationResponseSchema, apply=False)
    @tuning_page
    def get(self, args):
        return self._get(args)
