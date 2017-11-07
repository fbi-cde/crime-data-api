import re

from flask_restful import fields, marshal_with, reqparse
from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache

from crime_data.common import cdemodels, models, newmodels, lookupmodels
from crime_data.common import marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import(
    ArgumentsSchema, ApiKeySchema, StateParticipationRateSchema
)

class StateParticipation(CdeResource):
    schema = marshmallow_schemas.StateParticipationRateSchema(many=True)

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, state_id=None, state_abbr=None):
        self.verify_api_key(args)

        state = cdemodels.CdeRefState.get(abbr=state_abbr, state_id=state_id).one()
        rates = cdemodels.CdeParticipationRate(state_id=state.state_id).query.order_by('year DESC').all()
        filename = '{}_state_participation'.format(state.state_abbr)
        return self.render_response(rates, args, csv_filename=filename)

class RegionParticipation(CdeResource):
    schema = marshmallow_schemas.StateParticipationRateSchema(many=True)

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, region_code=None):
        self.verify_api_key(args)
        states = lookupmodels.StateLK.get(region_code=region_code).all()
        id_arr= []
        [id_arr.append(state.state_id) for state in states]
        rates = cdemodels.CdeParticipationRate(states=id_arr).query.order_by('year DESC').all()
        filename = '{}_state_participation'.format(region_code)
        return self.render_response(rates, args, csv_filename=filename)

class NationalParticipation(CdeResource):
    """Returns a collection of all state participation rates for each year"""
    schema = marshmallow_schemas.ParticipationRateSchema(many=True)

    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        self.verify_api_key(args)

        rates = cdemodels.CdeParticipationRate().query
        rates = rates.filter(newmodels.ParticipationRate.state_id == None)
        rates = rates.filter(newmodels.ParticipationRate.county_id == None)
        rates = rates.order_by('year DESC').all()
        filename = 'participation_rates'
        return self.render_response(rates, args, csv_filename=filename)


class AgenciesParticipation(CdeResource):

    schema = marshmallow_schemas.AgencyParticipationSchema(many=True)
    tables = newmodels.AgencyParticipation
    is_groupable = False

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args, csv_filename='agency_participation')
