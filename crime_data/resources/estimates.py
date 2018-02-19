from webargs.flaskparser import use_args
from crime_data.common import cdemodels, marshmallow_schemas, models, lookupmodels
from crime_data.common.newmodels import RetaEstimated
from crime_data.common.models import  RefState
from crime_data.common.base import CdeResource, tuning_page, ExplorerOffenseMapping
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

class EstimatesState(CdeResource):
    """Return the estimates for a state"""
    schema = marshmallow_schemas.EstimateSchema(many=True)
    fast_count = False

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, state_id):
        self.verify_api_key(args)
        estimates = RetaEstimated.query.filter(func.lower(RetaEstimated.state_abbr) == func.lower(state_id)).order_by(RetaEstimated.year)
        return self.with_metadata(estimates, args)

class EstimatesRegion(CdeResource):
    """Return the estimates for a region"""
    schema = marshmallow_schemas.EstimateSchema(many=True)
    fast_count = False

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, region_name):
        self.verify_api_key(args)
        region = lookupmodels.RegionLK.getByName(region_name=region_name).first()
        states = lookupmodels.StateLK.get(region_code=region.region_code).all()
        id_arr= []
        [id_arr.append(state.state_id) for state in states]
        estimates = RetaEstimated.query.filter(RetaEstimated.state_id.in_(id_arr)).order_by(RetaEstimated.year)
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
        estimates = RetaEstimated.query.filter(RetaEstimated.state_abbr == None).order_by(RetaEstimated.year)
        return self.with_metadata(estimates, args)

class SummarizedDataAgency(CdeResource):
    schema = marshmallow_schemas.SummarizedDataAgencySchema(many=True)
    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, offense=None):
        self.verify_api_key(args)
        query = cdemodels.SummarizedDataAgency.get(ori=ori,offense=offense)
        return self.with_metadata(query,args)
