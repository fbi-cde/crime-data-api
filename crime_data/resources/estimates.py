from webargs.flaskparser import use_args
from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.newmodels import RetaEstimated
from crime_data.common.base import CdeResource, tuning_page, ExplorerOffenseMapping, cache_for
from crime_data.extensions import DEFAULT_MAX_AGE, DEFAULT_SURROGATE_AGE
from sqlalchemy import func

class EstimatesState(CdeResource):
    """Return the estimates for a state"""
    schema = marshmallow_schemas.EstimateSchema(many=True)
    fast_count = False

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache_for(DEFAULT_MAX_AGE, DEFAULT_SURROGATE_AGE)
    @tuning_page
    def get(self, args, state_id):
        self.verify_api_key(args)
        estimates = RetaEstimated.query.filter(func.lower(RetaEstimated.state_abbr) == func.lower(state_id)).order_by(RetaEstimated.year)
        return self.render_response(estimates, args, csv_filename='{}_estimated'.format(state_id))


class EstimatesNational(CdeResource):
    """Return the estimates for nationwide"""
    schema = marshmallow_schemas.NationalEstimateSchema(many=True)
    fast_count = False

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache_for(DEFAULT_MAX_AGE, DEFAULT_SURROGATE_AGE)
    @tuning_page
    def get(self, args):
        self.verify_api_key(args)
        estimates = RetaEstimated.query.filter(RetaEstimated.state_abbr == None).order_by(RetaEstimated.year)
        return self.render_response(estimates, args, csv_filename='national_estimated')
