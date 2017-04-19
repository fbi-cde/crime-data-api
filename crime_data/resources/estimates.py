from webargs.flaskparser import use_args
from crime_data.common import cdemodels, marshmallow_schemas, models
from crime_data.common.newmodels import RetaEstimated
from crime_data.common.base import CdeResource, tuning_page, ExplorerOffenseMapping
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache


class EstimatesState(CdeResource):
    """Return the estimates for a state"""
    schema = marshmallow_schemas.EstimateSchema(many=True)
    fast_count = False

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, state_id):
        self.verify_api_key(args)
        estimates = RetaEstimated.query.filter(RetaEstimated.state_abbr == state_id)
        return self.with_metadata(estimates, args)


class EstimatesNational(CdeResource):
    """Return the estimates for nationwide"""
    schema = marshmallow_schemas.NationalEstimateSchema(many=True)
    fast_count = False

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        self.verify_api_key(args)
        estimates = RetaEstimated.query.filter(RetaEstimated.state_abbr == None)
        return self.with_metadata(estimates, args)
