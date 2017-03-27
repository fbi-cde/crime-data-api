from flask import jsonify
from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from marshmallow import fields
from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.base import CdeResource, tuning_page


class StateDetail(CdeResource):
    schema = marshmallow_schemas.StateDetailResponseSchema()

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, id):
        self.verify_api_key(args)
        state = cdemodels.CdeRefState.get(abbr=id).one()
        return jsonify(self.schema.dump(state).data)


class CountyDetail(CdeResource):
    schema = marshmallow_schemas.CountyDetailResponseSchema()

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, fips):
        self.verify_api_key(args)
        county = cdemodels.CdeRefCounty.get(fips=fips).one()
        return jsonify(self.schema.dump(county).data)


class StateParticipation(CdeResource):
    schema = marshmallow_schemas.StateParticipationRateSchema(many=True)

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, state_id=None, state_abbr=None):
        self.verify_api_key(args)

        state = cdemodels.CdeRefState.get(abbr=state_abbr, state_id=state_id).one()
        rates = cdemodels.CdeParticipationRate(state_id=state.state_id).query.order_by('data_year DESC').all()
        filename = '{}_state_participation'.format(state.state_postal_abbr)
        return self.render_response(rates, args, csv_filename=filename)
