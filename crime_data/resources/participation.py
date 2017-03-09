import re

from flask_restful import fields, marshal_with, reqparse
from webargs.flaskparser import use_args
import flask_apispec as swagger
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache

from crime_data.common import cdemodels, models, newmodels
from crime_data.common import marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import(
    ArgumentsSchema, ApiKeySchema, ParticipationRateSchema
)

class NationalParticipation(CdeResource):
    """Returns a collection of all state participation rates for each year"""

    @use_args(ArgumentsSchema)
    @swagger.use_kwargs(ApiKeySchema, apply=False, locations=['query'])
    @swagger.marshal_with(ParticipationRateSchema, apply=False)
    @swagger.doc(tags=['geo'], description='Participation data for a state')
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, state_id=None, state_abbr=None):
        self.verify_api_key(args)

        rates = cdemodels.CdeParticipationRate.query.join('RefState').order_by('data_year DESC, state_name').all()
        filename = 'participation_rates'.format(state.state_postal_abbr)
        return self.render_response(rates, args, csv_filename=filename)
