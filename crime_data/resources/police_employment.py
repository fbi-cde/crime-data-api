from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import ArgumentsSchema

class PoliceEmploymentDataAgency(CdeResource):
    schema = marshmallow_schemas.PoliceEmploymentDataAgencySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.PoliceEmploymentDataAgency.get(ori=ori)
        return self.with_metadata(query,args)

class PoliceEmploymentDataState(CdeResource):
    schema = marshmallow_schemas.PoliceEmploymentDataStateSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args,state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.PoliceEmploymentDataState.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class PoliceEmploymentDataRegion(CdeResource):
    schema = marshmallow_schemas.PoliceEmploymentDataRegionSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args,region_name=None):
        self.verify_api_key(args)
        query = cdemodels.PoliceEmploymentDataRegion.get(region_name=region_name)
        return self.with_metadata(query,args)

class PoliceEmploymentDataNation(CdeResource):
    schema = marshmallow_schemas.PoliceEmploymentDataNationSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args,):
        self.verify_api_key(args)
        query = cdemodels.PoliceEmploymentDataNation.query
        return self.with_metadata(query,args)
